# Railway-compatible n8n Dockerfile
FROM n8nio/n8n:latest

# Install curl for Railway health checks
USER root
RUN apk add --no-cache curl
USER node

# Set Railway-compatible defaults
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV DB_TYPE=postgresdb

# Expose port for Railway
EXPOSE 5678

# Use the same startup command as the official image
CMD ["n8n", "start"]