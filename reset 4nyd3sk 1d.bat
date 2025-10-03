@echo off
setlocal enabledelayedexpansion

:: === Configuration ===
set "SERVICE_NAME=AnyDesk"

:: === Administrator check ===
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Administrator privileges required! %LOG%
    echo Please run script as Administrator
    pause
    exit /b 1
)

:: === Stop AnyDesk service ===
echo Stopping AnyDesk service... %LOG%
sc query "AnyDesk" >nul 2>&1 && (
    sc stop "AnyDesk" >nul 2>&1
    echo AnyDesk service stopped %LOG%
) || (
    echo AnyDesk service not found or already stopped %LOG%
)

:: === Terminate AnyDesk processes ===
echo Terminating AnyDesk processes... %LOG%
set "PROCESSES=AnyDesk.exe AnyDeskMS.exe AnyDeskSVC.exe"

for %%P in (%PROCESSES%) do (
    tasklist /FI "IMAGENAME eq %%P" 2>NUL | find /I "%%P" >NUL
    if !errorlevel! equ 0 (
        echo Terminating process: %%P %LOG%
        taskkill /F /IM "%%P" >nul 2>&1
        if !errorlevel! equ 0 (
            echo Process %%P terminated successfully %LOG%
        ) else (
            echo Error terminating process %%P %LOG%
        )
    ) else (
        echo Process %%P not found %LOG%
    )
)

:: === Delete configuration files ===
echo Deleting configuration files... %LOG%

set "PATHS_TO_CLEAN="
set "PATHS_TO_CLEAN=%PATHS_TO_CLEAN% "%ALLUSERSPROFILE%\AnyDesk\service.conf""
set "PATHS_TO_CLEAN=%PATHS_TO_CLEAN% "%USERPROFILE%\AppData\Roaming\AnyDesk\service.conf""
set "PATHS_TO_CLEAN=%PATHS_TO_CLEAN% "%USERPROFILE%\AppData\Roaming\AnyDesk\system.conf""
set "PATHS_TO_CLEAN=%PATHS_TO_CLEAN% "%ProgramFiles%\AnyDesk\service.conf""
set "PATHS_TO_CLEAN=%PATHS_TO_CLEAN% "%ProgramFiles(x86)%\AnyDesk\service.conf""

for %%F in (%PATHS_TO_CLEAN%) do (
    if exist "%%F" (
        del /f /q "%%F" >nul 2>&1
        if !errorlevel! equ 0 (
            echo File deleted: %%F %LOG%
        ) else (
            echo Error deleting: %%F %LOG%
        )
    ) else (
        echo File not found: %%F %LOG%
    )
)

:: === Additional registry cleanup ===
echo Cleaning registry... %LOG%
reg delete "HKEY_CURRENT_USER\Software\AnyDesk" /f >nul 2>&1 && echo Registry key HKCU deleted %LOG%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\AnyDesk" /f >nul 2>&1 && echo Registry key HKLM deleted %LOG%

:: === Application cache cleanup ===
echo Cleaning cache... %LOG%
if exist "%USERPROFILE%\AppData\Roaming\AnyDesk" (
    rmdir /s /q "%USERPROFILE%\AppData\Roaming\AnyDesk" >nul 2>&1
    if !errorlevel! equ 0 (
        echo AppData folder cleaned %LOG%
    )
)

:: === Final status ===
echo. %LOG%
echo ======================================= %LOG%
echo AnyDesk cleanup completed! %LOG%
echo ======================================= %LOG%

:: === Final pause ===
echo.
echo Press any key to exit...
pause >nul

endlocal