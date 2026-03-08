# VPC Configuration Guide

## Overview

This guide explains how to configure the Legal Information System to deploy into existing AWS VPCs or create new ones, covering network architecture, security groups, and connectivity requirements. The VPC configuration supports two deployment modes with comprehensive validation and troubleshooting capabilities.

## VPC Deployment Modes

### Mode 1: Create New VPC (Default)
The stack creates a new VPC with all necessary networking components including public and private subnets, NAT gateways, and security groups.

### Mode 2: Use Existing VPC
The stack deploys into an existing VPC with optional subnet specification for database and Lambda resources.

## Configuration File

VPC configuration is managed through `infra/config.json` with environment-specific settings:

```json
{
  "environments": {
    "<environment-name>": {
      "vpc": {
        "create_new_vpc": boolean,
        "vpc_id": string | null,
        "database_subnet_ids": string[] | null,
        "lambda_subnet_ids": string[] | null
      }
    }
  }
}
```

### Configuration Parameters

| Parameter | Type | Description | Default | Required |
|-----------|------|-------------|---------|----------|
| `create_new_vpc` | boolean | Whether to create a new VPC | `true` | Yes |
| `vpc_id` | string | ID of existing VPC to use | `null` | Required if `create_new_vpc` is `false` |
| `database_subnet_ids` | array | Specific subnet IDs for Aurora database | `null` | No |
| `lambda_subnet_ids` | array | Specific subnet IDs for Lambda functions | `null` | No |

## Mode 1: Create New VPC (Default)

When `create_new_vpc` is `true`, the stack creates a new VPC with comprehensive networking infrastructure:

### Network Architecture
```
VPC (10.0.0.0/16)
├── AZ-1 (il-central-1a)
│   ├── Public Subnet (10.0.0.0/24)
│   │   ├── NAT Gateway
│   │   └── Internet Gateway
│   └── Private Subnet (10.0.2.0/24)
│       ├── Aurora Database
│       └── Lambda Functions
└── AZ-2 (il-central-1b)
    ├── Public Subnet (10.0.1.0/24)
    │   └── NAT Gateway
    └── Private Subnet (10.0.3.0/24)
        ├── Aurora Database (Replica)
        └── Lambda Functions
```

### Infrastructure Components
- **CIDR Block**: 10.0.0.0/16
- **Availability Zones**: 2 AZs for high availability
- **Public Subnets**: 10.0.0.0/24, 10.0.1.0/24 (for NAT Gateways)
- **Private Subnets**: 10.0.2.0/24, 10.0.3.0/24 (for Aurora and Lambda)
- **Internet Gateway**: For public subnet internet access
- **NAT Gateways**: One per AZ for private subnet outbound access
- **Route Tables**: Proper routing for public and private subnets

### Configuration Example
```json
{
  "environments": {
    "dev": {
      "vpc": {
        "create_new_vpc": true,
        "vpc_id": null,
        "database_subnet_ids": null,
        "lambda_subnet_ids": null
      }
    }
  }
}
```

### Deployment
```bash
# Deploy with new VPC
cdk deploy -c environment=dev
```

## Deployment Process

### Step 1: Identify VPC Resources

```bash
# List available VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table

# List subnets in a VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-0123456789abcdef0" \
  --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table

# Check route tables for internet access
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-0123456789abcdef0" \
  --query 'RouteTables[*].Routes[?GatewayId!=`local`].[RouteTableId,DestinationCidrBlock,GatewayId]' --output table
```

### Step 2: Update Configuration

Update `infra/config.json` with your VPC details:

```json
{
  "environments": {
    "prod": {
      "vpc": {
        "create_new_vpc": false,
        "vpc_id": "YOUR_VPC_ID",
        "database_subnet_ids": [
          "YOUR_DB_SUBNET_1",
          "YOUR_DB_SUBNET_2"
        ],
        "lambda_subnet_ids": [
          "YOUR_LAMBDA_SUBNET_1",
          "YOUR_LAMBDA_SUBNET_2"
        ]
      }
    }
  }
}
```

