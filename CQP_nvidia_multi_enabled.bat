:: FFMPEG script by Lohk 2024
:: Download FFMPEG somewhere like https://www.gyan.dev/ffmpeg/builds/ and extract alongside this script
:: FFMPEG .exe must be at ffmpeg/bin/ffmpeg.exe
:: This is used to compress common videos to a very small file, so backups are possible with small storage, better than erasing everything, right? Parameters may change over time.

@echo off
setlocal enabledelayedexpansion

color 0F

:: 37 in 720 is very economic
set PARAM_CQP=37
set PARAM_PRESET=slow
set PARAM_TUNE=hq
set PARAM_PROFILE=main

:: Not changing:
set PARAM_RC=constqp

:: Not related to NVENC:
set PARAM_SCALE=9
set PARAM_AUDIOK=128
set PARAM_AUDIOMIX51=""
:: ex audiomix51: -c dca -vol 256 -af "pan=stereo|c0=0.5*c2+0.707*c0+0.707*c4+0.5*c3|c1=0.5*c2+0.707*c1+0.707*c5+0.5*c3"
set IPATH=%1

:: PARSING INFORMATION
:: =================================================================================

echo FFMPEG NVENC HEVC script by Lohk, 2024
if [%1]==[] goto badnews

set argCount=0

for %%x in (%*) do (
   set /A argCount+=1
   set "argVec[!argCount!]=%%~x"
)

echo Arguments detected: %argCount%
echo:
echo -------------------------------------------------------------
for /L %%i in (1,1,%argCount%) do (
    echo #%%i. "!argVec[%%i]!"
)
echo -------------------------------------------------------------

:resume
set OPATH=_out_cqp.!PARAM_CQP!_scale.!PARAM_SCALE!_preset.!PARAM_PRESET!_audio.!PARAM_AUDIOK!.mp4
set STARTCMD="%~dp0ffmpeg\bin\ffmpeg.exe" -hide_banner -loglevel error -y -i
set FINALCMD=-vcodec hevc_nvenc
if !PARAM_AUDIOMIX51! == "" (
    set FINALCMD=!FINALCMD! -vsync 0 -ab !PARAM_AUDIOK!k
)
if not !PARAM_AUDIOMIX51! == "" (
    set FINALCMD=!FINALCMD! -vsync 0 !PARAM_AUDIOMIX51! -ab !PARAM_AUDIOK!k
)
:: Parameters
set FINALCMD=!FINALCMD! -preset !PARAM_PRESET! -tune !PARAM_TUNE! -profile !PARAM_PROFILE! -rc !PARAM_RC! -qp !PARAM_CQP!
:: Fixed
set FINALCMD=!FINALCMD! -rc-lookahead 40 -2pass 1 -gpu any -spatial-aq 1 -temporal-aq 1 -aq-strength 15 -multipass fullres 

if !PARAM_SCALE! equ 1 set FINALCMD=!FINALCMD! -filter:v "scale=in_w*0.5:in_h*0.5"
if !PARAM_SCALE! equ 2 set FINALCMD=!FINALCMD! -filter:v "scale=in_w*0.333:in_h*0.333"
if !PARAM_SCALE! equ 3 set FINALCMD=!FINALCMD! -filter:v "scale=in_w*0.25:in_h*0.25"
if !PARAM_SCALE! equ 4 set FINALCMD=!FINALCMD! -filter:v "scale=in_w*0.166:in_h*0.166"
if !PARAM_SCALE! equ 5 set FINALCMD=!FINALCMD! -filter:v "scale=in_w*0.125:in_h*0.125"
if !PARAM_SCALE! equ 6 set FINALCMD=!FINALCMD! -filter:v "scale=h='if(gt(iw\,ih)\,2160\,-2)':w='if(gt(iw\,ih)\,-2\,2160)"
if !PARAM_SCALE! equ 7 set FINALCMD=!FINALCMD! -filter:v "scale=h='if(gt(iw\,ih)\,1440\,-2)':w='if(gt(iw\,ih)\,-2\,1440)"
if !PARAM_SCALE! equ 8 set FINALCMD=!FINALCMD! -filter:v "scale=h='if(gt(iw\,ih)\,1080\,-2)':w='if(gt(iw\,ih)\,-2\,1080)"
if !PARAM_SCALE! equ 9 set FINALCMD=!FINALCMD! -filter:v "scale=h='if(gt(iw\,ih)\,720\,-2)':w='if(gt(iw\,ih)\,-2\,720)"
set FINALCMD=!FINALCMD!

