# T-045 – Bedrock AgentCore Memory Integration

## Overview
Implement Bedrock AgentCore Memory features to enable short-term and long-term memory capabilities for the async agent. This will allow the agent to maintain conversation context across sessions and learn user preferences over time.

## Context Gathered

### Documentation Reviewed
- `docs/backend/agentcore-integration.md` – Current AgentCore implementation with WebSocket integration
- `docs/backend/websocket-chat.md` – WebSocket chat system architecture and message flow
- `docs/project.md` – Current project status and completed features
- `agents-core/my_agent_async/src/agent.py` – Current async agent implementation
- AWS Bedrock AgentCore Memory documentation (web search results)

### Key Insights from Context
- Current async agent uses WebSocket for real-time communication
- Session management already implemented with DynamoDB
- Agent processes messages through Bedrock AgentCore Runtime
- Need to integrate memory without breaking existing WebSocket flow
- Session IDs are already tracked and can be used for memory consistency

## Implementation Progress

### Completed ✅
- [x] Deep dive into Bedrock AgentCore Memory documentation
- [x] Understand short-term and long-term memory strategies
- [x] Analyze current agent architecture and WebSocket integration
- [x] Identify integration points for memory functionality
- [x] Create memory deployment folder structure
- [x] Implement memory client integration
- [x] Add callback handlers for message buffering
- [x] Integrate memory storage with existing session management
- [x] Update existing agent to use memory functionality
- [x] Ensure session ID consistency between database and memory
- [x] Refactor streaming to use proper Strands callback handlers
- [x] Implement event loop buffering for complete messages
- [x] Fix Python import issues with memory modules
- [x] Fix session ID format inconsistency between WebSocket and memory storage
- [x] Test memory functionality with WebSocket integration
- [x] Deploy and validate memory features
- [x] Fix Boto3 response structure parsing in explore scripts
- [x] Verify memory events are properly stored and retrievable
- [x] Clean up redundant code (remove unused agent_with_memory)
- [x] Optimize memory storage (remove duplicate complete conversation storage)
- [x] Add comprehensive system prompt for AgentCore testing assistant

### In Progress 🔄
- [ ] Deploy WebSocket stack for frontend integration

### Planned 📋
- [ ] Create comprehensive test suite for memory functionality
- [ ] Add memory analytics and monitoring
- [ ] Document memory usage patterns and best practices

## Technical Decisions & Rationale

### Decision 1: Memory Architecture
**Choice**: Separate short-term and long-term memory handling
**Rationale**: 
- Short-term memory: Use direct MemoryClient for conversation events
- Long-term memory: Use AgentCoreMemoryToolProvider for user preferences
- Follows AWS documentation patterns
- Cleaner separation of concerns

### Decision 2: Session ID Consistency
**Choice**: Use existing session_id from DynamoDB for memory consistency
**Rationale**:
- Maintains traceability between database and memory
- Leverages existing session management infrastructure
- Ensures consistent user experience across systems

### Decision 3: Memory Tool Integration
**Choice**: Use AgentCoreMemoryToolProvider for long-term memory
**Rationale**:
- Follows AWS documentation examples
- Provides proper tool integration with Strands agent
- Handles user preferences automatically
- Cleaner than custom memory client implementation

