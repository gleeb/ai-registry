# Troubleshooting Guide

## Overview

This guide documents common issues encountered in the Legal Information System and their solutions, with a focus on preventing recurring problems and helping LLM assistants avoid known pitfalls.

## Critical Issues and Solutions

### 1. T-033 Bedrock Chat Infrastructure Issues (Resolved)

#### CloudFront to API Gateway Connectivity
**Problem**: Complex CORS configuration and routing issues between CloudFront and API Gateway during T-033 implementation.

**Symptoms**:
- CORS errors in browser console during chat requests
- Authentication failures at API Gateway
- Incorrect API routing and stage configuration
- Frontend environment variable mismatches

**Root Causes**:
1. **CORS Configuration**: Incompatible CORS setup between CloudFront and API Gateway
2. **Environment Variables**: Frontend using `VITE_API_URL` instead of `VITE_API_BASE_URL`
3. **Authentication Flow**: Missing combined authorizer for JWT + CloudFront validation
4. **API Gateway Routing**: Improper stage and path mapping configuration

**Solutions Implemented**:
1. **CloudFront CORS Function**: Custom CloudFront function to handle OPTIONS requests
2. **Combined Authorizer**: Single Lambda authorizer handling both JWT and CloudFront validation
3. **Environment Variable Fix**: Updated frontend to use correct `VITE_API_BASE_URL` variable
4. **API Gateway Routes**: Proper route configuration for chat endpoints

**Files Modified**:
- `infra/stacks/application/api_stack.py` - Complete API Gateway and CloudFront setup
- `lambdas/combined_authorizer/src/handler.py` - Combined authentication logic
- `frontend/.env` - Corrected environment variable names
- `frontend/src/services/api/chatApi.ts` - Updated to use correct API base URL

### 2. CloudFront Distribution with API Gateway Integration

#### ⚠️ CRITICAL ISSUE
**Problem**: CloudFront distribution fails when trying to use API Gateway HTTP API v2 as an origin.

**Root Cause**: CloudFront does not support API Gateway HTTP API v2 endpoints directly as origins. HTTP APIs v2 have a different URL structure and do not expose the necessary origin configuration that CloudFront expects.

**Failed Approach** (DO NOT USE):
```python
# This will fail - CloudFront cannot use HTTP API v2 as origin
distribution = cloudfront.Distribution(
    self, "Distribution",
    default_behavior=cloudfront.BehaviorOptions(
        origin=origins.HttpOrigin(
            f"{api.api_id}.execute-api.{region}.amazonaws.com"  # HTTP API v2 URL
        )
    )
)
```

**Correct Solution**:
```python
# Option 1: Use REST API (API Gateway v1) instead
rest_api = apigateway.RestApi(self, "RestApi")
distribution = cloudfront.Distribution(
    self, "Distribution", 
    default_behavior=cloudfront.BehaviorOptions(
        origin=origins.RestApiOrigin(rest_api)
    )
)

# Option 2: Use HTTP API with Lambda@Edge
# Create Lambda@Edge function to modify requests
# CloudFront -> Lambda@Edge -> HTTP API

# Option 3: Direct HTTP API access (without CloudFront)
# For development/testing only
```

**Prevention**: Always verify AWS service compatibility before integration. Check AWS documentation for supported origin types.

### 2. CDK Module Import Conflicts

#### Problem
**Error**: `ModuleNotFoundError: No module named 'constructs._jsii'`

**Root Cause**: Having a folder named `constructs` in your project conflicts with the Python `constructs` module required by CDK.

**Solution**:
```bash
# Rename the conflicting folder
mv infra/constructs infra/cdk_constructs

# Update all imports
# From: from constructs import MyConstruct
# To: from cdk_constructs import MyConstruct
```

**Prevention**: Never name folders with common module names (`constructs`, `aws_cdk`, `boto3`, etc.)