echo:
echo # --- Settings defined -----------
echo # CQP: !PARAM_CQP!
echo # Speed preset: !PARAM_PRESET!
echo # Tune: !PARAM_TUNE!
echo # Profile: !PARAM_PROFILE!
echo # Scale setting: !PARAM_SCALE!
echo # Audio: !PARAM_AUDIOK! kbps
if !PARAM_AUDIOMIX51! == "" ( 
    echo # Extra audio: none
)
if not !PARAM_AUDIOMIX51! == "" (
    echo # Extra audio: 5.1 downsample
)
echo # Command output: !FINALCMD! FILENAME!OPATH!
echo # --------------------------------
echo:
echo What do you want to do^?
echo 1 =^> Change CQP
echo 2 =^> Change scale
echo 3 =^> Change preset
echo 4 =^> Change audio bitrate
echo 5 =^> Enable/disable 5.1 downsample
echo 6 =^> Set TUNE preset
echo 7 =^> Set profile
echo Or input anything else to continue and work

set PARAM_RESUME=0
set /p PARAM_RESUME="> "
if !PARAM_RESUME! equ 1 goto backcqp
if !PARAM_RESUME! equ 2 goto backscale
if !PARAM_RESUME! equ 3 goto backpreset
if !PARAM_RESUME! equ 4 goto backaudio
if !PARAM_RESUME! equ 5 goto backaudio51
if !PARAM_RESUME! equ 6 goto backtunepreset
if !PARAM_RESUME! equ 7 goto backprofile
goto startwork


:: AUDIO 5.1 PARAMETER
:: =================================================================================
:backaudio51
if !PARAM_AUDIOMIX51! == "" (
    set PARAM_AUDIOMIX51=-vol 256 -af ^"pan=stereo^|c0=0.5^*c2^+0.707^*c0^+0.707^*c4^+0.5^*c3^|c1=0.5^*c2^+0.707^*c1^+0.707^*c5^+0.5^*c3^"
    goto resume
)
set PARAM_AUDIOMIX51=""
goto resume
:: AUDIO PARAMETER
:: =================================================================================
:backaudio
echo:
echo [^?] What bitrate (in KBPS) should the audio have^? [16..320]:
set /p PARAM_AUDIOK="> "
if !PARAM_AUDIOK! lss 16 goto failaudio
if !PARAM_AUDIOK! gtr 320 goto failaudio
goto resume
:: =================================================================================
:failaudio
echo:
color 0C
echo This is not a valid number. Please consider a value between 16 and 320. Try again in 3 seconds.
timeout /t 3 >nul
color 0F
goto backaudio

:: CQP PARAMETER
:: =================================================================================
:backcqp
echo:
echo [^?] Please tell me the CQP you want [0..51] (economy = 35, good enough = 30, fine detail = 25):
set /p PARAM_CQP="> "
if !PARAM_CQP! lss 0 goto failcqp
if !PARAM_CQP! gtr 51 goto failcqp
goto resume
:: =================================================================================
:failcqp
echo:
color 0C
echo This is not a valid number. Please consider a value between 15 and 50. Try again in 3 seconds.
timeout /t 3 >nul
color 0F
goto backcqp

:: RESOLUTION PARAMETER
:: =================================================================================

:backscale
echo:
echo [^?] What scale do we work with^? Valid options are: [0..5]
echo 0 =^> No scaling
echo 1 =^> 1/2
echo 2 =^> 1/3
echo 3 =^> 1/4
echo 4 =^> 1/6
echo 5 =^> 1/8
echo 6 =^> Force 2160p (auto rotate)
echo 7 =^> Force 1440p (auto rotate)
echo 8 =^> Force 1080p (auto rotate)
echo 9 =^> Force 720p (auto rotate)
set /p PARAM_SCALE="> "
if !PARAM_SCALE! lss 0 goto failscale
if !PARAM_SCALE! gtr 9 goto failscale
goto resume
:: =================================================================================
:failscale
echo:
color 0C
echo This is not a valid number. Please consider a value between 0 and 5. Try again in 3 seconds.
timeout /t 3 >nul
color 0F
goto backscale

