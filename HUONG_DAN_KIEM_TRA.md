# ✅ HƯỚNG DẪN KIỂM TRA HỆ THỐNG

## 🎯 Mục tiêu kiểm tra:
1. ✅ API server chạy được
2. ✅ API nhận được log và xử lý
3. ✅ Trả về response đúng format

---

## 📋 CÁC BƯỚC KIỂM TRA:

### **BƯỚC 1: Chạy Server**

Mở **PowerShell** hoặc **CMD** trong thư mục project và chạy:

```powershell
npm run dev
```

**Kết quả mong đợi:**
```
🚀 Log Ingestion API running on port 3000
⚠️  Pub/Sub not available (running in local mode)
📝 Logs will be printed to console instead
```

**✅ Nếu thấy dòng này = Server đã chạy thành công!**

**⚠️ GIỮ CỬA SỔ NÀY MỞ** (đừng đóng)

---

### **BƯỚC 2: Test API (Mở PowerShell/CMD MỚI)**

Mở **PowerShell/CMD mới** (giữ server đang chạy) và chạy:

**Cách 1: Dùng script tự động (Dễ nhất)**
```powershell
.\test-simple.ps1
```

**Cách 2: Test thủ công từng lệnh**

#### Test 1: Authentication Error
```powershell
curl -X POST http://localhost:3000/log/ingest -H "Content-Type: application/json" -d "{\"service_name\":\"auth-service\",\"severity\":\"error\",\"log_message\":\"Failed to authenticate user\"}"
```

#### Test 2: Database Error
```powershell
curl -X POST http://localhost:3000/log/ingest -H "Content-Type: application/json" -d "{\"service_name\":\"database-service\",\"severity\":\"critical\",\"log_message\":\"Database connection timeout\"}"
```

#### Test 3: Performance Issue
```powershell
curl -X POST http://localhost:3000/log/ingest -H "Content-Type: application/json" -d "{\"service_name\":\"api-gateway\",\"severity\":\"warning\",\"log_message\":\"Request processing time exceeded 5 seconds\"}"
```

---

### **BƯỚC 3: Kiểm tra kết quả**

**Trong cửa sổ Server (Bước 1), bạn sẽ thấy:**
```
📤 [LOCAL MODE] Log received: {
  "service_name": "auth-service",
  "severity": "error",
  "log_message": "Failed to authenticate user",
  ...
}
```

**Trong cửa sổ Test (Bước 2), bạn sẽ thấy:**
```json
{
  "success": true,
  "message": "Log ingested successfully",
  "messageId": "local-message-id-1234567890",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

## ✅ CHECKLIST HOÀN THÀNH:

- [ ] Server chạy được (thấy dòng "🚀 Log Ingestion API running")
- [ ] API nhận được request (thấy log trong server)
- [ ] API trả về `success: true`
- [ ] Test được ít nhất 3 loại log khác nhau

---

## 🐛 NẾU GẶP LỖI:

### Lỗi: "Cannot GET /"
→ **Bình thường!** API chỉ có endpoint POST /log/ingest

### Lỗi: "ECONNREFUSED" hoặc "Connection refused"
→ Server chưa chạy hoặc đã tắt. Chạy lại `npm run dev`

### Lỗi: "Port 3000 already in use"
→ Port 3000 đang được dùng. Đổi port trong `.env` hoặc kill process:
```powershell
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Lỗi PowerShell: "Execution Policy"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 🎉 HOÀN THÀNH!

Nếu tất cả test đều pass = **Hệ thống hoạt động tốt!** ✅

Bạn có thể:
- ✅ Gửi log qua API
- ✅ Xem log trong console
- ✅ API trả về response đúng

**Lưu ý:** Đang chạy ở **LOCAL MODE** (không cần GCP). Để deploy lên GCP, xem file `DEPLOYMENT.md`

