@echo off
echo ========================================
echo   KIEM TRA HE THONG
echo ========================================
echo.
echo [BƯỚC 1] Đang khởi động server...
echo.
echo ✅ Server sẽ chạy trên: http://localhost:3000
echo ✅ Giữ cửa sổ này mở
echo.
echo [BƯỚC 2] Mở PowerShell/CMD mới và chạy:
echo    test-simple.ps1
echo.
echo [BƯỚC 3] Hoặc test thủ công bằng lệnh:
echo    curl -X POST http://localhost:3000/log/ingest -H "Content-Type: application/json" -d "{\"service_name\":\"test\",\"severity\":\"error\",\"log_message\":\"Test message\"}"
echo.
echo ========================================
echo.
npm run dev

