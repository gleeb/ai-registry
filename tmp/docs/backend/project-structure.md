# Backend Project Structure

## Directory Overview

```
backend/
├── lambdas/                     # Lambda function implementations
│   ├── __init__.py
│   ├── main_api/                # Main API handler
│   ├── bedrock_chat/            # AI chat integration
│   ├── auth/                    # Authentication functions
│   ├── admin/                   # Admin operations
│   ├── document_processing/     # Document handling
│   ├── combined_authorizer/     # API authorization
│   ├── cloudfront_authorizer/   # CloudFront verification
│   └── db_migration/            # Database migrations
├── infra/                       # Infrastructure as Code
│   ├── app.py                   # CDK app entry point
│   ├── cdk.json                 # CDK configuration
│   ├── config.json              # Environment configurations
│   ├── stacks/                  # CDK stack definitions
│   └── cdk_constructs/          # Reusable CDK constructs
├── packages/                    # Shared Python packages
│   └── common/                  # Common utilities
├── tests/                       # Test files
│   ├── unit/                    # Unit tests
│   ├── integration/             # Integration tests
│   └── events/                  # Test event fixtures
└── scripts/                     # Utility scripts
    └── generate_sam_env.py      # SAM environment generator
```

## Lambda Functions Structure

### Standard Lambda Function Layout
Each Lambda function follows a consistent structure:

```
lambdas/function_name/
├── __init__.py                  # Package initialization
├── requirements.txt             # Function-specific dependencies
└── src/
    ├── __init__.py
    ├── handler.py               # Main handler function
    ├── utils.py                 # Utility functions
    ├── validators.py            # Input validation
    └── services/                # Business logic services
        ├── __init__.py
        └── service.py
```

### Main API Lambda (`lambdas/main_api/`)
Central API handler for core business operations.

```python
# src/handler.py structure
import json
import logging
import os
from typing import Dict, Any

logger = logging.getLogger()
logger.setLevel(os.getenv("LOG_LEVEL", "INFO"))

def handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """Main Lambda handler."""
    try:
        # Route handling
        route_key = event.get("routeKey", "")
        
        if route_key == "GET /api/health":
            return handle_health_check(event, context)
        elif route_key == "GET /api/user":
            return get_user(event, context)
        # ... more routes
        
    except Exception as e:
        logger.error(f"Error: {str(e)}", exc_info=True)
        return error_response(500, str(e))
```

### Bedrock Chat Lambda (`lambdas/bedrock_chat/`)
AI-powered chat functionality with streaming support.

```
bedrock_chat/
├── requirements.txt
│   # boto3
│   # aws-lambda-powertools
│   # pydantic
└── src/
    ├── handler.py               # Main handler with streaming
    ├── models.py                # Pydantic models
    ├── bedrock_client.py        # Bedrock service wrapper
    └── streaming.py             # SSE streaming utilities
```

### Combined Authorizer Lambda (`lambdas/combined_authorizer/`)
JWT and CloudFront authorization.

```python
# Key components
src/
├── handler.py                   # Authorization logic
├── jwt_validator.py             # JWT token validation
├── cloudfront_validator.py      # CloudFront header validation
└── policies.py                  # IAM policy generation
```

## Infrastructure Code Structure

### CDK Application (`infra/`)

```
infra/
├── app.py                       # CDK app entry point
├── cdk.json                     # CDK configuration
├── config.json                  # Environment configurations
├── requirements.txt             # CDK dependencies
├── stacks/                      # Stack definitions
│   ├── __init__.py
│   ├── core/                    # Foundation stacks
│   │   ├── base_stack.py        # Base stack class
│   │   ├── vpc_stack.py         # VPC configuration
│   │   └── config_utils.py      # Configuration utilities
│   ├── storage/                 # Data storage stacks
│   │   ├── database_stack.py    # Aurora PostgreSQL
│   │   └── storage_stack.py     # S3 buckets
│   └── application/             # Application stacks
│       ├── api_stack.py         # API Gateway + Lambda
│       ├── auth_stack.py        # Cognito configuration
│       └── db_migration_stack.py # Migration Lambda
└── cdk_constructs/              # Reusable constructs
    └── __init__.py
```

### Stack Organization Principles
1. **Separation of Concerns**: Each stack has a single responsibility
2. **Dependency Management**: Clear inter-stack dependencies
3. **Environment Configuration**: Environment-specific settings in config.json
4. **Reusability**: Common patterns in constructs

## Shared Packages (`packages/`)

### Common Package Structure
```
packages/common/
├── pyproject.toml               # Package configuration
├── src/
│   └── common/
│       ├── __init__.py
│       ├── database/            # Database utilities
│       │   ├── connection.py    # Connection pooling
│       │   ├── models.py        # SQLAlchemy models
│       │   └── queries.py       # Common queries
│       ├── validators/          # Input validation
│       │   ├── schemas.py       # Pydantic schemas
│       │   └── sanitizers.py    # Input sanitization
│       ├── utils/               # General utilities
│       │   ├── datetime.py      # Date/time helpers
│       │   ├── crypto.py        # Cryptographic functions
│       │   └── aws.py           # AWS service helpers
│       └── exceptions/          # Custom exceptions
│           └── errors.py
└── tests/
    └── test_common.py
```

## Configuration Management

