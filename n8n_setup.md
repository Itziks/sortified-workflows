# n8n Docker Stack Implementation Plan

## Overview
This plan outlines the implementation of a lean, self-hosted n8n workflow automation platform using Docker Compose for MVP deployment. The stack will consist of n8n and PostgreSQL with persistent storage, health monitoring, and clear upgrade paths.

## Architecture
- **Single-node n8n**: Combined UI, webhook receiver, and workflow execution engine
- **PostgreSQL 15**: Primary database for workflows, executions, and metadata
- **Docker Compose**: Container orchestration with health checks and dependencies
- **Named volumes**: Persistent storage for database and n8n data
- **Local filesystem**: Binary data storage (with S3 migration path)

## Implementation Tasks

### 1. docker-compose.yml Structure
```yaml
version: "3.9"
services:
  postgres:
    - PostgreSQL 15 official image
    - Environment variables from .env
    - Named volume for data persistence (/var/lib/postgresql/data)
    - Health check using pg_isready
    - restart: unless-stopped
  
  n8n:
    - n8nio/n8n:latest official image
    - Port mapping: 5678:5678 (configurable via env)
    - Depends on postgres with health condition
    - Two named volumes:
      - n8n_data: /home/node/.n8n (workflows, settings)
      - n8n_binaries: /home/node/.n8n/binary-data (file uploads)
    - Health check via HTTP GET to /healthz
    - restart: unless-stopped
    - Complete environment configuration from .env

volumes:
  - pg_data: PostgreSQL data
  - n8n_data: n8n application data
  - n8n_binaries: Binary file storage
```

### 2. Environment Configuration (.env.example)
**Core n8n Settings:**
- N8N_ENCRYPTION_KEY: Workflow encryption (must be 32+ chars)
- N8N_HOST: localhost (change for production)
- N8N_PORT: 5678
- WEBHOOK_URL: http://localhost:5678/ (critical for webhooks)

**Database Configuration:**
- DB_TYPE: postgresdb
- All PostgreSQL connection parameters
- Database credentials (n8n/change_me defaults)

**Binary Data Handling:**
- N8N_DEFAULT_BINARY_DATA_MODE: filesystem (MVP)
- N8N_BINARY_DATA_FOLDER: /home/node/.n8n/binary-data
- Commented S3 configuration for future migration

**Execution Management:**
- EXECUTIONS_MODE: regular (single-node)
- EXECUTIONS_DATA_PRUNE: true (automatic cleanup)
- EXECUTIONS_DATA_MAX_AGE: 336 hours (~14 days)

### 3. Documentation (README.md)
**Sections:**
1. **Purpose**: Single-node n8n + PostgreSQL for workflow automation
2. **Prerequisites**: Docker 20.10+, Docker Compose 2.0+
3. **Quick Start**:
   - Copy .env.example → .env
   - Generate N8N_ENCRYPTION_KEY (openssl rand -hex 32)
   - Fill database credentials
   - `docker compose up -d`
4. **Access**: http://localhost:5678/
5. **Persistence**: Volume locations and backup strategy
6. **Production Notes**: WEBHOOK_URL, reverse proxy, HTTPS
7. **Upgrades**: Image tag updates and rolling updates
8. **Troubleshooting**: Common issues and solutions

## Key Implementation Details

### Health Checks
- **PostgreSQL**: `pg_isready -U $POSTGRES_USER -d $POSTGRES_DB`
  - Interval: 10s, Timeout: 5s, Retries: 5
- **n8n**: HTTP GET to `/healthz` endpoint
  - Interval: 10s, Timeout: 5s, Retries: 5
  - Using Node.js fetch for lightweight check

### Service Dependencies
- n8n depends_on postgres with condition: service_healthy
- Ensures database is ready before n8n starts
- Prevents connection errors during startup

### Volume Strategy
- **Named volumes**: Better for production vs bind mounts
- **Separate binary volume**: Easier to manage large files
- **PostgreSQL data**: Standard /var/lib/postgresql/data mount

### Security Considerations
- No default passwords in docker-compose.yml
- All secrets via .env file
- .env.example with placeholder values
- Strong encryption key generation guidance

### Future Migration Paths
- **S3 Binary Storage**: Commented configuration ready
- **Multi-node**: Queue mode preparation in env vars
- **External Database**: Easy connection string changes
- **Reverse Proxy**: WEBHOOK_URL configuration guidance

## File Structure
```
sortified-workflows/
├── docker-compose.yml
├── env.example
├── .env (user creates)
├── README.md
└── n8n_setup.md (this file)
```

## Validation Criteria
✅ `docker compose up -d` starts cleanly
✅ http://localhost:5678 shows n8n setup wizard
✅ Workflows can be created and executed
✅ File uploads persist across container restarts
✅ Health checks pass for both services
✅ Database connection is stable
✅ README provides clear setup instructions
✅ Environment variables are properly documented

## Next Steps (Post-Review)
1. Create docker-compose.yml with exact service definitions
2. Create .env.example with all required variables and comments
3. Write concise README.md with setup and troubleshooting
4. Test complete stack startup and basic functionality
5. Validate persistent volumes and health checks
6. Document upgrade and backup procedures

## Optional Enhancements (Future)
- nginx reverse proxy configuration
- Let's Encrypt SSL automation
- Backup/restore scripts
- Monitoring with Prometheus/Grafana
- Log aggregation setup
- Multi-environment configurations