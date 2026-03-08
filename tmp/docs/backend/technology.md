# Backend Technology Stack

## Core Technologies

### Python 3.12
**Runtime Environment**: AWS Lambda Python 3.12

Python serves as the primary programming language for all backend Lambda functions, chosen for its excellent AWS SDK support, extensive libraries for data processing, and strong community support.

**Key Features Used**:
- Type hints for better code maintainability
- Async/await for concurrent operations
- Dataclasses for structured data
- Context managers for resource management
- Decorators for cross-cutting concerns

**Why Python?**
- Native AWS SDK (boto3) support
- Excellent for data processing and AI/ML workloads
- Rich ecosystem of scientific and data libraries
- Quick development and deployment cycles
- Strong support for serverless patterns

### AWS Lambda
**Serverless Compute Platform**

Lambda provides the serverless execution environment for all backend business logic, offering automatic scaling, pay-per-use pricing, and zero server management.

**Configuration**: Lambda function configurations are defined in the CDK stacks. See `infra/stacks/application/api_stack.py` for specific Lambda settings and environment variables.

**Lambda Functions**:
- `main_api` - Core API endpoints
- `bedrock_chat` - AI chat integration
- `combined_authorizer` - Request authorization
- `document_processing` - Async document handling
- `auth` - Authentication hooks
- `admin` - Administrative operations
- `db_migration` - Database migrations

## API Layer

### AWS API Gateway HTTP API v2
**Modern HTTP API Service**

API Gateway HTTP API provides a cost-effective, low-latency HTTP API service with built-in JWT authorization.

**Features Used**:
- JWT authorizer with Cognito integration
- CORS configuration
- Request/response transformations
- Throttling and quotas
- CloudWatch integration

**Configuration**:
```python
# API Gateway configuration
http_api = apigatewayv2.HttpApi(
    self, "HttpApi",
    cors_configuration={
        "allow_origins": ["*"],
        "allow_methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["*"],
        "max_age": Duration.days(1)
    },
    disable_execute_api_endpoint=False  # Use CloudFront instead
)
```

### CloudFront CDN
**Content Delivery and Security**

CloudFront provides global content delivery, DDoS protection, and serves as a security layer.

**Configuration**:
- Origin: API Gateway endpoint
- Caching: Optimized for API responses
- Security: WAF integration
- Headers: Custom origin verification

## Database Technologies

### Aurora PostgreSQL 15.4
**Managed PostgreSQL Database**

Aurora PostgreSQL provides a highly available, scalable PostgreSQL-compatible database with automated backups and replication.

**Features**:
- Multi-AZ deployment for high availability
- Auto-scaling read replicas
- Automated backups with PITR
- Performance Insights
- Serverless v2 for auto-scaling

**Instance Configuration**:
```python
# Aurora cluster configuration
cluster = rds.DatabaseCluster(
    self, "AuroraCluster",
    engine=rds.DatabaseClusterEngine.aurora_postgres(
        version=rds.AuroraPostgresEngineVersion.VER_15_4
    ),
    instances=2,  # Writer + Reader
    instance_props={
        "instance_type": ec2.InstanceType("t4g.medium"),
        "vpc": vpc,
        "auto_minor_version_upgrade": True
    }
)
```

### pgvector Extension
**Vector Similarity Search**

pgvector enables storing and searching vector embeddings for semantic search capabilities.

**Version**: 0.5.0

**Usage**:
```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create embeddings table
CREATE TABLE document_embeddings (
    id UUID PRIMARY KEY,
    document_id UUID REFERENCES documents(id),
    embedding vector(1536),  -- OpenAI embedding dimension
    metadata JSONB
);

-- Create index for similarity search
CREATE INDEX ON document_embeddings 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

## AI/ML Services

### AWS Bedrock
**Managed Foundation Models**

Bedrock provides access to various AI foundation models for text generation, embeddings, and more.

**Available Models**:
```python
AVAILABLE_MODELS = {
    "claude-3-sonnet": {
        "id": "anthropic.claude-3-sonnet-20240229-v1:0",
        "max_tokens": 4096,
        "supports_streaming": True
    },
    "claude-3-haiku": {
        "id": "anthropic.claude-3-haiku-20240307-v1:0",
        "max_tokens": 4096,
        "supports_streaming": True
    },
    "claude-instant": {
        "id": "anthropic.claude-instant-v1",
        "max_tokens": 100000,
        "supports_streaming": True
    }
}
```

**Integration**:
```python
import boto3
from botocore.config import Config

