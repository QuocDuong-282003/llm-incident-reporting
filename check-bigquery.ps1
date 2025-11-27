# Script để check dữ liệu trong BigQuery

$PROJECT_ID = "llm-incident-duong-2024"
$DATASET = "incident_reporting"
$TABLE = "Incidents_Analyzed"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  CHECK BIGQUERY DATA" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Project: $PROJECT_ID" -ForegroundColor Yellow
Write-Host "Dataset: $DATASET" -ForegroundColor Yellow
Write-Host "Table: $TABLE" -ForegroundColor Yellow
Write-Host ""

# Query 1: Tổng số incidents
Write-Host "[1/5] Tổng số incidents:" -ForegroundColor Yellow
bq query --use_legacy_sql=false --format=prettyjson "SELECT COUNT(*) as total FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\`"
Write-Host ""

# Query 2: Số lượng theo loại
Write-Host "[2/5] Số lượng theo loại sự cố:" -ForegroundColor Yellow
bq query --use_legacy_sql=false --format=prettyjson "SELECT incident_type, COUNT(*) as count FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\` GROUP BY incident_type ORDER BY count DESC"
Write-Host ""

# Query 3: Số lượng theo service
Write-Host "[3/5] Số lượng theo service:" -ForegroundColor Yellow
bq query --use_legacy_sql=false --format=prettyjson "SELECT service_name, COUNT(*) as count FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\` GROUP BY service_name ORDER BY count DESC"
Write-Host ""

# Query 4: Sự cố trong 24h
Write-Host "[4/5] Sự cố trong 24h gần nhất:" -ForegroundColor Yellow
bq query --use_legacy_sql=false --format=prettyjson "SELECT incident_type, COUNT(*) as count FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\` WHERE analyzed_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR) GROUP BY incident_type ORDER BY count DESC"
Write-Host ""

# Query 5: Latest 10 incidents
Write-Host "[5/5] 10 incidents mới nhất:" -ForegroundColor Yellow
bq query --use_legacy_sql=false --format=prettyjson "SELECT timestamp, service_name, severity, incident_type, LEFT(incident_summary, 50) as summary_preview, analyzed_at FROM \`${PROJECT_ID}.${DATASET}.${TABLE}\` ORDER BY analyzed_at DESC LIMIT 10"
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  HOÀN TẤT!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Xem chi tiết trong BigQuery Console:" -ForegroundColor Yellow
Write-Host "   https://console.cloud.google.com/bigquery?project=${PROJECT_ID}" -ForegroundColor Cyan
Write-Host ""

