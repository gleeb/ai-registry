# CloudFront & WAF Security Documentation

## Overview

This document explains the CloudFront and Web Application Firewall (WAF) security implementation for the Legal Information System, including origin protection, request filtering, and DDoS mitigation. The system enforces traffic through CloudFront with WAF protection to prevent direct API Gateway access.

## Architecture Overview

```
Internet → CloudFront → WAF → API Gateway → Lambda
             ↓                     ↓
        Secret Header         Combined Authorizer
        Origin Verification   (JWT + CloudFront)
```

## Security Layers

### 1. WAF Protection
- IP allowlisting (configured in environment)
- DDoS protection
- Rate limiting capabilities
- Request filtering

### 2. Combined Authorization
- **JWT Validation**: All protected endpoints require a valid JWT token from Cognito
- **CloudFront Header Validation**: When WAF is enabled, requests must also include the secret header (`x-origin-verify`)
- A single Lambda authorizer validates both requirements based on the `WAF_ENABLED` flag

### 3. Endpoint Protection

| Endpoint | Authorization | CloudFront Required | Purpose |
|----------|--------------|-------------------|---------|
| `/api/health` | None (public) | No | Health checks |
| `/api/user` | Combined Authorizer | Yes (if WAF enabled) | User data |
| `/api/admin/*` | Combined Authorizer | Yes (if WAF enabled) | Admin endpoints |
| Future endpoints | Combined Authorizer | Yes (if WAF enabled) | Automatically protected |

## CloudFront Configuration

### Distribution Setup
CloudFront distribution is configured in `infra/stacks/application/api_stack.py`:

- **Origin Access Identity**: For S3 static content (if applicable)
- **Custom Origin**: API Gateway with secret header verification
- **Viewer Protocol Policy**: Redirect to HTTPS
- **Allowed Methods**: All HTTP methods for API flexibility
- **Cache Policy**: Disabled for API responses, optimized for static content
- **Security Headers**: Comprehensive security headers policy
- **WAF Integration**: Web ACL attached for request filtering

### Security Headers Policy
Security headers are implemented in `infra/stacks/application/api_stack.py`:

- **Content Type Options**: Prevent MIME type sniffing
- **Frame Options**: Prevent clickjacking attacks
- **Referrer Policy**: Control referrer information
- **Strict Transport Security**: Enforce HTTPS connections
- **Content Security Policy**: Prevent XSS and injection attacks
- **Custom Headers**: API version and service identification

## WAF Configuration

### Web ACL Setup
WAF Web ACL is configured in `infra/stacks/application/api_stack.py`:

- **Rate Limiting Rule**: Prevent DDoS attacks with configurable limits
- **IP Allowlist Rule**: Restrict access to known IPs (production only)
- **AWS Managed Rules**: Common attack patterns and known bad inputs
- **Custom Rules**: Environment-specific security requirements
- **Visibility Configuration**: CloudWatch metrics and sampled requests

### IP Set Management
IP allowlisting is implemented in `infra/stacks/application/api_stack.py`:

- **IPv4 Support**: IPv4 address allowlisting
- **Environment-Specific**: Different IP sets per environment
- **CloudFormation Integration**: Managed through CDK
- **Monitoring**: CloudWatch metrics for IP-based blocks

## Origin Protection

### Secret Generation and Storage
Origin verification is implemented in `infra/stacks/application/api_stack.py`:

- **Secret Generation**: Cryptographically secure random secrets
- **AWS Secrets Manager**: Secure secret storage and rotation
- **CloudFormation Exports**: Cross-stack secret sharing
- **Custom Resource**: Secure secret retrieval for CloudFront

### Implementation Details
The combined authorizer validates both JWT tokens and CloudFront headers:

- **WAF Flag Check**: Environment-based WAF enablement
- **CloudFront Header Validation**: Secret header verification
- **JWT Token Validation**: Cognito token verification
- **Context Passing**: Validation status passed to Lambda functions

## Combined Authorization

### Lambda Authorizer Integration
The combined authorizer is implemented in `lambdas/combined_authorizer/src/handler.py`:

- **Environment Check**: WAF enablement based on environment
- **Header Validation**: CloudFront secret header verification
- **Token Validation**: JWT token from Cognito
- **Policy Generation**: Allow/deny policies with user context
- **Error Handling**: Comprehensive error logging and reporting

