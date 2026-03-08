# API Reference Documentation

## Overview

The Legal Information System API is a RESTful API built on AWS API Gateway HTTP API v2, providing endpoints for chat interactions, document management, user operations, and administrative functions.

## Base URL

API endpoints are deployed to environment-specific domains as configured in the CDK deployment. See [Deployment Guide](../other/deployment-guide.md) for environment URLs.

## Authentication

All protected endpoints require a valid JWT token in the Authorization header. Tokens are obtained through AWS Cognito OAuth 2.0 flow. See [Backend Authentication](./authentication.md) for implementation details.

## Request/Response Format

All API endpoints follow RESTful conventions with JSON payloads. Standard HTTP headers are used for content negotiation and authentication.

### Field Naming Conventions
- **Backend API**: Uses `snake_case` for all field names (e.g., `session_id`, `user_id`)
- **Frontend-Backend Communication**: Frontend sends `snake_case` fields to match backend expectations
- **Session Management**: Session identifiers use `session_id` field consistently across all endpoints

See individual Lambda function handlers for specific implementation details.

## API Endpoints

### Health Check

#### GET /api/health
Check API health status.

**Authentication**: None (Public)

**Response**:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T12:00:00Z",
  "service": "testmeout-api",
  "version": "1.0.0",
  "environment": "dev",
  "checks": {
    "database": "healthy",
    "s3": "healthy",
    "bedrock": "healthy"
  }
}
```

**Status Codes**:
- `200 OK` - Service is healthy
- `503 Service Unavailable` - Service is unhealthy

### User Endpoints

#### GET /api/user
Get current user profile.

**Authentication**: Required

**Implementation**: See `lambdas/main_api/src/handler.py` for user profile handling logic.

**Status Codes**:
- `200 OK` - Success
- `401 Unauthorized` - Invalid or missing token
- `404 Not Found` - User not found

#### PUT /api/user
Update user profile.

**Authentication**: Required
**Implementation**: See `lambdas/main_api/src/handler.py` for user profile update logic.
    "name": "John Doe",
    "preferences": {
      "language": "he",
      "theme": "dark",
      "notifications": false
    }
  }
}
```

**Status Codes**:
- `200 OK` - Success
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Invalid token
- `422 Unprocessable Entity` - Validation error

### Chat Endpoints

#### POST /api/chat
Send a chat message (non-streaming).

**Authentication**: Required

**Request Body**:
```json
{
  "message": "What is contract law?",
  "model": "claude-3-sonnet",
  "session_id": "uuid",
  "context": {
    "documentIds": ["doc1", "doc2"],
    "includeHistory": true,
    "maxTokens": 4096
  }
}
```

**Response**:
```json
{
  "id": "msg_uuid",
  "conversationId": "conv_uuid",
  "role": "assistant",
  "content": "Contract law is...",
  "model": "claude-3-sonnet",
  "thoughtProcess": "Analyzing the question about contract law...",
  "citations": [
    {
      "documentId": "doc1",
      "page": 15,
      "text": "Contract formation requires..."
    }
  ],
  "timestamp": "2024-01-01T12:00:00Z",
  "usage": {
    "promptTokens": 150,
    "completionTokens": 350,
    "totalTokens": 500
  }
}
```

**Status Codes**:
- `200 OK` - Success
- `400 Bad Request` - Invalid request
- `401 Unauthorized` - Invalid token
- `429 Too Many Requests` - Rate limit exceeded
- `503 Service Unavailable` - Model unavailable

#### POST /api/chat/stream
Send a chat message with streaming response.

**Authentication**: Required

**Request Body**:
```json
{
  "message": "Explain the legal process",
  "model": "claude-3-sonnet",
  "session_id": "uuid",
  "streamOptions": {
    "includeThoughts": true,
    "chunkSize": 10
  }
}
```

**Response**: Server-Sent Events (SSE) stream
```
data: {"type": "thought", "content": "Understanding the question..."}

data: {"type": "content", "content": "The legal process typically..."}

data: {"type": "content", "content": " involves several steps..."}

data: {"type": "citation", "documentId": "doc1", "page": 5}

data: {"type": "done", "usage": {"totalTokens": 500}}

data: [DONE]
```

