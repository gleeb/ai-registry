# T-046 – Code Interpreter Integration

## Overview
Implement AWS Bedrock AgentCore Code Interpreter tool to enable Python code execution, data analysis, and validation capabilities for the async agent. This will allow the agent to run code, perform calculations, create visualizations, and validate answers through actual code execution.

## Context Gathered

### Documentation Reviewed
- [AWS Bedrock AgentCore Code Interpreter documentation](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/code-interpreter-building-agents.html) – Official AWS documentation for Code Interpreter implementation
- `docs/backend/agentcore-integration.md` – Current AgentCore implementation with WebSocket integration
- `agents-core/my_agent_async/src/agent.py` – Current async agent implementation with existing tools
- `docs/staging/T-045-bedrock-agentcore-memory-integration.md` – Memory integration context

### Key Insights from Context
- Code Interpreter provides Python code execution with state persistence between executions
- Integrates with existing Strands framework and tool ecosystem
- Requires specific AWS Bedrock AgentCore permissions and configuration
- Maintains session state for complex multi-step code workflows
- Returns structured JSON responses with execution results, errors, and metadata
- Follows same tool pattern as existing tools (calculator, current_time, letter_counter)

## Implementation Progress

### Completed ✅
- [x] Analyze AWS Bedrock AgentCore Code Interpreter documentation
- [x] Understand Code Interpreter capabilities and integration patterns
- [x] Design Code Interpreter tool following Strands @tool decorator pattern
- [x] Implement execute_python tool with proper error handling
- [x] Update system prompt to include Code Interpreter capabilities and guidelines
- [x] Add Code Interpreter tool to all agent instances (main, streaming, fallback)
- [x] Update requirements.txt with Code Interpreter dependencies
- [x] Document Code Interpreter integration in staging document

### In Progress 🔄
- [ ] Test Code Interpreter functionality with sample code execution
- [ ] Deploy and validate Code Interpreter features

### Planned 📋
- [ ] Create comprehensive test suite for Code Interpreter functionality
- [ ] Add Code Interpreter analytics and monitoring
- [ ] Document Code Interpreter usage patterns and best practices
- [ ] Create examples demonstrating Code Interpreter capabilities

## Technical Decisions & Rationale

### Decision 1: Code Interpreter Tool Implementation
**Choice**: Implement execute_python tool following AWS documentation pattern
**Rationale**:
- Follows [AWS Bedrock AgentCore Code Interpreter documentation](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/code-interpreter-building-agents.html) exactly
- Uses code_session context manager for proper resource management
- Maintains state between executions with clearContext=False
- Returns structured JSON response for consistent parsing
- Includes comprehensive error handling and logging

### Decision 2: System Prompt Enhancement
**Choice**: Add Code Interpreter capabilities and usage guidelines to system prompt
**Rationale**:
- Explicitly defines Code Interpreter as a core capability
- Provides clear guidelines for when and how to use code execution
- Emphasizes validation through code execution for mathematical claims
- Maintains educational focus on demonstrating AgentCore features
- Ensures consistent behavior across all agent instances

### Decision 3: Tool Integration Strategy
**Choice**: Add Code Interpreter to all agent instances (main, streaming, fallback)
**Rationale**:
- Ensures Code Interpreter is available in all execution paths
- Maintains consistency across different agent configurations
- Provides fallback capability for code execution even during errors
- Follows same pattern as other tools (calculator, current_time, letter_counter)

### Decision 4: Error Handling and Logging
**Choice**: Implement comprehensive error handling with detailed logging
**Rationale**:
- Code execution can fail for various reasons (syntax errors, runtime errors, etc.)
- Detailed logging helps with debugging and monitoring
- Graceful error handling prevents agent crashes
- Returns structured error information for better user experience

## Implementation File References

### Files Created/Modified
- `agents-core/my_agent_async/src/agent.py` – Added execute_python tool and updated system prompt
- `agents-core/my_agent_async/requirements.txt` – Added Code Interpreter dependencies
- `docs/staging/T-046-code-interpreter-integration.md` – This staging document

## Code Interpreter Architecture Design

### Tool Implementation
- **Tool Name**: `execute_python`
- **Parameters**: 
  - `code` (str): Python code to execute
  - `description` (str): Optional description of what the code does
- **Return Type**: JSON string with execution results
- **State Management**: Maintains variables and context between executions
- **Error Handling**: Comprehensive error catching and structured error responses

### Response Format
The Code Interpreter returns a JSON response with:
- `sessionId`: The code interpreter session ID
- `id`: Request ID
- `isError`: Boolean indicating if there was an error
- `content`: Array of content objects with type and text/data
- `structuredContent`: For code execution, includes stdout, stderr, exitCode, executionTime

### Integration Points
1. **Agent Initialization**: Code Interpreter tool added to base agent
2. **Streaming Agent**: Code Interpreter available during streaming responses
3. **Fallback Agent**: Code Interpreter available during error fallback
4. **Memory Integration**: Code execution results can be stored in memory
5. **WebSocket Communication**: Code execution results streamed to frontend

## Code Interpreter Capabilities

### Core Features
- **Python Execution**: Run Python code with full standard library
- **Data Analysis**: Process and analyze data using pandas, numpy, matplotlib
- **Mathematical Validation**: Verify calculations and algorithms through code execution
- **State Persistence**: Maintain variables and context between executions
- **Error Handling**: Provide detailed error messages and debugging information
- **Result Interpretation**: Parse and explain code execution results

### Use Cases
- **Mathematical Verification**: Validate calculations and algorithms
- **Data Analysis**: Process and visualize data
- **Algorithm Testing**: Implement and test algorithms
- **Problem Solving**: Use code to solve complex problems
- **Educational Demonstrations**: Show how code works step by step

## Issues & Resolutions

| Issue | Root Cause | Resolution | Lesson for Future |
|----|---|---|----|
| Code Interpreter integration complexity | Need to understand AWS Code Interpreter API | Follow official AWS documentation exactly | Always use official examples as reference |
| State management between executions | Need to maintain context across code runs | Use clearContext=False parameter | Understand session lifecycle management |
| Error handling for code execution | Code can fail in many ways | Implement comprehensive try-catch with structured responses | Plan for all possible failure modes |
| Tool integration consistency | Need Code Interpreter in all agent instances | Add to all tools lists (main, streaming, fallback) | Maintain consistency across all execution paths |

## Next Steps
1. Test Code Interpreter functionality with sample code execution
2. Deploy and validate Code Interpreter features
3. Create comprehensive test suite for Code Interpreter functionality
4. Add Code Interpreter analytics and monitoring
5. Document Code Interpreter usage patterns and best practices
6. Create examples demonstrating Code Interpreter capabilities

## References
- [AWS Bedrock AgentCore Code Interpreter Documentation](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/code-interpreter-building-agents.html)
- [Strands Agents Tool Documentation](https://strandsagents.com/latest/documentation/docs/user-guide/concepts/tools/)
- [Python Code Execution Best Practices](https://docs.python.org/3/library/subprocess.html)
