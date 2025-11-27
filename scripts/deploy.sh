#!/bin/bash

# Deployment script for LLM-Driven Incident Reporting System
# Make sure you have gcloud CLI installed and authenticated

set -e

PROJECT_ID=${GCP_PROJECT_ID:-"your-project-id"}
REGION=${GCP_REGION:-"asia-southeast1"}

echo "🚀 Deploying LLM-Driven Incident Reporting System to GCP"
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"

# Set GCP project
gcloud config set project $PROJECT_ID

# Enable required APIs
echo "📦 Enabling required GCP APIs..."
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudscheduler.googleapis.com
gcloud services enable sheets.googleapis.com

# Create Pub/Sub topics
echo "📨 Creating Pub/Sub topics..."
gcloud pubsub topics create raw-app-logs || echo "Topic raw-app-logs already exists"
gcloud pubsub topics create clean-app-logs || echo "Topic clean-app-logs already exists"

# Deploy Cloud Functions
echo "☁️ Deploying Cloud Functions..."

# Log Processing Function (Pub/Sub trigger)
echo "  → Deploying log-processing..."
cd cloud-functions/log-processing
npm install
gcloud functions deploy logProcessing \
  --gen2 \
  --runtime=nodejs18 \
  --region=$REGION \
  --source=. \
  --entry-point=logProcessing \
  --trigger-topic=raw-app-logs \
  --set-env-vars="GCP_PROJECT_ID=$PROJECT_ID,PUBSUB_CLEAN_LOGS_TOPIC=clean-app-logs"
cd ../..

# LLM Analysis Function (Pub/Sub trigger)
echo "  → Deploying llm-analysis..."
cd cloud-functions/llm-analysis
npm install
gcloud functions deploy llmAnalysis \
  --gen2 \
  --runtime=nodejs18 \
  --region=$REGION \
  --source=. \
  --entry-point=llmAnalysis \
  --trigger-topic=clean-app-logs \
  --set-env-vars="GCP_PROJECT_ID=$PROJECT_ID,BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,LLM_PROVIDER=mock"
cd ../..

# Incident Reporting Function (HTTP trigger for Cloud Scheduler)
echo "  → Deploying incident-reporting..."
cd cloud-functions/incident-reporting
npm install
gcloud functions deploy incidentReporting \
  --gen2 \
  --runtime=nodejs18 \
  --region=$REGION \
  --source=. \
  --entry-point=incidentReporting \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars="GCP_PROJECT_ID=$PROJECT_ID,BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed"
cd ../..

# Incident Alerting Function (HTTP trigger)
echo "  → Deploying incident-alerting..."
cd cloud-functions/incident-alerting
npm install
gcloud functions deploy incidentAlerting \
  --gen2 \
  --runtime=nodejs18 \
  --region=$REGION \
  --source=. \
  --entry-point=incidentAlerting \
  --trigger-http \
  --allow-unauthenticated \
  --set-env-vars="GCP_PROJECT_ID=$PROJECT_ID,BIGQUERY_DATASET=incident_reporting,BIGQUERY_TABLE=Incidents_Analyzed,ALERT_THRESHOLD_COUNT=5,ALERT_TIME_WINDOW_MINUTES=15"
cd ../..

echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "1. Set up Cloud Scheduler for incident-reporting (hourly)"
echo "2. Set up Cloud Scheduler for incident-alerting (every 5 minutes)"
echo "3. Configure Google Sheets ID in incident-reporting function"
echo "4. Configure Telegram credentials in incident-alerting function"

