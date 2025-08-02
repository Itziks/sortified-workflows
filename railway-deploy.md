# Railway Deployment Guide for n8n

## 🚂 Deploy n8n to Railway Staging Environment

This guide will help you deploy the n8n service to your existing Railway infrastructure using your `sortified.net` domain setup.

## Prerequisites ✅
Based on your existing Railway setup, you already have:
- Railway account and project configured
- GitHub integration with Dockerfile deployment
- Railway managed PostgreSQL service
- Custom domain (`sortified.net`) configured
- Health check endpoints set up

## Deployment Steps

### 1. Create New Railway Service for n8n

In your Railway dashboard:
```bash
# Add a new service to your existing project
# Choose "Deploy from GitHub repo" option
# Select this repository
```

### 2. Configure Environment Variables

Copy these variables to your Railway project environment (from `railway-env.example`):

**Required Variables:**
```env
N8N_HOST=0.0.0.0
N8N_PORT=$PORT
WEBHOOK_URL=https://n8n-staging.sortified.net/
N8N_ENCRYPTION_KEY=64bee99beae89da0c16f26a35160b7b81746ca8c297b5ae04c8eb7b32444f598
NODE_ENV=production
DB_TYPE=postgresdb
DB_POSTGRESDB_SSL=true
N8N_DEFAULT_BINARY_DATA_MODE=filesystem
N8N_BINARY_DATA_FOLDER=/home/node/.n8n/binary-data
EXECUTIONS_MODE=regular
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=168
```

**Railway will automatically provide:**
- `DATABASE_URL` (from your managed PostgreSQL)
- `PORT` (Railway assigns the port)
- SSL certificates for your domain

### 3. Connect to Existing PostgreSQL

Since you already have Railway's managed PostgreSQL:
1. In Railway dashboard, link your n8n service to the existing PostgreSQL service
2. Railway will automatically provide the `DATABASE_URL` environment variable
3. n8n will auto-parse the connection details

### 4. Configure Custom Domain

Add subdomain to your existing `sortified.net` setup:
1. Railway Dashboard → n8n service → Settings → Domains
2. Add custom domain: `n8n-staging.sortified.net`
3. Update your DNS records to point to Railway

### 5. Deploy

Push to your GitHub repository:
```bash
git add .
git commit -m "Add n8n Railway deployment configuration"
git push origin main
```

Railway will automatically:
- Build the Docker image using our `Dockerfile`
- Deploy to your staging environment
- Run health checks on `/healthz`
- Assign SSL certificate to your domain

## Configuration Files Explained

### `Dockerfile`
- Railway-optimized n8n container
- Includes curl for health checks
- Proper permissions for Railway volumes
- Uses Railway's `$PORT` environment variable

### `railway.json`
- Dockerfile build configuration
- Health check endpoint: `/healthz`
- Restart policy for resilience
- Single replica for staging

### `railway-env.example`
- All required environment variables
- Railway-specific configuration
- Production-safe execution settings
- Ready for S3 migration later

## Post-Deployment Verification

After deployment:

1. **Check Service Status**
   ```bash
   railway status
   ```

2. **View Logs**
   ```bash
   railway logs
   ```

3. **Access n8n**
   - URL: `https://n8n-staging.sortified.net/`
   - Complete initial setup wizard
   - Test webhook functionality

4. **Verify Database Connection**
   - Check Railway dashboard for PostgreSQL metrics
   - Confirm n8n tables were created

## Webhook Configuration

For staging workflows:
- **Webhook Base URL**: `https://n8n-staging.sortified.net/`
- **Test Webhooks**: Use your staging domain in workflow configurations
- **Production Migration**: Change `WEBHOOK_URL` when moving to production

## Scaling & Performance

Current configuration:
- **Memory**: Railway default (can adjust in dashboard)
- **Replicas**: 1 (staging appropriate)
- **Auto-scaling**: Disabled (manual scaling available)
- **Health Checks**: 10s interval, 5 retries

## Migration from Local to Railway

Your data migration strategy:
1. **Workflows**: Export from local n8n → Import to Railway n8n
2. **Credentials**: Manually reconfigure (encrypted differently)
3. **Binary Files**: Re-upload (stored in Railway volumes)
4. **Database**: Fresh database on Railway PostgreSQL

## Troubleshooting

**Common Issues:**

1. **Health Check Failing**
   ```bash
   railway logs | grep healthz
   ```

2. **Database Connection**
   - Verify `DATABASE_URL` in Railway dashboard
   - Check PostgreSQL service status

3. **Domain Issues**
   - Verify DNS records for `n8n-staging.sortified.net`
   - Check SSL certificate status in Railway

4. **Port Conflicts**
   - Railway automatically assigns `$PORT`
   - Ensure `N8N_PORT=$PORT` in environment

## Production Readiness

When ready for production:
1. Change `WEBHOOK_URL` to production domain
2. Increase `EXECUTIONS_DATA_MAX_AGE` if needed
3. Enable S3 for binary storage (see commented config)
4. Scale replicas if high availability needed
5. Set up monitoring and alerts

## Support Resources

- **Railway Docs**: https://docs.railway.app/
- **n8n Docs**: https://docs.n8n.io/
- **Your Railway Dashboard**: Monitor deployments and logs
- **GitHub Integration**: Auto-deploy on push to main branch