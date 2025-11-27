@echo off
echo ========================================
echo   TEST API - AUTOMATIC
echo ========================================
echo.
echo Dang chay test...
echo.

cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "%~dp0test-simple.ps1"

echo.
echo ========================================
pause

