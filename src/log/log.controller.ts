import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { LogService } from './log.service';
import { LogIngestDto } from './dto/log-ingest.dto';

@Controller('log')
export class LogController {
    constructor(private readonly logService: LogService) { }

    @Post('ingest')
    @HttpCode(HttpStatus.ACCEPTED)
    async ingestLog(@Body() logDto: LogIngestDto) {
        return await this.logService.ingestLog(logDto);
    }
}

