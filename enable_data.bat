@echo off
setlocal enabledelayedexpansion

set adapter_name="Ethernet"
@REM set "log_file=%USERPROFILE%\Documents\data.log"
@REM set "log_file=C:\Users\Nate\Documents\data.log"

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')"`) do set "doc_folder=%%i"
set "log_file=%doc_folder%\data.log"

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -ArgumentList '%*' -Verb runAs"
    exit /b
)

:: Check for parameter
if "%~1"=="" (
    echo Usage: %~nx0 ^<duration_in_minutes^>
    exit /b 1
)

set /a target_minutes=%~1
set /a target_seconds=target_minutes * 60

set "user_message="
set /p user_message=Enter a log message (leave empty to cancel): 
if not defined user_message exit /b

:: Get timestamp and append to log
for /f "delims=" %%i in ('
    powershell -nologo -command "(Get-Date).ToString('M/d/yy, h:mm tt')"
') do (
    echo %%i [%target_minutes% minutes]: %user_message%>>%log_file%
)

:: Get start time as UNIX timestamp
for /f %%i in ('powershell -nologo -command "[int](Get-Date -UFormat %%s)"') do set start_ts=%%i

:: Calculate and display end time (formatted)
for /f "delims=" %%i in ('powershell -nologo -command "(Get-Date).AddSeconds(%target_seconds%).ToString('yyyy-MM-dd HH:mm:ss')"') do set end_time=%%i

echo Enabling network adapter: %adapter_name%
netsh interface set interface name=%adapter_name% admin=enabled
echo Adapter will be disabled at: %end_time%

:wait_loop
timeout /t 30 >nul

:: Get current time
for /f %%i in ('powershell -nologo -command "[int](Get-Date -UFormat %%s)"') do set current_ts=%%i

set /a elapsed=!current_ts! - !start_ts!
if !elapsed! GEQ %target_seconds% goto done
goto wait_loop

:done
echo Disabling network adapter: %adapter_name%
netsh interface set interface name=%adapter_name% admin=disabled

echo Done.
