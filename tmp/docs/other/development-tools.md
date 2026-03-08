# Development Tools and Workflow

## Overview

This document covers the development tools, commands, and workflow configurations that support the Legal Information System development process.

## Makefile Commands

The project includes a comprehensive Makefile for common development tasks:

### Testing Commands
```bash
make test              # Run all tests with coverage reporting
make test-unit         # Run unit tests only
make test-integration  # Run integration tests only
make coverage          # Generate HTML coverage report
```

### Code Quality Commands
```bash
make lint              # Run flake8 and mypy linting
make format            # Format code with black
make check             # Run all quality checks
```

### Deployment Commands
```bash
make deploy-dev        # Deploy to development environment
make deploy-staging    # Deploy to staging environment
make deploy-prod       # Deploy to production environment
make clean             # Clean build artifacts
```

### Local Development Commands
```bash
make sam-local         # Start SAM Local API for testing
make install           # Install development dependencies
make setup             # Set up development environment
```

## VS Code Integration

### Debugging Configurations
The project includes pre-configured debugging setups in `.vscode/launch.json`:

- **Lambda Function Debugging**: Debug individual Lambda functions locally
- **SAM Local Integration**: Debug Lambda functions with SAM Local
- **Python Extension**: Modern debugpy extension configuration
- **Test Debugging**: Debug unit and integration tests

### Extensions and Settings
Recommended VS Code extensions and settings:

```json
{
  "python.defaultInterpreterPath": "./venv/bin/python",
  "python.testing.pytestEnabled": true,
  "python.testing.unittestEnabled": false,
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "python.formatting.provider": "black"
}
```

## Testing Infrastructure

### Testing Framework
- **pytest**: Primary testing framework with fixture support
- **moto**: AWS service mocking for local testing without costs
- **coverage**: Code coverage reporting with HTML output
- **SAM Local**: Local Lambda testing with .env integration

### Test Structure
```
tests/
├── conftest.py                  # Shared test configuration and fixtures
├── events/                      # Test event fixtures for Lambda functions
│   ├── health_check.json
│   └── db_migration_stack_complete.json
├── unit/                        # Unit tests for individual components
│   ├── test_auth_lambda.py
│   ├── test_main_api.py
│   ├── test_bedrock_chat.py
│   └── test_combined_authorizer.py
└── integration/                 # Integration tests for full workflows
    └── test_api_integration.py
```

### Test Coverage Standards
- **Target Coverage**: 97%+ for new Lambda functions
- **AWS Mocking**: Comprehensive mocking of S3, SQS, Secrets Manager, Cognito
- **Event Fixtures**: Realistic test events for all Lambda triggers
- **Environment Testing**: Isolated test environment with proper cleanup

## Environment Variable Standards

### Frontend Environment Variables
```env
# API Configuration (Critical naming)
VITE_API_BASE_URL=/api          # NOT VITE_API_URL

# Authentication
VITE_COGNITO_USER_POOL_ID=your_user_pool_id
VITE_COGNITO_USER_POOL_CLIENT_ID=your_client_id
VITE_COGNITO_DOMAIN=your_domain.auth.region.amazoncognito.com

# Feature Flags
VITE_ENABLE_STREAMING=true
VITE_CHAT_API_ENDPOINT=/api/chat
VITE_STREAMING_ENDPOINT=/api/chat/stream
```

### Backend Environment Variables
```env
# AWS Configuration
AWS_REGION=il-central-1
BEDROCK_REGION=us-east-1

# Bedrock Configuration
DEFAULT_BEDROCK_MODEL_ID=anthropic.claude-3-5-sonnet-20241022-v2:0
ENABLE_THOUGHT_PROCESS=true
MAX_TOKENS_PER_REQUEST=4096
STREAMING_TIMEOUT_SECONDS=300

# Database
DATABASE_SECRET_ARN=arn:aws:secretsmanager:region:account:secret:name
DATABASE_NAME=lawinfo

# Environment
ENV_NAME=dev
LOG_LEVEL=INFO
```

### Environment Variable Validation
- **Frontend**: Validates required variables at startup with clear error messages
- **Backend**: Validates configuration in BaseStack initialization
- **Error Handling**: Specific guidance for missing or incorrect variables
- **Environment Parity**: Consistent naming across all environments

## Development Workflow

### Branch Management
- **Feature Branches**: `feature/T-###-brief-description`
- **Hotfix Branches**: `hotfix/T-###-brief-description`
- **Documentation**: `docs/T-###-brief-description`

### Pre-commit Checklist
1. **Code Formatting**: `make format` (black)
2. **Linting**: `make lint` (flake8 + mypy --strict)
3. **Testing**: `make test` (all tests must pass)
4. **Coverage**: Maintain >97% coverage for new code

### Deployment Process
1. **Development**: Test locally with SAM Local
2. **Unit Tests**: All tests must pass
3. **Integration**: Deploy to dev environment
4. **Staging**: Deploy to staging for final validation
5. **Production**: Deploy to production with monitoring

## AWS CLI Integration

### Profile Configuration
The project uses AWS CLI profiles for different environments:

```bash
# Development
aws configure --profile Eng-Sandbox

# Production  
aws configure --profile Eng-Prod
```

### CDK Commands with Profiles
```bash
# Deploy with profile
cdk deploy "*-sandbox" -c environment=sandbox --profile Eng-Sandbox

# List stacks
cdk ls -c environment=sandbox --profile Eng-Sandbox

# Show differences
cdk diff ApiStack-sandbox -c environment=sandbox --profile Eng-Sandbox
```

## Troubleshooting

### Common Development Issues

1. **Import Path Issues**: Resolved with editable package installation (`pip install -e .`)
2. **AWS Mocking**: Use moto for comprehensive AWS service mocking
3. **Environment Variables**: Validate all required variables are set
4. **VS Code Debugging**: Ensure Python interpreter path is correct

### Performance Optimization

1. **Test Performance**: Keep unit tests under 100ms each
2. **Mocking Strategy**: Mock external dependencies, test real business logic
3. **Coverage Reporting**: Use pytest-cov with HTML output for visualization
4. **Build Optimization**: Use Vite for fast frontend builds

## Related Documentation

- [Backend Project Structure](../backend/project-structure.md) - Code organization
- [CDK Architecture](./cdk-architecture.md) - Infrastructure setup
- [Environment Configuration](./environment-config.md) - Environment management