# Bedrock client configuration
config = Config(
    region_name='us-east-1',
    retries={'max_attempts': 3, 'mode': 'adaptive'}
)

bedrock_runtime = boto3.client(
    'bedrock-runtime',
    config=config
)
```

## Storage Services

### Amazon S3
**Object Storage Service**

S3 provides durable, scalable object storage for documents, processed files, and static assets.

**Bucket Configuration**:
```python
# Document storage bucket
document_bucket = s3.Bucket(
    self, "DocumentBucket",
    versioned=True,
    encryption=s3.BucketEncryption.S3_MANAGED,
    lifecycle_rules=[
        s3.LifecycleRule(
            id="delete-old-versions",
            noncurrent_version_expiration=Duration.days(90)
        )
    ],
    cors=[
        s3.CorsRule(
            allowed_methods=[s3.HttpMethods.PUT, s3.HttpMethods.POST],
            allowed_origins=["*"],
            allowed_headers=["*"],
            max_age=3600
        )
    ]
)
```

**Features Used**:
- Versioning for document history
- Server-side encryption
- Lifecycle policies for cost optimization
- Signed URLs for secure uploads
- Event notifications for processing triggers

## Queue Services

### Amazon SQS
**Message Queue Service**

SQS provides reliable, scalable message queuing for asynchronous processing.

**Queue Configuration**:
```python
# Document processing queue
processing_queue = sqs.Queue(
    self, "ProcessingQueue",
    visibility_timeout=Duration.minutes(15),
    retention_period=Duration.days(14),
    dead_letter_queue=sqs.DeadLetterQueue(
        max_receive_count=3,
        queue=dlq
    ),
    encryption=sqs.QueueEncryption.KMS_MANAGED
)
```

**Features**:
- FIFO queues for ordered processing
- Dead letter queues for failed messages
- Long polling for efficiency
- Message attributes for metadata
- Batch operations for throughput

## Authentication & Authorization

### AWS Cognito
**User Authentication Service**

Cognito provides user authentication, authorization, and user management.

**Configuration**:
```python
user_pool = cognito.UserPool(
    self, "UserPool",
    self_sign_up_enabled=True,
    sign_in_aliases=cognito.SignInAliases(email=True),
    auto_verify=cognito.AutoVerifiedAttrs(email=True),
    password_policy=cognito.PasswordPolicy(
        min_length=8,
        require_lowercase=True,
        require_uppercase=True,
        require_digits=True,
        require_symbols=True
    ),
    mfa=cognito.Mfa.OPTIONAL,
    mfa_second_factor=cognito.MfaSecondFactor(
        sms=False,
        otp=True
    )
)
```

### JWT Token Validation
**Token-based Authentication**

JWT tokens issued by Cognito are validated in Lambda authorizers.

**Libraries**:
- `python-jose` - JWT parsing and validation
- `cryptography` - Cryptographic operations

## Infrastructure as Code

### AWS CDK
**Cloud Development Kit**

CDK enables defining cloud infrastructure using Python code.

**Version**: 2.170.0+

**Stack Organization**:
```python
# Stack structure
infra/
├── stacks/
│   ├── core/
│   │   ├── vpc_stack.py
│   │   └── base_stack.py
│   ├── storage/
│   │   ├── database_stack.py
│   │   └── storage_stack.py
│   └── application/
│       ├── api_stack.py
│       └── auth_stack.py
```

## Monitoring & Observability

### AWS CloudWatch
**Logging and Metrics**

CloudWatch provides centralized logging, metrics, and alarms.

**Features Used**:
- Structured JSON logging
- Custom metrics
- Log groups with retention policies
- Metric alarms
- Dashboards

### AWS X-Ray
**Distributed Tracing**

X-Ray provides end-to-end request tracing and performance analysis.

**Integration**:
```python
from aws_lambda_powertools import Tracer

