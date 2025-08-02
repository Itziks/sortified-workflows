# n8n Docker Stack

A lean, self-hosted n8n workflow automation platform with PostgreSQL database, designed for MVP deployments with clear production upgrade paths.

## What This Provides

- **Single-node n8n**: Combined UI, webhook receiver, and workflow execution engine
- **PostgreSQL 15**: Reliable database for workflows, executions, and metadata
- **Persistent storage**: All data survives container restarts
- **Health monitoring**: Built-in health checks for both services
- **Local file storage**: Binary data stored on filesystem (S3 migration ready)

## Prerequisites

- Docker 20.10+ 
- Docker Compose 2.0+
- 2GB+ available RAM
- 10GB+ available disk space

## Quick Start

### 1. Configure Environment
```bash
# Copy the example environment file
cp env.example .env

# Generate a strong encryption key (REQUIRED)
openssl rand -hex 32

# Edit .env and set:
# - N8N_ENCRYPTION_KEY=<generated-key-from-above>
# - DB_POSTGRESDB_PASSWORD=<strong-password>
```

### 2. Start the Stack
```bash
# Start services in background
docker compose up -d

# View logs (optional)
docker compose logs -f
```

### 3. Access n8n
Open http://localhost:5678/ in your browser and complete the initial setup wizard.

## Data Persistence

All data is stored in Docker named volumes:
- `pg_data`: PostgreSQL database files
- `n8n_data`: n8n workflows, credentials, and settings  
- `n8n_binaries`: Uploaded files and binary data

**Backup Strategy**: Use `docker volume` commands or backup the entire `/var/lib/docker/volumes/` directory.

## Production Deployment

### WEBHOOK_URL Configuration
For production use behind a reverse proxy:
```bash
# In .env file:
WEBHOOK_URL=https://n8n.yourdomain.com/
N8N_HOST=0.0.0.0  # Allow external connections
```

### HTTPS Setup
Use a reverse proxy (nginx/Traefik) with Let's Encrypt for SSL termination. n8n will run on HTTP internally.

## Upgrading n8n

```bash
# Pull latest image
docker compose pull n8n

# Restart with new version
docker compose up -d n8n

# Check logs
docker compose logs -f n8n
```

## Volume Management

### List Volumes
```bash
docker volume ls | grep sortified-workflows
```

### Backup Volumes
```bash
# Backup database
docker compose exec postgres pg_dump -U n8n n8n > backup.sql

# Or backup entire volume
docker run --rm -v sortified-workflows_pg_data:/data -v $(pwd):/backup alpine tar czf /backup/pg_data.tar.gz -C /data .
```

## Troubleshooting

### Health Checks Failing
```bash
# Check service status
docker compose ps

# View detailed logs
docker compose logs postgres
docker compose logs n8n
```

### Common Issues

**Database connection errors:**
- Verify `DB_POSTGRESDB_PASSWORD` matches in .env
- Ensure PostgreSQL container is healthy: `docker compose ps`

**Port 5678 already in use:**
- Change `N8N_PORT=5679` in .env and restart

**n8n won't start:**
- Check encryption key is set and 32+ characters
- Verify all required environment variables in .env

**Large file upload issues:**
- Increase Docker container memory limits
- Consider migrating to S3 (see S3 configuration in .env.example)

**Webhook not working:**
- Verify `WEBHOOK_URL` points to your actual domain/IP
- Check firewall allows inbound connections to n8n port

### Reset Everything
```bash
# Stop and remove all containers, networks, and volumes
docker compose down -v

# Start fresh
docker compose up -d
```

## Migration to S3 (Future)

When ready to migrate binary storage to S3:

1. Uncomment S3 variables in .env
2. Fill in your S3 credentials and bucket details  
3. Change `N8N_DEFAULT_BINARY_DATA_MODE=s3`
4. Restart: `docker compose up -d n8n`

Binary files will be stored in S3 going forward. Existing local files remain accessible.

## Support

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Docker Compose Reference](https://docs.docker.com/compose/)