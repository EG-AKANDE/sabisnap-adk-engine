# ==============================================================================
# SabiSnap Ltd (RC 9414613) — Serverless Multi-Agent Engine
# Target Platform: Google Cloud Run (Fully Managed Containerized Service)
# Framework: Google Agent Development Kit (ADK v2.12.0)
# ==============================================================================

FROM python:3.11-slim

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Google ADK and production server dependencies
RUN pip install --no-cache-dir \
    google-adk==2.12.0 \
    google-genai>=2.30.0 \
    fastapi>=0.115.0 \
    uvicorn[standard]>=0.30.0 \
    pydantic>=2.9.0 \
    python-dotenv>=1.0.1

# Copy pipeline architecture and application assets
COPY sabisnap_adk_pipeline.py /app/sabisnap_adk_pipeline.py

# Create local offline cache directory
RUN mkdir -p /app/offline_cache

# Expose standard Cloud Run port
EXPOSE 8080

# Run the SabiSnap ADK service
CMD ["python", "sabisnap_adk_pipeline.py"]
