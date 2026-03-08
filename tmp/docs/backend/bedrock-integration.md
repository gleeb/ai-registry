# AWS Bedrock Integration Documentation

## Overview

AWS Bedrock provides access to foundation models for AI-powered chat functionality. The integration supports multiple models, streaming responses, conversation management, and thought process capture for enhanced user experience. The system uses the Bedrock Converse API for proper conversation context and session management.

## Available Models

### Current Model Support
The system supports 15+ Bedrock models with real-time pricing and usage tracking:

**Claude 3 Family**:
- **Claude 3.5 Sonnet**: Latest Anthropic model with enhanced reasoning
- **Claude 3.5 Haiku**: Fast, cost-effective responses with improved capabilities
- **Claude 3 Opus**: Most capable model for complex reasoning tasks
- **Claude 3 Sonnet**: Balanced performance and cost
- **Claude 3 Haiku**: Fast responses for simple queries

**Nova Family** (AWS Native):
- **Nova Pro**: AWS native multimodal model
- **Nova Lite**: Lightweight AWS model for simple tasks
- **Nova Micro**: Ultra-fast responses for basic queries

**Additional Models**:
- **Mistral 7B/8x7B**: Open-source alternatives
- **Llama 3.1/3.2**: Meta's latest models
- **Cohere Command R+**: Advanced reasoning model

Model availability and pricing are dynamically loaded from `lambdas/bedrock_chat/src/common/bedrock_client.py`.

## Integration Architecture

### Bedrock Client Configuration
The Bedrock client is implemented in `lambdas/bedrock_chat/src/common/bedrock_client.py` with comprehensive features:

**Core Features**:
- **Converse API Integration**: Uses `converse()` and `converse_stream()` for proper conversation support
- **Multi-Model Support**: Dynamic model enumeration and selection
- **Cost Calculation**: Real-time cost estimation based on current AWS pricing
- **Usage Tracking**: Token counting and CloudWatch metrics publishing
- **Error Handling**: Comprehensive retry logic with exponential backoff
- **Session Management**: Integration with DynamoDB for conversation persistence

**Configuration**:
- **Region**: us-east-1 (for Bedrock model access)
- **Retry Strategy**: Exponential backoff with max 3 attempts
- **Timeout**: 300 seconds for streaming operations
- **Authentication**: IAM role-based with least privilege access

**Environment Variables**:
- **BEDROCK_REGION**: us-east-1 (required for model access)
- **DEFAULT_BEDROCK_MODEL_ID**: anthropic.claude-3-5-sonnet-20241022-v2:0
- **ENABLE_THOUGHT_PROCESS**: true (enables AI reasoning display)
- **MAX_TOKENS_PER_REQUEST**: 4096 (configurable token limit)
- **STREAMING_TIMEOUT_SECONDS**: 300 (streaming operation timeout)

## Streaming Implementation

### Server-Sent Events (SSE) with Converse Stream API
The system implements SSE using Bedrock's `converse_stream()` API for real-time streaming with conversation context.

**Implementation Details**:
- **API Method**: `converse_stream()` instead of legacy `invoke_model_with_response_stream()`
- **Event Types**: `messageStart`, `contentBlockDelta`, `messageStop`, `metadata`
- **Session Integration**: Conversation history maintained in DynamoDB
- **Usage Tracking**: Real-time token counting and cost calculation
- **Error Recovery**: Graceful fallback to non-streaming mode

**Stream Event Processing**:
Implemented in `lambdas/bedrock_chat/src/handlers/stream_handler.py`:
- **messageStart**: Initial response metadata
- **contentBlockDelta**: Incremental text chunks for real-time display
- **messageStop**: Response completion with final metadata
- **metadata**: Usage statistics and token counts

**Key Features**:
- **Conversation Context**: Full conversation history sent to maintain context
- **Thought Process Extraction**: Parsing of `<thinking>`, `<analysis>`, and `<answer>` tags
- **Cost Tracking**: Real-time cost calculation during streaming
- **Session Continuity**: Proper session ID management for conversation persistence

## Prompt Engineering

### System Prompts
Implemented in `lambdas/bedrock_chat/src/handlers/chat_handler.py` and `stream_handler.py`:

**Thought Process Structure**:
```
You are a Hebrew law expert. For complex questions, show your reasoning using:
<thinking>Your analysis process</thinking>
<analysis>Key legal principles</analysis>
<answer>Final response</answer>
```

**Design Decisions**:
- **Streaming Method**: Server-Sent Events (SSE) chosen over WebSocket for simpler implementation
- **Thought Process Display**: Inline expansion with expand/collapse (similar to ChatGPT)
- **Session Persistence**: DynamoDB storage for chat history (not in-memory only)
- **Error Handling**: Exponential backoff for Bedrock throttling, no automatic retries for failed calls
- **Model Selection**: Multi-model support with dropdown selection interface

