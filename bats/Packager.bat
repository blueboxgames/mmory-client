

@echo off

:: Set working dir
cd %~dp0 & cd ..


:user_configuration

:: About AIR application packaging
:: http://help.adobe.com/en_US/air/build/WS5b3ccc516d4fbf351e63e3d118666ade46-7fd9.html

:: NOTICE: all paths are relative to project root

:: Android packaging
set AND_CERT_NAME="cert"
set AND_CERT_PASS=654321
set AND_CERT_FILE=cert/bbg-boom.p12
set AND_ICONS=files/icons/android
if NOT %SERVER%==iran set AND_ICONS=files/icons/gndroid

set AND_SIGNING_OPTIONS=-storetype pkcs12 -keystore "%AND_CERT_FILE%" -storepass %AND_CERT_PASS%

:: iOS packaging
set IOS_DIST_CERT_FILE=cert/TOD-Distribution-Certificate.p12
set IOS_DEV_CERT_FILE=cert/TOD-Distribution-Certificate.p12
set IOS_DEV_CERT_PASS=pppppp
set IOS_PROVISION=cert/Bluebox_K2K_Adhoc_Profile.mobileprovision
set IOS_ICONS=files/icons/ios

set IOS_DEV_SIGNING_OPTIONS=-storetype pkcs12 -keystore "%IOS_DEV_CERT_FILE%" -storepass %IOS_DEV_CERT_PASS% -provisioning-profile %IOS_PROVISION%
set IOS_DIST_SIGNING_OPTIONS=-storetype pkcs12 -keystore "%IOS_DIST_CERT_FILE%" -storepass %IOS_DEV_CERT_PASS% -provisioning-profile %IOS_PROVISION%

if "%PLATFORM%"=="android" goto android-config
if "%PLATFORM%"=="ios" goto ios-config
if "%PLATFORM%"=="ios-dist" goto ios-dist-config
goto start

:android-config
set CERT_FILE=%AND_CERT_FILE%
set SIGNING_OPTIONS=%AND_SIGNING_OPTIONS%
set ICONS=%AND_ICONS%
set DIST_EXT=apk
set TYPE=apk
goto start

:ios-config
set CERT_FILE=%IOS_DEV_CERT_FILE%
set SIGNING_OPTIONS=%IOS_DEV_SIGNING_OPTIONS%
set ICONS=%IOS_ICONS%
set DIST_EXT=ipa
set TYPE=ipa
goto start
:: Set working dir
cd %~dp0 & cd ..

:ios-dist-config
set CERT_FILE=%IOS_DIST_CERT_FILE%
set SIGNING_OPTIONS=%IOS_DIST_SIGNING_OPTIONS%
set ICONS=%IOS_ICONS%
set DIST_EXT=ipa
set TYPE=ipa
goto start

:start

:: Files to package
set APP_DIR=bin

:: Output packages
set DIST_PATH=dist
set DIST_NAME=%CODE_NAME%-%VER_LABEL%-%SERVER%-%MARKET%%TARGET%

if not exist "%CERT_FILE%" goto certificate
:: Output file

set BINF=%TEMP%\bin
rd /q /s %BINF%
if %TYPE%==ipa echo f | xcopy /f /y files\sfs-config.xml %BINF%\sfs-config.xml
echo f | xcopy /f /y bin\release.swf %BINF%\release.swf
echo d | xcopy /s /y files\assets %BINF%\assets
set FILE_OR_DIR=-C %BINF% . -C %ICONS% .

if not "%OPTIONS%"=="" set DIST_NAME=%DIST_NAME%-%OPTIONS:~6%

if not exist "%DIST_PATH%" md "%DIST_PATH%"
set OUTPUT=%DIST_PATH%\%DIST_NAME%.%DIST_EXT%
:: Package
echo Packaging: %OUTPUT%
echo using certificate: %CERT_FILE%...
echo.

echo adt -package -target %TYPE%%TARGET% %OPTIONS% %SIGNING_OPTIONS% "%OUTPUT%" "%APP_XML%" %FILE_OR_DIR% -extdir exts
call adt -package -target %TYPE%%TARGET% %OPTIONS% %SIGNING_OPTIONS% "%OUTPUT%" "%APP_XML%" %FILE_OR_DIR% -extdir exts 
echo.
if errorlevel 1 goto failed
goto end

:certificate
echo Certificate not found: %CERT_FILE%
echo.
echo Android: 
echo - generate a default certificate using 'bat\CreateCertificate.bat'
echo   or configure a specific certificate in 'bat\SetupApp.bat'.
echo.
echo iOS: 
echo - configure your developer key and project's Provisioning Profile
echo   in 'bat\SetupApp.bat'.
echo.
if %PAUSE_ERRORS%==1 pause
exit

:failed
echo APK setup creation FAILED.
echo.
echo Troubleshooting: 
echo - verify AIR SDK target version in %APP_XML%
echo.
if %PAUSE_ERRORS%==1 pause
exit

:end
rd /q /s %BINF%