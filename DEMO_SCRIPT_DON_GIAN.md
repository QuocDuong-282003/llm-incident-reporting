# 🎬 SCRIPT DEMO ĐƠN GIẢN

## ✅ CODE ĐÃ ĐƯỢC SỬA

Code test của bạn có một chỗ sai:
- ❌ `full_log_text` (sai)
- ✅ `log_message` (đúng)

Đã sửa trong file `demo-test-api.js` và `demo-test-api.ps1`

---

## 🚀 CÁCH CHẠY DEMO

### Cách 1: PowerShell Script (Dễ nhất)

```powershell
# Nếu API chạy local
.\demo-test-api.ps1
# Nhập: http://localhost:3001

# Nếu API deploy lên Cloud Run
$env:API_ENDPOINT="https://your-api-url.run.app"
.\demo-test-api.ps1
```

### Cách 2: Node.js Script

```powershell
# Cài axios nếu chưa có
npm install axios

# Chạy
node demo-test-api.js

# Hoặc với API URL khác
$env:API_ENDPOINT="https://your-api-url.run.app"
node demo-test-api.js
```

---

## 📋 DEMO FLOW (Từng bước)

### 1. Chuẩn bị (Trước khi demo)

Mở các tab:
- ✅ BigQuery Console: https://console.cloud.google.com/bigquery?project=llm-incident-duong-2024
- ✅ Google Sheets: https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit
- ✅ Telegram: https://api.telegram.org/bot8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA/getUpdates
- ✅ Terminal: Để chạy script

---

### 2. Chạy Script Demo

```powershell
.\demo-test-api.ps1
```

**Kết quả:**
```
========================================
  DEMO: LLM INCIDENT REPORTING SYSTEM
========================================

📡 API Endpoint: http://localhost:3001/log/ingest
📊 Sending 4 test logs...

[1/4] Test 1: Authentication Error
✅ Success! Message ID: local-message-id-...

[2/4] Test 2: Database Connectivity Issue
✅ Success! Message ID: local-message-id-...

...
```

---

### 3. Show BigQuery (Sau khi chạy script)

**Nói:**
> "Bây giờ chúng ta sẽ xem dữ liệu đã được phân tích và lưu vào BigQuery"

**Làm:**
1. Mở BigQuery Console
2. Query:
   ```sql
   SELECT *
   FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
   ORDER BY analyzed_at DESC
   LIMIT 10
   ```

**Show:**
- ✅ Cột `incident_type` (LLM đã phân loại)
- ✅ Cột `incident_summary` (LLM đã tóm tắt)

---

### 4. Show Google Sheets

**Nói:**
> "Hệ thống tự động export báo cáo vào Google Sheets"

**Làm:**
1. Mở Google Sheet
2. Show bảng báo cáo

---

### 5. Show Telegram

**Nói:**
> "Khi có sự cố nghiêm trọng, hệ thống gửi cảnh báo qua Telegram"

**Làm:**
1. Mở Telegram
2. Show messages từ bot

---

## 💡 TIPS

1. **Nếu chạy local:**
   - Đảm bảo API đang chạy: `npm run dev`
   - Dùng: `http://localhost:3001`

2. **Nếu deploy lên GCP:**
   - Lấy API URL từ Cloud Run
   - Dùng: `https://your-api-url.run.app`

3. **Nếu không thấy dữ liệu trong BigQuery:**
   - Đợi vài giây (functions cần thời gian xử lý)
   - Hoặc giải thích: "Dữ liệu sẽ xuất hiện sau khi functions xử lý xong"

---

## ✅ SẴN SÀNG DEMO!

Chạy script và show từng bước theo hướng dẫn trên!

