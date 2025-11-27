#!/bin/bash

# Setup Cloud Scheduler jobs for automated reporting and alerting

set -e

PROJECT_ID=${GCP_PROJECT_ID:-"your-project-id"}
REGION=${GCP_REGION:-"asia-southeast1"}

# Get function URLs
REPORTING_URL=$(gcloud functions describe incidentReporting --gen2 --region=$REGION --format="value(serviceConfig.uri)")
ALERTING_URL=$(gcloud functions describe incidentAlerting --gen2 --region=$REGION --format="value(serviceConfig.uri)")

echo "📅 Setting up Cloud Scheduler jobs..."

# Create hourly reporting job
echo "  → Creating hourly incident reporting job..."
gcloud scheduler jobs create http incident-reporting-hourly \
  --location=$REGION \
  --schedule="0 * * * *" \
  --uri="$REPORTING_URL" \
  --http-method=GET \
  --time-zone="UTC" \
  || echo "Job incident-reporting-hourly already exists"

# Create 5-minute alerting job
echo "  → Creating 5-minute alerting job..."
gcloud scheduler jobs create http incident-alerting-5min \
  --location=$REGION \
  --schedule="*/5 * * * *" \
  --uri="$ALERTING_URL" \
  --http-method=GET \
  --time-zone="UTC" \
  || echo "Job incident-alerting-5min already exists"

echo "✅ Cloud Scheduler jobs created!"
echo ""
echo "Jobs:"
echo "  - incident-reporting-hourly: Runs every hour"
echo "  - incident-alerting-5min: Runs every 5 minutes"

