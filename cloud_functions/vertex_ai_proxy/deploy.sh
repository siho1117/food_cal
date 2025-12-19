#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# Vertex AI Proxy - Cloud Function Deployment Script
# ═══════════════════════════════════════════════════════════════
#
# This script deploys the Vertex AI proxy Cloud Function to GCP.
# The function uses Workload Identity for secure authentication.
#
# Prerequisites:
# 1. gcloud CLI installed and authenticated
# 2. Service account created: vertex-ai-food-app@geminiopti.iam.gserviceaccount.com
# 3. Service account has "Vertex AI User" role
# 4. Vertex AI API enabled
#
# ═══════════════════════════════════════════════════════════════

set -e  # Exit on error

# Configuration
PROJECT_ID="geminiopti"
REGION="us-central1"  # Iowa - Best for global users
FUNCTION_NAME="vertex-ai-proxy"
SERVICE_ACCOUNT="vertex-ai-food-app@geminiopti.iam.gserviceaccount.com"
RUNTIME="python311"
ENTRY_POINT="vertex_ai_proxy"
MEMORY="512MB"
TIMEOUT="60s"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Vertex AI Proxy - Cloud Function Deployment${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}ERROR: gcloud CLI not found. Please install it first.${NC}"
    echo "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "main.py" ] || [ ! -f "requirements.txt" ]; then
    echo -e "${RED}ERROR: main.py or requirements.txt not found.${NC}"
    echo "Please run this script from the cloud_functions/vertex_ai_proxy directory."
    exit 1
fi

echo -e "${YELLOW}Configuration:${NC}"
echo "  Project ID:      $PROJECT_ID"
echo "  Region:          $REGION"
echo "  Function Name:   $FUNCTION_NAME"
echo "  Service Account: $SERVICE_ACCOUNT"
echo "  Runtime:         $RUNTIME"
echo "  Memory:          $MEMORY"
echo "  Timeout:         $TIMEOUT"
echo ""

# Confirm deployment
read -p "Deploy the Cloud Function? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}Deploying Cloud Function...${NC}"
echo ""

# Deploy the function
gcloud functions deploy $FUNCTION_NAME \
    --gen2 \
    --runtime=$RUNTIME \
    --region=$REGION \
    --source=. \
    --entry-point=$ENTRY_POINT \
    --trigger-http \
    --allow-unauthenticated \
    --service-account=$SERVICE_ACCOUNT \
    --memory=$MEMORY \
    --timeout=$TIMEOUT \
    --set-env-vars=GCP_PROJECT=$PROJECT_ID \
    --project=$PROJECT_ID

# Check deployment status
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Deployment Successful!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Get the function URL
    FUNCTION_URL=$(gcloud functions describe $FUNCTION_NAME \
        --region=$REGION \
        --project=$PROJECT_ID \
        --format='value(serviceConfig.uri)')

    echo -e "${BLUE}Function URL:${NC}"
    echo "$FUNCTION_URL"
    echo ""

    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Copy the Function URL above"
    echo "2. Update your Flutter app's .env file:"
    echo "   VERTEX_CLOUD_FUNCTION_URL=$FUNCTION_URL"
    echo "3. Rebuild and test your Flutter app"
    echo ""

    echo -e "${BLUE}Testing the function:${NC}"
    echo "curl -X POST $FUNCTION_URL \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo "  -d '{\"contents\": [{\"role\": \"user\", \"parts\": [{\"text\": \"Hello\"}]}]}'"
    echo ""
else
    echo ""
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}  Deployment Failed!${NC}"
    echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Please check the error messages above and try again."
    exit 1
fi