### Step 3: Validate Configuration

```bash
# Synthesize to check for errors
cdk synth -c environment=prod

# Compare with existing deployment
cdk diff -c environment=prod
```

### Step 4: Deploy

```bash
# Deploy to production
cdk deploy -c environment=prod --require-approval never
```

### Step 5: Verify Deployment

```bash
# Check stack outputs
aws cloudformation describe-stacks --stack-name LawInfoStack-prod \
  --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' --output table

# Verify database connectivity (from Lambda subnet)
aws rds describe-db-clusters --db-cluster-identifier lawinfo-database-cluster
```

## Mode 2: Use Existing VPC

When `create_new_vpc` is `false`, the stack uses an existing VPC. You must provide the VPC ID, and optionally specific subnet IDs.

### Basic Configuration (Auto-Select Subnets)
```json
{
  "environments": {
    "prod": {
      "vpc": {
        "create_new_vpc": false,
        "vpc_id": "vpc-0123456789abcdef0",
        "database_subnet_ids": null,
        "lambda_subnet_ids": null
      }
    }
  }
}
```

With this configuration:
- Database will use private subnets with egress capability
- Lambda functions will use private subnets with egress capability
- CDK automatically selects appropriate subnets

### Advanced Configuration (Specific Subnets)
```json
{
  "environments": {
    "prod": {
      "vpc": {
        "create_new_vpc": false,
        "vpc_id": "vpc-0123456789abcdef0",
        "database_subnet_ids": [
          "subnet-0123456789abcdef0",
          "subnet-0123456789abcdef1"
        ],
        "lambda_subnet_ids": [
          "subnet-0123456789abcdef2",
          "subnet-0123456789abcdef3"
        ]
      }
    }
  }
}
```

## Subnet Requirements

### Database Subnets (Aurora PostgreSQL)

**Requirements:**
- **Type**: Private subnets (no direct internet access)
- **Count**: Minimum 2 subnets in different AZs
- **Outbound Access**: Must have internet access via NAT Gateway for Aurora updates
- **Port Access**: Security groups must allow PostgreSQL (port 5432)

**Recommended Setup:**
- Use dedicated database subnets separate from application subnets
- CIDR blocks should not overlap with other application subnets
- Consider using /28 or /27 subnets (16-32 IP addresses) for cost optimization

### Lambda Subnets

**Requirements:**
- **Type**: Private subnets with outbound internet access
- **Count**: Minimum 2 subnets in different AZs for high availability
- **Outbound Access**: Must have HTTPS (port 443) access to AWS APIs
- **Database Access**: Must be able to communicate with database subnets

**Recommended Setup:**
- Use application-tier private subnets
- Ensure security groups allow communication between Lambda and Aurora
- Consider Lambda ENI limits when sizing subnets

## Security Group Considerations

The stack creates the following security groups automatically:

### Database Security Group
- **Inbound**: PostgreSQL (5432) from VPC CIDR
- **Outbound**: None (restrictive)

