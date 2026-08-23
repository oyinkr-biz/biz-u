@echo off
setlocal enabledelayedexpansion

set "BASE=https://raw.githubusercontent.com/oyinkr-biz/biz-u/main/v3"
set "SETUP_URL=https://github.com/oyinkr-biz/biz-u/releases/latest/download/BizTechSetup.exe"
set "SETUP_OUT=%TEMP%\BizTechSetup.exe"

echo BizTech v3 Online Installer
echo ============================
echo.

:: Step 1: Download installer
echo [1/3] Downloading installer... (about 90MB)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%SETUP_URL%' -OutFile '%SETUP_OUT%' -UseBasicParsing"
if %errorlevel% neq 0 ( echo [ERROR] Download failed. & pause & exit /b 1 )
if not exist "%SETUP_OUT%" ( echo [ERROR] File missing. & pause & exit /b 1 )

:: Step 2: Run installer
echo [2/3] Running installer...
start /wait "" "%SETUP_OUT%"
del "%SETUP_OUT%" > nul 2>&1

:: Step 3: Find installed location and update to latest
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
echo Could not find install folder. Update manually using online-update.bat.
goto :done

:found
echo Found: !DEST!
set "FILES=index.html api.js style.css mobile.html order.html version.json"
for %%F in (%FILES%) do (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%BASE%/%%F' -OutFile '!DEST!\%%F' -UseBasicParsing" > nul 2>&1
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%BASE%/온라인업데이트.bat' -OutFile '!DEST!\온라인업데이트.bat' -UseBasicParsing" > nul 2>&1

:done
echo.
echo Installation complete. Please launch BizTech.
pause
