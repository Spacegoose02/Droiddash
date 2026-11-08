@echo off
setlocal
title ATOTO App Installer

echo ==================================================
echo   ATOTO App Installer (installs APKs over Wi-Fi)
echo ==================================================
echo.
echo Before you start:
echo   1. This PC and the ATOTO must be on the SAME Wi-Fi (your phone hotspot).
echo   2. On the ATOTO: Settings ^> About ^> tap "Build number" 7 times,
echo      then turn on "Wireless debugging" or "USB debugging" in Developer options.
echo.
pause

set "PT=%USERPROFILE%\platform-tools"
set "ADB=%PT%\adb.exe"

if exist "%ADB%" goto :haveadb
echo.
echo Downloading Android platform-tools from Google...
curl -L -o "%TEMP%\platform-tools.zip" https://dl.google.com/android/repository/platform-tools-latest-windows.zip
if errorlevel 1 goto :dlfail
tar -xf "%TEMP%\platform-tools.zip" -C "%USERPROFILE%"
if errorlevel 1 goto :dlfail
if not exist "%ADB%" goto :dlfail
echo Done.

:haveadb
echo.
choice /c YN /m "Does the ATOTO have 'Wireless debugging' with a pairing code"
if errorlevel 2 goto :legacy

echo.
echo On the ATOTO: Wireless debugging ^> "Pair device with pairing code".
set /p PAIR=Type the IP:port shown in that pairing box (e.g. 192.168.43.20:37123):
"%ADB%" pair %PAIR%
echo.
echo Now look at the MAIN Wireless debugging screen (a different port).
set /p CONN=Type that IP:port (e.g. 192.168.43.20:41567):
"%ADB%" connect %CONN%
goto :check

:legacy
echo.
echo Find the ATOTO's IP: Settings ^> Wi-Fi ^> tap your hotspot name.
set /p IP=Type the ATOTO's IP address (e.g. 192.168.43.20):
"%ADB%" connect %IP%:5555
echo If a prompt appears on the ATOTO screen, tap ALLOW.
timeout /t 8 >nul

:check
echo.
"%ADB%" get-state 2>nul | findstr /x "device" >nul
if errorlevel 1 goto :notconnected
echo Connected to the ATOTO!

:loop
echo.
set "APK="
set /p APK=Drag an APK file into this window and press Enter (or just press Enter to quit):
if not defined APK goto :end
set APK=%APK:"=%
echo Installing "%APK%" ...
"%ADB%" install -r "%APK%"
goto :loop

:notconnected
echo.
echo Could not connect. Current status:
"%ADB%" devices
echo.
echo  - "unauthorized": tap ALLOW on the ATOTO screen, then run this again.
echo  - Nothing listed / "failed to connect": check both are on the same Wi-Fi
echo    and that debugging is turned on, then run this again.
goto :end

:dlfail
echo.
echo Download failed. Check this PC's internet connection and try again.

:end
echo.
pause
