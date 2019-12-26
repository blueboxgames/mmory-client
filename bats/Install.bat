@echo off
call bats/SetupSDK.bat
call bats/SetupApp.bat

%ANDROID_SDK%\adb devices
cd dist
set /P APK_FILE=TAP TO SELECT APK: 
cd ..
%ANDROID_SDK%\adb -d install -r "dist/%APK_FILE%"
%ANDROID_SDK%\adb shell am start -n %APP_ID%/.AppEntry
pause