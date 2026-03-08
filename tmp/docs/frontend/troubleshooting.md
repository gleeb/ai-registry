# Frontend Troubleshooting Guide

## Overview

This document provides solutions for common frontend issues encountered during development and usage of the Legal Information System. It serves as a quick reference for developers and users to resolve problems efficiently.

## Issue Categories

### UI/UX Issues

#### Chat Interface Layout Problems

**Issue**: Chat box is partially off screen
**Symptoms**: Chat interface extends beyond viewport boundaries
**Solutions**:
- Check CSS overflow properties in chat container
- Verify viewport meta tag is properly set
- Ensure responsive design breakpoints are working
**Files to Check**: `frontend/src/features/chat/components/ChatContainer.tsx`, `frontend/src/styles/index.css`

**Issue**: Chat bubbles spacing is too wide
**Symptoms**: Chat bubbles are positioned at screen edges with excessive spacing
**Solutions**:
- Adjust chat bubble margin and padding in CSS
- Check flexbox layout properties for proper alignment
- Verify chat container width constraints
**Files to Check**: `frontend/src/features/chat/components/MessageBubble.tsx`, `frontend/src/styles/index.css`

**Issue**: Chat bubble icons misaligned
**Symptoms**: User and bot icons are not properly aligned with message content
**Solutions**:
- Check icon positioning CSS properties
- Verify flexbox alignment in message bubble components
- Ensure consistent icon sizing and positioning
**Files to Check**: `frontend/src/features/chat/components/MessageBubble.tsx`

#### RTL (Right-to-Left) Layout Issues

**Issue**: RTL mode completely breaks layout
**Symptoms**: 
- User icon appears on right side with text on left
- Bot responses have reversed layout
- Text direction is inconsistent
**Solutions**:
- Verify RTL CSS properties are properly applied
- Check language detection and RTL flag setting
- Ensure all components support RTL layout
- Test with Hebrew language selection
**Files to Check**: `frontend/src/locales/he/translation.json`, `frontend/src/styles/index.css`, RTL-aware components

**RTL Implementation Notes**:
- Use CSS `direction: rtl` for Hebrew text
- Implement proper flexbox direction changes
- Ensure icons and avatars flip appropriately
- Test bidirectional text handling

### Functionality Issues

#### Session Cost Persistence

**Issue**: Session cost is not saved and zeroes out after login/logout
**Symptoms**: Cost tracking resets to zero when user re-authenticates
**Current Status**: Cost data is stored in session state but not persisted to database
**Solutions**:
- Implement cost persistence in backend database
- Store cost data in user profile or session records
- Display accumulated costs in session details header
**Files to Check**: `frontend/src/features/chat/stores/chatStore.ts`, `frontend/src/features/chat/components/UsageIndicator.tsx`

**Implementation Requirements**:
- Database schema for cost tracking
- Backend API endpoints for cost persistence
- Frontend integration with cost history
- Session cost aggregation and display

### Performance Issues

**Issue**: Chat response delays
**Symptoms**: Slow response times for chat interactions
**Solutions**:
- Check network latency and API response times
- Verify streaming implementation is working correctly
- Monitor Lambda function performance
- Check for unnecessary re-renders in React components

**Issue**: Large document processing delays
**Symptoms**: Document upload and processing takes excessive time
**Solutions**:
- Verify S3 upload performance
- Check Lambda function timeout settings
- Monitor document processing pipeline
- Implement progress indicators for user feedback

### Authentication Issues

**Issue**: Login flow problems
**Symptoms**: Authentication failures or unexpected redirects
**Solutions**:
- Verify Cognito configuration
- Check JWT token validation
- Ensure proper redirect handling
- Verify PKCE flow implementation

**Issue**: Session expiration handling
**Symptoms**: Users unexpectedly logged out
**Solutions**:
- Check token refresh logic
- Verify session timeout settings
- Implement proper session renewal
- Add user notification for expiring sessions

