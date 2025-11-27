@echo off
echo ========================================
echo   TEST API - CHAY NHANH
echo ========================================
echo.
echo Dang chay test script...
echo.

cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "test-simple.ps1"

echo.
echo ========================================
echo   Test hoan thanh!
echo ========================================
pause

