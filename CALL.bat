:: FFMPEG script by Lohk 2022
:: Download FFMPEG somewhere like https://www.gyan.dev/ffmpeg/builds/ and extract alongside this script
:: FFMPEG .exe must be at ffmpeg/bin/ffmpeg.exe
:: Drop a mp4 file into this to automatically convert a square video to 1600x1200 @ 70 kbps and 32 kbps mono audio for best ratio.
:: Change automatic crop on CROP right there below.
:: You can achieve square recording easily on PC. On smartphones, there's some apps like SnapCamera HDR that allows custom resolution using Camera2Api.

@echo off
echo FFMPEG script by Lohk, 2022

if [%1]==[] goto manual

set IPATH=%1
set OPATH=%IPATH:~0,-4%_out.mp4

echo Automatic call: assuming square input, 1600x1200 output cropped @ 70 kbps video ^& 32 kbps audio mono
echo SOURCE: %IPATH%
echo OUTPUT: %OPATH%
echo Please press ENTER once to continue with that configuration.
pause > nul
echo Starting FFMPEG...
dir
"%~dp0ffmpeg/bin/ffmpeg.exe" -y -i %IPATH% -ac 1 -preset slow -vb 70k -ab 32k -g 360 -keyint_min 360 -bf 20 -qcomp 0.9 -rc-lookahead 120 -filter:v "fps=1, crop=in_w:in_h*0.75:0:0.125*in_h, scale=1600:1200" %OPATH%

echo The end.
echo Press any key to exit.
pause > nul
exit

:manual
echo You didn't drop the file here, so expecting IN.mp4 to be converted to OUT.mp4.
echo Cropping is disabled in manual mode.

set /p VIDBIT="Video bitrate (kbps, defaults 70): "
set /p VIDX="Video width (pixels, default 1600): "
set /p VIDY="Video height (pixels, default 1200): "

echo Encoding with video bitrate of %VIDBIT% and resolution %VIDX%x%VIDY%

"%~dp0ffmpeg/bin/ffmpeg.exe" -n -i IN.mp4 -ac 1 -preset slow -vb %VIDBIT%k -ab 32k -g 360 -keyint_min 360 -bf 20 -qcomp 0.9 -rc-lookahead 120 -filter:v "fps=1, scale=%VIDX%:%VIDY%" OUT.mp4

echo DONE
pause