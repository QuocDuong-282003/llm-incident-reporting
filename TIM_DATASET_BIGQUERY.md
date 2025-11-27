# 🔍 TÌM DATASET VÀ TABLE TRONG BIGQUERY

## ❌ NẾU KHÔNG THẤY DATASET/TABLE

Có thể dataset/table chưa được tạo. Dataset và table sẽ được tạo **tự động** khi function `llmAnalysis` chạy lần đầu.

---

## 🔍 CÁCH TÌM TRONG BIGQUERY CONSOLE

### Bước 1: Kiểm tra Project

1. **Ở góc trên bên phải**, click vào project selector
2. **Chọn project:** `llm-incident-duong-2024`
3. **Đảm bảo đã chọn đúng project**

### Bước 2: Tìm trong Explorer

1. **Ở sidebar bên trái**, tìm phần **"Explorer"** hoặc **"Resources"**
2. **Mở rộng project** `llm-incident-duong-2024`
3. **Tìm dataset:** `incident_reporting`
4. **Nếu không thấy** → Dataset chưa được tạo

### Bước 3: Tạo Dataset thủ công (nếu chưa có)

**Cách 1: Dùng Console**

1. **Click "ADD DATA"** hoặc **"Create dataset"**
2. **Dataset ID:** `incident_reporting`
3. **Location:** `asia-southeast1` (hoặc `US`)
4. **Click "CREATE DATASET"**

**Cách 2: Dùng Command Line**

```powershell
bq mk --dataset --location=asia-southeast1 llm-incident-duong-2024:incident_reporting
```

### Bước 4: Tạo Table thủ công (nếu chưa có)

**Dùng Command Line:**

```powershell
bq mk --table `
  llm-incident-duong-2024:incident_reporting.Incidents_Analyzed `
  timestamp:TIMESTAMP,service_name:STRING,severity:STRING,full_log_text:STRING,incident_type:STRING,incident_summary:STRING,analyzed_at:TIMESTAMP
```

---

## 🚀 CÁCH TẠO TỰ ĐỘNG (KHUYẾN NGHỊ)

Dataset và table sẽ được tạo **tự động** khi function `llmAnalysis` chạy lần đầu.

### Để trigger function:

1. **Gửi log qua API** (nếu đã deploy API)
2. **Hoặc publish message trực tiếp lên Pub/Sub:**

```powershell
# Publish test message lên raw-app-logs
gcloud pubsub topics publish raw-app-logs --message='{"service_name":"test-service","severity":"error","log_message":"Database connection timeout","metadata":{}}'
```

3. **Function sẽ tự động:**
   - Nhận message từ `raw-app-logs`
   - Process và publish lên `clean-app-logs`
   - LLM Analysis function sẽ chạy
   - Tạo dataset và table tự động
   - Insert dữ liệu vào BigQuery

---

## 📋 CHECKLIST

- [ ] Đã chọn đúng project: `llm-incident-duong-2024`
- [ ] Đã tìm trong Explorer/Resources
- [ ] Dataset `incident_reporting` có tồn tại không?
- [ ] Table `Incidents_Analyzed` có tồn tại không?
- [ ] Nếu chưa có → Tạo thủ công hoặc trigger function

---

## ✅ TẠO NHANH BẰNG SCRIPT

Tạo file `create-bigquery.ps1`:

```powershell
$PROJECT_ID = "llm-incident-duong-2024"
$DATASET = "incident_reporting"
$TABLE = "Incidents_Analyzed"

Write-Host "Creating BigQuery dataset and table..." -ForegroundColor Yellow

# Tạo dataset
bq mk --dataset --location=asia-southeast1 "${PROJECT_ID}:${DATASET}"

# Tạo table
bq mk --table `
  "${PROJECT_ID}:${DATASET}.${TABLE}" `
  timestamp:TIMESTAMP,service_name:STRING,severity:STRING,full_log_text:STRING,incident_type:STRING,incident_summary:STRING,analyzed_at:TIMESTAMP

Write-Host "✅ Dataset and table created!" -ForegroundColor Green
```

Chạy:
```powershell
.\create-bigquery.ps1
```

---

## 🔍 SAU KHI TẠO XONG

Quay lại BigQuery Console và tìm:
- **Project:** `llm-incident-duong-2024`
- **Dataset:** `incident_reporting`
- **Table:** `Incidents_Analyzed`

---

**Bạn muốn tôi tạo script để tạo dataset/table ngay không?** 🤔

