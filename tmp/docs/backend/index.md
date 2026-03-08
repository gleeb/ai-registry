# Backend Documentation

## Overview

The backend of the Legal Information System is built on AWS serverless architecture, utilizing Lambda functions for compute, API Gateway for HTTP endpoints, and various AWS services for data storage and processing. The system is designed for scalability, cost-efficiency, and high availability.

## Architecture Overview

The backend follows a serverless, event-driven architecture with clear separation of concerns:

```
backend/
├── lambdas/              # Lambda function implementations
│   ├── main_api/         # Main API handler
│   ├── bedrock_chat/     # AI chat integration
│   ├── auth/             # Authentication functions
│   ├── admin/            # Admin operations
│   ├── document_processing/ # Document handling
│   └── combined_authorizer/ # API authorization
├── infra/                # CDK infrastructure code
│   ├── stacks/           # CDK stack definitions
│   └── config.json       # Environment configurations
└── packages/             # Shared Python packages
    └── common/           # Common utilities
```

## Core Technologies

- **Runtime**: Python 3.12 on AWS Lambda
- **API Layer**: AWS API Gateway HTTP API v2
- **AI Services**: AWS Bedrock (Claude, GPT models)
- **Database**: Aurora PostgreSQL with pgvector extension
- **Storage**: S3 for document storage
- **Queue**: SQS for asynchronous processing
- **Authentication**: AWS Cognito with JWT tokens
- **Infrastructure**: AWS CDK for IaC

## Documentation Sections

### 📚 [Technology Stack](./technology.md)
Comprehensive overview of backend technologies, AWS services, and architectural decisions behind the serverless implementation.

### 📁 [Project Structure](./project-structure.md)
Detailed guide to the backend code organization, Lambda function structure, and shared package architecture.

### 🚀 [API Reference](./api.md)
Complete API documentation including endpoints, request/response formats, authentication requirements, and OpenAPI specification.

### 🔐 [Authentication & Authorization](./authentication.md)
Backend authentication implementation including JWT validation, Cognito integration, and API authorization patterns.

### 🗄️ [Database Design](./database.md)
PostgreSQL database schema, pgvector configuration for semantic search, and data access patterns.

### ⚡ [Lambda Functions](./lambda-functions.md)
Detailed documentation for each Lambda function including triggers, environment variables, and business logic.

### 🤖 [Bedrock Integration](./bedrock-integration.md)
AWS Bedrock configuration for AI models, streaming responses, and prompt engineering patterns.

### 🤖 [Inline Agents](./inline-agents.md)
Advanced AWS Bedrock inline agent capabilities with MCP server integration, session management, and tool execution.

### 🔌 [MCP Integration](./mcp-integration.md)
Model Context Protocol server integration for external tools, knowledge bases, and specialized capabilities.

### 📨 [Message Queue](./message-queue.md)
SQS configuration for asynchronous document processing, dead letter queues, and retry policies.

## Quick Start

### Prerequisites
- Python 3.12+
- AWS CLI configured with appropriate permissions
- AWS CDK CLI installed
- Docker for local testing

### Local Development Setup
```bash
# Navigate to backend directory
cd lambdas

# Install development dependencies
pip install -r requirements-dev.txt

# Set up environment variables
cp env.example .env
# Edit .env with your configuration

# Run tests
pytest tests/
```

### Key Environment Variables
```env
# AWS Configuration
AWS_REGION=il-central-1
AWS_PROFILE=Eng-Sandbox

# Database
DATABASE_SECRET_ARN=arn:aws:secretsmanager:region:account:secret:name
DATABASE_NAME=lawinfo

# S3 Storage
DOCUMENT_BUCKET=lawinfo-documents
PROCESSED_BUCKET=lawinfo-processed

# Bedrock
BEDROCK_REGION=us-east-1
BEDROCK_MODEL_ID=anthropic.claude-3-sonnet

# Cognito
USER_POOL_ID=region_xxxxx
USER_POOL_CLIENT_ID=xxxxx

# Environment
ENV_NAME=dev
LOG_LEVEL=INFO
```

## Lambda Function Overview

### Main API Lambda (`main_api`)
Central API handler for core business operations:
- Health checks
- User profile management
- Document operations
- Admin endpoints

### Bedrock Chat Lambda (`bedrock_chat`)
AI-powered chat functionality:
- Model selection
- Streaming responses
- Thought process capture
- Context management

### Combined Authorizer Lambda (`combined_authorizer`)
API Gateway authorizer for request validation:
- JWT token validation
- CloudFront header verification
- Permission checking
- Rate limiting

