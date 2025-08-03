# Railway-compatible n8n Dockerfile
FROM n8nio/n8n:latest

# Install curl for Railway health checks
USER root
RUN apk add --no-cache curl

# Create a simple wrapper script to map Railway vars to n8n format
RUN echo '#!/bin/sh' > /usr/local/bin/start-n8n.sh && \
    echo 'if [ -n "$PGHOST" ]; then' >> /usr/local/bin/start-n8n.sh && \
    echo '  export DB_POSTGRESDB_HOST="$PGHOST"' >> /usr/local/bin/start-n8n.sh && \
    echo '  export DB_POSTGRESDB_PORT="$PGPORT"' >> /usr/local/bin/start-n8n.sh && \
    echo '  export DB_POSTGRESDB_DATABASE="$PGDATABASE"' >> /usr/local/bin/start-n8n.sh && \
    echo '  export DB_POSTGRESDB_USER="$PGUSER"' >> /usr/local/bin/start-n8n.sh && \
    echo '  export DB_POSTGRESDB_PASSWORD="$PGPASSWORD"' >> /usr/local/bin/start-n8n.sh && \
    echo 'fi' >> /usr/local/bin/start-n8n.sh && \
    echo 'exec n8n start' >> /usr/local/bin/start-n8n.sh && \
    chmod +x /usr/local/bin/start-n8n.sh && \
    ls -la /bin/ && \
    which sh

USER node

# Set Railway-compatible defaults
ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV DB_TYPE=postgresdb
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

# Expose port for Railway
EXPOSE 5678

# Use the wrapper script directly as executable
ENTRYPOINT ["/usr/local/bin/start-n8n.sh"]