### Context Management
**Conversation Context**:
- **Session Storage**: DynamoDB-based conversation persistence
- **Message History**: Complete conversation context sent to Bedrock
- **Context Window**: Automatic token optimization and truncation
- **User Preferences**: Model selection and response format preferences

**Session Integration**:
- **Session Creation**: Automatic session creation for new conversations
- **History Retrieval**: Previous messages loaded for context continuity
- **Message Persistence**: Conversation stored after each exchange
- **Cleanup**: TTL-based session expiration

## Error Handling

### Retry Strategy
Implemented in `lambdas/bedrock_chat/src/common/bedrock_client.py`:

**Exponential Backoff**:
- Initial delay: 1 second
- Max retries: 3 attempts
- Backoff multiplier: 2x
- Max delay: 60 seconds

**Error Types**:
- **ThrottlingException**: Automatic retry with backoff
- **ModelTimeoutException**: Fallback to non-streaming mode
- **ValidationException**: Immediate failure with user feedback
- **InternalServerError**: Retry with exponential backoff

**Graceful Degradation**:
- **Streaming to Non-streaming**: Automatic fallback on stream failures
- **Model Fallback**: Switch to alternative model on availability issues
- **Session Recovery**: Continue conversation without history on session errors

### Rate Limiting and Monitoring
**CloudWatch Integration**:
- **Request Metrics**: API call frequency and patterns
- **Error Tracking**: Categorized error metrics for monitoring
- **Cost Monitoring**: Real-time cost tracking with threshold alarms
- **Performance Metrics**: Latency and throughput monitoring

**Usage Controls**:
- **Token Limits**: Configurable per-request token limits
- **Cost Thresholds**: Automatic alerts on cost spikes
- **Session Limits**: TTL-based session cleanup
- **Rate Limiting**: API Gateway throttling integration

## Performance Optimization

### Lambda Optimization
**Function Configuration**:
- **Runtime**: Python 3.12 for optimal performance
- **Memory**: Environment-specific (512MB default)
- **Timeout**: 300 seconds for streaming operations
- **VPC Integration**: Deployed in private subnets for security

**Connection Optimization**:
- **Connection Pooling**: Reuse Bedrock client connections
- **Session Persistence**: DynamoDB connection pooling
- **Cold Start Mitigation**: Optimized import structure

### Token Management
**Context Window Optimization**:
- **Conversation Truncation**: Automatic history pruning for long conversations
- **Prompt Compression**: Efficient system prompt design
- **Token Counting**: Accurate token estimation using tiktoken
- **Cost Optimization**: Real-time cost calculation and warnings

**Usage Tracking**:
- **Input/Output Tokens**: Separate tracking for accurate cost calculation
- **Model-Specific Pricing**: Dynamic pricing based on current AWS rates
- **Cost Estimation**: Real-time cost display in frontend
- **Usage Analytics**: CloudWatch metrics for usage patterns

## Monitoring and Observability

### CloudWatch Metrics
Implemented in `infra/stacks/monitoring/monitoring_stack.py`:

**Custom Metrics Namespace**: `BedrockChat`

**Core Metrics**:
- **BedrockRequests**: API call count by model and environment
- **InputTokens/OutputTokens**: Token usage tracking
- **EstimatedCost**: Real-time cost calculation
- **BedrockLatency**: Response time tracking
- **SessionOperations**: Session CRUD operation metrics

**Error Metrics**:
- **ChatErrors**: Chat-specific error tracking
- **AuthErrors**: Authentication failure tracking
- **StreamingErrors**: Streaming-specific error metrics

### CloudWatch Alarms
**Performance Alarms**:
- **High Error Rate**: Triggers when 5xx errors exceed 10 per 5 minutes
- **High Latency**: Triggers when API Gateway latency exceeds 5 seconds
- **Lambda Errors**: Triggers when Lambda errors exceed 5 per 5 minutes

**Cost Alarms**:
- **High Cost**: Triggers when estimated cost exceeds $10 per 15 minutes
- **Usage Spike**: Alerts on unusual token usage patterns

### Dashboard and Alerting
**CloudWatch Dashboard**:
- **API Gateway Performance**: Request count, latency, error rates
- **Lambda Health**: Duration, errors, throttles
- **Bedrock Usage**: Token usage, cost trends, model performance
- **Session Analytics**: Session creation, duration, cleanup metrics

**SNS Integration**:
- Centralized notification system for all critical alarms
- Configurable email subscriptions for alerts
- Integration with monitoring stack for comprehensive alerting

### Logging Strategy
**AWS Lambda Powertools Integration**:
- **Structured Logging**: JSON format with correlation IDs
- **Request Tracing**: End-to-end request tracking
- **Performance Metrics**: Automatic latency and memory usage tracking
- **Error Categorization**: Detailed error classification and context