### Document Processing Lambda (`document_processing`)
Asynchronous document handling:
- PDF text extraction
- Vector embedding generation
- Metadata extraction
- Storage management

### Auth Lambda (`auth`)
Authentication-related operations:
- Email domain validation
- User registration hooks
- MFA management
- Password policies

## API Architecture

### RESTful Design
```
GET    /api/health           # Health check (public)
GET    /api/user             # Get user profile
POST   /api/chat             # Send chat message
POST   /api/chat/stream      # Stream chat response
GET    /api/chat/models      # List available models
POST   /api/documents        # Upload document
GET    /api/documents/{id}   # Get document details
DELETE /api/documents/{id}   # Delete document
GET    /api/admin/status     # Admin status
```

### Authentication Flow
1. Client obtains JWT from Cognito
2. JWT included in Authorization header
3. Combined Authorizer validates token
4. Lambda function receives validated context
5. Response returned with appropriate headers

## Database Architecture

### Core Tables
- `users` - User profiles and preferences
- `documents` - Document metadata and status
- `conversations` - Chat conversation history
- `messages` - Individual chat messages
- `embeddings` - Vector embeddings for search

### Vector Search
Utilizing pgvector for semantic search:
```sql
-- Example similarity search
SELECT id, content, 1 - (embedding <=> $1) as similarity
FROM documents
WHERE 1 - (embedding <=> $1) > 0.7
ORDER BY similarity DESC
LIMIT 10;
```

## Security Measures

### API Security
- JWT authentication for all protected endpoints
- CloudFront + WAF for DDoS protection
- API Gateway throttling and quotas
- Request validation and sanitization

### Data Security
- Encryption at rest (S3, RDS)
- Encryption in transit (TLS)
- Secrets Manager for credentials
- IAM roles with least privilege

### Compliance
- GDPR-compliant data handling
- Audit logging with CloudWatch
- Data retention policies
- PII data protection

## Performance Optimization

### Lambda Optimization
- Provisioned concurrency for critical functions
- Connection pooling for database
- Lambda layers for shared dependencies
- Memory and timeout tuning

### API Performance
- CloudFront caching for static responses
- API Gateway caching for GET requests
- Response compression
- Pagination for large datasets

### Database Performance
- Read replicas for scaling
- Connection pooling
- Query optimization
- Index management

## Monitoring and Observability

### CloudWatch Integration
- Structured logging with correlation IDs
- Custom metrics for business KPIs
- Alarms for error rates and latency
- Dashboard for system overview

### AWS X-Ray Tracing
- End-to-end request tracing
- Performance bottleneck identification
- Service map visualization
- Error analysis

## Development Workflow

### Testing Strategy
```bash
# Unit tests
pytest tests/unit/

# Integration tests
pytest tests/integration/

# Local Lambda testing
sam local start-api --env-vars sam-env.json

# Coverage report
pytest --cov=lambdas --cov-report=html
```

### Deployment Process
```bash
# Deploy to development
cdk deploy "*-dev" --profile Eng-Sandbox

# Deploy to staging
cdk deploy "*-staging" --profile Eng-Sandbox

# Deploy to production
cdk deploy "*-prod" --profile Eng-Prod
```

## Error Handling

### Standard Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input parameters",
    "details": {
      "field": "email",
      "reason": "Invalid email format"
    }
  },
  "requestId": "abc-123-def",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

### Error Categories
- `4xx` - Client errors (validation, auth)
- `5xx` - Server errors (internal, dependencies)
- Custom error codes for business logic

## Best Practices

### Code Organization
1. One Lambda per business domain
2. Shared code in Lambda layers
3. Environment-specific configurations
4. Comprehensive error handling
5. Structured logging

### Security
1. Never log sensitive data
2. Validate all inputs
3. Use least privilege IAM
4. Rotate secrets regularly
5. Monitor for anomalies

### Performance
1. Optimize cold starts
2. Use connection pooling
3. Implement caching strategies
4. Monitor and tune regularly
5. Use async processing when possible

## Related Documentation

- [Frontend Documentation](../frontend/index.md) - Frontend integration
- [CDK Architecture](../other/cdk-architecture.md) - Infrastructure details
- [Deployment Guide](../other/deployment-guide.md) - Deployment procedures

## Resources

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [API Gateway Documentation](https://docs.aws.amazon.com/apigateway/)
- [AWS Bedrock Guide](https://docs.aws.amazon.com/bedrock/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)