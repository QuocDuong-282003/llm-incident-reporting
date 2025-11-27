import * as functions from '@google-cloud/functions-framework';
import { BigQuery } from '@google-cloud/bigquery';
import axios from 'axios';

const bigquery = new BigQuery({
  projectId: process.env.GCP_PROJECT_ID || 'your-project-id',
});

const datasetId = process.env.BIGQUERY_DATASET || 'incident_reporting';
const tableId = process.env.BIGQUERY_TABLE || 'Incidents_Analyzed';

interface CleanLog {
  timestamp: string;
  service_name: string;
  severity: string;
  full_log_text: string;
}

interface IncidentAnalysis {
  timestamp: string;
  service_name: string;
  severity: string;
  full_log_text: string;
  incident_type: string;
  incident_summary: string;
  analyzed_at: string;
}

/**
 * Analyze log using LLM (Mock/Gemini/OpenAI)
 */
async function analyzeLogWithLLM(log: CleanLog): Promise<{ type: string; summary: string }> {
  const provider = process.env.LLM_PROVIDER || 'mock';

  if (provider === 'mock') {
    // Mock LLM analysis
    const logText = log.full_log_text.toLowerCase();
    
    let incidentType = 'General Error';
    if (logText.includes('auth') || logText.includes('login') || logText.includes('token')) {
      incidentType = 'Authentication Error';
    } else if (logText.includes('database') || logText.includes('db') || logText.includes('connection')) {
      incidentType = 'Database Connectivity Issue';
    } else if (logText.includes('timeout') || logText.includes('slow')) {
      incidentType = 'Performance Issue';
    } else if (logText.includes('memory') || logText.includes('oom')) {
      incidentType = 'Resource Exhaustion';
    }

    const summary = `Detected ${incidentType} in ${log.service_name}. Severity: ${log.severity}. Requires immediate attention.`;

    return { type: incidentType, summary };
  }

  if (provider === 'openai') {
    const prompt = `Analyze this log entry and provide:
1. Incident Type (one of: Authentication Error, Database Connectivity Issue, Performance Issue, Resource Exhaustion, General Error)
2. A 1-2 sentence summary of the cause and impact

Log Entry:
Service: ${log.service_name}
Severity: ${log.severity}
Log: ${log.full_log_text}

Respond in JSON format: {"type": "...", "summary": "..."}`;

    try {
      const response = await axios.post(
        'https://api.openai.com/v1/chat/completions',
        {
          model: 'gpt-3.5-turbo',
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.3,
        },
        {
          headers: {
            Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
            'Content-Type': 'application/json',
          },
        }
      );

      const content = response.data.choices[0].message.content;
      const parsed = JSON.parse(content);
      return { type: parsed.type, summary: parsed.summary };
    } catch (error) {
      console.error('OpenAI API error:', error);
      throw error;
    }
  }

  if (provider === 'gemini') {
    const prompt = `Analyze this log entry and provide:
1. Incident Type (one of: Authentication Error, Database Connectivity Issue, Performance Issue, Resource Exhaustion, General Error)
2. A 1-2 sentence summary of the cause and impact

Log Entry:
Service: ${log.service_name}
Severity: ${log.severity}
Log: ${log.full_log_text}

Respond in JSON format: {"type": "...", "summary": "..."}`;

    try {
      const response = await axios.post(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${process.env.GEMINI_API_KEY}`,
        {
          contents: [{
            parts: [{ text: prompt }],
          }],
        }
      );

      const content = response.data.candidates[0].content.parts[0].text;
      const parsed = JSON.parse(content);
      return { type: parsed.type, summary: parsed.summary };
    } catch (error) {
      console.error('Gemini API error:', error);
      throw error;
    }
  }

  throw new Error(`Unsupported LLM provider: ${provider}`);
}

/**
 * Cloud Function triggered by Pub/Sub (clean-app-logs)
 * Analyzes logs using LLM and stores results in BigQuery
 */
export const llmAnalysis = functions.cloudEvent('llmAnalysis', async (cloudEvent: any) => {
  try {
    // Pub/Sub Cloud Event format
    const message = cloudEvent.data?.message || cloudEvent.data;
    if (!message || !message.data) {
      console.error('Invalid Pub/Sub message format', JSON.stringify(cloudEvent));
      throw new Error('Invalid message format');
    }

    // Decode base64 message
    let cleanLogData: string;
    if (typeof message.data === 'string') {
      cleanLogData = Buffer.from(message.data, 'base64').toString('utf-8');
    } else {
      cleanLogData = JSON.stringify(message.data);
    }
    
    const cleanLog: CleanLog = JSON.parse(cleanLogData);

    console.log('🔍 Analyzing log:', cleanLog);

    // Analyze with LLM
    const analysis = await analyzeLogWithLLM(cleanLog);

    // Prepare BigQuery row
    const incidentAnalysis: IncidentAnalysis = {
      timestamp: cleanLog.timestamp,
      service_name: cleanLog.service_name,
      severity: cleanLog.severity,
      full_log_text: cleanLog.full_log_text,
      incident_type: analysis.type,
      incident_summary: analysis.summary,
      analyzed_at: new Date().toISOString(),
    };

    // Ensure dataset and table exist
    const dataset = bigquery.dataset(datasetId);
    const [datasetExists] = await dataset.exists();
    
    if (!datasetExists) {
      await bigquery.createDataset(datasetId);
      console.log(`✅ Created dataset: ${datasetId}`);
    }

    const table = dataset.table(tableId);
    const [tableExists] = await table.exists();
    
    if (!tableExists) {
      const schema = [
        { name: 'timestamp', type: 'TIMESTAMP' },
        { name: 'service_name', type: 'STRING' },
        { name: 'severity', type: 'STRING' },
        { name: 'full_log_text', type: 'STRING' },
        { name: 'incident_type', type: 'STRING' },
        { name: 'incident_summary', type: 'STRING' },
        { name: 'analyzed_at', type: 'TIMESTAMP' },
      ];
      
      await table.create({ schema });
      console.log(`✅ Created table: ${tableId}`);
    }

    // Insert into BigQuery
    await table.insert([incidentAnalysis]);
    console.log(`✅ Stored analysis in BigQuery: ${analysis.type}`);
  } catch (error: any) {
    console.error('❌ Error analyzing log:', error);
    throw error;
  }
});

