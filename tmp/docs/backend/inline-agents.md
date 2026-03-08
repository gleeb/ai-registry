# Inline Agents Documentation

## Overview

The Legal Information System includes advanced AWS Bedrock inline agent capabilities with MCP (Model Context Protocol) server integration. This system enables users to interact with specialized AI agents that can access external knowledge bases, execute tools, and provide context-aware responses through AWS Bedrock's inline agent API.

## Architecture Overview

### Inline Agent System Components
```
Inline Agent System
├── Inline Agent Lambda
│   ├── InlineAgentClient
│   ├── MCP Server Integration
│   └── Action Group Management
├── MCP Servers
│   ├── Context7 MCP Server (stdio)
│   └── AWS Knowledge MCP Server (HTTP)
└── AWS Bedrock
    └── InvokeInlineAgent API
```

### Key Design Principles
- **Separation of Concerns**: Dedicated inline agent project separate from main bedrock chat
- **MCP Server Integration**: Local MCP servers for reliable tool access
- **Cross-Region Support**: Inference profiles for accessing models across AWS regions
- **Function URL Endpoints**: Direct Lambda invocation for long-running agent operations
- **Dual MCP Architecture**: Support for multiple MCP server types

## Implementation Details

### Inline Agent Client

The core inline agent functionality is implemented in `lambdas/bedrock_inline_agent/src/inline_agent_client.py`:

#### Key Features
- **MCP Server Integration**: Automatic MCP client creation and management
- **Action Group Configuration**: Dynamic action group setup with MCP tools
- **Cross-Region Inference**: Support for Claude Sonnet 4 via inference profiles
- **Error Handling**: Comprehensive error handling and logging
- **Session Management**: Integration with existing session management system

#### MCP Server Configuration
```python
# Context7 MCP Server (stdio transport)
server_params = StdioServerParameters(
    command="node",
    args=["/var/task/node_modules/@upstash/context7-mcp/dist/index.js"],
)

# AWS Knowledge MCP Server (HTTP transport via mcp-remote)
server_params = StdioServerParameters(
    command="npx",
    args=["mcp-remote", "https://knowledge-mcp.global.api.aws"],
)
```

#### Environment Variable Control
```python
# MCP server selection - "aws-knowledge" or "context7"
MCP_SERVER_TYPE = os.environ.get("MCP_SERVER_TYPE", "aws-knowledge")

# Dynamic MCP client creation based on environment variable
if MCP_SERVER_TYPE == "context7":
    mcp_client = await self._create_context7_mcp_client()
else:
    mcp_client = await self._create_aws_knowledge_mcp_client()
```

### MCP Server Integration

#### Context7 MCP Server ✅ COMPLETED
**Implementation Status**: Successfully implemented and working
**Transport**: Stdio (standard input/output)
**Installation**: Local npm installation in Lambda container
**Purpose**: Documentation and knowledge retrieval

**Key Components**:
- **Local Installation**: Context7 installed directly in Lambda container
- **StdioServerParameters**: Standard input/output communication
- **Action Group Integration**: MCP client integrated into action groups
- **Direct Tool Access**: Seamless access to documentation tools

#### AWS Knowledge MCP Server ✅ COMPLETED
**Implementation Status**: Successfully implemented and ready for testing
**Transport**: HTTP via mcp-remote proxy
**Installation**: mcp-remote utility for HTTP transport
**Purpose**: AWS documentation and best practices

**Key Components**:
- **mcp-remote Proxy**: HTTP transport through mcp-remote utility
- **AWS Documentation Access**: Comprehensive AWS service documentation
- **Best Practices**: Real-time access to AWS architectural guidance
- **API References**: Up-to-date API documentation and parameters

### Action Group Management

The inline agent uses action groups to provide tools and capabilities:

```python
# Create action group with MCP client
action_group = ActionGroup(
    name="Context7ActionGroup",
    description="Provides access to documentation and knowledge through Context7 MCP server",
    mcp_clients=[mcp_client],
)

# Create inline agent with action groups
agent = InlineAgent(
    action_groups=ActionGroups(action_groups=[action_group])
)
```

## Infrastructure Configuration

### CDK Stack Integration

