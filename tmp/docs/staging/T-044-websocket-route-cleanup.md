# T-044 – WebSocket Route Cleanup and Frontend Update

## Overview
Clean up WebSocket routing to use only proper route-based routing without legacy action-based fallbacks. Update frontend to send messages to specific routes and remove backward compatibility code.

## Context Gathered

### Documentation Reviewed
- `docs/index.md` – Project overview and documentation structure
- `docs/backend/index.md` – Backend architecture and WebSocket integration
- `docs/project.md` – Current project status and task management
- `docs/backend/websocket-chat.md` – Current WebSocket implementation
- `docs/frontend/chat-interface.md` – Frontend WebSocket client implementation
- `lambdas/websocket_chat_invoker/src/handler.py` – Current handler with mixed routing
- `frontend/src/features/chat/hooks/useAsyncChat.ts` – Frontend WebSocket client
- `infra/stacks/application/websocket_stack.py` – WebSocket infrastructure

### Key Insights from Context
- Current implementation mixes route-based and action-based routing
- Frontend sends messages to base WebSocket URL (goes to `$default` route)
- Infrastructure defines three routes: `$connect`, `chat`, `$default`
- User wants clean implementation with only proper routing
- Need to update frontend to send messages to specific routes
- Agent stack needs deployment before testing

## Implementation Progress

### Completed ✅
- [x] Analyzed current WebSocket routing implementation
- [x] Identified mixed routing approach (route-based + action-based)
- [x] Created staging document following proper process
- [x] Created design document for route cleanup
- [x] Created task plan following Kanban format
- [x] Updated WebSocket handler to use only route-based routing
- [x] Removed action-based routing and $default route handlers
- [x] Updated frontend to send messages to specific /chat route
- [x] Removed action field from message format
- [x] **CRITICAL DISCOVERY**: AWS WebSocket API only allows authorizers on `$connect` route
- [x] **SOLUTION IMPLEMENTED**: Reverted to action-based routing with `$default` route
- [x] **FINAL WORKING SOLUTION**: WebSocket connection working perfectly with action-based routing
- [x] **TESTING COMPLETED**: WebSocket connection, authentication, and message flow all working
- [x] **DOCUMENTATION UPDATED**: Final working solution documented

### In Progress 🔄
- [ ] Committing progress and updating project board

### Planned 📋
- [ ] Update project documentation with final implementation
- [ ] Archive staging document

### Issues & Resolutions

| Issue | Root Cause | Resolution | Lesson for Future |
|----|---|---|----|
| WebSocket 403 Forbidden | `chat` route missing authorizer | Added authorizer to `chat` and `$default` routes | All WebSocket routes need authentication, not just `$connect` |
| CDK deployment failed with authorizer error | AWS only allows authorizers on `$connect` route | Reverted to action-based routing | Always check AWS service limitations before implementation |
| Agent updated with old container ID | Makefile didn't fetch latest CDK outputs | Added `get-outputs` step before `update` | Always ensure latest infrastructure state before updates |

### Planned 📋
- [ ] Create design document
- [ ] Create task plan
- [ ] Update documentation

## Technical Decisions & Rationale

### Decision 1: Route-Based vs Action-Based Routing
**Initial Choice**: Route-based routing with separate `/chat` route
**Final Choice**: Action-based routing with `$default` route
**Rationale**: 
- AWS WebSocket API Gateway only allows authorizers on `$connect` route
- Action-based routing is the recommended AWS pattern for non-connection routes
- Maintains authentication context from `$connect` route
- Simpler implementation and better security model

### Decision 2: WebSocket Authentication Strategy
**Choice**: JWT token as query parameter on connection
**Rationale**:
- Standard WebSocket authentication pattern
- Token validated once during `$connect` route
- Context flows to all subsequent messages via `$context.authorizer.principalId`
- No need for per-message authentication

### Decision 3: Frontend WebSocket Integration
**Choice**: Use `react-use-websocket` with action-based messaging
**Rationale**:
- Maintains existing frontend patterns
- Simple integration with existing state management
- Reliable WebSocket connection handling
- Easy to extend for additional message types

## Implementation File References

### Files to Modify
- `lambdas/websocket_chat_invoker/src/handler.py` – Remove action-based routing
- `frontend/src/features/chat/hooks/useAsyncChat.ts` – Update to use specific routes
- `infra/stacks/application/websocket_stack.py` – May need route updates

### Files to Deploy
- Agent stack deployment: `cdk deploy testmeoutAgent-sandbox --profile Eng-Sandbox`
- Agent update script execution

## Lessons Learned
- **AWS WebSocket API Limitations**: Only `$connect` route can have authorizers
- **Action-Based Routing**: Recommended pattern for WebSocket message handling
- **Authentication Flow**: Connection-level authentication with context propagation
- **CDK Deployment**: Always check AWS service constraints before implementation
- **Agent Updates**: Ensure latest infrastructure state before updating agents

## Final Working Solution
The WebSocket implementation now works perfectly with:
1. **Connection**: JWT token authentication on `$connect` route
2. **Messaging**: Action-based routing via `$default` route
3. **Frontend**: Simple WebSocket integration with action field
4. **Backend**: Clean separation of connection and message handling
5. **Security**: Proper authentication context flow from connection to messages

## Testing Results
✅ **WebSocket Connection**: Successfully established
✅ **Authentication**: JWT token validated correctly
✅ **Message Routing**: Action-based routing working perfectly
✅ **Agent Processing**: Bedrock agent processing messages and streaming responses
✅ **Real-time Streaming**: Content streaming back to frontend in real-time
✅ **Complete Flow**: End-to-end conversation flow working

## Next Steps
- Update project documentation with final implementation
- Archive this staging document
- Consider this pattern for future WebSocket implementations
