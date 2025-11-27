import { Injectable } from '@nestjs/common';
import { PubSubService } from '../common/pubsub.service';
import { LogIngestDto } from './dto/log-ingest.dto';

@Injectable()
export class LogService {
  constructor(private readonly pubSubService: PubSubService) {}

  async ingestLog(logDto: LogIngestDto) {
    const logData = {
      service_name: logDto.service_name,
      severity: logDto.severity,
      log_message: logDto.log_message,
      metadata: logDto.metadata || {},
      timestamp: logDto.timestamp || new Date().toISOString(),
    };

    const messageId = await this.pubSubService.publishRawLog(logData);

    return {
      success: true,
      message: 'Log ingested successfully',
      messageId: messageId,
      timestamp: new Date().toISOString(),
    };
  }
}