The inline agent infrastructure is integrated into the existing API stack in `infra/stacks/application/api_stack.py`:

#### Lambda Function Configuration
```python
# Inline agent Lambda function
inline_agent_lambda = lambda_.Function(
    self, "InlineAgentLambda",
    runtime=lambda_.Runtime.PYTHON_3_12,
    memory_size=1024,
    timeout=Duration.seconds(900),
    environment={
        "ENABLE_INLINE_AGENT": "true",
        "MCP_SERVER_TYPE": "aws-knowledge",
        "INLINE_AGENT_TIMEOUT_SECONDS": "900",
    },
    code=lambda_.Code.from_asset("lambdas/bedrock_inline_agent"),
    handler="src.function_url_handler.handler",
)
```

#### IAM Permissions
```python
# Inline agent permissions
inline_agent_lambda.add_to_role_policy(
    iam.PolicyStatement(
        actions=[
            "bedrock:InvokeInlineAgent",
            "bedrock:GetInferenceProfile",
            "bedrock:ListInferenceProfiles",
            "bedrock:UseInferenceProfile",
        ],
        resources=["*"]
    )
)
```

### Docker Container Setup

The inline agent uses a custom Docker container with both Python and Node.js runtimes:

```dockerfile
# From lambdas/bedrock_inline_agent/Dockerfile
FROM --platform=linux/amd64 public.ecr.aws/lambda/python:3.12

# Install Node.js and npm on Amazon Linux
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
RUN dnf install -y nodejs

# Install Context7 MCP locally for better Lambda compatibility
RUN npm install @upstash/context7-mcp

# Install mcp-remote for AWS Knowledge MCP server proxy
RUN npm install mcp-remote
```

## API Endpoints

### Function URL Endpoints

The inline agent uses Lambda Function URLs to bypass API Gateway timeouts:

- **`/api/inline-agent/chat`**: Main chat endpoint for agent interactions
- **`/api/inline-agent/stream`**: Streaming endpoint for real-time responses
- **`/api/inline-agent/capabilities`**: Agent capabilities and MCP server status

### Request/Response Format

#### Chat Request
```json
{
  "message": "What are the best practices for AWS Lambda deployment?",
  "session_id": "session-123",
  "conversation_context": [...]
}
```

#### Agent Response
```json
{
  "response": "Based on AWS best practices...",
  "thinking_process": "Let me analyze the question...",
  "tool_calls": [
    {
      "tool": "aws_knowledge_search",
      "parameters": {...},
      "result": "..."
    }
  ],
  "citations": [
    {
      "source": "AWS Lambda Best Practices",
      "excerpt": "...",
      "url": "..."
    }
  ],
  "token_usage": {...},
  "model_calls": 1
}
```

## Session Management

### Agent Session Types

Inline agent sessions are distinguished from regular chat sessions:

```python
# Session type identification
session_type = "inline_agent"  # vs "chat" for regular sessions

# Extended session data structure
session_data = {
    "session_type": "inline_agent",
    "agent_metadata": {
        "agent_type": "aws_knowledge",
        "mcp_servers": ["context7", "aws-knowledge"],
        "conversation_context": [...]
    },
    "mcp_server_calls": 0,
    "knowledge_base_queries": 0
}
```

### Conversation Context Management

The system maintains conversation context across multiple agent invocations:

- **Context Persistence**: Conversation history stored in DynamoDB
- **Context Retrieval**: Previous context loaded for each new request
- **Context Optimization**: Intelligent context truncation for long conversations
- **MCP Server State**: Tool call history and knowledge base queries

## Error Handling and Logging

### Comprehensive Logging

The inline agent system provides detailed operational visibility:

```python
# User prompt logging with privacy protection
logger.info(f"User prompt: {user_prompt[:100]}...")

# Tool call logging
logger.info(f"MCP server call: {tool_name} with parameters {params}")

# Agent thinking process capture
logger.info(f"Agent thinking: {thinking_process}")

# Performance metrics
logger.info(f"Response time: {duration}ms, tokens: {token_count}")
```

### Error Handling Strategies

