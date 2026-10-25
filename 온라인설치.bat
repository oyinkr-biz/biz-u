@echo off
setlocal

set SETUP_URL=https://github.com/oyinkr-biz/biz-u/releases/latest/download/BizTechSetup.exe
set SETUP_OUT=%TEMP%\BizTechSetup.exe

echo BizTech v3 Installer
echo =====================
echo.
echo Downloading... (90MB)
echo.

curl -L -o "%SETUP_OUT%" "%SETUP_URL%"

if not exist "%SETUP_OUT%" (
    echo DOWNLOAD FAILED
    pause
    exit /b 1
)

echo.
echo Closing BizTech...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Process | Where-Object { $_.Path -and $_.Path -like '*biztech*' } | Stop-Process -Force -ErrorAction SilentlyContinue"
timeout /t 2 /nobreak >nul

echo Running installer...
start /wait "" "%SETUP_OUT%"
del "%SETUP_OUT%" 2>nul

echo.
echo Done. Please launch BizTech.
pause
