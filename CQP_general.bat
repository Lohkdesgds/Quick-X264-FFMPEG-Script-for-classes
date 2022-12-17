:: FFMPEG script by Lohk 2022
:: Download FFMPEG somewhere like https://www.gyan.dev/ffmpeg/builds/ and extract alongside this script
:: FFMPEG .exe must be at ffmpeg/bin/ffmpeg.exe
:: This is used to compress common videos to a very small file, so backups are possible with small storage, better than erasing everything, right? Parameters may change over time.

@echo off
echo FFMPEG script by Lohk, 2022

if [%1]==[] goto manual


echo Please CHOOSE 1 for FULL RES (default), 2 for HALF, 3 for QUARTER, 0 to HIGH QUALITY FULL, and press ENTER once to continue with that configuration.
set /p SCALE="Option: "

set IPATH=%1
set OPATH=%IPATH:~0,-4%_out_opt%SCALE%.mp4

echo SOURCE: %IPATH%
echo OUTPUT: %OPATH%
echo Please press ENTER once to continue with that configuration.
pause > nul

if %SCALE% equ 0 goto g_min
if %SCALE% equ 2 goto g_half
if %SCALE% equ 3 goto g_quar
:: else

echo Starting FFMPEG FULL RES...
"%~dp0ffmpeg/bin/ffmpeg.exe" -y -i %IPATH% -preset slow -vsync 0 -crf 35 -ab 128k -g 120 -keyint_min 40 -bf 4 -qcomp 0.8 -rc-lookahead 80 %OPATH%
goto end

:g_half
echo Starting FFMPEG HALF RES...
"%~dp0ffmpeg/bin/ffmpeg.exe" -y -i %IPATH% -preset slow -vsync 0 -crf 32 -ab 128k -g 120 -keyint_min 40 -bf 4 -qcomp 0.8 -rc-lookahead 80 -filter:v "scale=in_w*0.5:in_h*0.5" %OPATH%
goto end

:g_quar
echo Starting FFMPEG QUARTER RES...
"%~dp0ffmpeg/bin/ffmpeg.exe" -y -i %IPATH% -preset slow -vsync 0 -crf 29 -ab 128k -g 120 -keyint_min 40 -bf 4 -qcomp 0.8 -rc-lookahead 80 -filter:v "scale=in_w*0.25:in_h*0.25" %OPATH%
goto end

:g_min
echo Starting FFMPEG FULL RES...
"%~dp0ffmpeg/bin/ffmpeg.exe" -y -i %IPATH% -preset slow -vsync 0 -crf 25 -ab 160k -g 120 -keyint_min 40 -bf 4 -qcomp 0.8 -rc-lookahead 80 %OPATH%
goto end


:end
echo The end.
echo Press any key to exit.
pause > nul
exit

:manual
echo You didn't drop the file here, do that. Thanks.
pause >nul