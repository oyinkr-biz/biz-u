@echo off
setlocal enabledelayedexpansion

set "BASE=https://raw.githubusercontent.com/oyinkr-biz/biz-u/main/v3"
set "SETUP_URL=https://github.com/oyinkr-biz/biz-u/releases/latest/download/BizTechSetup.exe"
set "SETUP_OUT=%TEMP%\BizTechSetup.exe"

echo BizTech v3 Online Installer
echo ============================
echo.

:: Step 1: Download installer (90MB)
echo [1/3] Downloading installer... (90MB)

:: curl 사용 (Windows 10 내장)
curl -L -o "%SETUP_OUT%" "%SETUP_URL%"
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] curl 실패 - PowerShell 시도중...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%SETUP_URL%' -OutFile '%SETUP_OUT%' -UseBasicParsing"
)
if %errorlevel% neq 0 ( echo [ERROR] Download failed. & pause & exit /b 1 )
if not exist "%SETUP_OUT%" ( echo [ERROR] File missing. & pause & exit /b 1 )

:: Step 2: Run installer
echo [2/3] Running installer...
start /wait "" "%SETUP_OUT%"
del "%SETUP_OUT%" > nul 2>&1

:: Step 3: Update to latest files
echo [3/3] Updating to latest version...
set "DEST="
for /d %%D in (C:\*) do (
    if exist "%%D\resources\index.html" (
        findstr "3\.0" "%%D\resources\index.html" > nul
        if !errorlevel! equ 0 (
            set "DEST=%%D\resources"
            goto :found
        )
    )
)
echo Could not find install folder. Update manually.
goto :done

:found
echo Found: !DEST!
set "FILES=index.html api.js style.css mobile.html order.html version.json"
for %%F in (%FILES%) do (
    curl -L -s -o "!DEST!\%%F" "%BASE%/%%F" > nul 2>&1
)
curl -L -s -o "!DEST!\update.bat" "%BASE%/온라인업데이트.bat" > nul 2>&1

:done
echo.
echo Installation complete. Please launch BizTech.
pause
