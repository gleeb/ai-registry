# Testing Infrastructure

## Overview

The testing infrastructure supports comprehensive testing across the Legal Information System including unit testing for Lambda functions, integration testing with mocked AWS services, local Lambda debugging with VS Code, SAM Local for API testing, and test coverage reporting.

## Setup

### 1. Install Dependencies

First, ensure you have created your `.env` file:
```bash
cp env.example .env
# Edit .env with your local values
```

Then install development dependencies:
```bash
make install-dev
# or manually:
pip install -r requirements-dev.txt
```

### 2. Configure Environment

The testing infrastructure uses environment variables from `.env`. For SAM Local testing, generate the SAM environment file:
```bash
make sam-env
# This creates sam-env-local.json from your .env file
```

### 3. Start Local Services

For integration testing, start the local PostgreSQL and LocalStack services:
```bash
make docker-up
# or: docker-compose up -d
```

## Running Tests

### Unit Tests

Run all unit tests:
```bash
make test
# or: pytest tests/ -v
```

Run specific test file:
```bash
pytest tests/unit/test_main_api.py -v
```

Run with coverage:
```bash
pytest --cov=lambdas --cov-report=html
# View coverage report: open htmlcov/index.html
```

### Integration Tests

Run integration tests (requires Docker services):
```bash
pytest tests/integration/ -v
```

## Debugging Lambda Functions

### VS Code Debugging

The project includes several debugging configurations in `.vscode/launch.json`:

1. **Python: Current File** - Debug any Python file directly
2. **Python: Debug Tests** - Debug pytest tests
3. **Python: Debug Lambda Function** - Debug Lambda handlers
4. **SAM: Debug Main API Lambda** - Debug with SAM Local
5. **SAM: Debug Document Processing Lambda** - Debug document processor
6. **SAM: Debug Admin Lambda** - Debug admin functions

To debug a Lambda function:
1. Open the Lambda handler file (e.g., `lambdas/main_api/src/handler.py`)
2. Set breakpoints
3. Select the appropriate debug configuration
4. Press F5 to start debugging

### SAM Local Testing

Start the API locally with SAM:
```bash
# First, synthesize the CDK stack
make cdk-synth

# Start SAM Local API
sam local start-api --env-vars sam-env-local.json
```

Test specific endpoints:
```bash
# Test health check
curl http://localhost:3000/api/health

# Test authenticated endpoint
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:3000/api/user
```

## Test Structure

### Unit Tests (`tests/unit/`)

Unit tests focus on individual components:

- **Lambda Functions**: Test handler logic with mocked AWS services
- **Configuration**: Test config loading and validation
- **Utilities**: Test shared utility functions
- **Models**: Test data models and validation

### Integration Tests (`tests/integration/`)

Integration tests verify component interactions:

- **API Endpoints**: Test complete request/response cycles
- **Database Operations**: Test with real PostgreSQL
- **Authentication**: Test JWT validation and Cognito integration
- **External Services**: Test AWS service integrations

### Test Events (`tests/events/`)

Sample event files for testing:

- `health_check.json` - API Gateway health check event
- `db_migration_stack_complete.json` - Database migration event

## Test Coverage

### Coverage Goals

- **New Code**: Aim for 100% coverage
- **Overall Project**: Maintain >80% coverage
- **Critical Paths**: Must have 100% coverage
- **Infrastructure Code**: Test CDK constructs and stack synthesis

### Coverage Reporting

Generate coverage reports:
```bash
# HTML report
pytest --cov=lambdas --cov-report=html

# Console report
pytest --cov=lambdas --cov-report=term-missing

# XML report (for CI/CD)
pytest --cov=lambdas --cov-report=xml
```

## Mocking AWS Services

### Boto3 Mocking

Use `moto` for AWS service mocking:

```python
import boto3
from moto import mock_s3

@mock_s3
def test_s3_operations():
    s3 = boto3.client('s3')
    # Test S3 operations with mocked service
```

### Lambda Context Mocking

Mock Lambda context for testing:

```python
from unittest.mock import Mock

def test_lambda_handler():
    event = {"key": "value"}
    context = Mock()
    context.function_name = "test-function"
    context.remaining_time_in_millis = lambda: 30000
    
    result = handler(event, context)
    assert result["statusCode"] == 200
```

## Performance Testing

### Load Testing

Test API performance under load:

```bash
# Install Apache Bench
sudo apt-get install apache2-utils

# Test health endpoint
ab -n 1000 -c 10 http://localhost:3000/api/health

# Test authenticated endpoint
ab -n 100 -c 5 -H "Authorization: Bearer TOKEN" http://localhost:3000/api/user
```

### Lambda Performance

Monitor Lambda function performance:

```bash
# Test Lambda directly
aws lambda invoke --function-name main-api-dev --payload file://test-event.json response.json

# Check CloudWatch metrics
aws cloudwatch get-metric-statistics --namespace AWS/Lambda --metric-name Duration --dimensions Name=FunctionName,Value=main-api-dev
```

## Continuous Integration

### GitHub Actions

The project includes GitHub Actions workflows for automated testing:

- **Unit Tests**: Run on every push
- **Integration Tests**: Run on pull requests
- **Coverage Reports**: Upload to Codecov
- **Security Scanning**: Run security checks

### Pre-commit Hooks

Install pre-commit hooks for code quality:

```bash
pip install pre-commit
pre-commit install
```

## Troubleshooting

### Common Test Issues

1. **Import Errors**
   - Ensure virtual environment is activated
   - Check Python path includes project root
   - Verify all dependencies are installed

2. **AWS Credentials**
   - Set up AWS credentials for local testing
   - Use AWS profiles for different environments
   - Mock AWS services for unit tests

3. **Database Connection**
   - Start Docker services for integration tests
   - Check database connection string
   - Verify PostgreSQL is running

4. **SAM Local Issues**
   - Ensure Docker is running
   - Check SAM CLI is installed
   - Verify CDK synthesis completed

### Debug Commands

```bash
# Check test discovery
pytest --collect-only

# Run tests with verbose output
pytest -v -s

# Debug specific test
pytest tests/unit/test_main_api.py::test_health_check -v -s

# Check test coverage
pytest --cov=lambdas --cov-report=term-missing tests/unit/
```

## Best Practices

### Test Organization

1. **Arrange-Act-Assert**: Structure tests clearly
2. **Descriptive Names**: Use clear test function names
3. **Single Responsibility**: Each test should test one thing
4. **Independent Tests**: Tests should not depend on each other

### Test Data Management

1. **Fixtures**: Use pytest fixtures for common test data
2. **Factories**: Create factory functions for complex objects
3. **Cleanup**: Always clean up test data
4. **Isolation**: Tests should not affect each other

### Performance Considerations

1. **Fast Tests**: Keep unit tests under 100ms
2. **Parallel Execution**: Use pytest-xdist for parallel testing
3. **Resource Management**: Clean up resources after tests
4. **Mocking**: Mock external services for faster tests

## Related Documentation

- [Python Code Standards](../backend/project-structure.md) - Code quality guidelines
- [Deployment Guide](./deployment-guide.md) - Production deployment
- [Troubleshooting Guide](./troubleshooting.md) - Common issues and solutions 