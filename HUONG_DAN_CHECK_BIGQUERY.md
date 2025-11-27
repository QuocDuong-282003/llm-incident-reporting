# 🔍 HƯỚNG DẪN CHECK DỮ LIỆU TRONG BIGQUERY

## 📊 CÁCH 1: DÙNG BIGQUERY CONSOLE (Giao diện Web)

### Bước 1: Truy cập BigQuery Console

1. **Mở trình duyệt**, truy cập:
   ```
   https://console.cloud.google.com/bigquery
   ```

2. **Chọn project:** `llm-incident-duong-2024` (nếu chưa chọn)

### Bước 2: Xem Dataset và Table

1. **Trong sidebar bên trái**, tìm:
   ```
   llm-incident-duong-2024
     └── incident_reporting (dataset)
         └── Incidents_Analyzed (table)
   ```

2. **Click vào table** `Incidents_Analyzed`

3. **Click tab "Preview"** để xem dữ liệu

### Bước 3: Query dữ liệu

1. **Click "Query"** (hoặc "Compose new query")

2. **Gõ query:**
   ```sql
   SELECT *
   FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
   ORDER BY analyzed_at DESC
   LIMIT 20
   ```

3. **Click "Run"**

4. **Xem kết quả** trong bảng bên dưới

### Bước 4: Query nâng cao

**Xem theo loại sự cố:**
```sql
SELECT 
  incident_type,
  COUNT(*) as count,
  MAX(analyzed_at) as latest
FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
GROUP BY incident_type
ORDER BY count DESC
```

**Xem sự cố trong 24h gần nhất:**
```sql
SELECT *
FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
WHERE analyzed_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
ORDER BY analyzed_at DESC
```

**Xem Database Connectivity Issues:**
```sql
SELECT *
FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
WHERE incident_type = 'Database Connectivity Issue'
ORDER BY analyzed_at DESC
```

---

## 💻 CÁCH 2: DÙNG COMMAND LINE (bq CLI)

### Bước 1: Cài đặt bq CLI (nếu chưa có)

```powershell
# bq CLI thường đi kèm với gcloud
gcloud components install bq
```

### Bước 2: Query dữ liệu

**Xem tất cả incidents:**
```powershell
bq query --use_legacy_sql=false "SELECT * FROM \`llm-incident-duong-2024.incident_reporting.Incidents_Analyzed\` ORDER BY analyzed_at DESC LIMIT 10"
```

**Xem theo loại:**
```powershell
bq query --use_legacy_sql=false "SELECT incident_type, COUNT(*) as count FROM \`llm-incident-duong-2024.incident_reporting.Incidents_Analyzed\` GROUP BY incident_type"
```

**Xem sự cố trong 1 giờ gần nhất:**
```powershell
bq query --use_legacy_sql=false "SELECT * FROM \`llm-incident-duong-2024.incident_reporting.Incidents_Analyzed\` WHERE analyzed_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR) ORDER BY analyzed_at DESC"
```

---

## 📱 CÁCH 3: DÙNG SCRIPT TỰ ĐỘNG

Tạo file `check-bigquery.ps1`:

```powershell
Write-Host "🔍 Checking BigQuery data..." -ForegroundColor Cyan
Write-Host ""

# Query tổng số incidents
Write-Host "📊 Total incidents:" -ForegroundColor Yellow
bq query --use_legacy_sql=false --format=prettyjson "SELECT COUNT(*) as total FROM \`llm-incident-duong-2024.incident_reporting.Incidents_Analyzed\`"

Write-Host ""
Write-Host "📊 Incidents by type:" -ForegroundColor Yellow
bq query --use_legacy_sql=false --format=prettyjson "SELECT incident_type, COUNT(*) as count FROM \`llm-incident-duong-2024.incident_reporting.Incidents_Analyzed\` GROUP BY incident_type ORDER BY count DESC"

Write-Host ""
Write-Host "📊 Latest 10 incidents:" -ForegroundColor Yellow
bq query --use_legacy_sql=false --format=prettyjson "SELECT timestamp, service_name, severity, incident_type, incident_summary FROM \`llm-incident-duong-2024.incident_reporting.Incidents_Analyzed\` ORDER BY analyzed_at DESC LIMIT 10"
```

Chạy:
```powershell
.\check-bigquery.ps1
```

---

## 🎯 CÁC QUERY HỮU ÍCH

### 1. Tổng số incidents
```sql
SELECT COUNT(*) as total_incidents
FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
```

### 2. Số lượng theo loại
```sql
SELECT 
  incident_type,
  COUNT(*) as count
FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
GROUP BY incident_type
ORDER BY count DESC
```

### 3. Số lượng theo service
```sql
SELECT 
  service_name,
  COUNT(*) as count
FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
GROUP BY service_name
ORDER BY count DESC
```

### 4. Sự cố trong 24h
```sql
SELECT 
  incident_type,
  COUNT(*) as count,
  MAX(analyzed_at) as latest
FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
WHERE analyzed_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
GROUP BY incident_type
```

### 5. Database Connectivity Issues (cho alerting)
```sql
SELECT 
  COUNT(*) as incident_count,
  STRING_AGG(DISTINCT service_name) as affected_services,
  MAX(analyzed_at) as latest_incident
FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
WHERE 
  incident_type = 'Database Connectivity Issue'
  AND analyzed_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 15 MINUTE)
```

---

## 📋 CHECKLIST

- [ ] Truy cập BigQuery Console
- [ ] Tìm dataset `incident_reporting`
- [ ] Tìm table `Incidents_Analyzed`
- [ ] Xem Preview data
- [ ] Chạy query để xem dữ liệu
- [ ] Kiểm tra có dữ liệu mới không

---

## 🐛 NẾU KHÔNG THẤY DỮ LIỆU

### Kiểm tra:
1. **Function đã chạy chưa?**
   ```powershell
   gcloud functions logs read llmAnalysis --gen2 --region=asia-southeast1 --limit=10
   ```

2. **Table đã được tạo chưa?**
   - Table sẽ tự động tạo khi function chạy lần đầu
   - Kiểm tra trong BigQuery Console

3. **Có log được gửi chưa?**
   - Kiểm tra Pub/Sub topics có message không
   - Kiểm tra log của logProcessing function

---

## ✅ TÓM TẮT

**Cách check dữ liệu:**

1. **BigQuery Console:** https://console.cloud.google.com/bigquery
   - Chọn project: `llm-incident-duong-2024`
   - Tìm: `incident_reporting.Incidents_Analyzed`
   - Click "Preview" hoặc "Query"

2. **Command line:**
   ```powershell
   bq query --use_legacy_sql=false "SELECT * FROM \`llm-incident-duong-2024.incident_reporting.Incidents_Analyzed\` LIMIT 10"
   ```

---

**Bạn muốn tôi tạo script tự động để check không?** 🤔

