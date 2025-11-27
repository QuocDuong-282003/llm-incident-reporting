# PowerShell script để setup Google Sheets API

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP GOOGLE SHEETS API" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Bước 1: Nhập Sheet ID
Write-Host "[BƯỚC 1] Tạo Google Sheet" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Mở trình duyệt: https://sheets.google.com" -ForegroundColor White
Write-Host "2. Tạo sheet mới, đặt tên: 'Incident Report'" -ForegroundColor White
Write-Host "3. Lấy Sheet ID từ URL (phần giữa /d/ và /edit)" -ForegroundColor White
Write-Host ""
$SHEET_ID = Read-Host "Nhập Sheet ID"

if ([string]::IsNullOrWhiteSpace($SHEET_ID)) {
    Write-Host "❌ Sheet ID không được để trống!" -ForegroundColor Red
    exit 1
}

# Bước 2: Enable API
Write-Host ""
Write-Host "[BƯỚC 2] Enable Google Sheets API..." -ForegroundColor Yellow
gcloud services enable sheets.googleapis.com --quiet
Write-Host "✅ Google Sheets API đã được enable" -ForegroundColor Green

# Bước 3: Lấy Service Account Email
Write-Host ""
Write-Host "[BƯỚC 3] Lấy Service Account Email..." -ForegroundColor Yellow
$SA_EMAIL = gcloud iam service-accounts list --format="value(email)" --filter="displayName:incident-reporting-sa" 2>&1

if ([string]::IsNullOrWhiteSpace($SA_EMAIL)) {
    Write-Host "⚠️  Service Account 'incident-reporting-sa' chưa tồn tại" -ForegroundColor Yellow
    Write-Host "   Tạo Service Account..." -ForegroundColor Yellow
    
    $PROJECT_ID = gcloud config get-value project
    gcloud iam service-accounts create incident-reporting-sa --display-name="Incident Reporting SA" --quiet
    $SA_EMAIL = "incident-reporting-sa@${PROJECT_ID}.iam.gserviceaccount.com"
}

Write-Host "✅ Service Account Email: $SA_EMAIL" -ForegroundColor Green

# Bước 4: Update Cloud Function
Write-Host ""
Write-Host "[BƯỚC 4] Update Cloud Function với Sheet ID..." -ForegroundColor Yellow
gcloud functions deploy incidentReporting `
    --gen2 `
    --region=asia-southeast1 `
    --update-env-vars="GOOGLE_SHEETS_ID=${SHEET_ID}" `
    --quiet

Write-Host "✅ Cloud Function đã được update" -ForegroundColor Green

# Tóm tắt
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SETUP HOÀN TẤT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Các bước tiếp theo:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Mở Google Sheet:" -ForegroundColor White
Write-Host "   https://docs.google.com/spreadsheets/d/${SHEET_ID}/edit" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Click 'Share' (góc trên bên phải)" -ForegroundColor White
Write-Host ""
Write-Host "3. Thêm email Service Account:" -ForegroundColor White
Write-Host "   $SA_EMAIL" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Chọn quyền: 'Editor' (quan trọng!)" -ForegroundColor White
Write-Host ""
Write-Host "5. Click 'Share'" -ForegroundColor White
Write-Host ""
Write-Host "✅ Sau đó test function để xem dữ liệu có được ghi vào Sheet không" -ForegroundColor Green
Write-Host ""

