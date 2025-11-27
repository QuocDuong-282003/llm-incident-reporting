import { Injectable, OnModuleInit } from '@nestjs/common';
import { PubSub } from '@google-cloud/pubsub';
import * as dotenv from 'dotenv';

dotenv.config();

@Injectable()
export class PubSubService implements OnModuleInit {
  private pubsub: PubSub;
  private rawLogsTopic: any;
  private projectId: string;
  private rawLogsTopicName: string;

  constructor() {
    this.projectId = process.env.GCP_PROJECT_ID || 'your-project-id';
    this.rawLogsTopicName = process.env.PUBSUB_RAW_LOGS_TOPIC || 'raw-app-logs';
    
    this.pubsub = new PubSub({
      projectId: this.projectId,
    });
  }

  async onModuleInit() {
    try {
      // Ensure topic exists
      this.rawLogsTopic = this.pubsub.topic(this.rawLogsTopicName);
      const [exists] = await this.rawLogsTopic.exists();
      
      if (!exists) {
        console.log(`Creating topic: ${this.rawLogsTopicName}`);
        await this.pubsub.createTopic(this.rawLogsTopicName);
        this.rawLogsTopic = this.pubsub.topic(this.rawLogsTopicName);
      }
      
      console.log(`✅ Pub/Sub topic ready: ${this.rawLogsTopicName}`);
    } catch (error: any) {
      console.warn('⚠️  Pub/Sub not available (running in local mode):', error.message);
      console.log('📝 Logs will be printed to console instead');
      // Don't throw - allow local testing without GCP
    }
  }

  async publishRawLog(logData: any): Promise<string> {
    try {
      if (!this.rawLogsTopic) {
        // Local mode - just log to console
        console.log('📤 [LOCAL MODE] Log received:', JSON.stringify(logData, null, 2));
        return 'local-message-id-' + Date.now();
      }
      
      const messageId = await this.rawLogsTopic.publishMessage({
        json: logData,
      });
      console.log(`📤 Published log to ${this.rawLogsTopicName}: ${messageId}`);
      return messageId;
    } catch (error: any) {
      // Fallback to local mode
      console.log('📤 [LOCAL MODE] Log received:', JSON.stringify(logData, null, 2));
      console.warn('⚠️  Pub/Sub error (using local mode):', error.message);
      return 'local-message-id-' + Date.now();
    }
  }
}

