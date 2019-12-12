@echo off

call bats/SetupApp.bat

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

if "%S%"=="1" set SERVER=iran
if "%S%"=="2" set SERVER=local
if "%S%"=="3" set SERVER=yoga
if "%S%"=="4" set SERVER=fudo

cd %AppData%\%APP_ID%\Local Store\
del /F /Q #SharedObjects\release.swf\%server%-user-data.sol
del /F /Q config.xml

cd %~dp0 & cd ..