### Environment Configuration (`config.json`)
```json
{
  "project_name": "testmeout",
  "default_region": "il-central-1",
  "default_environment": "dev",
  "environments": {
    "dev": {
      "vpc": {
        "create_new_vpc": true,
        "vpc_id": null
      },
      "database": {
        "instance_type": "t4g.medium",
        "deletion_protection": false
      },
      "lambda": {
        "memory_size": 512,
        "timeout_minutes": 5
      },
      "api": {
        "throttle_rate": 100,
        "throttle_burst": 200
      }
    },
    "prod": {
      "vpc": {
        "create_new_vpc": false,
        "vpc_id": "vpc-xxxxx"
      },
      "database": {
        "instance_type": "r6g.large",
        "deletion_protection": true
      },
      "lambda": {
        "memory_size": 1024,
        "timeout_minutes": 15
      }
    }
  }
}
```

### CDK Configuration (`cdk.json`)
```json
{
  "app": "python3 app.py",
  "context": {
    "@aws-cdk/core:stackRelativeExports": true,
    "@aws-cdk/aws-lambda:recognizeLayerVersion": true,
    "@aws-cdk/core:checkSecretUsage": true,
    "environment": "dev"
  }
}
```

## Testing Structure

### Test Organization
```
tests/
├── conftest.py                  # Pytest configuration
├── unit/                        # Unit tests
│   ├── test_main_api.py
│   ├── test_bedrock_chat.py
│   ├── test_combined_authorizer.py
│   └── test_db_migration_handler.py
├── integration/                 # Integration tests
│   ├── test_api_integration.py
│   ├── test_database_integration.py
│   └── test_bedrock_integration.py
└── events/                      # Test event fixtures
    ├── api_gateway_event.json
    ├── sqs_event.json
    └── cognito_event.json
```

### Test File Structure
```python
# tests/unit/test_main_api.py
import json
import pytest
from unittest.mock import patch, MagicMock
from lambdas.main_api.src.handler import handler

class TestMainApiHandler:
    """Test cases for main API handler."""
    
    @pytest.fixture
    def api_gateway_event(self):
        """API Gateway event fixture."""
        with open("tests/events/api_gateway_event.json") as f:
            return json.load(f)
    
    def test_health_check(self, api_gateway_event):
        """Test health check endpoint."""
        event = api_gateway_event
        event["rawPath"] = "/api/health"
        
        response = handler(event, None)
        
        assert response["statusCode"] == 200
        body = json.loads(response["body"])
        assert body["status"] == "healthy"
```

## Deployment Artifacts

### Lambda Deployment Package
```
# Build process creates:
.aws-sam/build/
├── MainApiFunction/
│   ├── handler.py
│   ├── requirements.txt
│   └── [dependencies]/
└── BedrockChatFunction/
    ├── handler.py
    ├── requirements.txt
    └── [dependencies]/
```

### Lambda Layers
```
layers/
├── common-layer/
│   └── python/
│       ├── common/              # Shared code
│       └── [shared dependencies]
└── dependencies-layer/
    └── python/
        └── [heavy dependencies]  # numpy, pandas, etc.
```

## File Naming Conventions

### Python Files
- **Modules**: `snake_case.py`
- **Classes**: `PascalCase` in files
- **Test files**: `test_*.py` or `*_test.py`
- **Config files**: `config.json`, `settings.py`

### Lambda Functions
- **Handler**: Always `handler.py` with `handler` function
- **Services**: `*_service.py` for business logic
- **Utils**: `utils.py` or `helpers.py`

### Infrastructure
- **Stacks**: `*_stack.py`
- **Constructs**: `*_construct.py`

## Import Organization

### Standard Import Order
```python
# 1. Standard library imports
import os
import json
from typing import Dict, Any

# 2. Third-party imports
import boto3
from pydantic import BaseModel

# 3. AWS Lambda Powertools
from aws_lambda_powertools import Logger, Tracer

# 4. Local application imports
from .utils import validate_input
from .services import UserService
```

## Environment Variables

### Lambda Environment Variables
```python
# Common environment variables
ENV_NAME = os.environ.get("ENV_NAME", "dev")
LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")
DATABASE_SECRET_ARN = os.environ.get("DATABASE_SECRET_ARN")
DOCUMENT_BUCKET = os.environ.get("DOCUMENT_BUCKET")
USER_POOL_ID = os.environ.get("USER_POOL_ID")
```

### Configuration Loading
```python
def load_config():
    """Load configuration from environment or defaults."""
    return {
        "database": {
            "host": os.environ.get("DB_HOST"),
            "port": int(os.environ.get("DB_PORT", 5432)),
            "name": os.environ.get("DB_NAME", "lawinfo")
        },
        "aws": {
            "region": os.environ.get("AWS_REGION", "il-central-1"),
            "profile": os.environ.get("AWS_PROFILE")
        }
    }
```

## Best Practices

### Code Organization
1. Keep Lambda functions focused and small
2. Extract shared code to layers or packages
3. Use consistent file structure across functions
4. Separate business logic from handler code
5. Implement proper error handling

### Dependency Management
1. Minimize function-specific dependencies
2. Use Lambda layers for shared dependencies
3. Pin dependency versions in requirements.txt
4. Regular security updates
5. Monitor package sizes

### Configuration
1. Use environment variables for configuration
2. Never hardcode sensitive values
3. Use AWS Secrets Manager for secrets
4. Implement configuration validation
5. Document all required variables

### Testing
1. Maintain test coverage above 80%
2. Use fixtures for test data
3. Mock external services
4. Test error scenarios
5. Implement integration tests

### Documentation
1. Document all public functions
2. Include type hints
3. Provide usage examples
4. Maintain up-to-date README files
5. Document environment requirements