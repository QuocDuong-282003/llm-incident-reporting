# Script để tạo BigQuery dataset và table

$PROJECT_ID = "llm-incident-duong-2024"
$DATASET = "incident_reporting"
$TABLE = "Incidents_Analyzed"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CREATE BIGQUERY DATASET & TABLE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project: $PROJECT_ID" -ForegroundColor Yellow
Write-Host "Dataset: $DATASET" -ForegroundColor Yellow
Write-Host "Table: $TABLE" -ForegroundColor Yellow
Write-Host ""

# Kiểm tra dataset đã tồn tại chưa
Write-Host "[1/2] Checking dataset..." -ForegroundColor Yellow
$datasetExists = bq ls -d --format=json $PROJECT_ID:$DATASET 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dataset đã tồn tại" -ForegroundColor Green
} else {
    Write-Host "📦 Creating dataset..." -ForegroundColor Yellow
    bq mk --dataset --location=asia-southeast1 "${PROJECT_ID}:${DATASET}"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Dataset created!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create dataset" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "[2/2] Checking table..." -ForegroundColor Yellow
$tableExists = bq ls -t --format=json $PROJECT_ID:$DATASET:$TABLE 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Table đã tồn tại" -ForegroundColor Green
} else {
    Write-Host "📦 Creating table..." -ForegroundColor Yellow
    bq mk --table `
      "${PROJECT_ID}:${DATASET}.${TABLE}" `
      timestamp:TIMESTAMP,service_name:STRING,severity:STRING,full_log_text:STRING,incident_type:STRING,incident_summary:STRING,analyzed_at:TIMESTAMP
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Table created!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to create table" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  HOÀN TẤT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Bây giờ bạn có thể xem trong BigQuery Console:" -ForegroundColor Yellow
Write-Host "   https://console.cloud.google.com/bigquery?project=${PROJECT_ID}" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Project: $PROJECT_ID" -ForegroundColor White
Write-Host "   Dataset: $DATASET" -ForegroundColor White
Write-Host "   Table: $TABLE" -ForegroundColor White
Write-Host ""

