call bats/SetupApp.bat

set APP_XML_TEMP=files/application-template.xml
set APP_XML=bin/application.xml

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
    set "line=!line:__VERID__=%VER_ID%!"
    set "line=!line:__VERLABEL__=%VER_LABEL%!"
    set "line=!line:__DESCRIPTION__=%DESC_FINE%!"
    set "line=!line:__BILLING__=%PERMISSION_FINE%!"
    echo(!line!
    endlocal
))>"%APP_XML%"