### API Stack Configuration
API Gateway configuration in `infra/stacks/application/api_stack.py`:

- **WafHttpApi**: Creates CloudFront distribution and generates secret
- **Secret Storage**: SSM Parameter Store for secret management
- **Authorizer Integration**: Combined authorizer for all protected routes
- **Environment Variables**: WAF enablement flag for Lambda functions

## Testing

### Test Direct Access (Should Fail When WAF Enabled)
```bash
# Without JWT token - returns 401
curl https://your-api-id.execute-api.region.amazonaws.com/api/user

# With JWT but without CloudFront header (when WAF enabled) - returns 403
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  https://your-api-id.execute-api.region.amazonaws.com/api/user
```

### Test Through CloudFront (Should Succeed)
```bash
# With valid JWT token
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  https://your-cloudfront-domain.cloudfront.net/api/user
```

### Test with Different Scenarios

#### WAF Disabled (Development)
```bash
# Only JWT required
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  https://your-api-id.execute-api.region.amazonaws.com/api/user
```

#### WAF Enabled (Production)
```bash
# Must go through CloudFront
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  https://your-cloudfront-domain.cloudfront.net/api/user
```

### Test with Secret Header (For Development Only)
```bash
# Get the secret from CloudFormation outputs
SECRET=$(aws cloudformation describe-stacks --stack-name YourStackName --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontSecretHeader`].OutputValue' --output text)

# Test with both JWT and CloudFront header
curl -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -H "$SECRET" \
     https://your-api-id.execute-api.region.amazonaws.com/api/user
```

**⚠️ WARNING**: The CloudFront secret header output is for testing only and should be removed in production!

## WebSocket Support

The combined authorizer also works with WebSocket APIs:

1. **Connection**: Validated during the `$connect` route
2. **Messages**: Authorization context passed through the connection
3. **CloudFront**: WebSocket connections also go through CloudFront when WAF is enabled

### WebSocket Configuration
WebSocket routes are configured in `infra/stacks/application/api_stack.py`:

- **Connection Route**: `$connect` route with combined authorizer
- **Message Routes**: Protected message handling routes
- **Disconnect Route**: `$disconnect` route for cleanup
- **Default Route**: `$default` route for unmatched messages

## Monitoring and Logging

### CloudWatch Metrics
Monitoring is implemented in `infra/stacks/application/api_stack.py`:

- **WAF Metrics**: Blocked requests, allowed requests, rate limiting
- **CloudFront Metrics**: Request count, error rates, cache hit ratios
- **Custom Metrics**: Application-specific security metrics
- **Alarms**: Automated alerting for security events

### Alarms
CloudWatch alarms are configured for security monitoring:

- **High Blocked Requests**: Alert on unusual WAF activity
- **CloudFront Error Rate**: Monitor for origin issues
- **Rate Limiting**: Alert on potential DDoS attacks
- **Custom Alarms**: Environment-specific security alerts

## Security Best Practices

### Request Filtering
1. **Rate Limiting**: Prevent DDoS attacks with configurable limits
2. **IP Allowlisting**: Restrict access to known IPs (production)
3. **Geographic Blocking**: Block requests from specific countries
4. **SQL Injection Protection**: AWS managed rules
5. **XSS Protection**: Content filtering rules

### Origin Protection
1. **Custom Headers**: Verify requests come through CloudFront
2. **Security Groups**: Restrict direct access to origin
3. **SSL/TLS**: Encrypt traffic between CloudFront and origin
4. **Access Logs**: Monitor and audit all requests

### Response Security
1. **Security Headers**: Implement OWASP recommendations
2. **Content Security Policy**: Prevent XSS attacks
3. **HSTS**: Force HTTPS connections
4. **X-Frame-Options**: Prevent clickjacking

### Security Best Practices
1. **Never expose the secret header value** in logs or error messages
2. **Rotate the secret** periodically by updating the stack
3. **Monitor direct access attempts** using CloudWatch metrics
4. **Use different authorization strategies** for different types of endpoints
5. **Keep the API Gateway endpoint private** - only share the CloudFront URL

## Limitations and Solutions

### Original HTTP API Limitations
- ❌ Cannot use resource policies (REST API feature)
- ❌ Cannot combine multiple authorizers on a single route
- ❌ Limited to JWT and Lambda authorizers

### Our Solution
- ✅ Single combined authorizer handles both JWT and CloudFront validation
- ✅ WAF protection controlled by environment flag
- ✅ Works with both HTTP and WebSocket APIs
- ✅ All future endpoints automatically protected

## Future Enhancements

1. **Custom Domain**: Add a custom domain to CloudFront for better branding
2. **Monitoring**: Add CloudWatch alarms for direct access attempts
3. **Rate Limiting**: Implement rate limiting at the WAF level
4. **Geographic Restrictions**: Add country-based access controls if needed

## Testing and Validation

### Security Testing
```bash
# Test rate limiting
for i in {1..2100}; do
  curl -s -o /dev/null -w "%{http_code}\n" https://api.testmeout.com/api/health &
