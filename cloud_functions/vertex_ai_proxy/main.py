"""
Vertex AI Proxy Cloud Function

This Cloud Function acts as a secure proxy between the Flutter mobile app
and Google Cloud Vertex AI. It uses Workload Identity for authentication,
eliminating the need to embed service account keys in the mobile app.

Architecture:
- Flutter App (Mobile) -> Cloud Function (this file) -> Vertex AI API
- Authentication: Workload Identity (service account attached to function)
- Region: us-central1 (Iowa)
- Model: gemini-1.5-flash
"""

import functions_framework
from google import genai
import os
import json

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════

PROJECT_ID = os.environ.get("GCP_PROJECT")
LOCATION = "us-central1"  # Iowa region - best model availability

# Initialize the Client for Vertex AI
# This automatically uses the Service Account credentials (Workload Identity)
client = genai.Client(
    vertexai=True,
    project=PROJECT_ID,
    location=LOCATION
)


# ═══════════════════════════════════════════════════════════════
# MAIN FUNCTION
# ═══════════════════════════════════════════════════════════════

@functions_framework.http
def vertex_ai_proxy(request):
    """
    HTTP Cloud Function to proxy requests to Vertex AI.

    This function accepts the same request format as the standard Gemini API
    for compatibility with the Flutter app.
    """

    # ═══════════════════════════════════════════════════════════════
    # 1. CORS HEADERS (for web/mobile app access)
    # ═══════════════════════════════════════════════════════════════

    # Handle preflight OPTIONS request
    if request.method == 'OPTIONS':
        headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)

    # Set CORS headers for actual request
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
    }

    # ═══════════════════════════════════════════════════════════════
    # 2. VALIDATE REQUEST
    # ═══════════════════════════════════════════════════════════════

    if request.method != 'POST':
        return (
            json.dumps({'error': 'Method not allowed. Use POST.'}),
            405,
            headers
        )

    try:
        request_json = request.get_json(silent=True)
        if not request_json:
            return (
                json.dumps({'error': 'Invalid JSON in request body'}),
                400,
                headers
            )
    except Exception as e:
        return (
            json.dumps({'error': f'Failed to parse JSON: {str(e)}'}),
            400,
            headers
        )

    # Check for required 'contents' field (Gemini API format)
    if 'contents' not in request_json:
        return (
            json.dumps({'error': 'Missing "contents" field in request'}),
            400,
            headers
        )

    # ═══════════════════════════════════════════════════════════════
    # 3. CALL VERTEX AI
    # ═══════════════════════════════════════════════════════════════

    try:
        contents = request_json['contents']
        generation_config = request_json.get('generationConfig', {})

        print(f"Calling Vertex AI with {len(contents)} content parts")

        # Call Vertex AI Gemini
        response = client.models.generate_content(
            model='gemini-1.5-flash',
            contents=contents,
            config=generation_config
        )

        # Extract response text
        response_text = response.text

        print(f"Response received: {len(response_text)} characters")

        # ═══════════════════════════════════════════════════════════════
        # 4. FORMAT RESPONSE (Gemini API compatible)
        # ═══════════════════════════════════════════════════════════════

        # Build response in Gemini API format for Flutter compatibility
        gemini_response = {
            "candidates": [
                {
                    "content": {
                        "parts": [{"text": response_text}],
                        "role": "model"
                    },
                    "finishReason": "STOP",
                    "index": 0,
                }
            ],
            "usageMetadata": {
                "promptTokenCount": 0,  # google-genai doesn't expose this
                "candidatesTokenCount": 0,
                "totalTokenCount": 0,
            },
            "modelVersion": "gemini-1.5-flash",
        }

        return (
            json.dumps(gemini_response),
            200,
            headers
        )

    except Exception as e:
        print(f"Vertex AI API error: {e}")
        return (
            json.dumps({
                'error': f'Vertex AI API call failed: {str(e)}',
                'model': 'gemini-1.5-flash',
            }),
            500,
            headers
        )
