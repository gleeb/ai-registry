# Environment Configuration Guide

## Overview

This guide explains how to configure and manage different environments (development, staging, production) for the Legal Information System, including environment variables, secrets management, and configuration files.

## Configuration Structure

### Configuration Files
- `infra/config.json` - Environment-specific infrastructure settings
- `env.example` - Template for environment variables
- `.env` - Local environment variables (never commit)
- `frontend/env.example` - Frontend environment template

## Environment Types

### Development Environment
**Purpose**: Active development and testing
**Characteristics**:
- Cost-optimized resources
- Relaxed security for debugging
- Frequent deployments
- Debug logging enabled

### Staging Environment
**Purpose**: Pre-production testing and QA
**Characteristics**:
- Production-like configuration
- Real integrations
- Performance testing
- Limited access

### Production Environment
**Purpose**: Live system serving end users
**Characteristics**:
- High availability configuration
- Full security measures
- Comprehensive monitoring
- Backup and disaster recovery

## Infrastructure Configuration

### config.json Structure
```json
{
  "project_name": "testmeout",
  "default_region": "il-central-1",
  "default_environment": "dev",
  "environments": {
    "dev": {
      "region": "il-central-1",
      "vpc": {
        "create_new_vpc": true,
        "vpc_id": null,
        "database_subnet_ids": null,
        "lambda_subnet_ids": null
      },
      "database": {
        "instance_type": "t4g.medium",
        "instances": 1,
        "deletion_protection": false,
        "backup_retention_days": 7,
        "performance_insights": false
      },
      "lambda": {
        "memory_size": 512,
        "timeout_minutes": 5,
        "reserved_concurrent_executions": 10,
        "provisioned_concurrency": 0
      },
      "api": {
        "throttle_burst_limit": 100,
        "throttle_rate_limit": 50,
        "caching_enabled": false
      },
      "s3": {
        "versioning_enabled": false,
        "lifecycle_rules": true,
        "cross_region_replication": false
      },
      "monitoring": {
        "detailed_monitoring": false,
        "x_ray_tracing": true,
        "log_retention_days": 7
      },
      "security": {
        "waf_enabled": false,
        "cloudfront_enabled": false,
        "mfa_required": false
      }
    },
    "staging": {
      "region": "il-central-1",
      "vpc": {
        "create_new_vpc": true,
        "vpc_id": null
      },
      "database": {
        "instance_type": "t4g.large",
        "instances": 2,
        "deletion_protection": true,
        "backup_retention_days": 14,
        "performance_insights": true
      },
      "lambda": {
        "memory_size": 1024,
        "timeout_minutes": 10,
        "reserved_concurrent_executions": 50,
        "provisioned_concurrency": 2
      },
      "api": {
        "throttle_burst_limit": 500,
        "throttle_rate_limit": 250,
        "caching_enabled": true
      },
      "s3": {
        "versioning_enabled": true,
        "lifecycle_rules": true,
        "cross_region_replication": false
      },
      "monitoring": {
        "detailed_monitoring": true,
        "x_ray_tracing": true,
        "log_retention_days": 30
      },
      "security": {
        "waf_enabled": true,
        "cloudfront_enabled": true,
        "mfa_required": true
      }
    },
    "prod": {
      "region": "il-central-1",
      "vpc": {
        "create_new_vpc": false,
        "vpc_id": "vpc-xxxxxxxxx",
        "database_subnet_ids": ["subnet-xxx", "subnet-yyy"],
        "lambda_subnet_ids": ["subnet-aaa", "subnet-bbb"]
      },
      "database": {
        "instance_type": "r6g.xlarge",
        "instances": 3,
        "deletion_protection": true,
        "backup_retention_days": 30,
        "performance_insights": true,
        "multi_az": true
      },
      "lambda": {
        "memory_size": 2048,
        "timeout_minutes": 15,
        "reserved_concurrent_executions": 200,
        "provisioned_concurrency": 10
      },
      "api": {
        "throttle_burst_limit": 2000,
        "throttle_rate_limit": 1000,
        "caching_enabled": true,
        "cache_ttl_seconds": 300
      },
      "s3": {
        "versioning_enabled": true,
        "lifecycle_rules": true,
        "cross_region_replication": true,
        "backup_region": "us-east-1"
      },
      "monitoring": {
        "detailed_monitoring": true,
        "x_ray_tracing": true,
        "log_retention_days": 90,
        "enhanced_monitoring": true
      },
      "security": {
        "waf_enabled": true,
        "cloudfront_enabled": true,
        "mfa_required": true,
        "ip_allowlisting": true
      }
    }
  }
}
```

## Environment Variables

### Backend Environment Variables

