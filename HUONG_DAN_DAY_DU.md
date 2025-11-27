# 🚀 HƯỚNG DẪN ĐẦY ĐỦ - UPDATE & TEST

## 📋 THÔNG TIN CỦA BẠN

### ✅ Telegram Bot:
- **Bot Token:** `8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA`
- **Chat ID:** `5804844515`
- **Test URL:** https://api.telegram.org/bot8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA/getUpdates

### ✅ Google Sheets:
- **Sheet ID:** `1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc`
- **Link:** https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit

---

## 🔧 BƯỚC 1: TEST CREDENTIALS (TRƯỚC KHI UPDATE)

Test xem credentials có hoạt động không:

```powershell
.\TEST_NHANH.ps1
```

**Kết quả mong đợi:**
- ✅ Telegram: Nhận được test message trong Telegram
- ✅ Google Sheets: Hiển thị Sheet ID và URL

---

## 🚀 BƯỚC 2: UPDATE CREDENTIALS VÀO CLOUD FUNCTIONS

Chạy script tự động:

```powershell
.\UPDATE_CREDENTIALS.ps1
```

**Script sẽ:**
1. Update `GOOGLE_SHEETS_ID` vào `incidentReporting` function
2. Update `TELEGRAM_BOT_TOKEN` và `TELEGRAM_CHAT_ID` vào `incidentAlerting` function

**Thời gian:** ~2-3 phút mỗi function

---

## 🧪 BƯỚC 3: TEST CLOUD FUNCTIONS

Sau khi update xong, test functions:

```powershell
.\TEST_CLOUD_FUNCTIONS.ps1
```

**Script sẽ:**
1. Lấy URLs của 2 functions
2. Test Reporting function (gọi HTTP GET)
3. Test Alerting function (gọi HTTP GET)

---

## 📊 BƯỚC 4: KIỂM TRA KẾT QUẢ

### 1. Google Sheets

Mở link:
https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit

**Kiểm tra:**
- Có header row: `Timestamp | Project | Severity | Description`
- Có dữ liệu incidents được ghi vào (sau khi Reporting function chạy)

**Trigger Reporting function thủ công:**
```powershell
$URL = gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
curl $URL
```

### 2. Telegram

**Kiểm tra:**
- Mở Telegram app
- Tìm bot của bạn
- Xem có nhận được alerts không (khi có sự cố vượt ngưỡng)

**Test thủ công:**
```powershell
curl "https://api.telegram.org/bot8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA/sendMessage?chat_id=5804844515&text=Test alert"
```

### 3. BigQuery

Mở link:
https://console.cloud.google.com/bigquery?project=llm-incident-duong-2024

**Query:**
```sql
SELECT * FROM `llm-incident-duong-2024.incident_reporting.Incidents_Analyzed` 
ORDER BY analyzed_at DESC 
LIMIT 10
```

---

## 🔄 FLOW HOẠT ĐỘNG

```
1. API nhận log → Pub/Sub (raw-app-logs)
   ↓
2. log-processing → normalize → Pub/Sub (clean-app-logs)
   ↓
3. llm-analysis → analyze → BigQuery (Incidents_Analyzed)
   ↓
4. incidentReporting (Cloud Scheduler hourly) → Google Sheets
   ↓
5. incidentAlerting (Cloud Scheduler every 15min) → Telegram (nếu vượt ngưỡng)
```

---

## 📝 CHECKLIST

- [ ] Đã test credentials (`TEST_NHANH.ps1`)
- [ ] Đã update credentials vào Cloud Functions (`UPDATE_CREDENTIALS.ps1`)
- [ ] Đã test Cloud Functions (`TEST_CLOUD_FUNCTIONS.ps1`)
- [ ] Đã kiểm tra Google Sheets có dữ liệu
- [ ] Đã kiểm tra Telegram có nhận alerts
- [ ] Đã kiểm tra BigQuery có dữ liệu

---

## 🆘 TROUBLESHOOTING

### Lỗi: Function không deploy được

```powershell
# Check xem function có tồn tại không
gcloud functions list --gen2 --region=asia-southeast1

# Check logs
gcloud functions logs read incidentReporting --gen2 --region=asia-southeast1 --limit=10
```

### Lỗi: Telegram không nhận message

1. Check bot token đúng chưa
2. Check chat ID đúng chưa (từ getUpdates API)
3. Test trực tiếp: `.\TEST_NHANH.ps1`

### Lỗi: Google Sheets không có dữ liệu

1. Check Sheet ID đúng chưa
2. Check Service Account có quyền edit sheet không
3. Trigger function thủ công và check logs

---

## 🎯 NEXT STEPS

Sau khi hoàn thành:

1. **Demo:** Chạy `.\demo-test-api.ps1` để gửi test logs
2. **Monitor:** Xem logs trong Cloud Console
3. **Submit:** Chuẩn bị nộp bài test

**Chúc bạn thành công! 🚀**

