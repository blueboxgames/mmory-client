call bats/SetupApp.bat

set APP_XML_TEMP=files/application-template.xml
set APP_XML=bin/application.xml
set iconsIOS="^<image36x36^>icons/icon36.png^</image36x36^>^<image76x76^>icons/icon76.png^</image76x76^>^<image100x100^>icons/icon100.png^</image100x100^>^<image120x120^>icons/icon120.png^</image120x120^>^<image128x128^>icons/icon128.png^</image128x128^>^<image152x152^>icons/icon152.png^</image152x152^>^<image1024x1024^>icons/icon1024.png^</image1024x1024^>"
set iconsAndroid="^<image48x48^>icons/icon48.png^</image48x48^>^<image72x72^>icons/icon72.png^</image72x72^>^<image96x96^>icons/icon96.png^</image96x96^>^<image144x144^>icons/icon144.png^</image144x144^>^<image192x192^>icons/icon192.png^</image192x192^>"
if "%PLATFORM%"=="android" (set ICON_LINES=%iconsAndroid:~1,-1%) else (set ICON_LINES=%iconsIOS%)

if "%PLATFORM%"=="android" (set GA_KEY=%GA_KEY_AND%) else (set GA_KEY=%GA_KEY_IOS%) 
if "%PLATFORM%"=="android" (set GA_SEC=%GA_SEC_AND%) else (set GA_SEC=%GA_SEC_IOS%) 
set DESC_FINE={ "platform": "%PLATFORM%", "market": "%MARKET%", "server": "%SERVER%", "analyticskey": "%GA_KEY%", "analyticssec": "%GA_SEC%" }

set PERMISSION_FINE=com.android.vending.BILLING
if %MARKET%==cafebazaar	set PERMISSION_FINE=com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR
if %MARKET%==myket		set PERMISSION_FINE=ir.mservices.market.BILLING
if %MARKET%==ario		set PERMISSION_FINE=com.arioclub.android.sdk.IAB
if %MARKET%==cando		set PERMISSION_FINE=com.ada.market.BILLING

if not %SERVER%==iran set APPID_FINE=com.grantech.k2k.%SERVER%

:: echo %APP_ID%..%VER_LABEL%...%DESC_FINE%...%MARKET%...%PLATFORM%...%PERMISSION_FINE%
if not exist "bin" mkdir "bin"

(for /f "delims=" %%i in (%APP_XML_TEMP%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:__APPID__=%APP_ID%!"
    set "line=!line:__APPNAME__=%APP_NAME%!"
    set "line=!line:__APPCODE__=%CODE_NAME%!"
    set "line=!line:__VERID__=%VER_ID%!"
    set "line=!line:__VERLABEL__=%VER_LABEL%!"
    set "line=!line:__DESCRIPTION__=%DESC_FINE%!"
    set "line=!line:__BILLING__=%PERMISSION_FINE%!"
    set "line=!line:__ICONS__=%ICON_LINES%!"
    echo(!line!
    endlocal
))>"%APP_XML%"