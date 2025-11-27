# Script tạo BigQuery dataset và table nhanh

$PROJECT_ID = "llm-incident-duong-2024"
$DATASET = "incident_reporting"
$TABLE = "Incidents_Analyzed"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TẠO BIGQUERY DATASET & TABLE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Tạo dataset
Write-Host "📦 Creating dataset: $DATASET..." -ForegroundColor Yellow
bq mk --dataset --location=asia-southeast1 "${PROJECT_ID}:${DATASET}" 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dataset created!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Dataset có thể đã tồn tại" -ForegroundColor Yellow
}

Write-Host ""

# Tạo table
Write-Host "📦 Creating table: $TABLE..." -ForegroundColor Yellow
bq mk --table `
  "${PROJECT_ID}:${DATASET}.${TABLE}" `
  timestamp:TIMESTAMP,service_name:STRING,severity:STRING,full_log_text:STRING,incident_type:STRING,incident_summary:STRING,analyzed_at:TIMESTAMP 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Table created!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Table có thể đã tồn tại" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  HOÀN TẤT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Bây giờ refresh BigQuery Console và tìm:" -ForegroundColor Yellow
Write-Host "   Project: $PROJECT_ID" -ForegroundColor White
Write-Host "   Dataset: $DATASET" -ForegroundColor White
Write-Host "   Table: $TABLE" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Link: https://console.cloud.google.com/bigquery?project=${PROJECT_ID}" -ForegroundColor Cyan
Write-Host ""