#### Lambda Functions
```bash
# Core Configuration
ENV_NAME=dev
PROJECT_NAME=testmeout
AWS_REGION=il-central-1
LOG_LEVEL=INFO

# Database
DATABASE_SECRET_ARN=arn:aws:secretsmanager:region:account:secret:name
DATABASE_NAME=lawinfo
DATABASE_HOST=cluster-endpoint.region.rds.amazonaws.com
DATABASE_PORT=5432

# Storage
DOCUMENT_BUCKET=testmeout-documents-dev
PROCESSED_BUCKET=testmeout-processed-dev
TEMP_BUCKET=testmeout-temp-dev

# Authentication
USER_POOL_ID=il-central-1_xxxxxxxxx
USER_POOL_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxx
COGNITO_DOMAIN=https://testmeout-dev.auth.il-central-1.amazoncognito.com

# AI Services
BEDROCK_REGION=us-east-1
BEDROCK_MODEL_ID=anthropic.claude-3-sonnet-20240229-v1:0
ENABLE_THOUGHT_PROCESS=true

# API Configuration
API_BASE_URL=https://api-dev.testmeout.com
CORS_ORIGINS=https://app-dev.testmeout.com,http://localhost:3000

# Security
WAF_ENABLED=false
CLOUDFRONT_SECRET_ARN=arn:aws:secretsmanager:region:account:secret:cf-secret
ALLOWED_EMAIL_DOMAINS=company.com,partner.org

# Monitoring
X_RAY_ENABLED=true
POWERTOOLS_SERVICE_NAME=testmeout-api
POWERTOOLS_METRICS_NAMESPACE=TestMeOut/API

# Feature Flags
ENABLE_DOCUMENT_PROCESSING=true
ENABLE_CHAT_STREAMING=true
ENABLE_ADMIN_ENDPOINTS=true
```

### Frontend Environment Variables

#### Development (.env.development)
```bash
# API Configuration
VITE_API_BASE_URL=http://localhost:8000
VITE_WEBSOCKET_URL=ws://localhost:8000/ws

# Authentication
VITE_COGNITO_USER_POOL_ID=il-central-1_xxxxxxxxx
VITE_COGNITO_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxx
VITE_COGNITO_HOSTED_UI_DOMAIN=https://testmeout-dev.auth.il-central-1.amazoncognito.com

# Application Settings
VITE_APP_NAME=Legal Information System (Dev)
VITE_DEFAULT_LANGUAGE=en
VITE_SUPPORTED_LANGUAGES=en,he

# Feature Flags
VITE_ENABLE_CHAT=true
VITE_ENABLE_DOCUMENTS=true
VITE_ENABLE_ADMIN=true
VITE_ENABLE_DEBUG=true

# Development Settings
VITE_MOCK_API=false
VITE_LOG_LEVEL=debug
VITE_ENABLE_DEVTOOLS=true
```

#### Production (.env.production)
```bash
# API Configuration
VITE_API_BASE_URL=https://api.testmeout.com
VITE_WEBSOCKET_URL=wss://api.testmeout.com/ws

# Authentication
VITE_COGNITO_USER_POOL_ID=il-central-1_xxxxxxxxx
VITE_COGNITO_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxx
VITE_COGNITO_HOSTED_UI_DOMAIN=https://testmeout.auth.il-central-1.amazoncognito.com

# Application Settings
VITE_APP_NAME=Legal Information System
VITE_DEFAULT_LANGUAGE=en
VITE_SUPPORTED_LANGUAGES=en,he

# Feature Flags
VITE_ENABLE_CHAT=true
VITE_ENABLE_DOCUMENTS=true
VITE_ENABLE_ADMIN=false
VITE_ENABLE_DEBUG=false

# Production Settings
VITE_MOCK_API=false
VITE_LOG_LEVEL=error
VITE_ENABLE_DEVTOOLS=false
VITE_ANALYTICS_ID=GA-XXXXXXXXX
```

## Secrets Management

### AWS Secrets Manager

#### Database Credentials
```json
{
  "username": "dbadmin",
  "password": "generated-secure-password",
  "engine": "postgres",
  "host": "cluster-endpoint.region.rds.amazonaws.com",
  "port": 5432,
  "dbname": "lawinfo"
}
```

#### API Keys and External Services
```json
{
  "openai_api_key": "sk-xxxxxxxxxxxxxxxx",
  "stripe_secret_key": "sk_live_xxxxxxxxxxxxxxxx",
  "sendgrid_api_key": "SG.xxxxxxxxxxxxxxxx"
}
```

#### CloudFront Security
```json
{
  "secret": "randomly-generated-secret-for-cloudfront-verification"
}
```

### Creating Secrets
```bash
# Database secret
aws secretsmanager create-secret \
  --name "/testmeout/prod/database" \
  --description "Database credentials for production" \
  --secret-string '{"username":"dbadmin","password":"secure-password"}' \
  --profile Eng-Prod

# API keys
aws secretsmanager create-secret \
  --name "/testmeout/prod/api-keys" \
  --description "External API keys" \
  --secret-string '{"openai_api_key":"sk-xxx"}' \
  --profile Eng-Prod

# CloudFront secret
aws secretsmanager create-secret \
  --name "/testmeout/prod/cloudfront-secret" \
  --description "CloudFront origin verification" \
  --generate-secret-string '{"SecretStringTemplate":"{\"secret\":\"\"}","GenerateStringKey":"secret","PasswordLength":32}' \
  --profile Eng-Prod
```