**Status Codes**:
- `200 OK` - Streaming started
- `400 Bad Request` - Invalid request
- `401 Unauthorized` - Invalid token
- `429 Too Many Requests` - Rate limit exceeded

#### GET /api/chat/models
Get available AI models.

**Authentication**: Required

**Response**:
```json
{
  "models": [
    {
      "id": "claude-3-sonnet",
      "name": "Claude 3 Sonnet",
      "provider": "anthropic",
      "capabilities": {
        "streaming": true,
        "maxTokens": 4096,
        "supportsCitations": true
      },
      "pricing": {
        "inputTokens": 0.003,
        "outputTokens": 0.015,
        "currency": "USD",
        "per": 1000
      }
    },
    {
      "id": "claude-3-haiku",
      "name": "Claude 3 Haiku",
      "provider": "anthropic",
      "capabilities": {
        "streaming": true,
        "maxTokens": 4096,
        "supportsCitations": true
      }
    }
  ],
  "defaultModel": "claude-3-sonnet"
}
```

#### GET /api/chat/conversations
Get user's conversations.

**Authentication**: Required

**Query Parameters**:
- `limit` (integer, default: 20) - Number of conversations
- `offset` (integer, default: 0) - Pagination offset
- `sortBy` (string, default: "updatedAt") - Sort field
- `order` (string, default: "desc") - Sort order

**Response**:
```json
{
  "conversations": [
    {
      "id": "conv_uuid",
      "title": "Contract Law Discussion",
      "lastMessage": "What are the key elements?",
      "messageCount": 15,
      "createdAt": "2024-01-01T10:00:00Z",
      "updatedAt": "2024-01-01T12:00:00Z"
    }
  ],
  "pagination": {
    "total": 50,
    "limit": 20,
    "offset": 0,
    "hasMore": true
  }
}
```

#### GET /api/chat/conversations/{id}
Get conversation details with messages.

**Authentication**: Required

**Response**:
```json
{
  "id": "conv_uuid",
  "title": "Contract Law Discussion",
  "messages": [
    {
      "id": "msg1",
      "role": "user",
      "content": "What is a contract?",
      "timestamp": "2024-01-01T10:00:00Z"
    },
    {
      "id": "msg2",
      "role": "assistant",
      "content": "A contract is...",
      "model": "claude-3-sonnet",
      "timestamp": "2024-01-01T10:00:05Z"
    }
  ],
  "metadata": {
    "totalMessages": 15,
    "totalTokens": 5000,
    "models": ["claude-3-sonnet", "claude-3-haiku"]
  }
}
```

### Agent Chat Endpoints

#### WebSocket Agent Chat
**Endpoint**: `wss://{websocket-api-id}.execute-api.{region}.amazonaws.com/{stage}`

**Authentication**: JWT token in query parameter `?token={jwt_token}`

**Connection Flow**:
1. Establish WebSocket connection with JWT token
2. Send chat messages via WebSocket
3. Receive real-time responses from async agent

**Message Format**:
```json
{
  "action": "chat",
  "message": "What are the key terms in this contract?",
  "session_id": "uuid",
  "includeHistory": true
}
```

**Response Format**:
```json
{
  "type": "start",
  "session_id": "agent_1234567890_username",
  "timestamp": "2024-01-01T12:00:00Z",
  "sequence": 1
}

{
  "type": "content",
  "content": "Based on the contract analysis, the key terms include...",
  "message_id": "msg_001",
  "sequence": 2
}

{
  "type": "trace",
  "trace_data": {
    "step": "knowledge_base_query",
    "query": "contract key terms"
  },
  "sequence": 3
}

{
  "type": "complete",
  "message_id": "msg_final",
  "total_tokens": 500,
  "sequence": 4
}

{
  "type": "done",
  "session_id": "agent_1234567890_username",
  "timestamp": "2024-01-01T12:00:30Z",
  "sequence": 5
}
```

