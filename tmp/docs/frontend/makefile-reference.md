# Frontend Makefile Reference

## Overview

This document provides a comprehensive reference for all frontend-related Makefile commands available in the project root. These commands streamline the frontend development, build, and deployment workflow.

## Quick Start

```bash
# View all available commands
make help

# Install frontend dependencies
make frontend-install

# Build and deploy in one command
make frontend-full-deploy BUCKET_NAME=my-bucket
```

## Frontend Build Commands

### Basic Build Commands

```bash
# Build for production (default)
make frontend-build

# Build for specific environment
make frontend-build-dev      # Development
make frontend-build-staging  # Staging
make frontend-build-prod     # Production
```

### Build Workflows

```bash
# Full build workflow (install + build)
make frontend-full-build

# Environment-specific workflows
make frontend-dev-workflow      # Development workflow
make frontend-staging-workflow  # Staging workflow
make frontend-prod-workflow     # Production workflow
```

## Frontend Development Commands

### Development Tools

```bash
# Install dependencies
make frontend-install

# Check environment variables
make frontend-env-check

# Preview production build locally
make frontend-preview

# Clean build artifacts
make frontend-clean
```

## Frontend Deployment Commands

### Basic Deployment

```bash
# Deploy to S3 (requires BUCKET_NAME)
make frontend-deploy BUCKET_NAME=my-bucket

# Deploy with CloudFront invalidation
make frontend-deploy BUCKET_NAME=my-bucket DISTRIBUTION_ID=d1234567890abc
```

### Environment-Specific Deployment

```bash
# Deploy to development environment
make frontend-deploy-dev BUCKET_NAME=my-dev-bucket

# Deploy to staging environment
make frontend-deploy-staging BUCKET_NAME=my-staging-bucket

# Deploy to production environment
make frontend-deploy-prod BUCKET_NAME=my-prod-bucket
```

### Full Deployment Workflow

```bash
# Build and deploy in one command
make frontend-full-deploy BUCKET_NAME=my-bucket DISTRIBUTION_ID=d1234567890abc
```

## Command Parameters

### Required Parameters

- **BUCKET_NAME**: S3 bucket name for deployment
  ```bash
  make frontend-deploy BUCKET_NAME=my-frontend-bucket
  ```

### Optional Parameters

- **DISTRIBUTION_ID**: CloudFront distribution ID for cache invalidation
  ```bash
  make frontend-deploy BUCKET_NAME=my-bucket DISTRIBUTION_ID=d1234567890abc
  ```

## Environment Variables

The Makefile respects these environment variables:

```bash
# AWS Configuration
export AWS_PROFILE=Eng-Sandbox
export AWS_REGION=us-east-1

# Use in commands
make frontend-deploy BUCKET_NAME=my-bucket
```

## Common Workflows

### 1. Development Workflow

```bash
# Complete development setup
make frontend-dev-workflow

# This runs:
# 1. frontend-install
# 2. frontend-build-dev
# 3. frontend-preview
```

### 2. Staging Deployment

```bash
# Build and deploy to staging
make frontend-staging-workflow
make frontend-deploy-staging BUCKET_NAME=my-staging-bucket
```

### 3. Production Deployment

```bash
# Build and deploy to production
make frontend-prod-workflow
make frontend-deploy-prod BUCKET_NAME=my-prod-bucket DISTRIBUTION_ID=d1234567890abc
```

### 4. Full Production Workflow

```bash
# Complete production deployment
make frontend-full-deploy BUCKET_NAME=my-prod-bucket DISTRIBUTION_ID=d1234567890abc

# This runs:
# 1. frontend-build
# 2. frontend-deploy
```

## Error Handling

### Missing Parameters

```bash
# Error: Missing BUCKET_NAME
make frontend-deploy
# Output: Error: BUCKET_NAME is required. Usage: make frontend-deploy BUCKET_NAME=my-bucket

# Solution: Provide required parameter
make frontend-deploy BUCKET_NAME=my-bucket
```

### Prerequisites

The deployment commands check for:
- AWS CLI installation
- AWS credentials configuration
- Frontend build artifacts (`dist/` directory)
- Valid S3 bucket access

## Integration with Scripts