### Navigation and Routing Issues

**Issue**: Route protection problems
**Symptoms**: Unauthorized access to protected routes
**Solutions**:
- Verify route guard implementation
- Check authentication state management
- Ensure proper redirect logic
- Test with different user roles

**Issue**: Browser navigation issues
**Symptoms**: Back/forward buttons not working correctly
**Solutions**:
- Check React Router configuration
- Verify browser history management
- Test with different navigation patterns
- Ensure proper route state preservation

## Common Error Messages

### Authentication Errors

**"Invalid JWT token"**
- **Cause**: Expired or malformed JWT token
- **Solution**: Re-authenticate user, check token format

**"Unauthorized access"**
- **Cause**: Missing or invalid authentication
- **Solution**: Verify user is logged in, check permissions

### API Errors

**"Network error"**
- **Cause**: Connection issues or API endpoint problems
- **Solution**: Check network connectivity, verify API status

**"Internal server error"**
- **Cause**: Backend service failures
- **Solution**: Check Lambda function logs, verify backend health

### Component Errors

**"Component not found"**
- **Cause**: Missing component imports or routing issues
- **Solution**: Verify component exists, check import paths

**"State update failed"**
- **Cause**: Zustand store issues or React state problems
- **Solution**: Check store implementation, verify state updates

## Debugging Tools and Techniques

### Browser Developer Tools

**Console Logging**:
- Use structured logging for debugging
- Check for JavaScript errors and warnings
- Monitor network requests and responses

**React Developer Tools**:
- Inspect component state and props
- Monitor component re-renders
- Debug state management issues

**Network Tab**:
- Monitor API calls and responses
- Check request/response headers
- Verify authentication tokens

### Frontend Debugging

**State Inspection**:
- Use Zustand devtools for store debugging
- Check component state with React DevTools
- Monitor state changes and updates

**Performance Monitoring**:
- Use React Profiler for performance analysis
- Monitor component render times
- Check for unnecessary re-renders

## Prevention and Best Practices

### Code Quality

**TypeScript Usage**:
- Enable strict mode for better error detection
- Use proper type annotations
- Avoid `any` types where possible

**Component Design**:
- Keep components focused and single-purpose
- Implement proper error boundaries
- Use React.memo for performance optimization

**State Management**:
- Follow Zustand best practices
- Avoid unnecessary state updates
- Implement proper state persistence

### Testing

**Unit Testing**:
- Test individual components in isolation
- Mock external dependencies
- Verify component behavior with different props

**Integration Testing**:
- Test component interactions
- Verify state management flows
- Test authentication and routing

**User Testing**:
- Test with different browsers and devices
- Verify accessibility compliance
- Test with different user roles and permissions

## Getting Help

### Internal Resources

**Documentation**:
- Check relevant feature documentation
- Review component implementation details
- Consult architecture documentation

**Code Review**:
- Review recent changes for potential issues
- Check for similar problems in other components
- Consult with team members

### External Resources

**React Documentation**: Official React troubleshooting guides
**Zustand Documentation**: State management best practices
**TypeScript Documentation**: Type system and error resolution
**Browser Documentation**: Developer tools and debugging techniques

## Issue Reporting

When reporting new issues, include:

1. **Clear Description**: What is the problem?
2. **Steps to Reproduce**: How can we recreate the issue?
3. **Expected vs Actual Behavior**: What should happen vs what does happen?
4. **Environment Details**: Browser, device, user role
5. **Error Messages**: Any console errors or error messages
6. **Screenshots**: Visual evidence of the problem
7. **Related Issues**: Similar problems or related functionality

## Maintenance

This troubleshooting guide should be updated:

- When new issues are discovered and resolved
- When new features are added that may introduce new issues
- When common problems are identified
- When solutions are improved or new approaches are found

Regular review ensures the guide remains current and helpful for developers and users.
