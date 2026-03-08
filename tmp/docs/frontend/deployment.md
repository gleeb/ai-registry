# Frontend Deployment Guide

## Overview

This guide covers deploying the React frontend application to AWS S3 and serving it via CloudFront. The deployment process includes building the application, uploading to S3, and invalidating CloudFront cache for immediate updates.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Node.js 18+ and npm/yarn installed
- CDK infrastructure deployed (S3 bucket and CloudFront distribution)
- Environment variables configured

## Environment Configuration

### Frontend Environment Variables

Update your `frontend/.env` file with the CloudFront domain:

```bash
# Development (localhost)
VITE_API_BASE_URL=http://localhost:3000/api

# Production (CloudFront)
VITE_API_BASE_URL=https://your-cloudfront-domain.cloudfront.net/api
```

### Environment-Specific Builds

Create environment-specific `.env` files:

- `.env.development` - Local development
- `.env.production` - CloudFront deployment
- `.env.staging` - Staging environment

## Build Process

### 1. Install Dependencies

```bash
cd frontend
npm install
```

### 2. Build for Production

```bash
# Standard production build
npm run build

# Environment-specific build
npm run build:production
npm run build:staging
```

### 3. Build Output

The build process creates a `dist/` directory containing:
- `index.html` - Main entry point
- `assets/` - JavaScript, CSS, and other assets
- Optimized and minified files for production

## S3 + CloudFront Deployment Architecture

### Implementation Decisions
The frontend deployment uses a sophisticated S3 + CloudFront architecture with the following key decisions:

1. **Extend Existing CloudFront Stack**
   - Leverage existing WAF and security infrastructure
   - Add S3 bucket as additional origin to existing distribution
   - Maintain cost efficiency through shared infrastructure

2. **S3 Origin with OAC (NOT Static Website Hosting)**
   - **Why**: Static website hosting requires public bucket access, creating security vulnerabilities
   - **Solution**: Use S3 origin with Origin Access Control (OAC) for secure, private access
   - **Result**: Bucket remains private, only accessible through CloudFront

3. **Custom Error Pages via L1 Construct**
   - **Why**: `origins.OriginGroup` fallback mechanism wasn't working reliably
   - **Solution**: Use `add_property_override` on the L1 `CfnDistribution` construct
   - **Result**: 404s and 403s now serve `index.html` with 200 status, enabling React Router

4. **Single `/api/*` Behavior Pattern**
   - **Why**: Multiple path-specific behaviors were redundant and confusing
   - **Solution**: Single `/api/*` behavior routes all API calls to API Gateway
   - **Result**: Clean, predictable routing that matches frontend's `VITE_API_BASE_URL=/api` pattern

### Security Features
- ✅ **WAF protection** through existing CloudFront setup
- ✅ **Private S3 bucket** with OAC (no public access)
- ✅ **HTTPS enforcement** via CloudFront viewer protocol policy
- ✅ **Origin verification** via custom headers
- ✅ **IP restrictions** through existing WAF rules

### Performance Optimizations
- ✅ **CloudFront caching** for static assets
- ✅ **S3 direct access** via CloudFront (no public bucket)
- ✅ **Path-based routing** for efficient origin selection
- ✅ **Custom error pages** with minimal TTL for React Router support

### Lessons Learned
- Existing CloudFront + WAF infrastructure can be extended rather than duplicated
- Cognito supports multiple OAuth callback URLs for different environments
- Path-based CloudFront behaviors allow serving multiple origins from single distribution
- **CRITICAL: Do NOT use S3 static website hosting** - it requires public bucket access and creates security vulnerabilities
- **Custom error pages must be configured via L1 construct** - `add_property_override` is more reliable than `origins.OriginGroup`
- **React Router requires 404s to serve `index.html`** - custom error pages with 200 status enable client-side routing

## Deployment to S3

### 1. Get S3 Bucket Name

Retrieve the S3 bucket name from CDK outputs:

```bash
cd infra
cdk deploy testmeoutApi-sandbox -c environment=sandbox --profile Eng-Sandbox
```

Look for the `FrontendBucketName` output.

### 2. Upload to S3

#### Using AWS CLI

```bash
# Upload all files from dist/ to S3 bucket
aws s3 sync frontend/dist/ s3://your-bucket-name/ --profile Eng-Sandbox

# Upload with specific profile and region
aws s3 sync frontend/dist/ s3://your-bucket-name/ \
  --profile Eng-Sandbox \
  --region us-east-1
```

#### Using AWS Console

