# Lambda Functions Documentation

## Overview

This document provides detailed documentation for each Lambda function in the system, including their triggers, environment variables, business logic, and integration points.

## Lambda Functions Inventory

### Main API Lambda
- **Function Name**: `main-api-function`
- **Runtime**: Python 3.12
- **Memory**: 512 MB
- **Timeout**: 5 minutes
- **Trigger**: API Gateway HTTP API
- **Purpose**: Central API handler for core business operations

### Bedrock Chat Lambda
- **Function Name**: `bedrock-chat-function`
- **Runtime**: Python 3.12
- **Memory**: 1024 MB
- **Timeout**: 5 minutes
- **Trigger**: API Gateway HTTP API
- **Purpose**: AI-powered chat with streaming responses using factory pattern architecture

**Architecture**: Modular factory-based design with separate handlers for each endpoint:
- **HandlerFactory**: Routes requests to appropriate handlers based on HTTP method and path
- **BaseHandler**: Common functionality for all endpoints (authentication, logging, error handling)
- **Endpoint Handlers**: Specialized handlers for each API endpoint

**Handler Classes**:
- `ModelsHandler`: GET /api/chat/models - Available model enumeration
- `ChatHandler`: POST /api/chat - Non-streaming chat requests
- `StreamHandler`: POST /api/chat/stream - Server-Sent Events streaming
- `SessionsListHandler`: GET /api/chat/sessions - List user sessions
- `SessionsCreateHandler`: POST /api/chat/sessions - Create new session
- `SessionsDeleteHandler`: DELETE /api/chat/sessions/{id} - Delete session
- `HealthHandler`: GET /api/chat/health - Health check endpoint

**Shared Modules**:
- `bedrock_client.py`: Bedrock API integration with cost calculation
- `session_manager.py`: DynamoDB session storage operations
- `response_utils.py`: Response formatting and SSE utilities

### Combined Authorizer Lambda
- **Function Name**: `combined-authorizer`
- **Runtime**: Python 3.12
- **Memory**: 256 MB
- **Timeout**: 10 seconds
- **Trigger**: API Gateway Authorizer
- **Purpose**: JWT validation and CloudFront verification

### Streaming Lambda (Function URL)
- **Function Name**: `streaming-chat-function`
- **Runtime**: Python 3.12
- **Memory**: 1024 MB
- **Timeout**: 5 minutes
- **Trigger**: Lambda Function URL (bypasses API Gateway)
- **Purpose**: Dedicated streaming endpoint to bypass API Gateway 29-second timeout

**Key Features**:
- **Direct CloudFront Integration**: Accessed via CloudFront distribution
- **In-Function Authentication**: JWT validation and CDN header verification
- **No API Gateway Timeout**: Supports streaming responses longer than 29 seconds
- **CORS Handling**: Custom CORS implementation for streaming requests
- **Resource Policy**: Restricted access only from CloudFront distribution

**Authentication**:
- **JWT Validation**: Validates Cognito JWT tokens using JWKS
- **CDN Header Verification**: Validates secret header from CloudFront
- **Resource Policy**: CloudFront distribution ARN-based access control

**CORS Configuration**:
- **Streaming-Specific CORS**: Custom policy for `/chat/stream*` and `/api/chat/stream*` paths
- **Credentials Support**: Proper CORS credentials handling for authenticated requests
- **OPTIONS Fast-path**: Optimized preflight handling for streaming requests
- **Origin Override**: Streaming CORS policy with credentials and origin override

### Document Processing Lambda
- **Function Name**: `document-processor`
- **Runtime**: Python 3.12
- **Memory**: 2048 MB
- **Timeout**: 15 minutes
- **Trigger**: S3 events, SQS queue
- **Purpose**: Process uploaded documents and generate embeddings

### Authentication Lambda
- **Function Name**: `auth-handler`
- **Runtime**: Python 3.12
- **Memory**: 256 MB
- **Timeout**: 10 seconds
- **Trigger**: Cognito User Pool triggers
- **Purpose**: Email validation and user management

### Database Migration Lambda
- **Function Name**: `db-migration`
- **Runtime**: Python 3.12
- **Memory**: 512 MB
- **Timeout**: 5 minutes
- **Trigger**: CloudFormation Custom Resource
- **Purpose**: Execute database migrations on stack deployment