**Note**: This issue is documented in [GitHub issue #19301](https://github.com/aws/aws-cdk/issues/19301) and has been resolved in this project by renaming `infra/constructs/` to `infra/cdk_constructs/`.

### 3. Lambda Cold Start Issues

#### Problem
**Symptoms**: First request after idle period takes 5-10 seconds

**Solutions**:
```python
# 1. Provisioned Concurrency
lambda_function.add_provisioned_concurrent_executions(
    "ProvisionedConcurrency",
    provisioned_executions=2
)

# 2. Warm-up function
import json
def handler(event, context):
    # Check for warm-up event
    if event.get('source') == 'aws.events':
        return {'statusCode': 200, 'body': 'Warmed up'}
    
    # Regular processing
    # ...

# 3. Optimize imports
# Move imports inside handler for rarely used modules
```

### 4. Database Connection Pool Exhaustion

#### Problem
**Error**: `FATAL: remaining connection slots are reserved`

**Root Cause**: Lambda functions creating too many database connections

**Solution**:
```python
# Use RDS Proxy
proxy = rds.DatabaseProxy(
    self, "DbProxy",
    proxy_target=rds.ProxyTarget.from_cluster(cluster),
    secrets=[cluster.secret],
    vpc=vpc,
    max_connections_percent=75
)

# In Lambda: connect to proxy endpoint instead
connection_string = f"postgresql://user@{proxy_endpoint}/database"
```

### 5. CORS Issues with API Gateway

#### Problem
**Error**: `Access to fetch at 'api.example.com' from origin 'app.example.com' has been blocked by CORS policy`

**Solutions**:
```python
# 1. Configure CORS in API Gateway
http_api = apigatewayv2.HttpApi(
    self, "HttpApi",
    cors_configuration={
        "allow_origins": ["https://app.example.com"],
        "allow_methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["*"],
        "allow_credentials": True,
        "max_age": Duration.days(1)
    }
)

# 2. Handle preflight in Lambda
def handler(event, context):
    if event['httpMethod'] == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': '*',
                'Access-Control-Allow-Methods': '*'
            },
            'body': ''
        }
```

### 6. Cognito Redirect URI Mismatch

#### Problem
**Error**: `redirect_uri_mismatch`

**Root Cause**: Callback URL in application doesn't match Cognito configuration

**Solution**:
```python
# In CDK - ensure all environments are configured
user_pool_client = cognito.UserPoolClient(
    self, "UserPoolClient",
    user_pool=user_pool,
    oauth={
        "callback_urls": [
            "http://localhost:3000/auth/callback",      # Local dev
            "https://dev.example.com/auth/callback",    # Dev
            "https://staging.example.com/auth/callback", # Staging  
            "https://app.example.com/auth/callback"     # Prod
        ]
    }
)
```

### 7. S3 Presigned URL Upload Failures

#### Problem
**Error**: `SignatureDoesNotMatch` when uploading to presigned URL

**Solutions**:
```python
# 1. Ensure correct headers in upload
# Frontend must include Content-Type
fetch(presignedUrl, {
    method: 'PUT',
    body: file,
    headers: {
        'Content-Type': file.type  // Must match presigned URL
    }
})

# 2. Generate URL with correct parameters
url = s3.generate_presigned_url(
    'put_object',
    Params={
        'Bucket': bucket,
        'Key': key,
        'ContentType': content_type  # Must be specified
    },
    ExpiresIn=3600
)
```

### 8. CloudWatch Logs Missing

#### Problem
**Issue**: Lambda logs not appearing in CloudWatch

**Solutions**:
```python
# 1. Ensure Lambda has logging permissions
lambda_role.add_managed_policy(
    iam.ManagedPolicy.from_aws_managed_policy_name(
        "service-role/AWSLambdaBasicExecutionRole"
    )
)

# 2. Check log retention settings
log_group = logs.LogGroup(
    self, "LogGroup",
    log_group_name=f"/aws/lambda/{function_name}",
    retention=logs.RetentionDays.ONE_WEEK
)
```

### 9. Environment Variable Size Limits

#### Problem
**Error**: `InvalidParameterValueException: Environment variables size exceeded 4KB`

**Solution**:
```python
# Store large values in SSM Parameter Store
param = ssm.StringParameter(
    self, "LargeConfig",
    string_value=json.dumps(large_config)
)

# In Lambda, retrieve at runtime
def handler(event, context):
    ssm_client = boto3.client('ssm')
    config = ssm_client.get_parameter(
        Name='/app/config',
        WithDecryption=True
    )['Parameter']['Value']
```

### 10. VPC Lambda Internet Access

#### Problem
**Issue**: Lambda in VPC cannot access internet or AWS services

**Solution**:
```python
# 1. Place Lambda in private subnet with NAT
vpc = ec2.Vpc(
    self, "VPC",
    subnet_configuration=[
        ec2.SubnetConfiguration(
            name="Public",
            subnet_type=ec2.SubnetType.PUBLIC
        ),
        ec2.SubnetConfiguration(
            name="Private",
            subnet_type=ec2.SubnetType.PRIVATE_WITH_EGRESS  # Has NAT
        )
    ]
)

# 2. Or use VPC endpoints for AWS services
s3_endpoint = vpc.add_gateway_endpoint(
    "S3Endpoint",
    service=ec2.GatewayVpcEndpointAwsService.S3
)
```

## Debugging Techniques

### 1. Enable Detailed Logging
```python
import logging
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

# Add request ID for tracing
logger.info(f"Request ID: {context.request_id}")
```

### 2. Use X-Ray for Tracing
```python
from aws_xray_sdk.core import xray_recorder

@xray_recorder.capture('process_request')
def process_request(data):
    # Processing logic
    pass
```

### 3. Local Testing with SAM
```bash
# Test Lambda locally
sam local start-api --env-vars env.json

# Invoke specific function
sam local invoke MainApiFunction --event events/test.json
```

## Performance Issues

### Slow API Response Times

**Diagnosis Steps**:
1. Check CloudWatch Logs for duration
2. Enable X-Ray tracing
3. Review cold start frequency
4. Analyze database query performance

**Common Causes**:
- Cold starts
- Inefficient database queries
- Large response payloads
- Synchronous operations that should be async

### High Lambda Costs

**Optimization Strategies**:
1. Right-size memory allocation
2. Reduce execution time
3. Use ARM architecture (Graviton2)
4. Implement caching
5. Batch operations

## Security Issues

### Exposed Secrets in Logs

**Prevention**:
```python
# Never log sensitive data
logger.info(f"User {user_id} authenticated")  # Good
# logger.info(f"Token: {token}")  # Bad!

# Sanitize error messages
try:
    # operation
except Exception as e:
    # Don't expose internal details
    logger.error("Authentication failed")
    # Not: logger.error(f"DB connection failed: {connection_string}")
```

### IAM Permission Errors

**Debugging**:
```bash
# Use IAM Policy Simulator
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::account:role/LambdaRole \
    --action-names s3:GetObject \
    --resource-arns arn:aws:s3:::bucket/*
```

## Monitoring and Alerts

### Key Metrics to Monitor
1. API Gateway 4xx/5xx errors
2. Lambda duration and errors
3. Database CPU and connections
4. SQS queue depth
5. DLQ message count

### Alert Configuration
```python
# High error rate alarm
alarm = cloudwatch.Alarm(
    self, "HighErrorRate",
    metric=api.metric_count("4XXError"),
    threshold=10,
    evaluation_periods=2,
    datapoints_to_alarm=2
)
```

## Recovery Procedures

### Database Recovery
```bash
# Point-in-time recovery
aws rds restore-db-cluster-to-point-in-time \
    --source-db-cluster-identifier prod-cluster \
    --target-db-cluster-identifier recovered-cluster \
    --restore-to-time 2024-01-01T12:00:00Z
```

### Lambda Rollback
```bash
# Rollback to previous version
aws lambda update-alias \
    --function-name my-function \
    --name PROD \
    --function-version 42
```

## Prevention Strategies

### Pre-deployment Checklist
- [ ] Run unit tests
- [ ] Run integration tests
- [ ] Check CloudFormation drift
- [ ] Review security groups
- [ ] Verify environment variables
- [ ] Test in staging environment
- [ ] Review cost implications
- [ ] Update documentation

### Post-deployment Verification
- [ ] Check CloudWatch Logs
- [ ] Verify API endpoints
- [ ] Test critical user flows
- [ ] Monitor error rates
- [ ] Check performance metrics
- [ ] Verify backups

## Getting Help

### Resources
- AWS Support Center
- AWS Forums
- Stack Overflow
- GitHub Issues
- Team Slack channel

### Information to Provide
1. Error message and stack trace
2. Environment (dev/staging/prod)
3. Recent changes
4. CloudWatch Logs
5. X-Ray traces
6. Steps to reproduce