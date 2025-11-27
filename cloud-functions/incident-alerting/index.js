const functions = require('@google-cloud/functions-framework');
const { BigQuery } = require('@google-cloud/bigquery');
const axios = require('axios');

const bigquery = new BigQuery({
  projectId: process.env.GCP_PROJECT_ID || 'your-project-id',
});

const datasetId = process.env.BIGQUERY_DATASET || 'incident_reporting';
const tableId = process.env.BIGQUERY_TABLE || 'Incidents_Analyzed';

const telegramBotToken = process.env.TELEGRAM_BOT_TOKEN || '';
const telegramChatId = process.env.TELEGRAM_CHAT_ID || '';
const alertThreshold = parseInt(process.env.ALERT_THRESHOLD_COUNT || '5', 10);
const alertTimeWindow = parseInt(process.env.ALERT_TIME_WINDOW_MINUTES || '15', 10);

/**
 * Send alert to Telegram
 */
async function sendTelegramAlert(message) {
  if (!telegramBotToken || !telegramChatId) {
    console.warn('Telegram credentials not configured, skipping alert');
    return;
  }

  try {
    const url = `https://api.telegram.org/bot${telegramBotToken}/sendMessage`;
    await axios.post(url, {
      chat_id: telegramChatId,
      text: `*INCIDENT ALERT*\n\n${message}`,
      parse_mode: 'Markdown',
    });
    console.log('Telegram alert sent successfully');
  } catch (error) {
    console.error('Error sending Telegram alert:', error.message);
    throw error;
  }
}

/**
 * Cloud Function for incident alerting
 * Checks BigQuery for critical incidents and sends Telegram alerts
 * Can be triggered by Cloud Scheduler (every 5 minutes) or HTTP
 */
exports.incidentAlerting = functions.http('incidentAlerting', async (req, res) => {
  try {
    console.log('🔔 Checking for critical incidents...');

    // Query BigQuery for Database Connectivity Issues in the last time window
    const query = `
      SELECT 
        COUNT(*) as incident_count,
        STRING_AGG(DISTINCT service_name) as affected_services,
        MAX(analyzed_at) as latest_incident
      FROM \`${process.env.GCP_PROJECT_ID}.${datasetId}.${tableId}\`
      WHERE 
        incident_type = 'Database Connectivity Issue'
        AND analyzed_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL ${alertTimeWindow} MINUTE)
    `;

    const [rows] = await bigquery.query({ query });
    const result = rows[0];
    const incidentCount = parseInt(result.incident_count, 10);

    console.log(`Found ${incidentCount} Database Connectivity Issues in the last ${alertTimeWindow} minutes`);

    if (incidentCount >= alertThreshold) {
      const alertMessage = `
*CRITICAL ALERT: Database Connectivity Issues Detected*

*Count:* ${incidentCount} incidents
⏰ *Time Window:* Last ${alertTimeWindow} minutes
🔴 *Threshold:* ${alertThreshold} incidents
📦 *Affected Services:* ${result.affected_services || 'Unknown'}
🕐 *Latest Incident:* ${result.latest_incident?.value || result.latest_incident || 'Unknown'}

*Action Required:* Immediate investigation needed!
      `.trim();

      await sendTelegramAlert(alertMessage);

      return res.status(200).json({
        success: true,
        alertSent: true,
        incidentCount: incidentCount,
        threshold: alertThreshold,
        message: 'Critical alert sent to Telegram',
      });
    }

    return res.status(200).json({
      success: true,
      alertSent: false,
      incidentCount: incidentCount,
      threshold: alertThreshold,
      message: 'No critical incidents detected',
    });
  } catch (error) {
    console.error('Error checking alerts:', error);
    return res.status(500).json({
      error: 'Failed to check incidents',
      details: error.message,
    });
  }
});

