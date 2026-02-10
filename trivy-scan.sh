#!/bin/bash

# -----------------------------
# CONFIGURATION
# -----------------------------
PROJECT_NAME="nextjs-frontend-prod"
IMAGE_NAME="nextjs-frontend-prod"
DOCKERFILE="Dockerfile"

echo "🔍 Starting Trivy security scan..."
echo "Project: $PROJECT_NAME"
echo "----------------------------------"

# -----------------------------
# 1. Scan project filesystem
# -----------------------------
echo "📁 Scanning project filesystem..."
trivy fs . \
  --severity HIGH,CRITICAL \
  --exit-code 0

# -----------------------------
# 2. Scan Dockerfile
# -----------------------------
if [ -f "$DOCKERFILE" ]; then
  echo "🐳 Scanning Dockerfile..."
  trivy config "$DOCKERFILE" \
    --severity HIGH,CRITICAL \
    --exit-code 0
else
  echo "⚠️ Dockerfile not found, skipping config scan"
fi

# -----------------------------
# 3. Build Docker image
# -----------------------------
echo "🔨 Building Docker image..."
docker build --no-cache -t "$IMAGE_NAME" .

if [ $? -ne 0 ]; then
  echo "❌ Docker build failed"
  exit 1
fi

# -----------------------------
# 4. Scan Docker image
# -----------------------------
echo "🛡️ Scanning Docker image..."
trivy image "$IMAGE_NAME" \
  --severity CRITICAL \
  --exit-code 1

# -----------------------------
# SUCCESS
# -----------------------------
echo "✅ Trivy scan completed successfully"
exit 0

