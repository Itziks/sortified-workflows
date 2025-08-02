# Minimal Railway-compatible n8n Dockerfile
FROM n8nio/n8n:latest

# Install curl for Railway health checks
USER root
RUN apk add --no-cache curl
USER node

# Expose port for Railway
EXPOSE 5678

# Use the same startup command as the official image
CMD ["n8n"]