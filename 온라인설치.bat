@echo off
setlocal

set "URL=https://github.com/oyinkr-biz/biz-u/releases/latest/download/BizTechSetup.exe"
set "OUT=%TEMP%\BizTechSetup.exe"

echo BizTech v3 Online Installer
echo ============================
echo.
echo Downloading... (about 90MB, please wait)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%URL%' -OutFile '%OUT%' -UseBasicParsing"

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Download failed. Check internet connection.
    pause
    exit /b 1
)

if not exist "%OUT%" (
    echo.
    echo [ERROR] File not found after download.
    pause
    exit /b 1
)

echo Download complete. Running installer...
echo.
"%OUT%"

del "%OUT%" > nul 2>&1
echo.
echo Done.
pause
