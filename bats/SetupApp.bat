:: Set working dir
cd %~dp0 & cd ..

:: Application descriptor
cd bin
set APP_XML=application.xml

:: Your application ID (must match <id> of Application descriptor) and remove spaces
for /f "tokens=3 delims=<>" %%a in ('findstr /R /C:"^[ 	]*<id>" %APP_XML%') do set APP_ID=%%a
set APP_ID=%APP_ID: =%

:: Your versionNumber (must match <versionNumber> of Application descriptor) and remove spaces
for /f "tokens=3 delims=<>" %%a in ('findstr /R /C:"^[ 	]*<versionNumber>" %APP_XML%') do set APP_VER=%%a

:: Get date with this template =>mouth day hours minutes seconds
set DATE=%date:~-10,2%%date:~-7,2%%time:~-11,2%%time:~-8,2%%time:~-5,2%
:: Replace space with 0
for %%a in (%DATE: =0%) do set DATE=%%a

:: Debugging using a custom IP
set DEBUG_IP=

:validation
findstr /C:"<id>%APP_ID%</id>" "%APP_XML%" > NUL
if errorlevel 1 goto badid
goto end

:badid
echo.
echo ERROR: 
echo   Application ID in 'bats\SetupApp.bat' (APP_ID) 
echo   does NOT match Application descriptor '%APP_XML%' (id)
echo.

:end
cd ..