- **Individual Event Error Isolation**: Prevents cascading failures
- **Graceful Degradation**: System continues operating despite individual errors
- **Comprehensive Error Context**: Detailed error information for debugging
- **Fallback Mechanisms**: Alternative approaches when primary methods fail

## Performance Optimization

### Caching Strategies

- **MCP Server Response Caching**: Cache frequently accessed documentation
- **Conversation Context Caching**: Optimize context retrieval and storage
- **Action Group Caching**: Cache action group configurations
- **Model Response Caching**: Cache similar queries for faster responses

### Resource Management

- **Connection Pooling**: Efficient MCP server connection management
- **Memory Optimization**: Intelligent memory usage for long conversations
- **Timeout Management**: Configurable timeouts for different operation types
- **Resource Cleanup**: Proper cleanup of temporary resources

## Monitoring and Observability

### CloudWatch Integration

- **Custom Metrics**: Agent invocation counts, response times, error rates
- **Structured Logging**: JSON-formatted logs for easy analysis
- **Performance Dashboards**: Real-time monitoring of agent operations
- **Alert Configuration**: Proactive notification of issues

### Operational Insights

- **Usage Patterns**: Track agent usage and popular queries
- **Performance Trends**: Monitor response times and throughput
- **Error Analysis**: Identify common failure patterns
- **Resource Utilization**: Track Lambda memory and execution time

## Current Status

### ✅ **Infrastructure Complete**
- Inline agent infrastructure deployed and running
- MCP server integration working with Context7
- AWS Knowledge MCP server ready for testing
- Cross-region inference profile configured
- All runtime errors resolved

### ✅ **Backend Implementation**
- Inline agent client fully functional
- MCP server integration complete
- Session management extended for agent sessions
- Error handling and logging comprehensive
- Performance optimization implemented

### 🔄 **Frontend Integration Pending**
- Agent chat interface components need implementation
- Rich metadata display (thought process, tool calls, citations)
- Real-time updates and streaming support
- User experience and interface polish

## File References

### Core Implementation
- `lambdas/bedrock_inline_agent/src/inline_agent_client.py` – Main inline agent client
- `lambdas/bedrock_inline_agent/src/function_url_handler.py` – Function URL handler
- `lambdas/bedrock_inline_agent/src/InlineAgent/` – Core inline agent implementation

### Infrastructure
- `infra/stacks/application/api_stack.py` – Inline agent Lambda and permissions
- `lambdas/bedrock_inline_agent/Dockerfile` – Container with Node.js + Python runtimes

### MCP Server Integration
- `lambdas/bedrock_inline_agent/src/InlineAgent/tools/mcp.py` – MCP server tools
- `lambdas/bedrock_inline_agent/src/InlineAgent/action_group/action_group.py` – Action group management

## Next Steps

### Immediate Priority
1. **Test AWS Knowledge MCP Server**: Deploy and validate HTTP transport integration
2. **Frontend Integration**: Implement agent chat interface components
3. **Rich Metadata Display**: Show thought process, tool calls, and citations
4. **Real-time Updates**: Implement streaming and live updates

### Future Enhancements
1. **Additional MCP Servers**: Integrate more specialized MCP servers
2. **Advanced Context Management**: Implement sophisticated conversation context handling
3. **Performance Optimization**: Add advanced caching and optimization strategies
4. **Monitoring Dashboards**: Create comprehensive operational dashboards

## Lessons Learned

### Architecture Decisions
- **Dedicated Project Structure**: Separation of concerns improves maintainability
- **Local MCP Installation**: Better Lambda compatibility than external servers
- **Function URL Endpoints**: Simpler than API Gateway for long-running operations
- **Cross-Region Inference**: Inference profiles provide better cost and access control

### Implementation Insights
- **EventStream Processing**: Individual event handling prevents cascading failures
- **MCP Server Integration**: Local installation eliminates external dependencies
- **Error Isolation**: Comprehensive error handling maintains system stability
- **Performance Monitoring**: Detailed logging enables operational insights

### Best Practices
- **Security First**: Private S3 buckets with OAC, not static website hosting
- **Resource Optimization**: Proper timeout and memory configuration
- **Monitoring Integration**: CloudWatch metrics and structured logging
- **Documentation**: Comprehensive implementation documentation for future development
