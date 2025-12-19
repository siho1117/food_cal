# Vertex AI Proxy Cloud Function

Secure backend proxy for Flutter mobile app to access Google Cloud Vertex AI without embedding service account credentials.

## Architecture

```
Flutter App (Mobile)
    ↓ HTTPS
Cloud Function (this)
    ↓ Workload Identity
Vertex AI API
```

**Key Security Benefits:**
- No service account keys in mobile app
- No credentials in source code
- Uses GCP Workload Identity for authentication
- Automatic token refresh by Google
- Centralized API access control

---

## Files

| File | Purpose |
|------|---------|
| `main.py` | Cloud Function entry point |
| `requirements.txt` | Python dependencies |
| `deploy.sh` | Deployment script |
| `README.md` | This file |

---

## Prerequisites

Before deploying, ensure:

1. **gcloud CLI installed**
   ```bash
   gcloud --version
   ```

2. **Authenticated with GCP**
   ```bash
   gcloud auth login
   gcloud config set project geminiopti
   ```

3. **Vertex AI API enabled**
   ```bash
   gcloud services enable aiplatform.googleapis.com --project=geminiopti
   ```

4. **Cloud Functions API enabled**
   ```bash
   gcloud services enable cloudfunctions.googleapis.com --project=geminiopti
   gcloud services enable cloudbuild.googleapis.com --project=geminiopti
   gcloud services enable artifactregistry.googleapis.com --project=geminiopti
   ```

5. **Service account created with proper role**
   ```bash
   # Check if service account exists
   gcloud iam service-accounts list --project=geminiopti | grep vertex-ai-food-app

   # Verify it has Vertex AI User role
   gcloud projects get-iam-policy geminiopti \
     --flatten="bindings[].members" \
     --filter="bindings.members:vertex-ai-food-app@geminiopti.iam.gserviceaccount.com"
   ```

---

## Deployment

### Quick Deploy

From this directory, run:

```bash
./deploy.sh
```

The script will:
1. Validate prerequisites
2. Deploy the function to `us-central1` (Iowa, USA - optimal for global users)
3. Attach the service account for Workload Identity
4. Display the function URL

### Manual Deploy

If you prefer manual deployment:

```bash
gcloud functions deploy vertex-ai-proxy \
  --gen2 \
  --runtime=python311 \
  --region=us-central1 \
  --source=. \
  --entry-point=vertex_ai_proxy \
  --trigger-http \
  --allow-unauthenticated \
  --service-account=vertex-ai-food-app@geminiopti.iam.gserviceaccount.com \
  --memory=512MB \
  --timeout=60s \
  --set-env-vars=GCP_PROJECT=geminiopti \
  --project=geminiopti
```

### Get Function URL

After deployment:

```bash
gcloud functions describe vertex-ai-proxy \
  --region=us-central1 \
  --project=geminiopti \
  --format='value(serviceConfig.uri)'
```

Example output:
```
https://vertex-ai-proxy-abc123-uc.a.run.app
```

---

## Configuration

### Region Selection

Currently set to: **`us-central1`** (Iowa, USA)

**Why us-central1 for global users?**
- Central location minimizes latency worldwide
- Most reliable Google Cloud region (highest availability)
- Best model availability - all Gemini models guaranteed
- Optimal for global CDN routing
- Cost-effective

**Alternative regions (if needed):**
- `us-central1` (Hong Kong) - for Asia-focused apps
- `asia-southeast1` (Singapore) - for Southeast Asia
- `europe-west1` (Belgium) - for Europe-focused apps

To change region, edit `deploy.sh` and update `REGION` variable.

### Model Selection

Current models:
- **Vision**: `gemini-2.5-flash-lite`
- **Text**: `gemini-2.5-flash-lite`

To change models, edit `main.py`:
```python
VISION_MODEL = "gemini-2.5-flash-lite"
TEXT_MODEL = "gemini-2.5-flash-lite"
```

---

## Testing

### Test with curl

```bash
# Get function URL
FUNCTION_URL=$(gcloud functions describe vertex-ai-proxy \
  --region=us-central1 \
  --project=geminiopti \
  --format='value(serviceConfig.uri)')

# Test text generation
curl -X POST $FUNCTION_URL \
  -H 'Content-Type: application/json' \
  -d '{
    "contents": [{
      "role": "user",
      "parts": [{"text": "Say hello in JSON format"}]
    }],
    "generationConfig": {
      "temperature": 0.4,
      "maxOutputTokens": 100
    }
  }'
```

### Test with image (base64)

