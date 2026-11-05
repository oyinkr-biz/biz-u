@echo off
setlocal
title BizTech 다른 PC 연결 설정
set "ROOT=%~dp0"
if not exist "%ROOT%resources\app.asar" if exist "%LOCALAPPDATA%\Programs\BizTech경영관리\resources\app.asar" set "ROOT=%LOCALAPPDATA%\Programs\BizTech경영관리\"
if not exist "%ROOT%resources\app.asar" if exist "C:\biztech-v3\resources\app.asar" set "ROOT=C:\biztech-v3\"
if not exist "%ROOT%resources\app.asar" (
    echo [오류] BizTech 설치 폴더를 찾을 수 없습니다. 먼저 온라인설치로 BizTech를 설치하세요.
    pause & exit /b 1
)

echo ==========================================================
echo  BizTech 다른 PC 연결 설정
echo  - 이 PC는 서버를 켜지 않고 메인(서버) PC에 연결해서 씁니다
echo  - 영수증은 이 PC에 연결된 영수증 프린터로 바로 출력됩니다
echo ==========================================================
echo  설치 폴더: %ROOT%
echo.
echo  메인(서버) PC 주소를 입력하세요.   예) 192.168.0.10
echo  (메인 PC 포트가 8085가 아니면 예: 192.168.0.10:8086)
echo  아무것도 입력하지 않고 Enter = 연결 해제 (이 PC를 다시 서버로)
echo.
set "SV="
set /p SV=메인 PC 주소:

echo.
echo BizTech 끄는 중...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$r='%ROOT%'; Get-Process | Where-Object { $_.Path -and $_.Path -like ($r + '*') } | Stop-Process -Force -ErrorAction SilentlyContinue"
timeout /t 2 /nobreak > nul

if "%SV%"=="" (
    del /q "%ROOT%resources\client.json" 2>nul
    echo 연결 해제 완료 - 이 PC가 다시 서버로 동작합니다.
    goto run
)

> "%ROOT%resources\client.json" echo {"server":"%SV%"}
echo 메인 PC 연결 확인 중...
powershell -NoProfile -Command "$u='%SV%'; if ($u -notmatch '^https?://') { $u='http://'+$u }; if ($u -notmatch ':\d+$') { $u+=':8085' }; try { $null = Invoke-RestMethod ($u + '/api/health') -TimeoutSec 5; Write-Host ('연결 성공: ' + $u) } catch { Write-Host ('[주의] 지금은 ' + $u + ' 에 연결되지 않습니다. 메인 PC가 켜져 있는지, 주소가 맞는지 확인하세요.') }"
echo 설정 저장 완료.

:run
echo.
echo BizTech를 실행합니다.
start "" "%ROOT%BizTech경영관리.exe"
pause
