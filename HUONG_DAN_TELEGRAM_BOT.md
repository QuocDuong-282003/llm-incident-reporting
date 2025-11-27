# 🤖 HƯỚNG DẪN SETUP TELEGRAM BOT

## 🎯 MỤC TIÊU

Setup Telegram Bot để hệ thống tự động gửi cảnh báo khi phát hiện sự cố nghiêm trọng.

---

## 📋 BƯỚC 1: TẠO TELEGRAM BOT

### 1.1. Mở Telegram và tìm BotFather

1. **Mở ứng dụng Telegram** trên điện thoại hoặc web: https://web.telegram.org

2. **Tìm BotFather:**
   - Click vào ô tìm kiếm
   - Gõ: `@BotFather`
   - Click vào kết quả (có biểu tượng ✅ xanh)

### 1.2. Tạo Bot mới

1. **Gửi lệnh:**
   ```
   /newbot
   ```

2. **Làm theo hướng dẫn:**
   - BotFather sẽ hỏi tên bot → Gõ tên (ví dụ: `Incident Alert Bot`)
   - BotFather sẽ hỏi username bot → Gõ username (phải kết thúc bằng `bot`, ví dụ: `incident_alert_bot`)
   - BotFather sẽ trả về **Bot Token** (dạng: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

3. **Lưu Bot Token lại** (sẽ dùng ở bước sau)

---

## 📋 BƯỚC 2: LẤY CHAT ID

### 2.1. Cách 1: Dùng @userinfobot (Dễ nhất)

1. **Tìm bot:**
   - Tìm: `@userinfobot`
   - Click vào và chọn "Start"

2. **Bot sẽ trả về thông tin:**
   - Tìm dòng `Id:` → Đó là Chat ID của bạn
   - Copy Chat ID (ví dụ: `123456789`)

### 2.2. Cách 2: Dùng @getidsbot

1. **Tìm bot:**
   - Tìm: `@getidsbot`
   - Click "Start"

2. **Bot sẽ trả về Chat ID**

### 2.3. Cách 3: Gửi message cho bot của bạn

1. **Tìm bot bạn vừa tạo** (ví dụ: `@incident_alert_bot`)

2. **Click "Start"** để bắt đầu chat

3. **Gửi bất kỳ message nào** (ví dụ: `/start`)

4. **Lấy Chat ID từ API:**
   - Truy cập: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
   - Thay `<YOUR_BOT_TOKEN>` bằng Bot Token bạn đã lấy
   - Tìm `"chat":{"id":123456789}` → Đó là Chat ID

---

## 📋 BƯỚC 3: TEST BOT

### 3.1. Test gửi message

Mở trình duyệt hoặc dùng curl:

```powershell
$BOT_TOKEN = "YOUR_BOT_TOKEN"
$CHAT_ID = "YOUR_CHAT_ID"

curl "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=Test message"
```

Nếu thành công, bạn sẽ nhận được message trong Telegram.

---

## 📋 BƯỚC 4: UPDATE CLOUD FUNCTION

### 4.1. Update Environment Variables

Chạy lệnh này trong PowerShell:

```powershell
$BOT_TOKEN = "YOUR_BOT_TOKEN"
$CHAT_ID = "YOUR_CHAT_ID"

gcloud functions deploy incidentAlerting `
  --gen2 `
  --region=asia-southeast1 `
  --update-env-vars="TELEGRAM_BOT_TOKEN=${BOT_TOKEN},TELEGRAM_CHAT_ID=${CHAT_ID}"
```

**Lưu ý:** Thay `YOUR_BOT_TOKEN` và `YOUR_CHAT_ID` bằng giá trị thật của bạn.

---

## 📋 BƯỚC 5: TEST FUNCTION

### 5.1. Test function

```powershell
# Lấy URL của function
$URL = gcloud functions describe incidentAlerting --gen2 --region=asia-southeast1 --format="value(serviceConfig.uri)"

# Test
curl $URL
```

### 5.2. Kiểm tra Telegram

- Mở Telegram
- Kiểm tra xem có nhận được alert không (nếu có sự cố vượt ngưỡng)

---

## ✅ CHECKLIST

- [ ] Đã tạo Telegram Bot với BotFather
- [ ] Đã lấy Bot Token
- [ ] Đã lấy Chat ID
- [ ] Đã test gửi message thành công
- [ ] Đã update Cloud Function với credentials
- [ ] Đã test function và nhận được alert

---

## 🐛 TROUBLESHOOTING

### Lỗi: "Unauthorized"
→ Kiểm tra Bot Token đúng chưa

### Lỗi: "Chat not found"
→ Kiểm tra Chat ID đúng chưa
→ Đảm bảo đã gửi `/start` cho bot

### Lỗi: "Bad Request"
→ Kiểm tra format của Bot Token và Chat ID
→ Bot Token: `123456789:ABCdef...`
→ Chat ID: `123456789` (số nguyên)

### Không nhận được message
→ Kiểm tra bot đã được start chưa
→ Kiểm tra Chat ID đúng chưa
→ Kiểm tra function logs: `gcloud functions logs read incidentAlerting --gen2 --region=asia-southeast1`

---

## 📝 TÓM TẮT NHANH

1. **Tạo Bot:** Telegram → Tìm `@BotFather` → `/newbot` → Lấy Bot Token
2. **Lấy Chat ID:** Tìm `@userinfobot` → Start → Copy Chat ID
3. **Test:** Gửi message test
4. **Update Function:** `gcloud functions deploy incidentAlerting --update-env-vars="TELEGRAM_BOT_TOKEN=...,TELEGRAM_CHAT_ID=..."`
5. **Test:** Gọi function và kiểm tra Telegram

---

## 🔗 LINKS HỮU ÍCH

- **BotFather:** https://t.me/botfather
- **userinfobot:** https://t.me/userinfobot
- **Telegram Bot API:** https://core.telegram.org/bots/api

---

**Sẵn sàng bắt đầu? Bắt đầu từ Bước 1!** 🚀

