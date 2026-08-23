@echo off
setlocal enabledelayedexpansion

set "URL=https://github.com/oyinkr-biz/biztech-updates/releases/latest/download/BizTechSetup.exe"
set "OUT=%TEMP%\BizTechSetup.exe"

echo BizTech v3 Online Installer
echo ============================
echo.
echo Downloading installer... (about 90MB)
echo.

powershell -Command "
try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile('%URL%', '%OUT%')
    Write-Host 'Download complete.'
} catch {
    Write-Host 'ERROR: ' + $_.Exception.Message
    exit 1
}"

if not exist "%OUT%" (
    echo [ERROR] Download failed. Check your internet connection.
    pause & exit /b 1
)

echo Running installer...
start /wait "" "%OUT%"
del "%OUT%" > nul 2>&1

echo.
echo Installation complete.
pause
