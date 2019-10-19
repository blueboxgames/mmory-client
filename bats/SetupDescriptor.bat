set APP_XML_TEMP=files/application-template.xml
set APP_XML=bin/application.xml

set ANA_KEY_AND=ANA_KEY_AND
set ANA_SEC_AND=ANA_SEC_AND
set ANA_KEY_IOS=ANA_KEY_IOS
set ANA_SEC_IOS=ANA_SEC_IOS
if "%PLATFORM%"=="android" (set ANA_KEY=%ANA_KEY_AND%) else (set ANA_KEY=%ANA_KEY_IOS%) 
if "%PLATFORM%"=="android" (set ANA_SEC=%ANA_SEC_AND%) else (set ANA_SEC=%ANA_SEC_IOS%) 

set APPID_TEMP=__APPID__
set APPID_FINE=com.grantech.k2k

set DESC_TEMP=__DESCRIPTION__
set DESC_FINE={ "platform": "%PLATFORM%", "market": "%MARKET%", "server": "%SERVER%", "analyticskey": "%ANA_KEY%", "analyticssec": "%ANA_SEC%" }

set PERMISSION_TEMP=com.domain.market.BILLING
set PERMISSION_FINE=com.domain.market.BILLING

if %MARKET%==cafebazaar	set PERMISSION_FINE=com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR
if %MARKET%==google		set PERMISSION_FINE=com.android.vending.BILLING
if %MARKET%==myket		set PERMISSION_FINE=ir.mservices.market.BILLING
if %MARKET%==ario		set PERMISSION_FINE=com.arioclub.android.sdk.IAB
if %MARKET%==cando		set PERMISSION_FINE=com.ada.market.BILLING

if NOT %SERVER%==iran set APPID_FINE=com.grantech.k2k.%SERVER%

echo %DESC_FINE%
::echo %APP_ID%... %MARKET%...%PLATFORM%...%PERMISSION_FINE%

(for /f "delims=" %%i in (%APP_XML_TEMP%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:%APPID_TEMP%=%APPID_FINE%!"
    set "line=!line:%DESC_TEMP%=%DESC_FINE%!"
    set "line=!line:%PERMISSION_TEMP%=%PERMISSION_FINE%!"
    echo(!line!
    endlocal
))>"%APP_XML%"
