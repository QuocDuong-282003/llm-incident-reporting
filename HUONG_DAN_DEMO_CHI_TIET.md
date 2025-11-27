# 🎬 HƯỚNG DẪN DEMO CHI TIẾT

## 📋 CHUẨN BỊ TRƯỚC KHI DEMO

### 1. Mở các tab cần thiết

1. **BigQuery Console:**
   ```
   https://console.cloud.google.com/bigquery?project=llm-incident-duong-2024
   ```

2. **Google Sheets** (nếu đã setup):
   ```
   https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit
   ```

3. **Telegram** (nếu đã setup):
   - Mở app Telegram
   - Tìm bot của bạn
   - Test URL: https://api.telegram.org/bot8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA/getUpdates

4. **Terminal/PowerShell:**
   - Để chạy test script

---

## 🎯 DEMO FLOW (Từng bước)

### BƯỚC 1: Giới thiệu Kiến trúc (2 phút)

**Nói:**
> "Hệ thống này xử lý log sự cố tự động với LLM. Flow như sau:
> 1. API nhận log → Pub/Sub
> 2. Processing function chuẩn hóa log
> 3. LLM Analysis phân loại và tóm tắt
> 4. Lưu vào BigQuery
> 5. Tự động export báo cáo vào Google Sheets
> 6. Gửi cảnh báo qua Telegram khi có sự cố nghiêm trọng"

**Show:** Vẽ sơ đồ flow hoặc mở file `README.md` có sơ đồ

---

### BƯỚC 2: Demo API (3 phút)

**Nói:**
> "Bây giờ tôi sẽ gửi một số log test để demo flow"

**Làm:**
1. Mở Terminal/PowerShell
2. Chạy script:
   ```powershell
   .\demo-test-api.ps1
   ```
   Hoặc nếu có API URL:
   ```powershell
   $env:API_ENDPOINT="https://your-api-url.run.app"
   .\demo-test-api.ps1
   ```

3. **Show kết quả:**
   - ✅ Logs được gửi thành công
   - ✅ Message IDs được trả về

**Giải thích:**
> "API đã nhận log và publish lên Pub/Sub topic `raw-app-logs`"

---

### BƯỚC 3: Show BigQuery (3 phút)

**Nói:**
> "Bây giờ chúng ta sẽ xem dữ liệu đã được phân tích và lưu vào BigQuery"

**Làm:**
1. Mở BigQuery Console (đã mở ở Bước 1)
2. Click vào table `Incidents_Analyzed`
3. Click tab "Preview" hoặc "Query"
4. Chạy query:
   ```sql
   SELECT *
   FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed`
   ORDER BY analyzed_at DESC
   LIMIT 10
   ```

**Show:**
- ✅ Dữ liệu incidents đã được phân tích
- ✅ Cột `incident_type` (LLM đã phân loại)
- ✅ Cột `incident_summary` (LLM đã tóm tắt)

**Giải thích:**
> "LLM đã phân tích log và phân loại thành các loại sự cố, đồng thời tạo tóm tắt về nguyên nhân và tác động"

---

### BƯỚC 4: Show Google Sheets (2 phút)

**Nói:**
> "Hệ thống tự động export báo cáo vào Google Sheets hàng giờ"

**Làm:**
1. Mở Google Sheet "Incident Report"
2. **Show:**
   - ✅ Bảng báo cáo với headers
   - ✅ Dữ liệu incidents (nếu có)
   - ✅ Các cột: Timestamp, Service Name, Severity, Incident Type, Summary

**Giải thích:**
> "Cloud Scheduler chạy function `incidentReporting` mỗi giờ, query BigQuery và tự động ghi vào Google Sheets"

**Nếu chưa có dữ liệu:**
> "Báo cáo sẽ được tạo tự động khi Cloud Scheduler chạy (hàng giờ). Hoặc có thể trigger thủ công bằng cách gọi function URL"

---

### BƯỚC 5: Show Telegram Alerts (2 phút)

**Nói:**
> "Khi phát hiện sự cố nghiêm trọng, hệ thống tự động gửi cảnh báo qua Telegram"

**Làm:**
1. Mở Telegram app
2. Tìm bot của bạn
3. **Show:**
   - ✅ Messages cảnh báo (nếu có)
   - ✅ Format: "🚨 INCIDENT ALERT" với thông tin chi tiết

**Giải thích:**
> "Function `incidentAlerting` chạy mỗi 5 phút, kiểm tra BigQuery. Nếu số lượng 'Database Connectivity Issue' >= 5 trong 15 phút, sẽ gửi alert"

**Nếu chưa có alert:**
> "Alert sẽ được gửi khi có đủ số lượng sự cố vượt ngưỡng. Có thể test bằng cách gửi nhiều database errors"

---

### BƯỚC 6: Show Code Structure (2 phút)

**Nói:**
> "Để tôi show cấu trúc code"

**Làm:**
1. Mở VS Code/IDE
2. **Show:**
   - `src/` - NestJS API
   - `cloud-functions/` - 4 Cloud Functions
   - `README.md` - Documentation

**Giải thích:**
> "Code được tổ chức rõ ràng, có documentation đầy đủ, dễ maintain và extend"

---

## 📝 SCRIPT DEMO

### Script đã tạo:
1. `demo-test-api.js` - Node.js script
2. `demo-test-api.ps1` - PowerShell script

### Cách chạy:

**Local API:**
```powershell
# Đảm bảo API đang chạy: npm run dev
.\demo-test-api.ps1
# Nhập: http://localhost:3001
```

**Cloud Run API:**
```powershell
$env:API_ENDPOINT="https://your-api-url.run.app"
.\demo-test-api.ps1
```

---

## 🎯 TỔNG THỜI GIAN DEMO

- Giới thiệu: 2 phút
- Demo API: 3 phút
- Show BigQuery: 3 phút
- Show Google Sheets: 2 phút
- Show Telegram: 2 phút
- Show Code: 2 phút
- **Tổng: ~14 phút**

---

## 💡 TIPS KHI DEMO

1. **Chuẩn bị trước:**
   - Mở tất cả tabs cần thiết
   - Test script trước
   - Đảm bảo có dữ liệu trong BigQuery

2. **Nếu có lỗi:**
   - Giải thích đó là do chưa deploy hoặc chưa setup
   - Show code để chứng minh đã implement đúng

3. **Nhấn mạnh:**
   - ✅ Code đã viết đầy đủ
   - ✅ Architecture đúng yêu cầu
   - ✅ Documentation đầy đủ
   - ✅ Có thể deploy và chạy ngay

---

## ✅ CHECKLIST DEMO

- [ ] Đã mở BigQuery Console
- [ ] Đã mở Google Sheets (nếu có)
- [ ] Đã mở Telegram (nếu có)
- [ ] Đã test script demo
- [ ] Đã chuẩn bị giải thích flow
- [ ] Đã sẵn sàng show code

---

**Sẵn sàng demo!** 🎬

