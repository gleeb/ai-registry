# Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the Legal Information System across different environments using AWS CDK and CI/CD pipelines.

## Prerequisites

### Local Development Setup
- AWS CLI installed and configured
- AWS CDK CLI installed (`npm install -g aws-cdk`)
- Python 3.12+
- Docker Desktop (for Lambda bundling)
- Git configured with repository access

### AWS Account Setup
- AWS account with appropriate permissions
- AWS profile configured (`aws configure --profile Eng-Sandbox`)
- CDK bootstrapped in target region

## Environment Configuration

### Available Environments
- **dev**: Development environment for active development
- **staging**: Pre-production testing environment
- **prod**: Production environment

### Configuration Files
- `infra/config.json`: Environment-specific settings
- `env.example`: Environment variable template
- `.env`: Local environment variables (never commit)

## Deployment Process

### 1. Initial Setup

```bash
# Clone repository
git clone <repository-url>
cd LawInfo

# Install dependencies
cd infra
pip install -r requirements.txt

# Configure environment
cp env.example .env
# Edit .env with your values

# Bootstrap CDK (first time only)
cdk bootstrap aws://ACCOUNT-ID/REGION --profile Eng-Sandbox
```

### 2. Deploy Infrastructure

#### Deploy All Stacks (Recommended Order)
```bash
# Deploy to development
cdk deploy "*-dev" -c environment=dev --profile Eng-Sandbox

# Deploy to staging
cdk deploy "*-staging" -c environment=staging --profile Eng-Sandbox

# Deploy to production (requires approval)
cdk deploy "*-prod" -c environment=prod --profile Eng-Prod --require-approval broadening
```

#### Deploy Individual Stacks
```bash
# 1. Deploy VPC (if creating new)
cdk deploy VpcStack-dev -c environment=dev --profile Eng-Sandbox

# 2. Deploy Database
cdk deploy DatabaseStack-dev -c environment=dev --profile Eng-Sandbox

# 3. Deploy Storage
cdk deploy StorageStack-dev -c environment=dev --profile Eng-Sandbox

# 4. Deploy Auth
cdk deploy AuthStack-dev -c environment=dev --profile Eng-Sandbox

# 5. Deploy API
cdk deploy ApiStack-dev -c environment=dev --profile Eng-Sandbox

# 6. Run migrations
cdk deploy MigrationStack-dev -c environment=dev --profile Eng-Sandbox
```

### 3. Deploy Frontend

#### Frontend S3 + CloudFront Deployment
The frontend is deployed using a sophisticated S3 + CloudFront architecture that extends the existing infrastructure:

**Architecture Overview:**
- **S3 Origin with OAC**: Private bucket with Origin Access Control (NOT static website hosting)
- **CloudFront Integration**: Extends existing CloudFront distribution with frontend origin
- **Path-based Routing**: S3 serves frontend, `/api/*` routes to API Gateway
- **Custom Error Pages**: L1 construct configuration for React Router support
- **WAF Protection**: Leverages existing WAF rules through CloudFront

**Deployment Steps:**
```bash
# Build frontend for production
cd frontend
npm install
npm run build:production

# Deploy to S3 (bucket name from CDK outputs)
aws s3 sync dist/ s3://frontend-bucket-dev --delete --profile Eng-Sandbox

# Invalidate CloudFront cache
aws cloudfront create-invalidation --distribution-id DIST-ID --paths "/*" --profile Eng-Sandbox
```

**Key Implementation Details:**
- **Custom Error Pages**: 404s and 403s serve `index.html` with 200 status for React Router
- **Single `/api/*` Behavior**: Clean routing pattern for all API calls
- **Dual OAuth Support**: Cognito configured for both localhost:3000 and CloudFront domain
- **Security**: Private S3 bucket with OAC, WAF protection maintained

**File References:**
- `infra/stacks/application/api_stack.py` – S3 bucket and CloudFront configuration
- `frontend/package.json` – Environment-specific build scripts
- `frontend/scripts/` – Deployment and build utility scripts
- `Makefile` – Comprehensive build and deployment automation

## Troubleshooting

### Common Issues

1. **VPC Lookup Failures**
   ```
   Error: Cannot find VPC with ID vpc-xyz
   ```
   - Verify the VPC ID exists in the target region
   - Ensure AWS credentials have VPC read permissions

2. **Subnet Configuration Errors**
   ```
   Error: Subnets must span multiple AZs
   ```
   - Provide subnets from at least 2 different availability zones
   - Verify subnet IDs are correct and exist

3. **Security Group Issues**
   ```
   Error: Cannot connect to database
   ```
   - Check security group rules allow traffic between Lambda and Aurora
   - Verify subnets have proper routing to internet (for Lambda)

### Debugging Commands

```bash
# Synthesize CloudFormation template
cdk synth -c environment=prod

# Compare deployed vs local changes
cdk diff -c environment=prod

# View stack resources
aws cloudformation list-stack-resources --stack-name LawInfoStack-prod

# Check VPC configuration
aws ec2 describe-vpcs --vpc-ids vpc-0123456789abcdef0
aws ec2 describe-subnets --subnet-ids subnet-0123456789abcdef0
```

## Cost Optimization

### Resource Costs

Major cost components:
- **Aurora PostgreSQL**: ~$50-200/month depending on instance size
- **Lambda Functions**: Pay per invocation and duration
- **API Gateway**: Pay per request
- **S3 Storage**: Pay per GB stored and requests
- **NAT Gateway**: ~$45/month per gateway (when creating new VPC)

### Cost Reduction Strategies

