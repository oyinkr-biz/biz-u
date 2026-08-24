@echo off
setlocal enabledelayedexpansion

set "BASE=https://raw.githubusercontent.com/oyinkr-biz/biz-u/main/v3"
set "DEST=%~dp0"

echo BizTech v3 Online Updater
echo ========================
echo.

:: Check version
echo Checking latest version...
powershell -Command "try { $v=(Invoke-WebRequest '%BASE%/version.json' -UseBasicParsing).Content | ConvertFrom-Json; Write-Host $v.version } catch { Write-Host 'ERROR' }" > "%TEMP%\biz_ver.txt"
set /p NEWVER=<"%TEMP%\biz_ver.txt"

if "!NEWVER!"=="ERROR" (
    echo [ERROR] Cannot connect to update server. Check internet connection.
    pause & exit /b 1
)

:: Check current version
set "CURVER=unknown"
if exist "%DEST%version.json" (
    powershell -Command "try { $v=(Get-Content '%DEST%version.json'|ConvertFrom-Json).version; Write-Host $v } catch { Write-Host 'unknown' }" > "%TEMP%\biz_curver.txt"
    set /p CURVER=<"%TEMP%\biz_curver.txt"
)

echo Current : !CURVER!
echo Latest  : !NEWVER!
echo.

if "!CURVER!"=="!NEWVER!" (
    echo Already up to date.
    pause & exit /b 0
)

echo Update available: !CURVER! -> !NEWVER!
echo Press any key to update...
pause > nul

:: Download files
set "FILES=index.html api.js style.css mobile.html order.html version.json"
for %%F in (%FILES%) do (
    echo Downloading %%F...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest '%BASE%/%%F' -OutFile '%DEST%%%F' -UseBasicParsing"
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to download %%F
        pause & exit /b 1
    )
)
:: server.exe 업데이트 (서버 중단 후 교체)
echo Downloading server.exe... (14MB)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest '%BASE%/server.exe' -OutFile '%DEST%server_new.exe' -UseBasicParsing"
if !errorlevel! equ 0 (
    if exist "%DEST%server_new.exe" (
        move /y "%DEST%server_new.exe" "%DEST%server.exe" > nul
        echo server.exe updated.
    )
)

echo.
echo Update complete! (!NEWVER!)
echo Please restart BizTech.
pause