done
wait

# Test blocked IPs (if IP allowlisting enabled)
curl -H "X-Forwarded-For: 192.168.1.1" https://api.testmeout.com/api/health

# Test security headers
curl -I https://api.testmeout.com/api/health
```

### Origin Protection Testing
```bash
# Test direct API access (should be blocked)
curl https://api-gateway-id.execute-api.region.amazonaws.com/api/health

# Test through CloudFront (should work)
curl https://api.testmeout.com/api/health
```

## Incident Response

### DDoS Attack Response
1. **Monitor WAF metrics** for unusual traffic patterns
2. **Adjust rate limits** if necessary
3. **Enable additional AWS Shield** if attack persists
4. **Implement geographic blocking** if attack originates from specific regions
5. **Contact AWS Support** for Advanced Shield customers

### False Positive Handling
False positive handling is implemented in `infra/stacks/application/api_stack.py`:

- **Exception Rules**: Allow trusted IPs to bypass certain rules
- **Custom Rules**: Environment-specific exception handling
- **Monitoring**: Track false positive rates
- **Rule Optimization**: Regular rule effectiveness review

## Cost Optimization

### CloudFront Optimization
1. **Price Class**: Use appropriate price class for target regions
2. **Caching**: Cache static content and appropriate API responses
3. **Compression**: Enable compression for text-based content
4. **Origin Shield**: Use for high-traffic scenarios

### WAF Optimization
1. **Rule Efficiency**: Order rules by likelihood of match
2. **Sampling**: Reduce sampling rate for cost savings
3. **Log Analysis**: Use logs to optimize rule effectiveness
4. **Regular Review**: Remove unnecessary rules

## Troubleshooting

### Common Issues

#### 1. CloudFront 403 Errors
```bash
# Check WAF logs
aws wafv2 get-sampled-requests \
  --web-acl-arn arn:aws:wafv2:us-east-1:account:global/webacl/name/id \
  --rule-metric-name RateLimitRule \
  --scope CLOUDFRONT \
  --time-window StartTime=2024-01-01T00:00:00Z,EndTime=2024-01-01T23:59:59Z \
  --max-items 100
```

#### 2. Origin Connection Issues
```bash
# Test origin connectivity
curl -H "x-origin-verify: secret" https://api-gateway.amazonaws.com/api/health

# Check security groups
aws ec2 describe-security-groups --group-ids sg-xxx
```

#### 3. Cache Issues
```bash
# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id DISTRIBUTION_ID \
  --paths "/*"
```

### Debug Tools
1. **CloudFront Real-time Logs**: Detailed request analysis
2. **WAF Sampled Requests**: Review blocked/allowed requests
3. **X-Ray Tracing**: End-to-end request tracing
4. **CloudWatch Insights**: Log analysis and querying

## Implementation Files

### Application Infrastructure
- `infra/stacks/application/api_stack.py` - CloudFront and WAF configuration
- `infra/stacks/application/auth_stack.py` - Authentication integration

### Lambda Functions
- `lambdas/combined_authorizer/src/handler.py` - Combined authorization logic
- `lambdas/combined_authorizer/src/cloudfront_validator.py` - CloudFront header validation

### Configuration Files
- `infra/config.json` - WAF and security configuration
- `infra/env.example` - Environment variables template

## Related Documentation

- [CDK Architecture](./cdk-architecture.md) - Infrastructure architecture overview
- [Backend Authentication](../backend/authentication.md) - JWT validation details
- [VPC Configuration](./vpc-configuration.md) - Network security setup
- [Monitoring & Observability](./monitoring.md) - Security monitoring
- [Troubleshooting Guide](./troubleshooting.md) - Security issue resolution