1. **Use Existing VPC**: Avoid NAT Gateway costs by using existing infrastructure
2. **Aurora Serverless**: Consider Aurora Serverless v2 for variable workloads
3. **Lambda Provisioned Concurrency**: Only use for production high-traffic endpoints
4. **S3 Lifecycle Policies**: Automatic transition to cheaper storage classes

## CI/CD Pipeline

### GitHub Actions Workflow

The project uses GitHub Actions for automated deployments:

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches:
      - main  # Production
      - develop  # Staging
      - 'feature/*'  # Development

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.12'
      
      - name: Install dependencies
        run: |
          npm install -g aws-cdk
          pip install -r infra/requirements.txt
      
      - name: Deploy CDK
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          ENVIRONMENT=$([ "${{ github.ref }}" == "refs/heads/main" ] && echo "prod" || echo "dev")
          cdk deploy "*-${ENVIRONMENT}" -c environment=${ENVIRONMENT} --require-approval never
```

## Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing (`pytest`)
- [ ] Linting passed (`flake8`, `black`)
- [ ] Type checking passed (`mypy`)
- [ ] Security scan completed
- [ ] Code review approved

### Infrastructure
- [ ] CDK diff reviewed (`cdk diff`)
- [ ] Cost implications assessed
- [ ] Security groups reviewed
- [ ] IAM permissions validated
- [ ] Backup strategy confirmed

### Configuration
- [ ] Environment variables set
- [ ] Secrets stored in AWS Secrets Manager
- [ ] Feature flags configured
- [ ] Monitoring alerts configured

## Deployment Verification

### Health Checks
```bash
# Check API health
curl https://api-dev.testmeout.com/api/health

# Check frontend
curl https://app-dev.testmeout.com

# Check database connectivity
aws rds describe-db-clusters --profile Eng-Sandbox
```

### Smoke Tests
```bash
# Run smoke tests
pytest tests/smoke/ -v

# Manual verification checklist
- [ ] Login functionality working
- [ ] Chat interface responsive
- [ ] Document upload successful
- [ ] Database queries working
```

## Rollback Procedures

### Lambda Rollback
```bash
# List versions
aws lambda list-versions-by-function --function-name MainApiFunction

# Update alias to previous version
aws lambda update-alias \
  --function-name MainApiFunction \
  --name PROD \
  --function-version 42
```

### Database Rollback
```bash
# Restore from snapshot
aws rds restore-db-cluster-from-snapshot \
  --db-cluster-identifier restored-cluster \
  --snapshot-identifier snapshot-id \
  --profile Eng-Sandbox
```

### CDK Stack Rollback
```bash
# Rollback to previous version
aws cloudformation cancel-update-stack --stack-name ApiStack-prod
aws cloudformation continue-update-rollback --stack-name ApiStack-prod
```

## Environment-Specific Configurations

### Development
- Auto-approval for deployments
- Deletion protection disabled
- Minimal resource sizing
- Debug logging enabled

### Staging
- Manual approval required
- Production-like configuration
- Performance testing enabled
- Integration with monitoring

### Production
- Manual approval required
- Deletion protection enabled
- High availability configuration
- Full monitoring and alerting
- Backup and disaster recovery

## Security Considerations

### Secrets Management
```bash
# Store secrets in AWS Secrets Manager
aws secretsmanager create-secret \
  --name /testmeout/prod/api-key \
  --secret-string '{"key":"value"}' \
  --profile Eng-Prod

# Rotate secrets
aws secretsmanager rotate-secret \
  --secret-id /testmeout/prod/api-key \
  --rotation-lambda-arn arn:aws:lambda:... \
  --profile Eng-Prod
```

### Access Control
- Use IAM roles for service access
- Implement least privilege principle
- Enable MFA for production deployments
- Audit trail with CloudTrail

## Monitoring Post-Deployment

### CloudWatch Dashboards
- API Gateway metrics
- Lambda function metrics
- Database performance
- Error rates and latency

### Alerts
```bash
# Check alarm status
aws cloudwatch describe-alarms --profile Eng-Sandbox

# View recent metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=MainApiFunction \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T23:59:59Z \
  --period 3600 \
  --statistics Sum
```

## Troubleshooting Deployments

### Common Issues

1. **Stack Already Exists**
```bash
# Delete existing stack
cdk destroy StackName-env --profile Eng-Sandbox
```

2. **Insufficient Permissions**
```bash
# Check IAM permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::account:user/deploy-user \
  --action-names cloudformation:CreateStack
```

3. **Resource Limits**
```bash
# Check service quotas
aws service-quotas get-service-quota \
  --service-code lambda \
  --quota-code L-B99A9384
```

## Best Practices

### Version Control
1. Tag releases appropriately
2. Use semantic versioning
3. Maintain changelog
4. Document breaking changes

### Deployment Frequency
- Development: Multiple times daily
- Staging: Daily
- Production: Weekly or bi-weekly

### Communication
1. Announce deployments in team channel
2. Update status page
3. Notify stakeholders
4. Document in deployment log

## Emergency Procedures

### Hotfix Deployment
```bash
# Create hotfix branch
git checkout -b hotfix/critical-fix main

# Make fixes and test
# ...

# Deploy directly to production
cdk deploy "*-prod" -c environment=prod --profile Eng-Prod --hotswap

# Merge back to main
git checkout main
git merge hotfix/critical-fix
```

### Disaster Recovery
1. Assess impact and scope
2. Initiate incident response
3. Restore from backups if needed
4. Deploy fixes
5. Post-mortem analysis

## Documentation

### Deployment Log
Maintain a deployment log with:
- Date and time
- Environment
- Version deployed
- Deployer name
- Changes included
- Issues encountered

### Update Documentation
After deployment:
1. Update API documentation
2. Update runbooks
3. Update architecture diagrams
4. Notify documentation team