# MCP Integration Documentation

## Overview

The Legal Information System integrates with MCP (Model Context Protocol) servers to provide AI agents with access to external tools, knowledge bases, and specialized capabilities. This integration enables the system to leverage AWS Bedrock's inline agent capabilities while maintaining security, performance, and reliability.

## MCP Architecture Overview

### MCP Protocol Implementation
```
MCP Integration System
├── Inline Agent Lambda
│   ├── MCP Client Creation
│   ├── Action Group Integration
│   └── Tool Execution
├── MCP Servers
│   ├── Context7 MCP Server (stdio transport)
│   ├── AWS Knowledge MCP Server (HTTP transport)
│   └── Custom MCP Servers (future)
└── External Services
    ├── Documentation APIs
    ├── Knowledge Bases
    └── Tool Execution Services
```

### Key Design Principles
- **Local Installation**: MCP servers installed locally in Lambda containers for reliability
- **Transport Flexibility**: Support for both stdio and HTTP transport methods
- **Tool Integration**: Seamless integration of MCP tools into Bedrock action groups
- **Error Handling**: Comprehensive error handling and graceful degradation
- **Performance Optimization**: Efficient tool execution and response handling

## MCP Server Types

### Context7 MCP Server ✅ COMPLETED

**Implementation Status**: Successfully implemented and working
**Transport Method**: Stdio (standard input/output)
**Installation**: Local npm installation in Lambda container
**Purpose**: Documentation and knowledge retrieval

#### Implementation Details

**Local Installation Strategy**:
```dockerfile
# From lambdas/bedrock_inline_agent/Dockerfile
FROM --platform=linux/amd64 public.ecr.aws/lambda/python:3.12

# Install Node.js and npm on Amazon Linux
RUN curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
RUN dnf install -y nodejs

# Install Context7 MCP locally for better Lambda compatibility
RUN npm install @upstash/context7-mcp
```

**MCP Client Configuration**:
```python
# From lambdas/bedrock_inline_agent/src/inline_agent_client.py
async def _create_context7_mcp_client(self):
    """Create Context7 MCP client using local installation."""
    server_params = StdioServerParameters(
        command="node",
        args=["/var/task/node_modules/@upstash/context7-mcp/dist/index.js"],
    )
    
    # Create and return MCP client using stdio transport
    mcp_client = await MCPStdio.create(server_params=server_params)
    return mcp_client
```

**Key Features**:
- **Local Installation**: Eliminates external infrastructure dependencies
- **Stdio Transport**: Reliable communication protocol for Lambda environment
- **Direct Tool Access**: Seamless integration with action groups
- **Lambda Compatibility**: Optimized for serverless execution environment

### AWS Knowledge MCP Server ✅ COMPLETED

**Implementation Status**: Successfully implemented and ready for testing
**Transport Method**: HTTP via mcp-remote proxy
**Installation**: mcp-remote utility for HTTP transport
**Purpose**: AWS documentation and best practices

#### Implementation Details

**mcp-remote Proxy Integration**:
```python
async def _create_aws_knowledge_mcp_client(self):
    """Create AWS Knowledge MCP client using mcp-remote proxy."""
    server_params = StdioServerParameters(
        command="npx",
        args=["mcp-remote", "https://knowledge-mcp.global.api.aws"],
    )
    
    # Create and return MCP client using stdio transport through mcp-remote
    mcp_client = await MCPStdio.create(server_params=server_params)
    return mcp_client
```

**Docker Container Setup**:
```dockerfile
# Install mcp-remote for AWS Knowledge MCP server proxy
RUN npm install mcp-remote
```

**Key Features**:
- **HTTP Transport**: Uses the correct streamable HTTP transport method as specified in MCP specification
- **AWS Documentation Access**: Comprehensive AWS service documentation and best practices
- **Real-time Updates**: Access to latest AWS service announcements and features
- **Proxy Architecture**: mcp-remote utility provides reliable HTTP transport

## MCP Server Integration Architecture

### Dynamic MCP Client Creation

The system dynamically creates MCP clients based on environment configuration:

