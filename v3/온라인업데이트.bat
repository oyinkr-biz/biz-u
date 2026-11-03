@echo off
setlocal enabledelayedexpansion

set "BASE=https://raw.githubusercontent.com/oyinkr-biz/biz-u/main/v3"
set "ROOT=%~dp0"
set "DEST=%~dp0resources\"

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

:: server.exe missing (failed update etc.) - download again even if version is the same
if not exist "%DEST%server.exe" set "CURVER=missing-server"
:: old BizTech program (no server_bg.json = before 2026-11 always-on server) - update app.asar even if version is the same
if not exist "%DEST%server_bg.json" set "CURVER=old-app"

if "!CURVER!"=="!NEWVER!" (
    echo Already up to date.
    pause & exit /b 0
)

echo Update available: !CURVER! -^> !NEWVER!
echo BizTech will be closed automatically during the update.
echo Press any key to update...
pause > nul

:: Close BizTech and its server (only programs inside this install folder)
echo Closing BizTech...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$r='%ROOT%'; Get-Process | Where-Object { $_.Path -and $_.Path -like ($r + '*') } | Stop-Process -Force -ErrorAction SilentlyContinue"
timeout /t 2 /nobreak > nul

:: server.exe first - if this fails, stop before version.json so the next run retries
echo Downloading server.exe... (14MB)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest '%BASE%/server.exe' -OutFile '%DEST%server_new.exe' -UseBasicParsing"
if !errorlevel! neq 0 (
    echo [ERROR] Failed to download server.exe
    pause & exit /b 1
)
move /y "%DEST%server_new.exe" "%DEST%server.exe" > nul
if !errorlevel! neq 0 (
    echo [ERROR] Could not replace server.exe. Close BizTech completely and run this again.
    pause & exit /b 1
)
echo server.exe updated.

:: BizTech program (app.asar) - can only be replaced while BizTech is closed (done above)
echo Downloading app.asar...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest '%BASE%/app.asar' -OutFile '%DEST%app_new.asar' -UseBasicParsing } catch { exit 1 }"
if !errorlevel! equ 0 (
    for %%A in ("%DEST%app_new.asar") do if %%~zA GTR 10000 (
        move /y "%DEST%app_new.asar" "%DEST%app.asar" > nul && echo app.asar updated.
    )
)
if exist "%DEST%app_new.asar" del /q "%DEST%app_new.asar"

:: Other files (version.json last)
set "FILES=index.html api.js style.css mobile.html order.html xlsx-js-style.bundle.js version.json"
for %%F in (%FILES%) do (
    echo Downloading %%F...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest '%BASE%/%%F' -OutFile '%DEST%%%F' -UseBasicParsing"
    if !errorlevel! neq 0 (
        echo [ERROR] Failed to download %%F
        pause & exit /b 1
    )
)

echo.
echo Update complete! (!NEWVER!)
echo Please start BizTech again.
pause
