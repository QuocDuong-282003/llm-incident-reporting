# Script để deploy incidentReporting function

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  DEPLOY INCIDENT REPORTING FUNCTION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Di chuyển đến thư mục function
Set-Location $PSScriptRoot

# Tạm thời ẩn tsconfig.json
Write-Host "[1/4] Ẩn tsconfig.json..." -ForegroundColor Yellow
if (Test-Path "tsconfig.json") {
    Rename-Item "tsconfig.json" "tsconfig.json.hidden" -ErrorAction SilentlyContinue
    Write-Host "✅ Đã ẩn tsconfig.json" -ForegroundColor Green
}

# Tạm thời ẩn index.ts
Write-Host "[2/4] Ẩn index.ts..." -ForegroundColor Yellow
if (Test-Path "index.ts") {
    Rename-Item "index.ts" "index.ts.hidden" -ErrorAction SilentlyContinue
    Write-Host "✅ Đã ẩn index.ts" -ForegroundColor Green
}

# Lấy Sheet ID
Write-Host ""
Write-Host "[3/4] Setup environment..." -ForegroundColor Yellow
$SHEET_ID = Read-Host "Nhập Google Sheet ID (hoặc Enter để dùng giá trị cũ)"

if ([string]::IsNullOrWhiteSpace($SHEET_ID)) {
    $SHEET_ID = "1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc"
}

$PROJECT_ID = gcloud config get-value project
Write-Host "✅ Project ID: $PROJECT_ID" -ForegroundColor Green
Write-Host "✅ Sheet ID: $SHEET_ID" -ForegroundColor Green

# Deploy
Write-Host ""
Write-Host "[4/4] Deploying function..." -ForegroundColor Yellow
Write-Host ""

gcloud functions deploy incidentReporting `
  --gen2 `
  --runtime=nodejs18 `
  --region=asia-southeast1 `
  --source=. `
  --entry-point=incidentReporting `
  --trigger-http `
  --allow-unauthenticated `
  --set-env-vars="GCP_PROJECT_ID=${PROJECT_ID},BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,GOOGLE_SHEETS_ID=${SHEET_ID}"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  DEPLOY THÀNH CÔNG!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Restore files
    Write-Host "Đang restore files..." -ForegroundColor Yellow
    Rename-Item "tsconfig.json.hidden" "tsconfig.json" -ErrorAction SilentlyContinue
    Rename-Item "index.ts.hidden" "index.ts" -ErrorAction SilentlyContinue
    Write-Host "✅ Đã restore files" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "📋 Test function:" -ForegroundColor Yellow
    $URL = gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
    Write-Host "   curl $URL" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "❌ Deploy thất bại!" -ForegroundColor Red
    Write-Host "Đang restore files..." -ForegroundColor Yellow
    Rename-Item "tsconfig.json.hidden" "tsconfig.json" -ErrorAction SilentlyContinue
    Rename-Item "index.ts.hidden" "index.ts" -ErrorAction SilentlyContinue
}

