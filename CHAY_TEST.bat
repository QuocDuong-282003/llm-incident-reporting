@echo off
echo ========================================
echo   TEST API - CHI TIET TUNG BUOC
echo ========================================
echo.
echo [BUOC 1] Dang test API...
echo.
echo Neu gap loi "Execution Policy", chay:
echo    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
echo.
pause

powershell -ExecutionPolicy Bypass -File "test-simple.ps1"

pause