```python
# MCP server selection via environment variable
MCP_SERVER_TYPE = os.environ.get("MCP_SERVER_TYPE", "aws-knowledge")

# Dynamic MCP client creation
if MCP_SERVER_TYPE == "context7":
    self.logger.info("Creating Context7 MCP client")
    mcp_client = await self._create_context7_mcp_client()
else:
    # Default to AWS Knowledge MCP server
    self.logger.info("Creating AWS Knowledge MCP client")
    mcp_client = await self._create_aws_knowledge_mcp_client()
```

### Action Group Integration

MCP clients are integrated into Bedrock action groups to provide tools to the inline agent:

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

### Tool Discovery and Registration

The system automatically discovers and registers MCP server tools:

```python
# Discover available tools from MCP server
await mcp_client.set_available_tools()

# Tools are automatically available through the action group
# The inline agent can now use these tools during conversations
```

## Transport Methods

### Stdio Transport (Context7)

**Advantages**:
- **Reliability**: Direct process communication without network dependencies
- **Performance**: Low latency, no network overhead
- **Security**: No external network access required
- **Lambda Compatibility**: Works well in serverless environment

**Implementation**:
```python
# StdioServerParameters configuration
server_params = StdioServerParameters(
    command="node",
    args=["/var/task/node_modules/@upstash/context7-mcp/dist/index.js"],
)

# MCP client creation
mcp_client = await MCPStdio.create(server_params=server_params)
```

### HTTP Transport (AWS Knowledge)

**Advantages**:
- **Remote Access**: Access to external MCP servers
- **Scalability**: Can handle multiple concurrent connections
- **Standard Protocol**: Follows MCP specification for HTTP transport
- **Service Integration**: Direct integration with AWS services

**Implementation**:
```python
# HTTP transport via mcp-remote proxy
server_params = StdioServerParameters(
    command="npx",
    args=["mcp-remote", "https://knowledge-mcp.global.api.aws"],
)

# MCP client creation through proxy
mcp_client = await MCPStdio.create(server_params=server_params)
```

## Error Handling and Resilience

### MCP Server Failure Handling

The system implements comprehensive error handling for MCP server failures:

```python
try:
    # Attempt MCP server operation
    result = await mcp_client.execute_tool(tool_name, parameters)
    return result
except MCPConnectionError as e:
    logger.error(f"MCP server connection failed: {e}")
    # Implement fallback behavior
    return self._fallback_response(tool_name, parameters)
except MCPToolExecutionError as e:
    logger.error(f"Tool execution failed: {e}")
    # Return error information to user
    return {"error": str(e), "tool": tool_name}
```

### Graceful Degradation

When MCP servers are unavailable, the system provides fallback capabilities:

- **Tool Unavailable Messages**: Inform users when specific tools are not available
- **Alternative Approaches**: Suggest alternative methods for obtaining information
- **Error Recovery**: Automatic retry mechanisms for transient failures
- **User Communication**: Clear communication about system limitations

### Connection Management

Efficient connection management for MCP servers:

- **Connection Pooling**: Reuse connections when possible
- **Timeout Configuration**: Configurable timeouts for different operation types
- **Health Checking**: Regular health checks for MCP server availability
- **Automatic Reconnection**: Attempt reconnection on connection failures

## Performance Optimization

### MCP Server Response Caching

Implement caching strategies for MCP server responses:

```python
# Cache MCP server responses
@lru_cache(maxsize=1000)
def get_cached_mcp_response(tool_name, parameters_hash):
    # Return cached response if available
    pass

# Use caching for frequently accessed tools
def execute_mcp_tool_with_caching(tool_name, parameters):
    cache_key = f"{tool_name}_{hash(str(parameters))}"
    return get_cached_mcp_response(tool_name, cache_key)
```

### Tool Execution Optimization

Optimize tool execution for better performance:

- **Parallel Execution**: Execute multiple tools concurrently when possible
- **Request Batching**: Batch multiple tool requests to reduce overhead
- **Response Streaming**: Stream responses for long-running tool operations
- **Resource Management**: Efficient memory and CPU usage during tool execution

### Monitoring and Metrics

Track MCP server performance and usage:

```python
# Performance metrics
logger.info(f"MCP tool execution time: {execution_time}ms")
logger.info(f"MCP server response size: {response_size} bytes")
logger.info(f"MCP tool cache hit rate: {cache_hit_rate}%")

# CloudWatch metrics
cloudwatch.put_metric_data(
    Namespace="MCPIntegration",
    MetricData=[
        {
            "MetricName": "ToolExecutionTime",
            "Value": execution_time,
            "Unit": "Milliseconds"
        }
    ]
)
```

