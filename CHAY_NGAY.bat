@echo off
echo ========================================
echo   LLM Incident Reporting - Quick Start
echo ========================================
echo.

echo [1/3] Checking Node.js...
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js not found! Please install Node.js first.
    pause
    exit /b 1
)
echo ✅ Node.js found
echo.

echo [2/3] Installing dependencies...
call npm install
if errorlevel 1 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)
echo ✅ Dependencies installed
echo.

echo [3/3] Starting server...
echo.
echo ✅ Server is starting on http://localhost:3000
echo ✅ Press Ctrl+C to stop
echo.
echo To test, open another terminal and run:
echo    test-simple.ps1
echo.
call npm run dev