1. Navigate to S3 console
2. Select your frontend bucket
3. Click "Upload"
4. Drag and drop contents of `frontend/dist/` folder
5. Click "Upload"

### 3. Verify Upload

```bash
# List bucket contents
aws s3 ls s3://your-bucket-name/ --profile Eng-Sandbox

# Check specific file
aws s3 ls s3://your-bucket-name/index.html --profile Eng-Sandbox
```

## CloudFront Cache Invalidation

### 1. Invalidate Specific Files

```bash
# Invalidate specific files
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/index.html" "/assets/*" \
  --profile Eng-Sandbox
```

### 2. Invalidate All Files

```bash
# Invalidate entire distribution (use sparingly)
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*" \
  --profile Eng-Sandbox
```

### 3. Check Invalidation Status

```bash
# List recent invalidations
aws cloudfront list-invalidations \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --profile Eng-Sandbox
```

## Complete Deployment Workflow

### 1. Build and Deploy

```bash
# Build frontend
cd frontend
npm run build

# Deploy to S3
aws s3 sync dist/ s3://your-bucket-name/ --profile Eng-Sandbox

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*" \
  --profile Eng-Sandbox
```

### 2. Verify Deployment

1. **Check S3**: Verify files are uploaded correctly
2. **Check CloudFront**: Wait for invalidation to complete
3. **Test Frontend**: Visit CloudFront URL and test functionality
4. **Test API**: Verify API calls work with `/api` prefix

## Troubleshooting

### Common Issues

#### Build Failures

```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Check Node.js version
node --version  # Should be 18+
```

#### S3 Upload Issues

```bash
# Check AWS credentials
aws sts get-caller-identity --profile Eng-Sandbox

# Verify bucket permissions
aws s3 ls s3://your-bucket-name/ --profile Eng-Sandbox
```

#### CloudFront Issues

```bash
# Check distribution status
aws cloudfront get-distribution \
  --id YOUR_DISTRIBUTION_ID \
  --profile Eng-Sandbox

# Verify invalidation completed
aws cloudfront list-invalidations \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --profile Eng-Sandbox
```

### Debugging Steps

1. **Check CloudFront Logs**: Enable access logging for debugging
2. **Verify CORS**: Check browser console for CORS errors
3. **Test API Endpoints**: Verify `/api/*` routes work correctly
4. **Check WAF Rules**: Ensure WAF isn't blocking legitimate requests

## Security Considerations

### WAF Protection

- WAF is enabled by default for production environments
- IP restrictions and rate limiting are configured
- CloudFront origin validation prevents direct S3 access

### S3 Bucket Security

- Public access is blocked
- Origin Access Control (OAC) required for CloudFront access
- Encryption enabled by default

### Environment Variables

- Never commit `.env` files to version control
- Use `.env.example` as template
- Rotate secrets regularly

## Performance Optimization

### Build Optimization

- Enable tree shaking in build process
- Use code splitting for large applications
- Optimize images and assets

### CloudFront Optimization

- Configure appropriate cache policies
- Use regional edge caches
- Monitor cache hit rates

## Monitoring and Maintenance

### Health Checks

```bash
# Frontend health
curl https://your-cloudfront-domain.cloudfront.net/

# API health
curl https://your-cloudfront-domain.cloudfront.net/api/health
```

### Regular Maintenance

- Monitor CloudFront metrics
- Review WAF logs for security threats
- Update dependencies regularly
- Test deployment process periodically

## Rollback Procedures

### Quick Rollback

```bash
# Revert to previous S3 version
aws s3 cp s3://your-bucket-name/previous-version/ s3://your-bucket-name/ \
  --recursive --profile Eng-Sandbox

# Invalidate CloudFront
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*" \
  --profile Eng-Sandbox
```

### Emergency Rollback

1. **Stop CloudFront distribution** (if necessary)
2. **Restore from S3 versioning**
3. **Verify functionality**
4. **Re-enable CloudFront**

## Support and Resources

### Documentation

- [AWS S3 User Guide](https://docs.aws.amazon.com/s3/)
- [AWS CloudFront User Guide](https://docs.aws.amazon.com/cloudfront/)
- [CDK Documentation](https://docs.aws.amazon.com/cdk/)

### Troubleshooting Resources

- AWS Support (if applicable)
- CloudFront troubleshooting guide
- S3 error code reference

---

**Note**: This deployment process assumes the CDK infrastructure is already deployed. If you need to deploy the infrastructure first, refer to the CDK deployment guide in `docs/other/deployment-guide.md`.
