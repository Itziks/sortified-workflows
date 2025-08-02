# Railway-optimized n8n Dockerfile
FROM n8nio/n8n:latest

# Set Railway-specific user and working directory
USER root
WORKDIR /home/node

# Install curl for health checks (Railway requirement)
RUN apk add --no-cache curl

# Create necessary directories with proper permissions
RUN mkdir -p /home/node/.n8n/binary-data && \
    chown -R node:node /home/node/.n8n

# Switch back to node user for security
USER node

# Expose port (Railway will override with PORT env var)
EXPOSE 5678

# Health check endpoint for Railway
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD curl -f http://localhost:${PORT:-5678}/health || exit 1

# Railway-compatible startup command
CMD ["n8n", "start"]