@echo off
echo ========================================
echo   SETUP GOOGLE SHEETS API
echo ========================================
echo.

echo [BƯỚC 1] Tạo Google Sheet
echo.
echo 1. Mở trình duyệt: https://sheets.google.com
echo 2. Tạo sheet mới, đặt tên: "Incident Report"
echo 3. Lấy Sheet ID từ URL (phần giữa /d/ và /edit)
echo.
set /p SHEET_ID="Nhập Sheet ID: "

echo.
echo [BƯỚC 2] Enable Google Sheets API
echo.
gcloud services enable sheets.googleapis.com

echo.
echo [BƯỚC 3] Lấy Service Account Email
echo.
for /f "tokens=*" %%i in ('gcloud iam service-accounts list --format="value(email)" --filter="displayName:incident-reporting-sa"') do set SA_EMAIL=%%i

if "%SA_EMAIL%"=="" (
    echo ⚠️  Service Account chưa tồn tại
    echo    Tạo Service Account trước: gcloud iam service-accounts create sheets-service-account
    pause
    exit /b 1
)

echo Service Account Email: %SA_EMAIL%
echo.
echo [BƯỚC 4] Update Cloud Function với Sheet ID
echo.
gcloud functions deploy incidentReporting --gen2 --region=asia-southeast1 --update-env-vars="GOOGLE_SHEETS_ID=%SHEET_ID%"

echo.
echo ========================================
echo   SETUP HOÀN TẤT!
echo ========================================
echo.
echo 📋 Các bước tiếp theo:
echo.
echo 1. Mở Google Sheet: https://docs.google.com/spreadsheets/d/%SHEET_ID%/edit
echo 2. Click "Share" (góc trên bên phải)
echo 3. Thêm email: %SA_EMAIL%
echo 4. Chọn quyền: "Editor"
echo 5. Click "Share"
echo.
echo ✅ Sau đó test function để xem dữ liệu có được ghi vào Sheet không
echo.
pause

