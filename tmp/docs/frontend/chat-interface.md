# Chat Interface Documentation

## Overview

The chat interface provides real-time AI-powered conversations with support for streaming responses, model selection, and thought process visualization. It integrates with AWS Bedrock through API Gateway and WebSocket connections for a seamless user experience, featuring comprehensive Hebrew RTL support and modern React patterns.

## Architecture

### Component Hierarchy
```
ChatPage
├── ChatContainer
│   ├── ConnectionStatus
│   ├── ModelSelector
│   ├── MessageList
│   │   ├── SystemMessage
│   │   ├── MessageBubble (user)
│   │   ├── MessageBubble (assistant)
│   │   ├── ThoughtProcess
│   │   └── TypingIndicator
│   └── ErrorMessage
└── ChatInput
```

## Implementation Overview

### Authentication Integration
The chat interface integrates with the authentication system implemented in `frontend/src/app/providers/AuthProvider.tsx`:

- **Token Management**: Automatic token refresh for API calls
- **Protected Routes**: Chat interface requires authentication
- **User Context**: User information available in chat components
- **Session Handling**: Automatic session restoration

### RTL Support Implementation
Hebrew RTL support is implemented throughout the chat interface:

- **Ant Design RTL**: ConfigProvider setup in `frontend/src/app/providers/ThemeProvider.tsx`
- **CSS Direction**: Dynamic direction classes based on language
- **Text Alignment**: RTL-aware text alignment and layout
- **Component Adaptation**: RTL-specific component rendering

## Core Components

### Chat Page
The main chat interface is implemented in `frontend/src/features/chat/components/ChatPage.tsx`:

- **Layout Structure**: Header with model selector and connection status
- **Chat Container**: Main message display area
- **Input Area**: Message input with send functionality
- **Responsive Design**: Mobile-friendly layout with proper RTL support

### Chat Container
The message display area is implemented in `frontend/src/features/chat/components/ChatContainer.tsx`:

- **Message Rendering**: Display user and assistant messages
- **Auto-scroll**: Automatic scrolling to latest messages
- **Streaming Support**: Real-time message streaming display
- **Error Handling**: Error message display and retry functionality

### Message Components

#### Message Bubble
Individual message display in `frontend/src/features/chat/components/MessageBubble.tsx`:

- **Role-based Styling**: Different styles for user and assistant messages
- **RTL Support**: Proper text direction and bubble alignment
- **Markdown Rendering**: Rich text formatting support
- **Timestamp Display**: Message timing information
- **Model Information**: AI model used for response

#### System Message
System notifications in `frontend/src/features/chat/components/SystemMessage.tsx`:

- **Welcome Messages**: Initial system messages
- **Status Updates**: Connection and system status
- **Error Notifications**: System error messages
- **Information Display**: Help and guidance messages

#### Typing Indicator
Loading state display in `frontend/src/features/chat/components/TypingIndicator.tsx`:

- **Animated Dots**: Visual loading indicator
- **Status Text**: "AI is thinking..." message
- **RTL Support**: Proper text direction for Hebrew

### Chat Input
Message input functionality in `frontend/src/features/chat/components/ChatInput.tsx`:

- **Auto-resize**: Dynamic textarea height adjustment
- **Keyboard Shortcuts**: Enter to send, Shift+Enter for new line
- **File Attachment**: Document upload support
- **Send Button**: Submit message with loading state
- **RTL Support**: Proper text input direction

### Special Components

#### Model Selector
AI model selection in `frontend/src/features/chat/components/ModelSelector.tsx`:

## Session Management

### Session Sidebar Implementation
The chat interface includes a comprehensive session management system with backend integration, implemented in `frontend/src/shared/components/Layout/MainLayout.tsx`:

#### Architecture Decisions
- **DynamoDB GSI Strategy**: Added UserSessionsIndex with user_id as partition key and created_at as sort key for efficient session queries
- **Session Title Generation**: Implemented LLM-based automatic title generation from first user message using Bedrock
- **Lazy Session Creation**: Sessions are created only when first message is sent, not on "New Chat" click
- **Split Sidebar Layout**: Integrated session management into existing navigation sidebar under Chat tab
- **RTL Support**: Implemented language-aware sidebar positioning for Hebrew/RTL languages
- **Compact Header Design**: Redesigned chat header to be sleek with icons and tooltips instead of verbose text

