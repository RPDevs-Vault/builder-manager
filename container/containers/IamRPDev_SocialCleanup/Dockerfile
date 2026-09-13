# syntax=docker/dockerfile:1
FROM python:3.12-slim

# Set environment flags
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Create non-root system user and group
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -s /bin/bash -m appuser

# Install curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY --chown=appuser:appuser . .

# Ensure data and backups directories exist with correct permissions
RUN mkdir -p /app/data/avatars/history /app/data/sessions /app/backups /app/static && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 5050

# Health check against unauthenticated status route
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://127.0.0.1:5050/api/status || python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5050/api/status', timeout=3)" || exit 1

# Launch server binding to 0.0.0.0 on host network
ENTRYPOINT ["python3", "server.py"]
CMD ["--host", "0.0.0.0", "--port", "5050"]
