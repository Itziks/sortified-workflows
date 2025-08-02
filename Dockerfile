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

# Railway handles health checks externally via railway.json

# Railway-compatible startup command
CMD ["n8n", "start"]