**Message Types**:
- `start` - Initial message indicating processing has begun
- `content` - Agent response content chunks
- `trace` - Agent reasoning and tool execution traces
- `complete` - Indicates the agent has finished processing
- `done` - Final message indicating the entire response is complete
- `error` - Error occurred during processing

**Implementation**: See `lambdas/websocket_chat_invoker/src/handler.py` for WebSocket message handling logic.

**Status Codes**:
- `101 Switching Protocols` - WebSocket connection established
- `401 Unauthorized` - Invalid or missing JWT token
- `403 Forbidden` - Insufficient permissions

**Note**: WebSocket agent chat eliminates API Gateway timeout limitations and provides true real-time bidirectional communication. This replaces the previous Function URL approach for async agent interactions.

#### Legacy Agent Endpoints (Deprecated)
The following endpoints are deprecated and will be migrated to WebSocket:

- `POST /api/agent/chat` - Use WebSocket instead
- `POST /api/agent/chat/stream` - Use WebSocket instead

**Migration Timeline**: Function URL endpoints will be removed in future releases as all agent interactions migrate to WebSocket.

### Document Endpoints

#### POST /api/documents
Upload a document.

**Authentication**: Required

**Request**: Multipart form data or JSON with presigned URL request

**Option 1: Request Presigned URL**
```json
{
  "fileName": "contract.pdf",
  "fileSize": 1048576,
  "mimeType": "application/pdf",
  "metadata": {
    "category": "contracts",
    "tags": ["legal", "business"]
  }
}
```

**Response**:
```json
{
  "uploadUrl": "https://s3.amazonaws.com/bucket/...",
  "documentId": "doc_uuid",
  "expiresAt": "2024-01-01T13:00:00Z",
  "fields": {
    "key": "documents/doc_uuid/contract.pdf",
    "bucket": "testmeout-documents"
  }
}
```

#### GET /api/documents
List user's documents.

**Authentication**: Required

**Query Parameters**:
- `limit` (integer, default: 20)
- `offset` (integer, default: 0)
- `status` (string) - Filter by status: processing, processed, failed
- `category` (string) - Filter by category
- `search` (string) - Search in document names

**Response**:
```json
{
  "documents": [
    {
      "id": "doc_uuid",
      "name": "contract.pdf",
      "size": 1048576,
      "mimeType": "application/pdf",
      "status": "processed",
      "category": "contracts",
      "tags": ["legal", "business"],
      "uploadedAt": "2024-01-01T10:00:00Z",
      "processedAt": "2024-01-01T10:05:00Z",
      "metadata": {
        "pages": 10,
        "extractedText": true,
        "hasEmbeddings": true
      }
    }
  ],
  "pagination": {
    "total": 100,
    "limit": 20,
    "offset": 0,
    "hasMore": true
  }
}
```

#### GET /api/documents/{id}
Get document details.

**Authentication**: Required

**Response**:
```json
{
  "id": "doc_uuid",
  "name": "contract.pdf",
  "size": 1048576,
  "mimeType": "application/pdf",
  "status": "processed",
  "downloadUrl": "https://s3.amazonaws.com/...",
  "metadata": {
    "pages": 10,
    "author": "John Doe",
    "createdDate": "2023-12-01",
    "extractedText": true,
    "summary": "This contract defines..."
  },
  "processing": {
    "startedAt": "2024-01-01T10:00:00Z",
    "completedAt": "2024-01-01T10:05:00Z",
    "duration": 300,
    "steps": [
      {
        "name": "text_extraction",
        "status": "completed",
        "duration": 120
      },
      {
        "name": "embedding_generation",
        "status": "completed",
        "duration": 180
      }
    ]
  }
}
```

#### DELETE /api/documents/{id}
Delete a document.

**Authentication**: Required

**Response**:
```json
{
  "message": "Document deleted successfully",
  "documentId": "doc_uuid"
}
```

**Status Codes**:
- `200 OK` - Success
- `404 Not Found` - Document not found
- `403 Forbidden` - Not document owner

### Search Endpoints

#### POST /api/search
Semantic search across documents.

**Authentication**: Required

