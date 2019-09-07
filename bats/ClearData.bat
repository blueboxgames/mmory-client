@echo off

call bats/SetupApp.bat

echo %APP_XML%
echo %APP_ID%

:: find value <description> of Application descriptor and remove spaces
for /f "tokens=3 delims=<>" %%a in ('findstr /R /C:"^[ 	]*<description>" %APP_XML%') do set string=%%a

:: parse json config
:: Remove quotes
set string=%string:"=%
:: Remove braces
set "string=%string:~2,-2%"
:: Change colon+space by equal-sign
set "string=%string:: ==%"
:: Separate parts at comma into individual assignments
set "%string:, =" & set "%"

:menu
echo.
echo Change server after deletion?
echo.
echo  [0] no change
echo  [1] iran
echo  [2] local
echo  [3] yoga
echo  [4] fudo

:choice
set /P S=[Choice]: 
echo.

set SERVER=iran
if "%S%"=="0" goto clear
if "%S%"=="1" set SERVER=iran
if "%S%"=="2" set SERVER=local
if "%S%"=="3" set SERVER=yoga
if "%S%"=="4" set SERVER=fudo
set MARKET=cafebazaar

call bats/SetupDescriptor.bat

:clear

cd %AppData%\%APP_ID%\Local Store\
del /F /Q #SharedObjects\release.swf\%server%-user-data.sol
del /F /Q config.xml

cd %~dp0 & cd ..