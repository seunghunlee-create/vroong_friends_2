@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title 부릉 프렌즈 대시보드 GitHub 푸시

REM ====================================================
REM   부릉 프렌즈 대시보드 → GitHub 자동 푸시 스크립트
REM   Repo: https://github.com/seunghunlee-create/vroong_friends_2
REM ====================================================

set "REPO_URL=https://github.com/seunghunlee-create/vroong_friends_2.git"
set "REPO_DIR=%USERPROFILE%\Documents\vroong_friends_2"
set "DASHBOARD_SRC=C:\Users\seunghun.lee\Desktop\클로드 파일(1)\오더_대시보드_2026-05-01_05-06.html"
set "DASHBOARD_DST=index.html"
set "BRANCH=main"

echo.
echo ============================================================
echo   부릉 프렌즈 대시보드 GitHub 푸시
echo ============================================================
echo.
echo  - 소스: %DASHBOARD_SRC%
echo  - Repo: %REPO_DIR%
echo  - Target: %DASHBOARD_DST%
echo  - Branch: %BRANCH%
echo.

REM Step 1: Verify dashboard file exists
if not exist "%DASHBOARD_SRC%" (
  echo [에러] 대시보드 파일을 찾을 수 없습니다.
  echo        %DASHBOARD_SRC%
  pause
  exit /b 1
)

REM Step 2: Clone repo if not exists
if not exist "%REPO_DIR%\.git" (
  echo [1/5] Repo가 로컬에 없습니다. 클론을 시작합니다...
  if not exist "%USERPROFILE%\Documents" mkdir "%USERPROFILE%\Documents"
  cd /d "%USERPROFILE%\Documents"
  git clone "%REPO_URL%" vroong_friends_2
  if errorlevel 1 (
    echo [에러] git clone 실패. GitHub 인증 또는 네트워크 확인 필요.
    pause
    exit /b 1
  )
  echo       클론 완료.
) else (
  echo [1/5] Repo 확인 완료: %REPO_DIR%
)

REM Step 3: Pull latest
cd /d "%REPO_DIR%"
echo [2/5] 원격 변경사항 가져오는 중...
git pull origin %BRANCH% --rebase --autostash
if errorlevel 1 (
  echo [경고] git pull 실패. 충돌이 있을 수 있습니다. 계속 진행합니다...
)

REM Step 4: Copy latest dashboard
echo [3/5] 대시보드 파일 복사 중...
copy /Y "%DASHBOARD_SRC%" "%REPO_DIR%\%DASHBOARD_DST%" >nul
if errorlevel 1 (
  echo [에러] 파일 복사 실패.
  pause
  exit /b 1
)
echo       %DASHBOARD_DST% 갱신 완료.

REM Step 5: Commit and push
echo [4/5] 변경사항 커밋 중...
git add %DASHBOARD_DST%
git diff --cached --quiet
if not errorlevel 1 (
  echo       변경사항 없음. 푸시 건너뜀.
  echo.
  goto :open_url
)

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "TS=%dt:~0,4%-%dt:~4,2%-%dt:~6,2% %dt:~8,2%:%dt:~10,2%"
git commit -m "대시보드 갱신 %TS%"
if errorlevel 1 (
  echo [에러] git commit 실패.
  pause
  exit /b 1
)

echo [5/5] GitHub에 푸시 중...
git push origin %BRANCH%
if errorlevel 1 (
  echo [에러] git push 실패. 인증 확인 또는 네트워크 확인 필요.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo   ✅ 푸시 완료!
echo ============================================================
echo.

:open_url
echo  GitHub Pages URL:
echo  https://seunghunlee-create.github.io/vroong_friends_2/
echo.
echo  Repo:
echo  https://github.com/seunghunlee-create/vroong_friends_2
echo.

choice /C YN /M "브라우저에서 GitHub Pages URL을 열까요"
if errorlevel 2 goto :end
if errorlevel 1 start https://seunghunlee-create.github.io/vroong_friends_2/

:end
echo.
echo 종료합니다.
timeout /t 3 >nul
endlocal
exit /b 0