**Request Body**:
```json
{
  "query": "termination clauses",
  "filters": {
    "documentIds": ["doc1", "doc2"],
    "categories": ["contracts"],
    "dateRange": {
      "from": "2023-01-01",
      "to": "2024-01-01"
    }
  },
  "limit": 10,
  "threshold": 0.7
}
```

**Response**:
```json
{
  "results": [
    {
      "documentId": "doc1",
      "documentName": "Employment Contract.pdf",
      "excerpt": "...the termination clause states that either party...",
      "page": 5,
      "similarity": 0.92,
      "highlights": [
        {
          "text": "termination clause",
          "position": [150, 168]
        }
      ]
    }
  ],
  "metadata": {
    "totalResults": 15,
    "searchTime": 250,
    "query": "termination clauses"
  }
}
```

### Admin Endpoints

#### GET /api/admin/status
Get system status (admin only).

**Authentication**: Required (Admin role)

**Response**:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T12:00:00Z",
  "metrics": {
    "activeUsers": 150,
    "totalDocuments": 5000,
    "processingQueue": 10,
    "averageResponseTime": 250
  },
  "services": {
    "database": {
      "status": "healthy",
      "connections": 10,
      "maxConnections": 100
    },
    "s3": {
      "status": "healthy",
      "bucketSize": "10GB"
    },
    "bedrock": {
      "status": "healthy",
      "modelsAvailable": 3
    }
  }
}
```

#### GET /api/admin/users
List all users (admin only).

**Authentication**: Required (Admin role)

**Query Parameters**:
- `limit` (integer, default: 50)
- `offset` (integer, default: 0)
- `search` (string) - Search by email or name
- `role` (string) - Filter by role

**Response**:
```json
{
  "users": [
    {
      "id": "user_uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "role": "user",
      "status": "active",
      "createdAt": "2024-01-01T10:00:00Z",
      "lastLogin": "2024-01-01T12:00:00Z"
    }
  ],
  "pagination": {
    "total": 500,
    "limit": 50,
    "offset": 0
  }
}
```

## Error Responses

### Standard Error Format
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
  "requestId": "req_uuid",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

### Error Codes

| Code                  | HTTP Status | Description                              |
| --------------------- | ----------- | ---------------------------------------- |
| `UNAUTHORIZED`        | 401         | Authentication required or invalid token |
| `FORBIDDEN`           | 403         | Insufficient permissions                 |
| `NOT_FOUND`           | 404         | Resource not found                       |
| `VALIDATION_ERROR`    | 400         | Invalid input parameters                 |
| `RATE_LIMIT_EXCEEDED` | 429         | Too many requests                        |
| `INTERNAL_ERROR`      | 500         | Internal server error                    |
| `SERVICE_UNAVAILABLE` | 503         | Service temporarily unavailable          |

## Rate Limiting

Rate limits are applied per user:
- **Default**: 100 requests per minute
- **Chat endpoints**: 20 requests per minute
- **Document upload**: 10 requests per minute

Rate limit headers:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704110400
```

## Pagination

Pagination is supported on list endpoints:

**Request**:
```
GET /api/documents?limit=20&offset=40
```

**Response**:
```json
{
  "data": [...],
  "pagination": {
    "total": 100,
    "limit": 20,
    "offset": 40,
    "hasMore": true,
    "nextOffset": 60
  }
}
```

## Webhooks

Webhook notifications for async events:

**Document Processing Complete**:
```json
{
  "event": "document.processed",
  "timestamp": "2024-01-01T12:00:00Z",
  "data": {
    "documentId": "doc_uuid",
    "status": "completed",
    "processingTime": 300
  }
}
```

## API Versioning

The API uses URL path versioning:
- Current version: `/api/` (v1)
- Future versions: `/api/v2/`

Version information in response headers:
```http
X-API-Version: 1.0.0
```

## OpenAPI Specification

The complete OpenAPI 3.0 specification is available at:
```
GET /api/openapi.json
```

## SDK Support

Official SDKs available for:
- JavaScript/TypeScript
- Python
- Java (coming soon)

## Testing

### Test Environment
```
Base URL: https://api-test.testmeout.com
Test API Key: Available in developer portal
```

### Postman Collection
Import the Postman collection from:
```
/api/postman-collection.json
```