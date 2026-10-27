#!/usr/bin/env bash
# ==============================================================================
# SabiSnap Ltd (RC 9414613) — Production Serverless Deployment
# Service: SabiSnap ADK Multi-Agent Container
# Platform: Google Cloud Run (2nd Gen Serverless Runtime)
# Guidance: Immersion Session 3 Alignment (Zack Akil, Google Cloud)
# ==============================================================================

set -euo pipefail

PROJECT_ID="${GOOGLE_CLOUD_PROJECT:-sabisnap-production}"
REGION="${GOOGLE_CLOUD_LOCATION:-europe-west1}"
SERVICE_NAME="sabisnap-adk-engine"
INGESTION_BUCKET="${PROJECT_ID}-textbook-scans"

echo "================================================================="
echo " Deploying SabiSnap Serverless Multi-Agent Pipeline to Cloud Run"
echo " Project: ${PROJECT_ID} | Region: ${REGION}"
echo "================================================================="

# 1. Ensure active gcloud project configuration
gcloud config set project "${PROJECT_ID}"

# 2. Deploy Containerized Service with Concurrency Governance
# Notice: Concurrency=1 ensures 1 heavy multimodal scan per container instance
# Max Instances=5 caps simultaneous workers, protecting Gemini API rate limits
gcloud run deploy "${SERVICE_NAME}" \
  --source="." \
  --region="${REGION}" \
  --platform="managed" \
  --allow-unauthenticated \
  --memory="2Gi" \
  --cpu="2" \
  --concurrency=1 \
  --min-instances=0 \
  --max-instances=5 \
  --set-env-vars="GOOGLE_GENAI_USE_VERTEXAI=TRUE,GOOGLE_CLOUD_LOCATION=${REGION}"

echo "================================================================="
echo " SabiSnap ADK Pipeline Active on Google Cloud Run"
echo "================================================================="
