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

echo Automatic call 70 kbps video ^& 96 kbps audio mono
echo SOURCE: %IPATH%
echo OUTPUT: %OPATH%
:: echo Please press ENTER once to continue with that configuration.
:: pause > nul
echo Starting FFMPEG...

"%~dp0ffmpeg/bin/ffmpeg.exe" -y -i %IPATH% -ac 1 -preset slow -vb 70k -ab 96k -g 360 -keyint_min 360 -bf 20 -qcomp 0.9 -rc-lookahead 120 -filter:v "fps=1" %OPATH%

echo The end.
echo Press any key to exit.
timeout /t 5 > nul
exit

:manual
echo You didn't drop the file here, so expecting IN.mp4 to be converted to OUT.mp4.
echo Cropping is disabled in manual mode.

set /p VIDBIT="Video bitrate (kbps, defaults 70): "

echo Encoding with video bitrate of %VIDBIT%

"%~dp0ffmpeg/bin/ffmpeg.exe" -n -i IN.mp4 -ac 1 -preset slow -vb %VIDBIT%k -ab 96k -g 360 -keyint_min 360 -bf 20 -qcomp 0.9 -rc-lookahead 120 -filter:v "fps=1" OUT.mp4

echo DONE
pause