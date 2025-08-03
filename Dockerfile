# Railway-compatible n8n Dockerfile
FROM n8nio/n8n:latest

# Install curl for Railway health checks
USER root
RUN apk add --no-cache curl

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

USER node

# Set Railway-compatible defaults
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV DB_TYPE=postgresdb
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Expose port for Railway
EXPOSE 5678

# Use custom startup script
CMD ["/bin/sh", "/start.sh"]