### Lambda Security Groups
- **Inbound**: None (Lambda functions don't receive direct traffic)
- **Outbound**: HTTPS (443) to 0.0.0.0/0 for AWS API calls

## Network Architecture Examples

### Example 1: Simple Production Setup
```
VPC: 10.0.0.0/16 (Existing Corporate VPC)

Subnets:
├── Public Subnets (existing)
│   ├── 10.0.1.0/24 (us-east-1a) - NAT Gateway
│   └── 10.0.2.0/24 (us-east-1b) - NAT Gateway
│
├── Application Subnets (for Lambda)
│   ├── 10.0.10.0/24 (us-east-1a) - Private with NAT
│   └── 10.0.11.0/24 (us-east-1b) - Private with NAT
│
└── Database Subnets (for Aurora)
    ├── 10.0.20.0/28 (us-east-1a) - Private with NAT
    └── 10.0.21.0/28 (us-east-1b) - Private with NAT
```

**Configuration:**
```json
{
  "vpc": {
    "create_new_vpc": false,
    "vpc_id": "vpc-0a1b2c3d4e5f6g7h8",
    "database_subnet_ids": [
      "subnet-db1a1b2c3d4e5f6g7h8",
      "subnet-db2b3c4d5e6f7g8h9i0"
    ],
    "lambda_subnet_ids": [
      "subnet-app1c3d4e5f6g7h8i9j0",
      "subnet-app2d4e5f6g7h8i9j0k1"
    ]
  }
}
```

### Example 2: Shared VPC with Auto-Selection
```
VPC: 172.16.0.0/16 (Shared Corporate VPC)

Let CDK automatically select appropriate subnets:
- Database: Uses any private subnets with egress
- Lambda: Uses any private subnets with egress
```

**Configuration:**
```json
{
  "vpc": {
    "create_new_vpc": false,
    "vpc_id": "vpc-shared123456789",
    "database_subnet_ids": null,
    "lambda_subnet_ids": null
  }
}
```

## Deployment Process

### Step 1: Identify VPC Resources
```bash
# List available VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table

# List subnets in a VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-0123456789abcdef0" \
  --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table

# Check route tables for internet access
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=vpc-0123456789abcdef0" \
  --query 'RouteTables[*].Routes[?GatewayId!=`local`].[RouteTableId,DestinationCidrBlock,GatewayId]' --output table
```

### Step 2: Update Configuration
Update `infra/config.json` with your VPC details:

```json
{
  "environments": {
    "prod": {
      "vpc": {
        "create_new_vpc": false,
        "vpc_id": "YOUR_VPC_ID",
        "database_subnet_ids": [
          "YOUR_DB_SUBNET_1",
          "YOUR_DB_SUBNET_2"
        ],
        "lambda_subnet_ids": [
          "YOUR_LAMBDA_SUBNET_1",
          "YOUR_LAMBDA_SUBNET_2"
        ]
      }
    }
  }
}
```

### Step 3: Validate Configuration
```bash
# Synthesize to check for errors
cdk synth -c environment=prod

# Compare with existing deployment
cdk diff -c environment=prod
```

### Step 4: Deploy
```bash
# Deploy to production
cdk deploy -c environment=prod --require-approval never
```

### Step 5: Verify Deployment
```bash
# Check stack outputs
aws cloudformation describe-stacks --stack-name LawInfoStack-prod \
  --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' --output table

# Verify database connectivity (from Lambda subnet)
aws rds describe-db-clusters --db-cluster-identifier lawinfo-database-cluster
```

## VPC Endpoints

### AWS Service Endpoints
The VPC configuration supports optional VPC endpoints for improved security and performance:

- **S3 Gateway Endpoint**: Free gateway endpoint for S3 access
- **DynamoDB Gateway Endpoint**: Free gateway endpoint for DynamoDB access
- **Secrets Manager Interface Endpoint**: Interface endpoint for secure secrets access
- **Lambda Interface Endpoint**: Interface endpoint for Lambda service access

### Implementation
VPC endpoints are configured in `infra/stacks/core/vpc_stack.py`:

- **Gateway Endpoints**: Automatically added for S3 and DynamoDB
- **Interface Endpoints**: Conditionally added based on configuration
- **Security Groups**: Proper security group rules for endpoint access
- **DNS Resolution**: Automatic DNS resolution for endpoint services

## Security Groups

### Database Security Group
Database security groups are implemented in `infra/stacks/storage/database_stack.py`:

- **Inbound Rules**: PostgreSQL (5432) from Lambda security group
- **Outbound Rules**: None (restrictive for security)
- **Source**: Lambda security group for application access
- **Additional**: Optional bastion host access if configured

### Lambda Security Group
Lambda security groups are implemented in `infra/stacks/application/api_stack.py`:

**Configuration**:
- **Inbound Rules**: None (Lambda functions don't receive direct traffic)
- **Outbound Rules**: HTTPS (443) to 0.0.0.0/0 for AWS API calls
- **Database Access**: Outbound PostgreSQL (5432) to database security group
- **Internet Access**: Required for AWS service calls and external APIs

**VPC Lambda Deployment**:
- **All Lambda Functions**: Deployed within VPC for security isolation
- **Subnet Selection**: Uses ApplicationSubnetIds from VPC stack
- **Network Isolation**: Functions isolated from public internet
- **AWS Service Access**: Outbound internet access through NAT Gateway
- **Performance**: VPC deployment adds ~100ms cold start latency

**Subnet Requirements**:
- **Type**: Private subnets with egress (PRIVATE_WITH_EGRESS)
- **Connectivity**: Must have route to NAT Gateway for internet access
- **Security**: Network-level isolation while maintaining service access
- **Multi-AZ**: Functions distributed across availability zones

### VPC Endpoint Security Group
VPC endpoint security groups are configured in `infra/stacks/core/vpc_stack.py`:

- **Inbound Rules**: HTTPS (443) from VPC CIDR
- **Outbound Rules**: None (endpoints only receive traffic)
- **Scope**: Limited to VPC CIDR for security

## Network ACLs

### Private Subnet NACL
Network ACLs provide additional network-level security:

- **Inbound Rules**: HTTPS (443) and PostgreSQL (5432) from VPC
- **Outbound Rules**: All traffic to 0.0.0.0/0
- **Scope**: Applied to private subnets only
- **Logging**: VPC Flow Logs for audit trails

## DNS Configuration

### Route 53 Private Hosted Zone
Private DNS zones are configured for internal service discovery:

- **Zone Name**: `testmeout.internal`
- **Database Records**: Automatic A records for database endpoints
- **Lambda Records**: Service discovery for Lambda functions
- **Integration**: Automatic integration with VPC

## Monitoring and Logging

### VPC Flow Logs
Comprehensive network monitoring is implemented:

- **Flow Logs**: All VPC traffic logged to CloudWatch
- **Retention**: Configurable retention periods
- **Analysis**: CloudWatch Insights for traffic analysis
- **Alerts**: CloudWatch alarms for unusual traffic patterns

### Network Insights
Network troubleshooting tools are configured:

- **Network Paths**: Pre-configured paths for common connectivity tests
- **Troubleshooting**: Automated connectivity validation
- **Documentation**: Network architecture diagrams and documentation

## Connectivity Testing

### Database Connectivity Test
Database connectivity validation is implemented in `lambdas/main_api/src/handler.py`:

- **Connection Test**: Automatic database connectivity validation
- **Timeout Handling**: Proper connection timeouts
- **Error Reporting**: Detailed error messages for troubleshooting
- **Health Checks**: Regular connectivity health checks

### Internet Connectivity Test
Internet connectivity validation for Lambda functions:

- **API Access**: Test AWS API connectivity
- **External APIs**: Test external service connectivity
- **Timeout Handling**: Proper timeout configuration
- **Error Reporting**: Detailed connectivity error reporting

## Troubleshooting

### Common Issues

#### 1. VPC Not Found
```
Error: Cannot find VPC with ID vpc-xyz
```

**Solutions:**
- Verify VPC ID exists: `aws ec2 describe-vpcs --vpc-ids vpc-xyz`
- Check AWS region matches your CDK deployment region
- Ensure AWS credentials have EC2 read permissions

#### 2. Insufficient Subnets
```
Error: Need at least 2 subnets in different AZs
```

**Solutions:**
- Provide subnets from at least 2 different availability zones
- Check subnet AZ distribution: `aws ec2 describe-subnets --subnet-ids subnet-1 subnet-2`

#### 3. No Internet Access
```
Error: Lambda function timeout / Aurora connection failed
```

**Solutions:**
- Verify private subnets have routes to NAT Gateway
- Check security group rules allow required traffic
- Ensure NAT Gateway has internet gateway route

#### 4. Database Connection Issues
```
Error: Could not connect to Aurora cluster
```

**Solutions:**
- Verify database and Lambda subnets can communicate
- Check security group rules for PostgreSQL (5432)
- Ensure Aurora is in same VPC as Lambda functions

### Debugging Commands
```bash
# Check VPC configuration
aws ec2 describe-vpcs --vpc-ids vpc-0123456789abcdef0

# Check subnet details
aws ec2 describe-subnets --subnet-ids subnet-0123456789abcdef0

# Check route tables
aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=subnet-0123456789abcdef0"

# Check security groups
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=vpc-0123456789abcdef0"

# Check NAT Gateways
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-0123456789abcdef0"

# Test connectivity from Lambda
aws lambda invoke --function-name lawinfo-main-api \
  --payload '{"test": "connectivity"}' response.json
```

## Migration Strategies

### Migrating to Existing VPC
1. **Prepare target VPC**
   - Ensure proper subnet configuration
   - Configure security groups
   - Set up VPC endpoints if needed

2. **Update configuration**
   ```json
   {
     "vpc": {
       "create_new_vpc": false,
       "vpc_id": "vpc-target",
       "database_subnet_ids": ["subnet-1", "subnet-2"],
       "lambda_subnet_ids": ["subnet-3", "subnet-4"]
     }
   }
   ```

3. **Deploy and test**
   ```bash
   cdk deploy DatabaseStack-prod -c environment=prod
   # Test connectivity
   cdk deploy ApiStack-prod -c environment=prod
   ```

### Blue-Green VPC Migration
1. Deploy to new VPC
2. Test thoroughly
3. Update DNS/load balancer
4. Monitor and rollback if needed
5. Cleanup old VPC

## Best Practices

### Security
1. **Least Privilege**: Use minimal required security group rules
2. **Network Segmentation**: Separate database and application subnets
3. **VPC Endpoints**: Use VPC endpoints for AWS services to avoid internet routing
4. **Network ACLs**: Consider additional network ACL restrictions
5. **Flow Logs**: Enable VPC Flow Logs for audit trails

### Performance
1. **Multi-AZ**: Always use subnets across multiple availability zones
2. **VPC Endpoints**: Use VPC endpoints for AWS services to reduce latency
3. **Subnet Sizing**: Use appropriate CIDR sizes to avoid IP waste
4. **Monitoring**: Set up VPC Flow Logs and CloudWatch monitoring

### Cost Optimization
1. **Gateway Endpoints**: Use Gateway endpoints (free) over Interface endpoints
2. **NAT Gateway**: Reuse existing NAT Gateways instead of creating new ones
3. **Subnet Sizing**: Use appropriate subnet sizes to avoid IP waste
4. **Consolidation**: Consolidate VPC endpoints across environments

### High Availability
1. **Multi-AZ**: Always use subnets across multiple availability zones
2. **Redundancy**: Ensure multiple paths for critical communications
3. **Monitoring**: Set up VPC Flow Logs and CloudWatch monitoring
4. **Testing**: Regular connectivity testing and validation

### Maintenance
1. **Documentation**: Document your VPC configuration and requirements
2. **Automation**: Use infrastructure as code for all network changes
3. **Testing**: Test connectivity after any network changes
4. **Reviews**: Regular network architecture reviews

## Implementation Files

### Core Infrastructure
- `infra/stacks/core/vpc_stack.py` - VPC and networking implementation
- `infra/stacks/core/config_utils.py` - Configuration validation utilities

### Storage Infrastructure
- `infra/stacks/storage/database_stack.py` - Database security group configuration
- `infra/stacks/storage/storage_stack.py` - Storage security group configuration

### Application Infrastructure
- `infra/stacks/application/api_stack.py` - Lambda security group configuration
- `infra/stacks/application/auth_stack.py` - Authentication security groups

### Configuration Files
- `infra/config.json` - VPC configuration settings
- `infra/env.example` - Environment variables template

## Related Documentation

- [CDK Architecture](./cdk-architecture.md) - Infrastructure architecture overview
- [Deployment Guide](./deployment-guide.md) - Step-by-step deployment instructions
- [Environment Configuration](./environment-config.md) - Environment management
- [Monitoring & Observability](./monitoring.md) - Network monitoring setup
- [Troubleshooting Guide](./troubleshooting.md) - Common network issues and solutions