#### Implementation Details
- **Session Storage**: Backend integration with DynamoDB for persistent session storage
- **Real-time Updates**: Polling mechanism for session title updates after LLM generation
- **User Experience**: Compact UI design reduces cognitive load and improves usability
- **RTL Layout**: Proper flexbox structure with height constraints for scrolling in Hebrew mode

#### Key Components
- **MainLayout**: Integrated session management into main navigation sidebar
- **SessionSidebar**: Collapsible session management component with RTL support
- **UsageIndicator**: Redesigned compact usage display with icons
- **ModelSelector**: Simplified model selection display
- **ChatContainer**: Updated header layout with removed verbose text

#### File References
- `frontend/src/shared/components/Layout/MainLayout.tsx` – Main layout with integrated session management
- `frontend/src/features/chat/components/SessionSidebar.tsx` – Session management component
- `frontend/src/features/chat/stores/chatStore.ts` – Backend session integration and caching
- `frontend/src/features/chat/components/UsageIndicator.tsx` – Compact usage display
- `frontend/src/features/chat/components/ModelSelector.tsx` – Simplified model selector
- `frontend/src/styles/index.css` – Sidebar layout and scrolling styles

#### Lessons Learned
- DynamoDB GSI design requires careful consideration of access patterns and cost optimization
- Frontend-backend session coordination needs proper ID mapping and state synchronization
- RTL layout support requires language-aware positioning and proper CSS direction handling
- Compact UI design improves user experience by reducing cognitive load
- Sidebar layout requires proper flexbox structure with height constraints for scrolling

### Inline Agent UI Integration
The chat interface supports both regular chat and inline agent sessions with advanced UI integration patterns:

**Agent Session Management**:
- **Dual Session Types**: Regular chat sessions and agent chat sessions with distinct icons
- **Robot Icons**: Agent sessions display robot icons to distinguish them from regular chat bubbles
- **Session Navigation**: Seamless switching between different agent chat sessions
- **Unified Sidebar**: Combined session list with proper sorting by creation date

**UI Architecture Decisions**:
1. **Component Re-rendering Strategy**
   - **Problem**: Agent responses not displaying immediately due to Zustand reactivity issues
   - **Solution**: Added `key={currentAgentSession.id}` prop to force component re-mounting
   - **Rationale**: Simpler than complex Zustand subscription debugging
   - **Implementation**: `frontend/src/features/chat/components/ChatContainer.tsx`

2. **Session Sorting Strategy**
   - **Problem**: New agent chats appearing at bottom of sessions list
   - **Solution**: Consistent sorting by creation date (newest first) across all session types
   - **Rationale**: Better user experience for session discovery
   - **Implementation**: `frontend/src/shared/components/Layout/MainLayout.tsx`

3. **State Update Patterns**
   - **Problem**: Zustand reactivity with nested object properties in agent store
   - **Solution**: Improved state update patterns ensuring proper reactivity
   - **Rationale**: Prevents stale state references and maintains consistency
   - **Implementation**: `frontend/src/features/chat/stores/agentStore.ts`

**Key Components**:
- **AgentChatInterface**: Specialized interface for agent interactions with improved state subscriptions
- **AgentIndicator**: Visual indicator showing when agent mode is active
- **SessionSidebar**: Unified session management supporting both chat types
- **ChatContainer**: Container component with proper re-rendering for session changes

**Implementation Benefits**:
- **Consistent UX**: Same session management patterns for both chat types
- **Visual Distinction**: Clear icons differentiate agent and regular sessions
- **Performance**: Efficient re-rendering through strategic use of component keys
- **Maintainability**: Shared session logic reduces code duplication

**Current Status**:
- ✅ **Working**: Session creation, navigation, and visual distinction
- ❌ **In Progress**: Agent response display reactivity (responses received but not displayed immediately)
- 🔄 **Next Steps**: Fix remaining reactivity issue and clean up debug logs

- **Available Models**: Dynamic model list from API (15+ Bedrock models)
- **Model Information**: Name, tier, capabilities, and pricing information
- **Selection State**: Current model tracking with persistence
- **UI Integration**: Searchable dropdown with model details and descriptions
- **Model Categories**: Organized by provider (Claude, Nova, Mistral, Llama, etc.)

#### Usage Indicator
Token usage and cost tracking in `frontend/src/features/chat/components/UsageIndicator.tsx`:

**Core Features**:
- **Token Display**: Input, output, and total token counts
- **Cost Calculation**: Real-time cost estimation in USD
- **Visual Indicators**: Progress bar and color-coded cost thresholds
- **Model Information**: Current model and pricing details
- **Tooltips**: Educational information about token usage and costs