tracer = Tracer()

@tracer.capture_lambda_handler
def handler(event, context):
    # Automatic tracing
    pass
```

## Development Tools

### AWS Lambda Powertools
**Lambda Development Utilities**

Lambda Powertools provides utilities for logging, tracing, and metrics.

**Version**: ^2.0.0

**Features**:
```python
from aws_lambda_powertools import Logger, Tracer, Metrics
from aws_lambda_powertools.metrics import MetricUnit

logger = Logger()
tracer = Tracer()
metrics = Metrics()

@logger.inject_lambda_context
@tracer.capture_lambda_handler
@metrics.log_metrics
def handler(event, context):
    logger.info("Processing request")
    metrics.add_metric(name="RequestCount", unit=MetricUnit.Count, value=1)
    return response
```

### Boto3
**AWS SDK for Python**

Boto3 provides Python interface to AWS services.

**Version**: Latest

**Common Usage**:
```python
import boto3

# Service clients
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
bedrock = boto3.client('bedrock-runtime')
secrets = boto3.client('secretsmanager')
```

## Testing Tools

### pytest
**Testing Framework**

pytest provides comprehensive testing capabilities.

**Version**: ^7.0.0

**Features Used**:
- Fixtures for test setup
- Parameterized tests
- Mocking with pytest-mock
- Coverage with pytest-cov
- Async test support

### moto
**AWS Service Mocking**

moto provides mocking for AWS services in tests.

**Version**: ^4.0.0

**Usage**:
```python
import boto3
from moto import mock_s3

@mock_s3
def test_s3_operations():
    s3 = boto3.client('s3')
    s3.create_bucket(Bucket='test-bucket')
    # Test S3 operations
```

## Package Management

### pip
**Python Package Manager**

pip manages Python dependencies for Lambda functions.

**Requirements Management**:
```txt
# requirements.txt
boto3>=1.26.0
aws-lambda-powertools>=2.0.0
python-jose[cryptography]>=3.3.0
psycopg2-binary>=2.9.0
pydantic>=2.0.0
```

### Lambda Layers
**Shared Dependencies**

Lambda Layers provide shared code and dependencies across functions.

**Common Layer Structure**:
```
layers/
├── common/
│   └── python/
│       ├── utils/
│       ├── database/
│       └── validators/
└── dependencies/
    └── python/
        └── [pip packages]
```

## Security Libraries

### cryptography
**Cryptographic Operations**

Provides cryptographic primitives and recipes.

**Version**: ^41.0.0

**Usage**:
- JWT signature verification
- Password hashing
- Encryption/decryption
- Secure random generation

### python-jose
**JWT Implementation**

Handles JWT creation and validation.

**Version**: ^3.3.0

**Usage**:
```python
from jose import jwt

# Decode and verify JWT
payload = jwt.decode(
    token,
    key,
    algorithms=['RS256'],
    audience=client_id
)
```

## Data Processing

### pandas
**Data Analysis Library**

Used for data manipulation in document processing.

**Version**: ^2.0.0

**Usage**:
- CSV/Excel file processing
- Data transformation
- Statistical analysis

### numpy
**Numerical Computing**

Provides support for large arrays and matrices.

**Version**: ^1.24.0

**Usage**:
- Vector operations
- Embedding manipulation
- Mathematical computations

## Best Practices

### Technology Selection Criteria
1. AWS-native services for better integration
2. Serverless-first approach for scalability
3. Managed services to reduce operational overhead
4. Open-source tools with strong community support
5. Security and compliance considerations

### Version Management
1. Pin major versions in production
2. Regular security updates
3. Test thoroughly before upgrades
4. Use Lambda layers for dependency management
5. Monitor for deprecations

### Performance Considerations
1. Choose appropriate Lambda memory sizes
2. Use connection pooling for databases
3. Implement caching strategies
4. Optimize cold start times
5. Monitor and tune regularly