## Security Considerations

### MCP Server Security

Security measures for MCP server integration:

- **Local Installation**: MCP servers installed locally to prevent external access
- **Network Isolation**: MCP servers run in isolated Lambda environment
- **Input Validation**: Validate all parameters passed to MCP tools
- **Output Sanitization**: Sanitize responses from MCP servers
- **Access Control**: Limit MCP server access to authorized users

### Tool Execution Security

Secure tool execution environment:

- **Parameter Validation**: Validate tool parameters before execution
- **Resource Limits**: Enforce limits on tool execution time and memory
- **Sandboxing**: Execute tools in isolated environment
- **Audit Logging**: Log all tool executions for security monitoring

## Troubleshooting and Debugging

### Common Issues

#### MCP Server Connection Failures
**Symptoms**: Tool execution fails with connection errors
**Causes**: MCP server process not running, incorrect configuration
**Solutions**: Check MCP server installation, verify configuration parameters

#### Tool Execution Errors
**Symptoms**: Tools return error responses or fail to execute
**Causes**: Invalid parameters, MCP server limitations, network issues
**Solutions**: Validate tool parameters, check MCP server logs, verify network connectivity

#### Performance Issues
**Symptoms**: Slow tool execution, high latency
**Causes**: Resource constraints, inefficient tool implementation
**Solutions**: Optimize tool implementation, increase Lambda resources, implement caching

### Debugging Tools

#### Logging and Monitoring
```python
# Enable debug logging for MCP operations
logger.setLevel(logging.DEBUG)

# Log MCP server communication
logger.debug(f"MCP server request: {request}")
logger.debug(f"MCP server response: {response}")
```

#### Health Checks
```python
async def check_mcp_server_health():
    """Check MCP server health and availability."""
    try:
        # Attempt basic tool discovery
        tools = await mcp_client.list_tools()
        return {"status": "healthy", "tools_count": len(tools)}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}
```

## Future Enhancements

### Additional MCP Servers

Planned integration of additional MCP servers:

- **Database MCP Server**: Direct database access and querying
- **File System MCP Server**: File operations and document processing
- **API Integration MCP Server**: External API integration capabilities
- **Custom Domain MCP Server**: Specialized tools for legal domain

### Advanced Features

Future MCP integration enhancements:

- **Dynamic Tool Loading**: Load MCP servers at runtime
- **Tool Composition**: Combine multiple MCP server tools
- **Advanced Caching**: Intelligent caching strategies for tool responses
- **Performance Analytics**: Detailed performance analysis and optimization

## File References

### Core Implementation
- `lambdas/bedrock_inline_agent/src/inline_agent_client.py` – MCP client creation and management
- `lambdas/bedrock_inline_agent/src/InlineAgent/tools/mcp.py` – MCP server tools implementation
- `lambdas/bedrock_inline_agent/src/InlineAgent/action_group/action_group.py` – Action group integration

### Infrastructure
- `lambdas/bedrock_inline_agent/Dockerfile` – MCP server installation and configuration
- `infra/stacks/application/api_stack.py` – MCP server environment variables

### Configuration
- `lambdas/bedrock_inline_agent/src/InlineAgent/constants.py` – MCP server configuration constants
- Environment variables for MCP server selection and configuration

## Lessons Learned

### Implementation Insights
- **Local Installation**: MCP servers installed locally provide better Lambda compatibility
- **Transport Flexibility**: Support for both stdio and HTTP transport methods is essential
- **Error Handling**: Comprehensive error handling prevents system failures
- **Performance Monitoring**: Detailed metrics enable optimization and troubleshooting

### Best Practices
- **Security First**: Local installation and network isolation for MCP servers
- **Resource Management**: Efficient resource usage and connection management
- **Monitoring Integration**: CloudWatch metrics and structured logging
- **Documentation**: Comprehensive documentation for future development and maintenance

### Architecture Decisions
- **Dual MCP Architecture**: Support for multiple MCP server types provides flexibility
- **Environment Variable Control**: Easy switching between MCP servers via configuration
- **Action Group Integration**: Seamless integration of MCP tools into Bedrock agents
- **Container-Based Approach**: Docker containers enable complex runtime environments
