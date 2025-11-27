import { Module } from '@nestjs/common';
import { LogController } from './log/log.controller';
import { LogService } from './log/log.service';
import { PubSubService } from './common/pubsub.service';

@Module({
  imports: [],
  controllers: [LogController],
  providers: [LogService, PubSubService],
})
export class AppModule {}

