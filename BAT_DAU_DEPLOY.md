# 🚀 BẮT ĐẦU DEPLOY LÊN GCP

## 📋 CHECKLIST TRƯỚC KHI BẮT ĐẦU

### ✅ Yêu cầu bắt buộc:
- [ ] Có GCP account (Google Cloud Platform)
- [ ] Có billing enabled (free tier đủ dùng)
- [ ] Đã cài gcloud CLI
- [ ] Đã login: `gcloud auth login`

### ✅ Kiểm tra nhanh:

Mở PowerShell và chạy:

```powershell
# 1. Kiểm tra gcloud
gcloud --version

# 2. Kiểm tra đã login chưa
gcloud auth list

# 3. Nếu chưa login, chạy:
gcloud auth login
```

---

## 🎯 2 CÁCH DEPLOY

### **CÁCH 1: Script tự động (Khuyến nghị)**

```powershell
.\deploy-gcp.ps1
```

Script sẽ:
- ✅ Kiểm tra prerequisites
- ✅ Tạo/setup GCP project
- ✅ Enable APIs
- ✅ Tạo Pub/Sub topics
- ✅ Deploy 4 Cloud Functions
- ✅ Setup Cloud Scheduler
- ✅ Tạo file config

**Thời gian:** ~10-15 phút

---

### **CÁCH 2: Manual từng bước**

Làm theo file: `HUONG_DAN_DEPLOY_GCP.md`

**Thời gian:** ~30-45 phút

---

## 📝 SAU KHI DEPLOY

### 1. Setup Google Sheets (Optional)

Xem hướng dẫn trong `HUONG_DAN_DEPLOY_GCP.md` - Bước 7

### 2. Setup Telegram Bot (Optional)

Xem hướng dẫn trong `HUONG_DAN_DEPLOY_GCP.md` - Bước 8

### 3. Test API

```powershell
# Lấy API URL (nếu deploy lên Cloud Run)
API_URL="https://your-api-url.run.app"

# Test
curl -X POST "${API_URL}/log/ingest" `
  -H "Content-Type: application/json" `
  -d '{\"service_name\":\"test\",\"severity\":\"error\",\"log_message\":\"Test\"}'
```

---

## 🐛 NẾU GẶP LỖI

### Lỗi: "gcloud not found"
→ Cài gcloud CLI: https://cloud.google.com/sdk/docs/install

### Lỗi: "Billing not enabled"
→ Vào GCP Console → Billing → Enable billing

### Lỗi: "Permission denied"
→ Kiểm tra Service Account roles

### Lỗi: "Project not found"
→ Tạo project mới hoặc kiểm tra Project ID

---

## 💰 CHI PHÍ

**Free tier đủ dùng cho test:**
- Cloud Functions: 2M invocations/tháng free
- Pub/Sub: 10GB messages/tháng free
- BigQuery: 10GB storage + 1TB queries/tháng free
- Cloud Scheduler: 3 jobs free

**Ước tính:** $0-5/tháng cho test

---

## ✅ SẴN SÀNG?

**Chạy lệnh này để bắt đầu:**

```powershell
.\deploy-gcp.ps1
```

**Hoặc làm manual:**

```powershell
# Đọc hướng dẫn chi tiết
notepad HUONG_DAN_DEPLOY_GCP.md
```

---

**Chúc bạn deploy thành công!** 🚀