The Makefile commands use the underlying scripts:

- **Build**: `frontend/scripts/build.sh`
- **Deploy**: `frontend/scripts/deploy.sh`
- **Environment Check**: `frontend/scripts/check-env.js`

## Examples

### Complete Development Session

```bash
# 1. Install dependencies
make frontend-install

# 2. Build for development
make frontend-build-dev

# 3. Preview locally
make frontend-preview

# 4. Make changes and rebuild
make frontend-build-dev
```

### Complete Production Deployment

```bash
# 1. Build for production
make frontend-build-prod

# 2. Deploy to S3 with CloudFront invalidation
make frontend-deploy BUCKET_NAME=my-prod-bucket DISTRIBUTION_ID=d1234567890abc

# 3. Verify deployment
aws s3 ls s3://my-prod-bucket/ --profile Eng-Sandbox
```

### Staging Environment Setup

```bash
# 1. Build for staging
make frontend-staging-workflow

# 2. Deploy to staging
make frontend-deploy-staging BUCKET_NAME=my-staging-bucket

# 3. Test staging environment
curl https://my-staging-bucket.s3.amazonaws.com/
```

## Troubleshooting

### Common Issues

1. **Missing Dependencies**
   ```bash
   # Solution: Install frontend dependencies
   make frontend-install
   ```

2. **Build Failures**
   ```bash
   # Check environment variables
   make frontend-env-check
   
   # Clean and rebuild
   make frontend-clean
   make frontend-build
   ```

3. **Deployment Failures**
   ```bash
   # Verify AWS credentials
   aws sts get-caller-identity --profile Eng-Sandbox
   
   # Check S3 bucket access
   aws s3 ls s3://my-bucket/ --profile Eng-Sandbox
   ```

### Debug Commands

```bash
# Check environment configuration
make frontend-env-check

# Verify build output
ls -la frontend/dist/

# Check AWS configuration
aws configure list --profile Eng-Sandbox
```

## Best Practices

### 1. Always Check Environment

```bash
# Before building
make frontend-env-check

# Before deploying
make frontend-env-check
```

### 2. Use Environment-Specific Builds

```bash
# Development
make frontend-build-dev

# Staging
make frontend-build-staging

# Production
make frontend-build-prod
```

### 3. Verify Deployments

```bash
# Check S3 upload
aws s3 ls s3://my-bucket/ --profile Eng-Sandbox

# Test CloudFront URL
curl https://my-distribution.cloudfront.net/
```

### 4. Use Workflow Commands

```bash
# Instead of multiple commands
make frontend-install
make frontend-build
make frontend-deploy BUCKET_NAME=my-bucket

# Use workflow command
make frontend-full-deploy BUCKET_NAME=my-bucket
```

## Command Reference Summary

| Command | Description | Parameters |
|---------|-------------|------------|
| `frontend-install` | Install dependencies | None |
| `frontend-build` | Build for production | None |
| `frontend-build-dev` | Build for development | None |
| `frontend-build-staging` | Build for staging | None |
| `frontend-build-prod` | Build for production | None |
| `frontend-preview` | Preview build locally | None |
| `frontend-env-check` | Check environment | None |
| `frontend-clean` | Clean build artifacts | None |
| `frontend-deploy` | Deploy to S3 | `BUCKET_NAME`, `DISTRIBUTION_ID` (optional) |
| `frontend-deploy-dev` | Deploy to dev | `BUCKET_NAME`, `DISTRIBUTION_ID` (optional) |
| `frontend-deploy-staging` | Deploy to staging | `BUCKET_NAME`, `DISTRIBUTION_ID` (optional) |
| `frontend-deploy-prod` | Deploy to production | `BUCKET_NAME`, `DISTRIBUTION_ID` (optional) |
| `frontend-full-build` | Install + build | None |
| `frontend-full-deploy` | Build + deploy | `BUCKET_NAME`, `DISTRIBUTION_ID` (optional) |
| `frontend-dev-workflow` | Complete dev workflow | None |
| `frontend-staging-workflow` | Complete staging workflow | None |
| `frontend-prod-workflow` | Complete production workflow | None |

---

**Note**: All commands should be run from the project root directory where the Makefile is located.