:: PROFILE PARAMETER
:: =================================================================================

:backprofile
echo:
echo [^?] NVENC profile value^? [main, main10, rext]
set /p PARAM_PROFILE="> "
if "!PARAM_PROFILE!" == "main" goto resume
if "!PARAM_PROFILE!" == "main10" goto resume
if "!PARAM_PROFILE!" == "rext" goto resume
goto failprofile
:: =================================================================================
:failprofile
echo:
color 0C
echo This is not a valid option. Please consider one of the following:
echo main, main10, rext
echo Try again in 3 seconds.
timeout /t 3 >nul
color 0F
goto backprofile

:: TUNE PARAMETER
:: =================================================================================

:backtunepreset
echo:
echo [^?] NVENC Tune value^? [hq, ll, ull, lossless]
set /p PARAM_TUNE="> "
if "!PARAM_TUNE!" == "hq" goto resume
if "!PARAM_TUNE!" == "ll" goto resume
if "!PARAM_TUNE!" == "ull" goto resume
if "!PARAM_TUNE!" == "lossless" goto resume
goto failtunepreset
:: =================================================================================
:failtunepreset
echo:
color 0C
echo This is not a valid option. Please consider one of the following:
echo hq, ll, ull, lossless
echo Try again in 3 seconds.
timeout /t 3 >nul
color 0F
goto backtunepreset

:: PRESET PARAMETER
:: =================================================================================

:backpreset
echo:
echo [^?] CPU x264 preset^? [default, slow, medium, fast, hp, hq, bd, ll, llhq, llhp, lossless, losslesshp, p1-p7]
set /p PARAM_PRESET="> "
if "!PARAM_PRESET!" == "default" goto resume
if "!PARAM_PRESET!" == "slow" goto resume
if "!PARAM_PRESET!" == "medium" goto resume
if "!PARAM_PRESET!" == "fast" goto resume
if "!PARAM_PRESET!" == "hp" goto resume
if "!PARAM_PRESET!" == "hq" goto resume
if "!PARAM_PRESET!" == "bd" goto resume
if "!PARAM_PRESET!" == "ll" goto resume
if "!PARAM_PRESET!" == "llhq" goto resume
if "!PARAM_PRESET!" == "llhp" goto resume
if "!PARAM_PRESET!" == "lossless" goto resume
if "!PARAM_PRESET!" == "losslesshp" goto resume
if "!PARAM_PRESET!" == "p1" goto resume
if "!PARAM_PRESET!" == "p2" goto resume
if "!PARAM_PRESET!" == "p3" goto resume
if "!PARAM_PRESET!" == "p4" goto resume
if "!PARAM_PRESET!" == "p5" goto resume
if "!PARAM_PRESET!" == "p6" goto resume
if "!PARAM_PRESET!" == "p7" goto resume
goto failpreset
:: =================================================================================
:failpreset
echo:
color 0C
echo This is not a valid option. Please consider one of the following:
echo default, slow, medium, fast, hp, hq, bd, ll, llhq, llhp, lossless, losslesshp, p1-p7
echo Try again in 3 seconds.
timeout /t 3 >nul
color 0F
goto backpreset

:: how did you get here?
goto badnews


:startwork
echo STARTING SEQUENCE IN 3 SECONDS^!
echo LOG WILL BE REGENERATED TO THIS SESSION AS LOG.LOG
echo:

cls
echo Starting sequence with settings:
echo # CQP: !PARAM_CQP!
echo # Scale setting: !PARAM_SCALE!
echo # x264 preset: !PARAM_PRESET!
echo # Audio: !PARAM_AUDIOK! kbps
echo:

timeout /t 3 >nul

for /L %%i in (1,1,%argCount%) do (
    echo Working %%i of %argCount%...
    !STARTCMD! "!argVec[%%i]!" !FINALCMD! "!argVec[%%i]:~0,-4!!OPATH!"
)
echo:
echo Ended all inputs. Press any key to exit.
pause >nul
exit


:badnews
echo This script MUST HAVE arguments. Please drop one or more ONTO THE BATCH FILE to do a batch ffmpeg compression in sequence.
echo Close this window to exit.
pause >nul
exit