**Cost Thresholds**:
- **Green**: Low cost (< $0.02)
- **Yellow**: Medium cost ($0.02 - $0.05)
- **Red**: High cost (> $0.05)

**Implementation Details**:
- **Header Placement**: Always visible in chat header for better UX
- **Default Values**: Shows 0 tokens when no usage data available
- **Bilingual Support**: English and Hebrew translations
- **Data Persistence**: Stores usage data in session state
- **Real-time Updates**: Updates during streaming responses

#### Thought Process Viewer
AI reasoning display in `frontend/src/features/chat/components/ThoughtProcess.tsx`:

**Core Features**:
- **Expandable Content**: Collapsible thought process with smooth animations
- **Visual Indicators**: Bulb icon and expand/collapse arrows
- **Structured Display**: Separate sections for thinking, analysis, and conclusions
- **User Control**: Toggle visibility with persistent preferences
- **Syntax Highlighting**: Code blocks within thought process

**Thought Process Structure**:
- **Thinking Section**: AI's analytical reasoning process
- **Analysis Section**: Key principles and legal considerations
- **Answer Section**: Final structured response
- **Metadata Display**: Token usage, model information, response timing

**Implementation Details**:
- **XML Parsing**: Extracts `<thinking>`, `<analysis>`, and `<answer>` tags
- **LocalStorage Persistence**: Remembers user's expand/collapse preferences
- **RTL Support**: Proper Hebrew text direction and layout
- **Accessibility**: Screen reader support and keyboard navigation

**User Requirements Implemented**:
- **Visibility Persistence**: Thought process expand/collapse state persisted between messages
- **Intermediate Steps**: Shows agent loop steps ("Searching documents...", "Processing query...")
- **Inline Display**: Thought process shown inline with messages, not in separate panels

#### Connection Status
Real-time connection monitoring in `frontend/src/features/chat/components/ConnectionStatus.tsx`:

- **Visual Indicator**: Green/red dot for connection status
- **Status Text**: "Connected" or "Disconnected" labels
- **Animation**: Pulsing animation for active connection
- **Real-time Updates**: Live connection status monitoring

#### Error Message
Error handling and display in `frontend/src/features/chat/components/ErrorMessage.tsx`:

- **Error Display**: Clear error message presentation
- **Retry Functionality**: Retry button for failed operations
- **User Guidance**: Helpful error descriptions
- **Action Buttons**: Retry and dismiss options

## State Management

### Chat Store
State management is implemented using Zustand in `frontend/src/features/chat/stores/chatStore.ts`:

**State Structure**:
```typescript
interface ChatState {
  sessions: ChatSession[]
  currentSession: ChatSession | null
  isLoading: boolean
  isStreaming: boolean
  error: string | null
  availableModels: ChatModel[]
  selectedModel: ChatModel | null
}

interface ChatSession {
  id: string
  backendSessionId?: string  // Coordination with backend
  title: string
  messages: Message[]
  createdAt: string
  lastUsage?: TokenUsage    // Usage tracking
  lastModel?: string        // Model tracking
}
```

**Key Features**:
- **Session Management**: Multiple conversation sessions with persistence
- **Message History**: Complete conversation history with metadata
- **Streaming State**: Real-time message streaming with progress tracking
- **Usage Tracking**: Token usage and cost information per session
- **Model Selection**: Dynamic model loading and selection
- **Error Handling**: Comprehensive error state management
- **Backend Coordination**: Proper session ID synchronization

**Persistence**:
- **LocalStorage Integration**: Automatic state persistence
- **Session Restoration**: Restore conversations on app reload
- **Usage Data Persistence**: Store token usage and cost information
- **Model Preferences**: Remember user's model selection

### Store Actions
The chat store provides comprehensive actions:

**Core Actions**:
- **sendMessage**: Send user message and handle both streaming and non-streaming responses
- **sendStreamingMessage**: Dedicated streaming message handling with SSE
- **stopStreaming**: Cancel active streaming operations
- **clearMessages**: Clear chat history and reset session
- **createNewChat**: Start new conversation session

**Model Management**:
- **loadModels**: Fetch available Bedrock models from API
- **selectModel**: Change AI model with persistence
- **setSelectedModel**: Update current model selection

**Message Operations**:
- **retryLastMessage**: Retry failed message with same parameters
- **deleteMessage**: Remove specific message from history
- **updateMessage**: Update message content during streaming
- **updateStreamingMessage**: Handle real-time streaming updates