## Configuration Loading

### CDK Configuration Loading
```python
import json
import os
from typing import Dict, Any

class ConfigUtils:
    @staticmethod
    def load_config(config_path: str = "config.json") -> Dict[str, Any]:
        """Load configuration from JSON file."""
        with open(config_path, 'r') as f:
            return json.load(f)
    
    @staticmethod
    def get_environment_config(config: Dict[str, Any], env_name: str) -> Dict[str, Any]:
        """Get configuration for specific environment."""
        env_config = config["environments"].get(env_name, {})
        
        # Merge with defaults
        defaults = {
            "region": config.get("default_region", "il-central-1"),
            "project_name": config.get("project_name", "testmeout")
        }
        
        return {**defaults, **env_config}
```

### Lambda Configuration Loading
```python
import os
import json
import boto3
from functools import lru_cache

@lru_cache(maxsize=1)
def get_secret(secret_name: str) -> Dict[str, Any]:
    """Retrieve secret from AWS Secrets Manager."""
    client = boto3.client('secretsmanager')
    
    try:
        response = client.get_secret_value(SecretId=secret_name)
        return json.loads(response['SecretString'])
    except Exception as e:
        logger.error(f"Error retrieving secret {secret_name}: {e}")
        raise

def load_database_config() -> Dict[str, str]:
    """Load database configuration."""
    secret_arn = os.environ['DATABASE_SECRET_ARN']
    secret = get_secret(secret_arn)
    
    return {
        'host': secret['host'],
        'port': secret['port'],
        'database': secret['dbname'],
        'user': secret['username'],
        'password': secret['password']
    }
```

## Environment Switching

### CDK Deployment
```bash
# Deploy to specific environment
cdk deploy "*-dev" -c environment=dev --profile Eng-Sandbox
cdk deploy "*-staging" -c environment=staging --profile Eng-Sandbox
cdk deploy "*-prod" -c environment=prod --profile Eng-Prod
```

### Frontend Build
```bash
# Build for specific environment
npm run build:dev      # Uses .env.development
npm run build:staging  # Uses .env.staging
npm run build:prod     # Uses .env.production
```

## Validation and Testing

### Configuration Validation
```python
import jsonschema

CONFIG_SCHEMA = {
    "type": "object",
    "properties": {
        "project_name": {"type": "string"},
        "environments": {
            "type": "object",
            "patternProperties": {
                "^[a-z]+$": {
                    "type": "object",
                    "properties": {
                        "database": {
                            "type": "object",
                            "properties": {
                                "instance_type": {"type": "string"},
                                "instances": {"type": "integer", "minimum": 1}
                            },
                            "required": ["instance_type", "instances"]
                        }
                    }
                }
            }
        }
    },
    "required": ["project_name", "environments"]
}

def validate_config(config: Dict[str, Any]) -> bool:
    """Validate configuration against schema."""
    try:
        jsonschema.validate(config, CONFIG_SCHEMA)
        return True
    except jsonschema.ValidationError as e:
        print(f"Configuration validation error: {e}")
        return False
```

### Environment Testing
```bash
# Test environment configuration
pytest tests/config/test_environment_config.py

# Validate secrets exist
aws secretsmanager describe-secret --secret-id /testmeout/dev/database

# Test connectivity
python scripts/test_connections.py --environment dev
```

## Security Best Practices

### Environment Isolation
1. Separate AWS accounts for prod/non-prod
2. Different VPCs for each environment
3. Isolated IAM roles and policies
4. Environment-specific secrets

### Access Control
```bash
# Development environment - broader access
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "il-central-1"
        }
      }
    }
  ]
}

# Production environment - restricted access
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:DescribeStacks",
        "lambda:InvokeFunction"
      ],
      "Resource": "arn:aws:*:il-central-1:ACCOUNT:*"
    }
  ]
}
```

## Monitoring Configuration

### Environment-Specific Alerts
```python
# Development - minimal alerting
dev_alarms = [
    "HighErrorRate",
    "DatabaseDown"
]

# Production - comprehensive alerting
prod_alarms = [
    "HighErrorRate",
    "HighLatency", 
    "DatabaseDown",
    "HighCPU",
    "LowDiskSpace",
    "FailedBackups",
    "SecurityAlerts"
]
```

### Log Retention
- Development: 7 days
- Staging: 30 days  
- Production: 90 days

## Troubleshooting

### Common Configuration Issues

1. **Missing Environment Variables**
```bash
# Check required variables
python scripts/check_env_vars.py --environment prod
```

2. **Incorrect Secret ARNs**
```bash
# List secrets
aws secretsmanager list-secrets --profile Eng-Sandbox
```

3. **VPC Configuration Errors**
```bash
# Validate VPC settings
aws ec2 describe-vpcs --vpc-ids vpc-xxxxxxxxx
```

### Configuration Drift Detection
```bash
# Check for configuration drift
cdk diff "*-prod" -c environment=prod --profile Eng-Prod

# Detect changes
python scripts/detect_config_drift.py --environment prod
```