```bash
# Convert image to base64
IMAGE_BASE64=$(base64 -i /path/to/food.jpg)

# Call function
curl -X POST $FUNCTION_URL \
  -H 'Content-Type: application/json' \
  -d "{
    \"contents\": [{
      \"role\": \"user\",
      \"parts\": [
        {\"text\": \"What food is this?\"},
        {\"inline_data\": {\"mime_type\": \"image/jpeg\", \"data\": \"$IMAGE_BASE64\"}}
      ]
    }]
  }"
```

---

## Flutter Integration

### 1. Add Function URL to .env

```env
VERTEX_CLOUD_FUNCTION_URL=https://vertex-ai-proxy-abc123-uc.a.run.app
```

### 2. Update VertexAIService

The `VertexAIService` class in your Flutter app has been updated to call the Cloud Function instead of trying to authenticate directly.

### 3. No More Service Account JSON Required

You can now remove the `VERTEX_SERVICE_ACCOUNT_JSON` from your `.env` file - it's no longer needed!

---

## Monitoring

### View Logs

```bash
gcloud functions logs read vertex-ai-proxy \
  --region=us-central1 \
  --project=geminiopti \
  --limit=50
```

### View Metrics

```bash
# Invocation count
gcloud monitoring time-series list \
  --filter='metric.type="cloudfunctions.googleapis.com/function/execution_count"' \
  --project=geminiopti

# Error rate
gcloud monitoring time-series list \
  --filter='metric.type="cloudfunctions.googleapis.com/function/execution_error_count"' \
  --project=geminiopti
```

### Cloud Console

- Functions: https://console.cloud.google.com/functions/list?project=geminiopti
- Logs: https://console.cloud.google.com/logs/query?project=geminiopti
- Metrics: https://console.cloud.google.com/monitoring?project=geminiopti

---

## Security

### Current Setup (Testing)

- `--allow-unauthenticated`: Anyone with the URL can call the function
- **Use for testing only!**

### Production Security

Before going to production, implement authentication:

#### Option 1: Cloud Functions IAM

Remove `--allow-unauthenticated` and require authentication:

```bash
gcloud functions deploy vertex-ai-proxy \
  --no-allow-unauthenticated \
  # ... other flags
```

Then, Flutter app must send authentication token:

```dart
final token = await user.getIdToken();
final response = await http.post(
  url,
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode(request),
);
```

#### Option 2: API Key

Add API key verification in `main.py`:

```python
API_KEY = os.environ.get("API_KEY")

def vertex_ai_proxy(request):
    # Verify API key
    provided_key = request.headers.get('X-API-Key')
    if provided_key != API_KEY:
        return ('Unauthorized', 401)

    # ... rest of function
```

#### Option 3: Firebase Auth

Integrate with Firebase Authentication for user-level access control.

---

## Troubleshooting

### Error: "Permission denied"

**Cause**: Service account lacks Vertex AI User role

**Fix**:
```bash
gcloud projects add-iam-policy-binding geminiopti \
  --member="serviceAccount:vertex-ai-food-app@geminiopti.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user"
```

### Error: "API not enabled"

**Cause**: Vertex AI API not enabled

**Fix**:
```bash
gcloud services enable aiplatform.googleapis.com --project=geminiopti
```

### Error: "Function deployment failed"

**Cause**: Cloud Functions or Cloud Build API not enabled

**Fix**:
```bash
gcloud services enable cloudfunctions.googleapis.com --project=geminiopti
gcloud services enable cloudbuild.googleapis.com --project=geminiopti
gcloud services enable artifactregistry.googleapis.com --project=geminiopti
```

### Error: "Invalid base64 image"

**Cause**: Image not properly encoded

**Fix**: Ensure image is base64 encoded without newlines:
```dart
final imageBytes = await imageFile.readAsBytes();
final base64Image = base64Encode(imageBytes); // No newlines
```

---

## Cost Estimation

### Cloud Functions Pricing

- **Invocations**: First 2M free/month, then $0.40 per 1M
- **Compute Time**: 400,000 GB-seconds free/month
  - 512MB function = ~800,000 invocations free
- **Networking**: First 5GB free/month

### Vertex AI Pricing (Gemini 2.0 Flash)

- **Input**: ~$0.075 per 1M tokens
- **Output**: ~$0.30 per 1M tokens
- **Images**: ~$0.00025 per image

### Example: 1000 food scans/month

```
Cloud Functions:
- 1,000 invocations: FREE (within free tier)
- Compute time: FREE (within free tier)

Vertex AI:
- 1,000 images × $0.00025 = $0.25
- 1,000 responses × 500 tokens × $0.30/1M = $0.15

Total: ~$0.40/month
```

---

## Support

- **Vertex AI Docs**: https://cloud.google.com/vertex-ai/docs
- **Cloud Functions Docs**: https://cloud.google.com/functions/docs
- **Gemini API**: https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/gemini

---

Last Updated: 2025-12-13
