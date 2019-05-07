set APP_XML_TEMP=files/application-template.xml
set APP_XML=src/application.xml
set DESC_TEMP=__DESCRIPTION__
set DESC_FINE={ "platform": "%PLATFORM%", "market": "%MARKET%", "server": "%SERVER%" }

set PERMISSION_TEMP=com.domain.market.BILLING
set PERMISSION_FINE=com.domain.market.BILLING
if %MARKET%==cafebazaar	set PERMISSION_FINE=com.farsitel.bazaar.permission.PAY_THROUGH_BAZAAR
if %MARKET%==google		set PERMISSION_FINE=com.android.vending.BILLING
if %MARKET%==myket		set PERMISSION_FINE=ir.mservices.market.BILLING
if %MARKET%==ario		set PERMISSION_FINE=com.arioclub.android.sdk.IAB
if %MARKET%==cando		set PERMISSION_FINE=com.ada.market.BILLING

echo %DESC_FINE%

::echo %MARKET%...%PLATFORM%...%PERMISSION_FINE%

(for /f "delims=" %%i in (%APP_XML_TEMP%) do (
    set "line=%%i"
    setlocal enabledelayedexpansion
    set "line=!line:%DESC_TEMP%=%DESC_FINE%!"
    set "line=!line:%PERMISSION_TEMP%=%PERMISSION_FINE%!"
    echo(!line!
    endlocal
))>"%APP_XML%"