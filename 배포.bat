@echo off
setlocal enabledelayedexpansion

set "SRC=C:\Users\oyinkr\Desktop\바탕메인폴더\AI_작업장_2\biz_006\biz_3.0_배포패키지\biz_3.0_업데이트패키지"
set "REPO=%~dp0v3"

echo BizTech v3 GitHub 배포
echo ======================

:: Get version from version.json
powershell -Command "(Get-Content '%SRC%\version.json' | ConvertFrom-Json).version" > "%TEMP%\biz_newver.txt"
set /p VER=<"%TEMP%\biz_newver.txt"
echo Version: !VER!
echo.

:: Copy update files
echo Copying files...
copy /y "%SRC%\index.html"   "%REPO%\index.html"   > nul
copy /y "%SRC%\api.js"       "%REPO%\api.js"        > nul
copy /y "%SRC%\style.css"    "%REPO%\style.css"     > nul
copy /y "%SRC%\mobile.html"  "%REPO%\mobile.html"   > nul
copy /y "%SRC%\order.html"   "%REPO%\order.html"    > nul
copy /y "%SRC%\version.json" "%REPO%\version.json"  > nul
echo Done.

:: Git push
cd /d "%~dp0"
git add -A
git commit -m "v!VER!"
git push origin main

echo.
echo Deployed: v!VER!
pause
