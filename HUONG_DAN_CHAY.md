# 🚀 HƯỚNG DẪN CHẠY ĐƠN GIẢN

## Bước 1: Cài đặt (Chỉ cần làm 1 lần)

Mở Terminal/PowerShell trong thư mục project và chạy:

```bash
npm install
```

## Bước 2: Chạy Server

Sau khi cài đặt xong, chạy:

```bash
npm run dev
```

Bạn sẽ thấy:
```
🚀 Log Ingestion API running on port 3000
```

## Bước 3: Test API

Mở Terminal/PowerShell khác (giữ server đang chạy) và chạy:

### Test 1: Gửi log đơn giản
```bash
curl -X POST http://localhost:3000/log/ingest -H "Content-Type: application/json" -d "{\"service_name\":\"test-service\",\"severity\":\"error\",\"log_message\":\"Test log message\"}"
```

### Test 2: Gửi log với metadata
```bash
curl -X POST http://localhost:3000/log/ingest -H "Content-Type: application/json" -d "{\"service_name\":\"auth-service\",\"severity\":\"error\",\"log_message\":\"Failed to authenticate\",\"metadata\":{\"user_id\":\"123\"}}"
```

### Hoặc dùng file test có sẵn:
```bash
cd examples
# Sửa API_URL trong send-test-logs.sh nếu cần
bash send-test-logs.sh
```

## Kết quả mong đợi

Khi chạy local (không có GCP), bạn sẽ thấy:
- ✅ Server chạy trên port 3000
- ✅ Logs được in ra console (thay vì gửi lên Pub/Sub)
- ✅ API trả về success message

## Lưu ý

- **Chạy local**: Không cần GCP credentials, chỉ test API
- **Chạy với GCP**: Cần setup GCP project và credentials (xem DEPLOYMENT.md)

## Troubleshooting

### Lỗi "Cannot find module"
→ Chạy lại `npm install`

### Lỗi port 3000 đã được sử dụng
→ Đổi port trong file `.env` hoặc kill process đang dùng port 3000

### Lỗi TypeScript
→ Đảm bảo đã cài `typescript` và `ts-node-dev`

