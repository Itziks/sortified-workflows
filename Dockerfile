# Railway-compatible n8n Dockerfile
FROM n8nio/n8n:latest

# Install curl for Railway health checks
USER root
RUN apk add --no-cache curl
USER node

# Set Railway-compatible defaults
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
ENV N8N_METRICS=true
ENV N8N_DIAGNOSTICS_ENABLED=true
ENV QUEUE_HEALTH_CHECK_ACTIVE=true

# Expose port for Railway
EXPOSE 5678

# Use default n8n startup (SQLite database)
CMD ["start"]