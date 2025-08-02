#!/bin/bash

# Railway n8n Deployment Script
# Usage: ./railway-deploy.sh

set -e

echo "🚂 Railway n8n Deployment Script"
echo "=================================="

# Check if railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Please install it first:"
    echo "   npm install -g @railway/cli"
    exit 1
fi

# Login check
echo "🔑 Checking Railway authentication..."
if ! railway whoami &> /dev/null; then
    echo "Please login to Railway first:"
    echo "   railway login"
    exit 1
fi

echo "✅ Railway CLI authenticated"

# Project selection
echo ""
echo "📋 Available Railway projects:"
railway projects

echo ""
read -p "Enter your Railway project ID or name: " PROJECT_ID

if [ -z "$PROJECT_ID" ]; then
    echo "❌ Project ID is required"
    exit 1
fi

# Link to project
echo "🔗 Linking to Railway project: $PROJECT_ID"
railway link $PROJECT_ID

# Deploy
echo ""
echo "🚀 Starting deployment to Railway..."
echo "This will:"
echo "  - Build the Docker image"
echo "  - Deploy to your Railway project"
echo "  - Configure health checks"
echo ""

read -p "Continue with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 1
fi

# Deploy
echo "🔨 Building and deploying..."
railway up

echo ""
echo "✅ Deployment initiated!"
echo ""
echo "Next steps:"
echo "1. Configure environment variables in Railway dashboard"
echo "2. Set up custom domain: n8n-staging.sortified.net"
echo "3. Verify health checks are passing"
echo ""
echo "View deployment status:"
echo "  railway status"
echo ""
echo "View logs:"
echo "  railway logs"