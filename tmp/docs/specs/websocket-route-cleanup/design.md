# WebSocket Route Cleanup Design

## Overview

Clean up the WebSocket routing implementation to use only proper route-based routing without legacy action-based fallbacks. Update the frontend to send messages to specific routes and remove all backward compatibility code.

## Current State Analysis

### Backend Issues
- **Mixed Routing**: Handler uses both `route_key` and `action` field from message body
- **Legacy Code**: `$default` route with action-based fallback for backward compatibility
- **Inefficient**: Message body parsing instead of leveraging API Gateway routing
- **Complex**: Multiple routing paths make code harder to maintain

### Frontend Issues
- **Generic Routing**: Sends all messages to base WebSocket URL (goes to `$default`)
- **No Route Specificity**: Doesn't leverage WebSocket route capabilities
- **Legacy Dependencies**: Relies on action-based routing in backend

## Target Architecture

### Clean Route-Based Routing
```
WebSocket Routes:
├── $connect    → Connection Authorizer Lambda
├── chat        → Chat Invoker Lambda (direct)
└── $disconnect → Connection cleanup
```

### Frontend Route Usage
```typescript
// Send chat messages to specific route
const wsUrl = `${baseWsUrl}/chat?token=${jwt}`
```

## Implementation Plan

### Phase 1: Backend Cleanup
1. **Remove Action-Based Routing**
   - Remove `$default` route handler
   - Remove action field parsing
   - Use only `route_key` for routing decisions

2. **Simplify Handler Logic**
   - Direct routing based on `route_key`
   - Clean error handling for unknown routes
   - Remove backward compatibility code

### Phase 2: Frontend Update
1. **Route-Specific URLs**
   - Update WebSocket URL construction
   - Send chat messages to `/chat` route
   - Remove action field from message body

2. **Clean Message Format**
   - Remove `action` field from messages
   - Simplify message structure
   - Update TypeScript interfaces

### Phase 3: Infrastructure Update
1. **Route Configuration**
   - Ensure proper route setup in CDK
   - Remove `$default` route if not needed
   - Update route selection expression

## Technical Specifications

### Backend Changes

#### WebSocket Handler
```python
def handler(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:
    route_key = event.get('requestContext', {}).get('routeKey')
    
    if route_key == 'chat':
        return handle_chat_message(connection_id, event, user_id)
    elif route_key == '$connect':
        return handle_connection(connection_id, event, user_id)
    elif route_key == '$disconnect':
        return handle_disconnection(connection_id, event, user_id)
    else:
        return send_error_message(connection_id, f"Unknown route: {route_key}")
```

#### Message Format (Simplified)
```typescript
interface ChatMessage {
  message: string;
  session_id?: string;
  includeHistory?: boolean;
}
```

### Frontend Changes

#### WebSocket URL Construction
```typescript
const wsUrl = `${baseWsUrl}/chat?token=${jwt}`
```

#### Message Sending
```typescript
sendJsonMessage({
  message: "Hello",
  session_id: sessionId,
  includeHistory: true
})
```

## Benefits

### Performance
- **Faster Routing**: Direct route-based routing vs message parsing
- **Reduced Complexity**: Simpler handler logic
- **Better Caching**: API Gateway can cache route-specific responses

### Security
- **Route-Based Security**: Different security policies per route
- **Input Validation**: Route-specific validation rules
- **Audit Trail**: Clear route-based logging

### Maintainability
- **Cleaner Code**: Single routing approach
- **Easier Debugging**: Clear route separation
- **Better Testing**: Route-specific test cases

## Migration Strategy

### Backward Compatibility
- **None**: Clean break from legacy approach
- **Frontend Update Required**: Must update WebSocket client
- **Deployment Coordination**: Backend and frontend must be deployed together

### Testing Approach
1. **Unit Tests**: Test route-specific handlers
2. **Integration Tests**: Test complete WebSocket flow
3. **End-to-End Tests**: Test frontend-backend integration

## Risk Mitigation

### Deployment Risks
- **Breaking Changes**: Frontend must be updated simultaneously
- **Route Mismatch**: Ensure frontend sends to correct routes
- **Error Handling**: Proper error messages for route mismatches

### Mitigation Strategies
- **Coordinated Deployment**: Deploy backend and frontend together
- **Comprehensive Testing**: Test all route combinations
- **Rollback Plan**: Keep previous version available

## Success Criteria

### Functional Requirements
- [ ] All WebSocket messages use route-based routing only
- [ ] Frontend sends messages to specific routes
- [ ] No action-based routing code remains
- [ ] All existing functionality works with new routing

### Performance Requirements
- [ ] Routing performance improved
- [ ] Code complexity reduced
- [ ] Error handling simplified

### Quality Requirements
- [ ] Clean, maintainable code
- [ ] Comprehensive test coverage
- [ ] Clear documentation
- [ ] No breaking changes for users

## Implementation Timeline

1. **Design Review** (1 hour)
2. **Backend Implementation** (2 hours)
3. **Frontend Implementation** (1 hour)
4. **Testing** (1 hour)
5. **Deployment** (30 minutes)
6. **Validation** (30 minutes)

**Total Estimated Time**: 6 hours
