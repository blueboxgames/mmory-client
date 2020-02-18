@echo off
:: Set working dir
cd %~dp0 & cd ..

:: Get date with this template =>mouth day hours minutes seconds
set DATE=%date:~-10,2%%date:~-7,2%%time:~-11,2%%time:~-8,2%
:: Replace space with 0
for %%a in (%DATE: =0%) do set DATE=%%a

:: Application descriptor
set VER_ID=0.3.220
set VER_LABEL=%VER_ID%.%DATE%
set APP_ID=com.grantech.k2k
set APP_NAME=Boomland
set CODE_NAME=k2k
echo %VER_LABEL%
:: Game Analytics
set GA_KEY_AND=df4b20d8b9a4b0ec2fdf5ac49471d5b2
set GA_SEC_AND=972a1c900218b46f42d8a93e2f69710545903307
set GA_KEY_IOS=GA_KEY_IOS
set GA_SEC_IOS=GA_SEC_IOS

if [%SERVER%]==[] set SERVER=iran
if [%MARKET%]==[] set MARKET=cafebazaar
if [%PLATFORM%]==[] set PLATFORM=android
if NOT %SERVER%==iran set APP_ID=%APP_ID%.%SERVER%

:: Debugging using a custom IP
set DEBUG_IP=