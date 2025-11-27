// Script test API để demo
const axios = require('axios');

// Thay bằng endpoint API của bạn
// Nếu chạy local: http://localhost:3001
// Nếu deploy lên Cloud Run: https://your-api-url.run.app
// Thay bằng endpoint API của bạn
// Nếu chạy local: http://localhost:3001
// Nếu deploy lên Cloud Run: https://your-api-url.run.app
const API_ENDPOINT = process.env.API_ENDPOINT || "http://localhost:3001/log/ingest";

// Test logs để demo
const testLogs = [
  {
    service_name: "auth-service",
    severity: "error",
    log_message: "User login failed due to invalid credentials",
    metadata: {
      user_id: "12345",
      ip_address: "192.168.1.1",
      attempt_count: 3
    }
  },
  {
    service_name: "database-service",
    severity: "critical",
    log_message: "Database connection timeout after 30 seconds. Retrying connection...",
    metadata: {
      db_host: "db.example.com",
      retry_count: 3,
      error_code: "ETIMEDOUT"
    }
  },
  {
    service_name: "database-service",
    severity: "critical",
    log_message: "Database connection failed. Cannot establish connection to primary database",
    metadata: {
      db_host: "db.example.com",
      retry_count: 5
    }
  },
  {
    service_name: "api-gateway",
    severity: "warning",
    log_message: "Request processing time exceeded 5 seconds threshold",
    metadata: {
      endpoint: "/api/users",
      response_time_ms: 5234
    }
  }
];

async function sendTestLog(log, index) {
  try {
    console.log(`\n[${index + 1}/${testLogs.length}] Sending log: ${log.service_name} - ${log.severity}`);
    
    const res = await axios.post(API_ENDPOINT, log, {
      headers: {
        "Content-Type": "application/json"
      }
    });

    console.log(`Success! Message ID: ${res.data.messageId}`);
    return true;
  } catch (err) {
    console.error(`Error: ${err.message}`);
    if (err.response) {
      console.error(`   Status: ${err.response.status}`);
      console.error(`   Data: ${JSON.stringify(err.response.data)}`);
    }
    return false;
  }
}

async function runDemo() {
  console.log("========================================");
  console.log("  DEMO: LLM INCIDENT REPORTING SYSTEM");
  console.log("========================================");
  console.log(`\nAPI Endpoint: ${API_ENDPOINT}`);
  console.log(`Sending ${testLogs.length} test logs...\n`);

  let successCount = 0;
  for (let i = 0; i < testLogs.length; i++) {
    const success = await sendTestLog(testLogs[i], i);
    if (success) successCount++;
    
    // Đợi 2 giây giữa các request
    if (i < testLogs.length - 1) {
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }

  console.log("\n========================================");
  console.log(`Demo completed! ${successCount}/${testLogs.length} logs sent successfully`);
  console.log("========================================");
  console.log("\nNext steps:");
  console.log("1. Check BigQuery Console for analyzed incidents");
  console.log("2. Check Google Sheets for report (if configured)");
  console.log("3. Check Telegram for alerts (if configured)");
  console.log("\n");
}

// Chạy demo
runDemo().catch(console.error);

