const { PubSub } = require('@google-cloud/pubsub');
const functions = require('@google-cloud/functions-framework');

const pubsub = new PubSub({
  projectId: process.env.GCP_PROJECT_ID || 'your-project-id',
});

const cleanLogsTopicName = process.env.PUBSUB_CLEAN_LOGS_TOPIC || 'clean-app-logs';

/**
 * Cloud Function triggered by Pub/Sub (raw-app-logs)
 * Normalizes raw logs and publishes to clean-app-logs topic
 */
exports.logProcessing = functions.cloudEvent('logProcessing', async (cloudEvent) => {
  try {
    // Pub/Sub Cloud Event format
    const message = cloudEvent.data?.message || cloudEvent.data;
    if (!message || !message.data) {
      console.error('Invalid Pub/Sub message format', JSON.stringify(cloudEvent));
      throw new Error('Invalid message format');
    }

    // Decode base64 message
    let rawLogData;
    if (typeof message.data === 'string') {
      rawLogData = Buffer.from(message.data, 'base64').toString('utf-8');
    } else {
      rawLogData = JSON.stringify(message.data);
    }
    
    const rawLog = JSON.parse(rawLogData);

    console.log('📥 Received raw log:', rawLog);

    // Normalize log to fixed fields
    const cleanLog = {
      timestamp: rawLog.timestamp || new Date().toISOString(),
      service_name: rawLog.service_name,
      severity: rawLog.severity,
      full_log_text: JSON.stringify({
        log_message: rawLog.log_message,
        metadata: rawLog.metadata || {},
        original_timestamp: rawLog.timestamp,
      }),
    };

    // Publish to clean-app-logs topic
    const cleanLogsTopic = pubsub.topic(cleanLogsTopicName);
    const [exists] = await cleanLogsTopic.exists();
    
    if (!exists) {
      await pubsub.createTopic(cleanLogsTopicName);
    }

    const messageId = await cleanLogsTopic.publishMessage({
      json: cleanLog,
    });

    console.log(`✅ Normalized and published to ${cleanLogsTopicName}: ${messageId}`);
  } catch (error) {
    console.error('❌ Error processing log:', error);
    throw error;
  }
});