### Inline Agent Lambda
- **Function Name**: `inline-agent-function`
- **Runtime**: Python 3.12 (Container-based)
- **Memory**: 1024 MB
- **Timeout**: 5 minutes
- **Trigger**: Lambda Function URL (bypasses API Gateway)
- **Purpose**: AWS Bedrock inline agent operations with MCP server integration

**Architecture**: Direct Function URL access through CloudFront:
- **CloudFront Integration**: Routes `/api/inline-agent*` requests directly to Function URL
- **No API Gateway**: Bypasses API Gateway entirely for better performance and flexibility
- **Container-Based**: Uses Docker container for complex MCP server dependencies
- **Direct Security**: JWT validation and CloudFront header verification in Lambda

**Architecture**: Advanced agent system with MCP server integration:
- **InlineAgentClient**: Direct Bedrock inline agent API integration
- **MCP Server Support**: Context7 and custom AWS MCP server integration
- **Session Management**: Persistent agent sessions with DynamoDB storage
- **Tool Execution**: Action group integration for external tool access

**Key Features**:
- **Cross-Region Inference**: Claude Sonnet 4 access via inference profiles
- **Container-Based MCP**: Docker containers for complex runtime environments
- **Action Group Management**: Seamless integration of MCP tools into Bedrock agents
- **Structured Logging**: Comprehensive observability with CloudWatch integration

## Handler Architecture Patterns

### Factory Pattern Implementation
The system uses a sophisticated factory pattern for request routing and handler management:

**HandlerFactory Architecture**:
```python
class HandlerFactory:
    def __init__(self):
        self.handlers = {
            'GET:/api/chat/models': ModelsHandler(),
            'POST:/api/chat': ChatHandler(),
            'POST:/api/chat/stream': StreamHandler(),
            'GET:/api/chat/sessions': SessionsListHandler(),
            'POST:/api/chat/sessions': SessionsCreateHandler(),
            'DELETE:/api/chat/sessions/{id}': SessionsDeleteHandler(),
            'GET:/api/chat/health': HealthHandler(),
            # Agent-specific endpoints
            'POST:/api/agent/chat': AgentChatHandler(),
            'POST:/api/agent/stream': AgentStreamHandler(),
        }
```

**Benefits**:
- **Centralized Routing**: Single point of endpoint registration and management
- **Consistent Interface**: All handlers implement the same base interface
- **Easy Extension**: New endpoints require only handler registration
- **Testing**: Simplified unit testing with mock handler injection

### Function URL Handler Architecture
Advanced streaming endpoints and inline agent operations use Function URL handlers with different architectural patterns:

**Streaming Endpoints Architecture**:
```
Function URL Request → Event Transformation → Main Handler → Factory → Appropriate Handler
```

**Inline Agent Architecture**:
```
CloudFront Request → Function URL → Direct Lambda Handler (bypasses API Gateway)
```

**Key Design Decisions**:
1. **Event Transformation**: Function URL events transformed to API Gateway format for compatibility (streaming endpoints)
2. **Direct Access**: Inline agent uses dedicated Function URL endpoint (`/api/inline-agent*`) bypassing API Gateway entirely
3. **Facade Pattern**: Streaming Function URL handlers act as facades, delegating to main handler
4. **Security**: JWT + CloudFront header validation implemented in Lambda for both patterns

**Implementation Benefits**:
- **Consistency**: Same routing logic for all endpoints regardless of trigger
- **Maintainability**: Single codebase for streaming functionality
- **Security**: Lambda-based authentication with CloudFront integration
- **Performance**: Direct CloudFront integration bypasses API Gateway timeouts

### Base Handler Pattern
All handlers inherit from a common base class providing shared functionality:

**BaseHandler Features**:
- **Authentication**: JWT validation and user context extraction
- **Logging**: Structured logging with correlation IDs
- **Error Handling**: Consistent error response formatting
- **CORS**: Cross-origin resource sharing configuration
- **Metrics**: CloudWatch metrics and monitoring integration

**Correlation ID Strategy**:
- **Generic Approach**: Uses `"requestContext.requestId"` for both event types
- **Cross-Platform**: Works with API Gateway and Function URL events
- **Tracing**: Enables end-to-end request tracing across services

## Detailed documentation for each function would include:
- Environment variables
- IAM permissions
- Input/output formats
- Error handling
- Business logic
- Integration patterns
- Testing approaches
- Monitoring and metrics