### Decision 4: Streaming Architecture Refactor
**Choice**: Use Strands callback handlers instead of manual event processing
**Rationale**:
- Follows [Strands documentation](https://strandsagents.com/latest/documentation/docs/user-guide/concepts/streaming/callback-handlers/) best practices
- Proper event loop lifecycle tracking (init, start, complete, force_stop)
- Buffers content per event loop and sends complete messages
- Cleaner separation between streaming logic and memory integration
- More maintainable and follows framework patterns

### Decision 5: Session ID Format Consistency
**Choice**: Clean session IDs at creation time in handler.py instead of cleaning in agent.py
**Rationale**:
- Eliminates inconsistency between WebSocket messages and memory storage
- Session IDs are already compatible with Bedrock AgentCore Memory regex from creation
- Cleaner code - no need for cleaning logic in multiple places
- Better user experience - what they see in WebSocket matches what's stored in memory
- Single source of truth for session ID format

### Decision 6: Memory Storage Optimization
**Choice**: Store individual messages during streaming, remove complete conversation storage
**Rationale**:
- Eliminates duplicate data storage (individual messages + complete conversation)
- More efficient memory usage - each message is a separate event
- Better performance - no unnecessary memory operations at conversation end
- Cleaner memory structure - event-by-event storage as they happen
- Easier debugging and analysis of conversation flow

### Decision 7: Code Cleanup and Optimization
**Choice**: Remove unused variables and redundant code paths
**Rationale**:
- `agent_with_memory` was created but never used - removed for clarity
- Simplified agent creation flow - only create agents that are actually used
- Better maintainability - less confusing code paths
- Improved performance - no unnecessary object creation

### Decision 8: System Prompt Implementation
**Choice**: Add comprehensive system prompt for AgentCore testing assistant
**Rationale**:
- Follows [Strands documentation](https://strandsagents.com/latest/documentation/docs/user-guide/concepts/agents/prompts/) best practices
- Defines clear role and capabilities for the testing assistant
- Explicitly mentions memory management, tool usage, and streaming capabilities
- Provides educational value by explaining AgentCore features
- Ensures consistent behavior across all agent instances (main, streaming, fallback)

## Implementation File References

### Files Created/Modified
- `agents-core/my_agent_async/src/agent.py` – Updated with memory integration using AgentCoreMemoryToolProvider
- `agents-core/my_agent_async/src/memory_client.py` – Short-term memory client wrapper
- `agents-core/my_agent_async/src/callback_handlers.py` – Message buffering handlers for short-term memory
- `agents-core/my_agent_async/requirements.txt` – Added memory dependencies
- `agents-core/my_agent_memory/deploy_memory.py` – Memory deployment script
- `agents-core/my_agent_memory/Makefile` – Memory deployment automation
- `agents-core/my_agent_memory/README.md` – Memory deployment documentation

## Memory Architecture Design

### Short-term Memory
- **Purpose**: Maintain conversation context within a session
- **Storage**: Events stored per actor_id and session_id
- **Lifecycle**: Automatically expires based on eventExpiryDuration
- **Usage**: Immediate context for current conversation

### Long-term Memory
- **Purpose**: Learn and store user preferences across sessions
- **Implementation**: AgentCoreMemoryToolProvider
- **Strategy**: UserPreferenceMemoryStrategy
- **Namespace**: `/users/{actorId}` for user-specific preferences
- **Usage**: Automatic tool integration with Strands agent

### Message Flow Integration
1. **WebSocket Message Received** → Buffer in callback handler
2. **Agent Processing** → Continue normal WebSocket flow
3. **Conversation Complete** → Create memory events
4. **Memory Storage** → Store in both short-term and long-term memory
5. **Context Retrieval** → Query memory for future conversations

## Issues & Resolutions

| Issue | Root Cause | Resolution | Lesson for Future |
|----|---|---|----|
| Memory client integration complexity | Need to understand AgentCore Memory API | Use official SDK and documentation | Always start with official examples |
| Session ID consistency | Need to ensure same IDs across systems | Use existing DynamoDB session_id | Leverage existing infrastructure |
| Boto3 response parsing | Expected different response structure | Fixed explore scripts to parse payload.conversational structure | Always check official API documentation for response format |
| Memory events showing empty | Incorrect field names in parsing | Used correct field names (eventId, eventTimestamp, payload) | Verify field names match official documentation |
| Duplicate memory storage | Storing individual messages + complete conversation | Removed complete conversation storage, keep individual messages | Avoid redundant data storage patterns |
| Unused code variables | agent_with_memory created but never used | Removed unused variables, simplified code flow | Regular code cleanup prevents confusion |

## Next Steps
1. ✅ Deploy memory resource using deployment scripts
2. ✅ Test memory functionality with WebSocket integration
3. ✅ Validate memory storage and retrieval
4. Deploy WebSocket stack for frontend integration
5. Test complete frontend-to-agent flow with memory
6. Create comprehensive test suite
7. Add memory analytics and monitoring
8. Document memory usage patterns and best practices

## References
- [Bedrock AgentCore Memory Getting Started](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-getting-started.html)
- [Short-term Memory Operations](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/short-term-memory-operations.html)
- [Memory Strategies](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory-strategies.html)
- [Strands Callback Handlers](https://strandsagents.com/latest/documentation/docs/user-guide/concepts/streaming/callback-handlers/)