**Session Management**:
- **Session Creation**: Automatic session creation for new conversations
- **Session Persistence**: Store conversation history and metadata
- **Backend Session ID**: Proper coordination between frontend and backend sessions
- **Usage Tracking**: Store token usage and cost information per session

**Error Handling**:
- **setError**: Set error state with categorized error types
- **clearError**: Clear current error state
- **handleStreamingError**: Specialized streaming error handling

## WebSocket Integration

### Async Chat WebSocket Client
Real-time communication for async agent interactions is handled in `frontend/src/features/chat/hooks/useAsyncChat.ts`:

**Core Features**:
- **WebSocket Connection**: Real-time bidirectional communication
- **Message Streaming**: Progressive text display with configurable delays
- **Authentication**: JWT token-based authentication
- **Error Recovery**: Automatic reconnection with exponential backoff
- **Event Handling**: Comprehensive WebSocket event processing

**WebSocket Message Types**:
```typescript
interface WebSocketMessage {
  type: 'start' | 'content' | 'trace' | 'complete' | 'error' | 'done'
  session_id: string
  message_id?: string
  content?: string
  trace_data?: any
  timestamp: string
  sequence: number
  metadata?: {
    model?: string
    processing_time?: number
    total_tokens?: number
  }
}
```

**WebSocket UI Implementation**:
- **Producer-Consumer Pattern**: Separates event handling from UI updates
- **Configurable Delays**: `STREAMING_DELAY_MS = 500` for visible streaming effect
- **React Batching Fix**: Uses `requestAnimationFrame` to force immediate updates
- **Direct Message Updates**: `updateMessage()` calls for better performance

**Connection Management**:
- **Automatic Reconnection**: Exponential backoff with max 3 retries
- **Timeout Handling**: 300-second timeout with heartbeat support
- **Error Recovery**: Graceful fallback to non-streaming mode
- **Connection Status**: Real-time connectivity monitoring

### Server-Sent Events (SSE) Integration

**Note**: SSE is still used for regular chat streaming endpoints. WebSocket is specifically for async agent interactions.

**Streaming Client**: `frontend/src/services/streaming/streamingClient.ts`

**Stream Event Types**:
```typescript
type StreamEvent = {
  type: 'start' | 'content_delta' | 'complete' | 'error'
  text?: string
  response?: Partial<Message>
  usage?: TokenUsage
  error?: string
  session_id?: string
}
```

### API Integration
Chat API integration in `frontend/src/services/api/chatApi.ts`:

- **Message Sending**: HTTP POST for message submission
- **Streaming Support**: Server-sent events for real-time responses
- **Model Management**: Available models retrieval
- **Authentication**: JWT token inclusion in requests
- **Error Handling**: Comprehensive error management

## Features

### Message Formatting
Rich text support throughout the chat interface:

- **Markdown Rendering**: Full markdown support with syntax highlighting
- **Code Blocks**: Syntax-highlighted code with copy functionality
- **Link Detection**: Automatic link detection and rendering
- **Emoji Support**: Unicode emoji rendering
- **RTL Text**: Proper Hebrew text rendering

### File Attachments
Document and file handling capabilities:

- **Document Upload**: Support for various document formats
- **Image Preview**: Inline image display in chat
- **File Validation**: Type and size validation
- **Progress Tracking**: Upload progress indicators
- **Error Handling**: Upload error management

### Message Actions
Comprehensive message interaction features:

- **Copy Content**: Copy message text to clipboard
- **Regenerate Response**: Retry AI response generation
- **Edit and Resend**: Modify and resend user messages
- **Delete Message**: Remove messages from history
- **Share Conversation**: Export or share chat history

### Keyboard Shortcuts
Efficient keyboard navigation:

- **Enter**: Send message
- **Shift + Enter**: New line in input
- **Ctrl/Cmd + K**: Clear chat history
- **Ctrl/Cmd + /**: Focus message input
- **Escape**: Cancel editing or close dialogs

## Performance Optimizations

### Virtual Scrolling
Large message list optimization:

- **React Window**: Virtual scrolling for large message lists
- **Dynamic Heights**: Variable message heights based on content
- **Memory Management**: Efficient memory usage for long conversations
- **Smooth Scrolling**: Optimized scroll performance

### Message Caching
Efficient message storage and retrieval:

- **Message Cache**: In-memory message caching
- **Cache Limits**: Configurable cache size limits
- **LRU Eviction**: Least recently used cache eviction
- **Persistent Storage**: Optional local storage for messages

### Bundle Optimization
Build-time optimizations:

- **Code Splitting**: Route-based code splitting
- **Tree Shaking**: Unused code elimination
- **Lazy Loading**: Component lazy loading
- **Asset Optimization**: Image and asset optimization

## Error Handling

### Error States
Comprehensive error management:

- **Network Errors**: Connection and API error handling
- **Authentication Errors**: Token expiration and auth failures
- **Streaming Errors**: Real-time communication errors
- **User Feedback**: Clear error messages and recovery options

### Retry Logic
Automatic error recovery:

- **Exponential Backoff**: Intelligent retry timing
- **Max Retries**: Configurable retry limits
- **User Notification**: Clear retry status updates
- **Graceful Degradation**: Fallback to non-streaming mode

### Error Display
User-friendly error presentation:

- **Error Messages**: Clear, actionable error descriptions
- **Retry Options**: Easy retry functionality
- **Help Links**: Links to troubleshooting resources
- **Status Indicators**: Visual error state indicators

## Testing

### Unit Testing
Component-level testing:

- **Component Tests**: Individual component testing
- **Hook Testing**: Custom hook testing
- **Store Testing**: Zustand store testing
- **Utility Testing**: Helper function testing

### Integration Testing
End-to-end functionality testing:

- **Chat Flow**: Complete message sending and receiving
- **Authentication**: Auth integration testing
- **Streaming**: Real-time communication testing
- **Error Scenarios**: Error handling and recovery

### E2E Testing
Full application testing:

- **User Journeys**: Complete user interaction flows
- **Cross-browser**: Multi-browser compatibility
- **Mobile Testing**: Responsive design testing
- **Accessibility**: Screen reader and keyboard navigation

## Internationalization

### RTL Support
Comprehensive Hebrew support:

- **Text Direction**: Automatic RTL text direction
- **Layout Adaptation**: RTL-aware component layouts
- **Input Handling**: RTL text input support
- **Message Alignment**: RTL message bubble alignment

### Translation Support
Multi-language interface:

- **Hebrew/English**: Full bilingual support
- **Dynamic Switching**: Runtime language switching
- **Context-aware**: Language-specific content
- **Fallback Handling**: Graceful fallback to English

## Security Considerations

### Input Validation
User input security:

- **XSS Prevention**: Input sanitization
- **File Validation**: Secure file upload handling
- **Rate Limiting**: Message sending rate limits
- **Content Filtering**: Inappropriate content detection

### Authentication
Secure communication:

- **Token Management**: Secure token handling
- **Session Validation**: Session integrity checks
- **API Security**: Secure API communication
- **HTTPS Enforcement**: Secure connection requirements

## Implementation Files

### Core Components
- `frontend/src/features/chat/components/ChatPage.tsx` - Main chat page
- `frontend/src/features/chat/components/ChatContainer.tsx` - Message container
- `frontend/src/features/chat/components/MessageBubble.tsx` - Individual messages
- `frontend/src/features/chat/components/ChatInput.tsx` - Message input
- `frontend/src/features/chat/components/SystemMessage.tsx` - System messages
- `frontend/src/features/chat/components/TypingIndicator.tsx` - Loading indicator

### Special Components
- `frontend/src/features/chat/components/ModelSelector.tsx` - AI model selection
- `frontend/src/features/chat/components/ThoughtProcess.tsx` - AI reasoning display
- `frontend/src/features/chat/components/ConnectionStatus.tsx` - Connection monitoring
- `frontend/src/features/chat/components/ErrorMessage.tsx` - Error handling

### State Management
- `frontend/src/features/chat/stores/chatStore.ts` - Chat state management
- `frontend/src/features/chat/types/` - TypeScript type definitions

### Services
- `frontend/src/services/api/chatApi.ts` - Chat API integration
- `frontend/src/services/streaming/streamingClient.ts` - Real-time communication

### Testing
- `frontend/tests/unit/chat/` - Unit tests for chat components
- `frontend/tests/integration/chat/` - Integration tests
- `frontend/tests/e2e/chat/` - End-to-end tests

## Related Documentation

- [Frontend Authentication](./authentication.md) - Authentication integration
- [Frontend State Management](./state-management.md) - State management patterns
- [Frontend Internationalization](./internationalization.md) - i18n and RTL support
- [Backend API Reference](../backend/api.md) - API endpoint documentation
- [Backend Bedrock Integration](../backend/bedrock-integration.md) - AI model integration