const functions = require('@google-cloud/functions-framework');
const { BigQuery } = require('@google-cloud/bigquery');
const { google } = require('googleapis');

const bigquery = new BigQuery({
    projectId: process.env.GCP_PROJECT_ID || 'your-project-id',
});

const datasetId = process.env.BIGQUERY_DATASET || 'incident_reporting';
const tableId = process.env.BIGQUERY_TABLE || 'Incidents_Analyzed';
const sheetId = process.env.GOOGLE_SHEETS_ID || '';
const sheetRange = process.env.GOOGLE_SHEETS_RANGE || 'Incident Report!A1';

/**
 * Cloud Function triggered by Cloud Scheduler (hourly)
 * Queries BigQuery for latest incidents and writes to Google Sheets
 */
exports.incidentReporting = functions.http('incidentReporting', async (req, res) => {
    try {
        console.log('Generating incident report...');

        // Query BigQuery for latest incidents (last hour)
        const query = `
      SELECT 
        timestamp,
        service_name,
        severity,
        incident_type,
        incident_summary,
        analyzed_at
      FROM \`${process.env.GCP_PROJECT_ID}.${datasetId}.${tableId}\`
      WHERE analyzed_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
      ORDER BY analyzed_at DESC
      LIMIT 100
    `;

        const [rows] = await bigquery.query({ query });
        console.log(`📈 Found ${rows.length} incidents in the last hour`);

        if (rows.length === 0) {
            return res.status(200).json({
                success: true,
                message: 'No new incidents to report',
                count: 0,
            });
        }

        // Prepare data for Google Sheets
        const headers = ['Timestamp', 'Service Name', 'Severity', 'Incident Type', 'Summary', 'Analyzed At'];
        const values = rows.map((row) => [
            row.timestamp?.value || row.timestamp,
            row.service_name,
            row.severity,
            row.incident_type,
            row.incident_summary,
            row.analyzed_at?.value || row.analyzed_at,
        ]);

        // Authenticate with Google Sheets API
        const auth = new google.auth.GoogleAuth({
            scopes: ['https://www.googleapis.com/auth/spreadsheets'],
        });

        const authClient = await auth.getClient();
        const sheets = google.sheets({ version: 'v4', auth: authClient });

        // Clear existing data and write new data
        await sheets.spreadsheets.values.clear({
            spreadsheetId: sheetId,
            range: sheetRange,
        });

        // Write headers and data
        await sheets.spreadsheets.values.append({
            spreadsheetId: sheetId,
            range: sheetRange,
            valueInputOption: 'RAW',
            requestBody: {
                values: [headers, ...values],
            },
        });

        console.log(`Written ${rows.length} incidents to Google Sheets`);

        return res.status(200).json({
            success: true,
            message: 'Incident report generated successfully',
            incidentsCount: rows.length,
            sheetId: sheetId,
        });
    } catch (error) {
        console.error('Error generating report:', error);
        return res.status(500).json({
            error: 'Failed to generate incident report',
            details: error.message,
        });
    }
});
