@echo off

:: Set working dir
cd %~dp0 & cd ..

:menu
echo.
echo Select server
echo.
echo  [1] iran
echo  [2] local
echo  [3] yoga
echo  [4] fudo
echo  [5] surface

:choice
set /P S=[Choice]: 
echo.

set SERVER=iran
if "%S%"=="1" set SERVER=iran
if "%S%"=="2" set SERVER=local
if "%S%"=="3" set SERVER=yoga
if "%S%"=="4" set SERVER=fudo
if "%S%"=="5" set SERVER=surface


:menu
echo.
echo Package for target
echo.
echo Android:
echo.
echo  [1] normal       (apk)
echo  [2] debug        (apk-debug)
::echo  [3] captive      (apk-captive-runtime)
echo.
echo iOS:
echo.
echo  [4] fast test    (ipa-test-interpreter)
echo  [5] fast debug   (ipa-debug-interpreter)
echo  [6] slow test    (ipa-test)
echo  [7] slow debug   (ipa-debug)
echo  [8] "ad-hoc"     (ipa-ad-hoc)
echo  [9] App Store    (ipa-app-store)
echo.

:choice
set /P C=[Choice]: 
echo.

set PLATFORM=android
set OPTIONS=
if %C% GTR 3 set PLATFORM=ios
if %C% GTR 7 set PLATFORM=ios-dist

if "%C%"=="1" set TARGET=
if "%C%"=="2" set TARGET=-debug
if "%C%"=="2" set OPTIONS=-connect %DEBUG_IP%
if "%C%"=="3" set TARGET=-captive-runtime

if "%C%"=="4" set TARGET=-test-interpreter
if "%C%"=="5" set TARGET=-debug-interpreter
if "%C%"=="5" set OPTIONS=-connect %DEBUG_IP%
if "%C%"=="6" set TARGET=-test
if "%C%"=="7" set TARGET=-debug
if "%C%"=="7" set OPTIONS=-connect %DEBUG_IP%
if "%C%"=="8" set TARGET=-ad-hoc
if "%C%"=="9" set TARGET=-app-store


:menu
echo.
echo Select for Market
echo.
echo  [1] cafebazaar
echo  [2] myket
echo  [3] ario
echo  [4] cando
echo  [5] google
echo  [6] zarinpal

:choice
set /P M=[Choice]: 
echo.

set MARKET=cafebazaar
if "%M%"=="1" set MARKET=cafebazaar
if "%M%"=="2" set MARKET=myket
if "%M%"=="3" set MARKET=ario
if "%M%"=="4" set MARKET=cando
if "%M%"=="5" set MARKET=google
if "%M%"=="6" set MARKET=zarinpal


:menu
echo.
echo Select for CPU arc
echo.
echo  [1] armv7
echo  [2] armv8

:choice
set /P A=[Choice]: 
echo.
if "%A%"=="2" set OPTIONS=%OPTIONS%-arch armv8

set PAUSE_ERRORS=1
call bats/SetupDescriptor.bat
call bats/SetupSDK.bat
call bats/Packager.bat
if "%PLATFORM%"=="android" goto android-package

:ios-package
if "%AUTO_INSTALL_IOS%" == "yes" goto ios-install
echo Now manually install and start application on device
echo.
goto end

:ios-install
echo Installing application for testing on iOS (%DEBUG_IP%)
echo.
call adt -installApp -platform ios -package "%OUTPUT%"
if errorlevel 1 goto installfail

echo Now manually start application on device
echo.
goto end

:android-package
adb devices
echo.
echo Installing %OUTPUT% on the device...
echo.
%ANDROID_SDK%\adb -d install -r "%OUTPUT%"
if errorlevel 1 goto installfail
echo Running %OUTPUT% on the device...
%ANDROID_SDK%\adb shell am start -n %APP_ID%/.AppEntry
goto end

:installfail
echo.
echo Installing the app on the device failed

:end
pause
