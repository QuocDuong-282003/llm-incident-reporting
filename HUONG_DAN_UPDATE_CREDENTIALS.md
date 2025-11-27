# 🔧 HƯỚNG DẪN UPDATE CREDENTIALS

## 📋 THÔNG TIN CỦA BẠN

### Telegram Bot:
- **Bot Token:** `8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA`
- **Chat ID:** `5804844515`

### Google Sheets:
- **Sheet ID:** `1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc`
- **Link:** https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit

---

## 🚀 CÁCH UPDATE (TỰ ĐỘNG)

### Chạy script tự động:

```powershell
.\UPDATE_CREDENTIALS.ps1
```

Script sẽ tự động update cả 2 functions với credentials của bạn.

---

## 🚀 CÁCH UPDATE (THỦ CÔNG)

### 1. Update Google Sheets ID

```powershell
$SHEET_ID = "1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc"

gcloud functions deploy incidentReporting `
  --gen2 `
  --region=asia-southeast1 `
  --update-env-vars="GOOGLE_SHEETS_ID=${SHEET_ID}"
```

### 2. Update Telegram Credentials

```powershell
$BOT_TOKEN = "8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA"
$CHAT_ID = "5804844515"

gcloud functions deploy incidentAlerting `
  --gen2 `
  --region=asia-southeast1 `
  --update-env-vars="TELEGRAM_BOT_TOKEN=${BOT_TOKEN},TELEGRAM_CHAT_ID=${CHAT_ID}"
```

---

## 🧪 TEST CREDENTIALS

### Test Telegram:

```powershell
.\TEST_CREDENTIALS.ps1
```

Hoặc test thủ công:

```powershell
$BOT_TOKEN = "8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA"
$CHAT_ID = "5804844515"

curl "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=Test message"
```

Nếu thành công, bạn sẽ nhận được message trong Telegram.

---

## ✅ SAU KHI UPDATE

### 1. Test Reporting Function

```powershell
$URL = gcloud functions describe incidentReporting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
curl $URL
```

**Kiểm tra:** Mở Google Sheet và xem có dữ liệu được ghi vào không.

### 2. Test Alerting Function

```powershell
$URL = gcloud functions describe incidentAlerting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"
curl $URL
```

**Kiểm tra:** Xem Telegram có nhận được alert không (nếu có sự cố vượt ngưỡng).

---

## 📋 CHECKLIST

- [ ] Đã update Google Sheets ID vào `incidentReporting`
- [ ] Đã update Telegram credentials vào `incidentAlerting`
- [ ] Đã test Telegram bot (gửi message thành công)
- [ ] Đã test Reporting function (có dữ liệu trong Sheet)
- [ ] Đã test Alerting function (có alert trong Telegram)

---

## 🔗 LINKS QUAN TRỌNG

1. **Google Sheets:**
   https://docs.google.com/spreadsheets/d/1wt6JKQpTqgILQhgUNJEEAjFVixW8f_B-aS1MP_UHgIc/edit

2. **Telegram Bot:**
   - Bot Token: `8596284014:AAGCZfPe0yURLSMsxMfbhIMFgnhRxsltHmA`
   - Chat ID: `5804844515`

3. **BigQuery Console:**
   https://console.cloud.google.com/bigquery?project=llm-incident-duong-2024

---

**Sẵn sàng update! Chạy script:** `.\UPDATE_CREDENTIALS.ps1` 🚀

