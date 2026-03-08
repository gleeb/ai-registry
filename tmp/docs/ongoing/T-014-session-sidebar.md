# T-014: Chat Session Sidebar Implementation

## Context Gathered
- `docs/frontend/chat-interface.md` - Current chat interface documentation
- `docs/backend/bedrock-integration.md` - Backend API structure
- `frontend/src/features/chat/stores/chatStore.ts` - Current session state management
- `lambdas/bedrock_chat/src/common/session_manager.py` - Backend session CRUD operations
- `lambdas/bedrock_chat/src/handlers/sessions_handler.py` - Session API endpoints
- `infra/stacks/storage/session_stack.py` - Current DynamoDB table structure
- `frontend/src/shared/components/Layout/MainLayout.tsx` - Current layout structure

## Implementation Plan

### Phase 1: Fix DynamoDB Table Structure and GSI
**Current Issue**: The existing session table has `session_id` as partition key and `user_id` as sort key, but `list_user_sessions` is trying to query by `user_id` which is inefficient.

**Solution**: Create a Global Secondary Index (GSI) with `user_id` as partition key and `session_id` as sort key for efficient user session queries.

**Questions for User:**
1. Should we keep the current table structure and add a GSI, or restructure the table entirely?
2. What should be the GSI name? (suggestion: `UserSessionsIndex`)
3. Should we include all attributes in the GSI projection or just specific ones for cost optimization?

** Answer:
1. We should keep the current table structure and add a GSI.
2. The GSI name should be `UserSessionsIndex`.
3. Use `created_at` as the sort key in the GSI for better chronological session listing.
4. project only the session id and user id and session name for the GSI, in the ui, implement lazy loading of sessions, displaying the session name, but only load the session data when the user clicks on the session.

### Phase 2: Update Backend Session Management
**Current State**: Basic CRUD operations exist but need refinement for UI integration.

**Tasks:**
- Update session creation to include title generation from first message
- Ensure proper session metadata (created_at, updated_at, last_message_preview)
- Add session update endpoint for title changes
- Optimize session listing to return UI-friendly format

**Questions for User:**
1. How should session titles be generated? From first user message, AI response, or manual naming?
2. Should we limit the number of sessions returned (pagination) or load all user sessions?
3. Do you want session folders/categories or just a flat list?

** Answer:
1. We should generate the session title by invoking the LLM with the first user message, requesting a short title for the session.
2. We should not limit the number of sessions returned, because we will implement lazy loading of sessions, displaying the session name, but only load the session data when the user clicks on the session.
3. flat list.

### Phase 3: Create Session Sidebar Component
**Location**: `frontend/src/features/chat/components/SessionSidebar.tsx`

**Features:**
- List all user sessions with titles and timestamps
- Current session highlighting
- Session selection/switching
- New session creation button
- Session deletion (with confirmation)
- Search/filter sessions

**Questions for User:**
1. Should the sidebar be collapsible/expandable?
2. Do you want session grouping by date (Today, Yesterday, Last Week, etc.) like ChatGPT?
3. Should sessions show preview of last message or just title?
4. Do you want drag-and-drop reordering of sessions?

** Answer:
1. collapsible/expandable.
2. no, we will implement lazy loading of sessions, displaying the session name, but only load the session data when the user clicks on the session.
3. title only.
4. no, we will implement lazy loading of sessions, displaying the session name, but only load the session data when the user clicks on the session.

### Phase 4: Update Layout Integration
**Current Layout**: `MainLayout.tsx` has a sidebar with navigation menu.

**Integration Options:**
1. **Replace current sidebar** with session sidebar (move nav to header/footer)
2. **Split sidebar** into navigation section and session section
3. **Add second sidebar** specifically for sessions (dual sidebar layout)

**Questions for User:**
1. Which layout approach do you prefer?
2. Should the session sidebar be on the left or right side?
3. How should the current navigation menu be handled?

** Answer:
1. I prefer the split sidebar layout.
2. we are supporting RTL, so the bar should shift to the right, when selecting a rtl languege
3. The current navigation menu should be handled by the user.

### Phase 5: Frontend-Backend Session Coordination
**Current Issue**: Frontend creates local sessions, backend creates separate sessions.

**Solution**: 
- When user starts new chat, immediately create backend session
- Store backend session ID in frontend session object
- Sync session state between frontend and backend
- Handle session restoration on page reload

**Questions for User:**
1. Should session creation be lazy (on first message) or eager (on "New Chat" click)?
2. How should we handle offline session creation if backend is unavailable?
3. Should we sync session titles between frontend and backend?

** Answer:  
1. lazy, on first message.
2. No, if the backend is unavailable, the user should not be able to create a new session.
3. yes, we should sync session titles between frontend and backend.

## Current DynamoDB Table Schema Analysis

**Existing Table Structure:**
```
Session Table:
- Partition Key: session_id (STRING)
- Sort Key: user_id (STRING)
- Attributes: created_at, expires_at, session_data, last_updated
```

**Problem**: The current `list_user_sessions` method tries to query by `user_id` which is the sort key, not the partition key. This is inefficient and may not work as expected.

**GSI Recommendation:**
```
UserSessionsIndex (GSI):
- Partition Key: user_id (STRING)
- Sort Key: created_at (NUMBER) or session_id (STRING)
- Projection: ALL or INCLUDE specific attributes
```

**Questions for User:**
1. Should the GSI sort key be `created_at` (for chronological listing) or `session_id` (for unique identification)?
2. What attributes should be projected into the GSI? (ALL vs INCLUDE for cost optimization)
3. Should we add TTL to the GSI as well or rely on the base table TTL?

** Answer:
1. created_at.
2. session_id, user_id, session_name.
3. we should relay on base table TTL.

## Frontend State Management Updates

**Current ChatStore**: Already has sessions array and currentSession, but needs backend integration.

**Required Updates:**
- Add `loadUserSessions()` action to fetch from backend
- Add `createBackendSession()` action for backend coordination  
- Update `selectSession()` to handle backend session loading
- Add session metadata (title, preview, timestamps)
- Implement session persistence across page reloads

**Questions for User:**
1. Should sessions be loaded immediately on app start or when sidebar is first opened?
2. How should we handle session loading errors (network issues, auth failures)?
3. Should we cache sessions locally or always fetch fresh from backend?

** Answer:
1. immediately on app start.
2. we should handle session loading errors by showing a message to the user.
3. we should cache sessions locally, but always fetch fresh from backend.

## UI/UX Considerations

**Session Display Format:**
- Session title (truncated if long)
- Last message timestamp
- Optional message preview
- Active session indicator
- Loading/error states

**User Actions:**
- Click to switch sessions
- Long press / right-click for context menu (rename, delete)
- Drag to reorder (optional)
- Search/filter sessions

**Questions for User:**
1. What's the maximum session title length before truncation?
2. Should deleted sessions go to trash or be permanently deleted?
3. Do you want session export/import functionality?
4. Should there be session sharing capabilities?

** Answer:
1. 50 characters.
2. permanently deleted.
3. no.
4. no.

## Implementation File References
- `infra/stacks/storage/session_stack.py` - Add GSI to DynamoDB table
- `lambdas/bedrock_chat/src/common/session_manager.py` - Update query methods for GSI
- `lambdas/bedrock_chat/src/handlers/sessions_handler.py` - Enhance API responses
- `frontend/src/features/chat/components/SessionSidebar.tsx` - New component
- `frontend/src/features/chat/stores/chatStore.ts` - Add backend integration
- `frontend/src/shared/components/Layout/MainLayout.tsx` - Layout updates
- `frontend/src/services/api/chatApi.ts` - Session API methods

## Testing Strategy
- Unit tests for session CRUD operations
- Integration tests for frontend-backend session sync
- E2E tests for session switching and persistence
- Performance tests for session loading with many sessions

## Lessons Learned
- Current DynamoDB table structure needs GSI for efficient user queries
- Frontend already has good session state foundation
- Need to carefully coordinate frontend and backend session IDs
- Layout integration requires UX decisions about sidebar usage

## Task Management

### Implementation Tasks

#### Phase 1: Backend Infrastructure ✅
- [x] **T014-001**: Add GSI to DynamoDB session table
  - [x] Update `infra/stacks/storage/session_stack.py` with UserSessionsIndex
  - [x] Configure GSI with user_id as partition key and created_at as sort key
  - [x] Set projection to include only session_id, user_id, session_name

- [x] **T014-002**: Update backend session manager
  - [x] Modify `list_user_sessions` to use GSI for efficient queries
  - [x] Add session_name field to session creation and updates
  - [x] Implement LLM-based session title generation using Bedrock

- [x] **T014-003**: Update session handlers
  - [x] Ensure all CRUD operations work with new session structure
  - [x] Add proper error handling and authentication
  - [x] Register handlers in factory

#### Phase 2: Frontend Components ✅
- [x] **T014-004**: Create SessionSidebar component
  - [x] Implement session listing with search and filtering
  - [x] Add session selection, creation, deletion, and renaming
  - [x] Include collapsible design and RTL support

- [x] **T014-005**: Update MainLayout integration
  - [x] Implement split sidebar layout
  - [x] Add RTL-aware positioning
  - [x] Show session sidebar only on chat page

- [x] **T014-006**: Update chat store
  - [x] Add backend session integration methods
  - [x] Implement lazy session creation on first message
  - [x] Add session CRUD operations

#### Phase 3: Integration and Coordination ⚠️
- [x] **T014-007**: Update frontend to coordinate with backend session IDs and lazy session creation
  - [x] Ensure proper session ID mapping between frontend and backend
  - [x] Implement session title sync after LLM generation
  - [x] Handle session restoration on page reload

- [x] **T014-008**: Add session caching with fresh backend fetches
  - [x] Implement local session caching
  - [x] Add background refresh mechanism
  - [x] Handle cache invalidation on updates

#### Phase 4: Testing and Validation ⚠️
- [ ] **T014-009**: Test session persistence, switching, and RTL functionality
  - [ ] Verify session data persists across page reloads
  - [ ] Test session switching maintains message history
  - [ ] Validate RTL layout behavior
  - [ ] Test error handling and edge cases

### Current Status
- **Completed**: 8/10 tasks (80%)
- **In Progress**: 0 tasks
- **Pending**: 2 tasks (20%)

### Next Actions
1. **T014-010**: Fix double sidebar layout by integrating sessions into main navigation
2. **T014-011**: Implement real-time session title synchronization
3. **T014-012**: Fix thinking bubble component rendering and behavior
4. **T014-013**: Remove duplicate new chat button
5. **T014-009**: Complete testing and validation

### Notes
- All major components are implemented and integrated
- Session ID coordination between frontend and backend is working
- Caching mechanism is implemented with proper invalidation
- Sidebar scrolling and footer positioning issue has been resolved ✅
- New UI issues discovered during testing require immediate attention
- Ready to begin Phase 5-8 fixes for remaining UI issues

## New UI Issues Discovered During Testing

### Issue 1: Double Sidebar Problem ⚠️
**Problem**: The sessions sidebar is appearing as a separate sidebar on top of the existing navigation sidebar, instead of being integrated into the main navigation sidebar under the Chat tab.

**Expected Behavior**: Sessions should be displayed within the existing navigation sidebar under the Chat tab, not as a separate sidebar.

**Root Cause**: The current implementation creates a separate `SessionSidebar` component instead of integrating session management into the existing `MainLayout` sidebar structure.

**Impact**: Poor UX with confusing double sidebar layout, not following the intended split sidebar design.

### Issue 2: Chat Name Not Updating ⚠️
**Problem**: Session titles/names are not being updated in the UI after they are generated by the backend.

**Expected Behavior**: When a session title is generated by the LLM backend, it should immediately appear in the UI sidebar.

**Root Cause**: Missing frontend-backend synchronization for session title updates after LLM generation.

**Impact**: Users cannot see meaningful session names, making it difficult to navigate between conversations.

### Issue 3: Thinking Bubble Display Issues ⚠️
**Problem**: Multiple issues with the thinking bubble component:
1. Raw HTML tags (`<thinking>`) are visible instead of proper rendering
2. Thinking bubble disappears completely after final message arrives instead of collapsing into an expandable button
3. Missing proper expand/collapse functionality for viewing the thinking process

**Expected Behavior**: 
- Thinking bubbles should render properly without showing HTML tags
- After thinking is complete, bubble should collapse into a "Show Thinking" button
- Button should expand to show the full thinking process when clicked

**Root Cause**: 
- Incorrect HTML rendering in the `ThoughtProcess` component
- Missing collapse/expand state management
- Improper cleanup of thinking bubbles after completion

**Impact**: Poor user experience with broken thinking visualization and lost thinking process information.

### Issue 4: Sidebar Scrolling and Footer Positioning ✅ RESOLVED
**Problem**: The sidebar sessions list was taking up too much space (982px) and pushing the footer beyond the visible screen area, with no scrolling available for the sessions list.

**Expected Behavior**: 
- Sessions list should be scrollable when it exceeds available space
- Footer should stay fixed at the bottom of the sidebar
- Layout should not overflow beyond the screen boundaries

**Root Cause**: 
- Missing proper flexbox layout structure for the sidebar
- No height constraints on the sessions container
- Missing overflow handling for the sessions list
- Footer positioning not properly constrained

**Impact**: Footer was completely hidden below the screen, making logout functionality inaccessible.

**Solution Implemented**:
1. **Fixed Layout Structure**: Implemented proper flexbox layout with `flex: 1` and `min-height: 0` for the sessions container
2. **Added Scrolling**: Created scrollable container with `overflow-y: auto` and proper height constraints
3. **Footer Positioning**: Used `position: sticky` and `bottom: 0` to keep footer at bottom
4. **CSS Overrides**: Added `!important` rules to override Ant Design's default sidebar behavior

**Implementation Details**:
- Modified `frontend/src/shared/components/Layout/MainLayout.tsx` to use proper flexbox structure
- Added custom CSS classes in `frontend/src/styles/index.css` for sidebar layout and scrolling
- Used `sessions-scroll-container` and `sessions-scroll-content` classes for proper scrolling behavior
- Implemented `sidebar-footer` class for fixed footer positioning

**Result**: 
- Footer is now visible and properly positioned at bottom of sidebar
- Sessions list is scrollable with custom scrollbar styling
- Layout no longer overflows beyond screen boundaries
- Proper flexbox structure ensures responsive behavior

## UI Fixes Implementation Plan

### Phase 5: Fix Double Sidebar Layout
**Task T014-010**: Integrate sessions into main navigation sidebar
- [ ] **T014-010a**: Modify `MainLayout.tsx` to include session management under Chat tab
- [ ] **T014-010b**: Remove separate `SessionSidebar` component from chat page
- [ ] **T014-010c**: Update layout to show sessions within existing sidebar structure
- [ ] **T014-010d**: Ensure RTL support for integrated sidebar layout

**Files to Modify**:
- `frontend/src/shared/components/Layout/MainLayout.tsx` - Integrate sessions into main sidebar
- `frontend/src/features/chat/components/ChatPage.tsx` - Remove separate session sidebar
- `frontend/src/features/chat/components/SessionSidebar.tsx` - Refactor for integration or remove

### Phase 6: Fix Session Title Synchronization
**Task T014-011**: Implement real-time session title updates
- [ ] **T014-011a**: Add WebSocket or polling mechanism for session title updates
- [ ] **T014-011b**: Update chat store to handle real-time title changes
- [ ] **T014-011c**: Ensure UI reflects title changes immediately after LLM generation
- [ ] **T014-011d**: Add loading states during title generation

**Files to Modify**:
- `frontend/src/features/chat/stores/chatStore.ts` - Add real-time title sync
- `frontend/src/services/api/chatApi.ts` - Add title update polling
- `frontend/src/features/chat/components/SessionSidebar.tsx` - Handle real-time updates

### Phase 7: Fix Thinking Bubble Component
**Task T014-012**: Repair thinking bubble rendering and behavior
- [ ] **T014-012a**: Fix HTML tag rendering in `ThoughtProcess` component
- [ ] **T014-012b**: Implement proper collapse/expand state management
- [ ] **T014-012c**: Add "Show Thinking" button after thinking completion
- [ ] **T014-012d**: Ensure thinking process persists and is expandable
- [ ] **T014-012e**: Remove thinking bubble cleanup that causes disappearance

**Files to Modify**:
- `frontend/src/features/chat/components/ThoughtProcess.tsx` - Fix rendering and state management
- `frontend/src/features/chat/components/ChatContainer.tsx` - Update thinking bubble handling
- `frontend/src/features/chat/stores/chatStore.ts` - Preserve thinking state

### Phase 8: Remove Duplicate New Chat Button
**Task T014-013**: Consolidate new chat functionality
- [ ] **T014-013a**: Remove new chat button from main chat window
- [ ] **T014-013b**: Ensure new chat button is only in the integrated sidebar
- [ ] **T014-013c**: Update new chat flow to work with integrated layout

**Files to Modify**:
- `frontend/src/features/chat/components/ChatContainer.tsx` - Remove duplicate new chat button
- `frontend/src/features/chat/components/ChatInput.tsx` - Update new chat handling if needed

## Updated Implementation File References
- `frontend/src/shared/components/Layout/MainLayout.tsx` - Integrate sessions into main sidebar
- `frontend/src/features/chat/components/ChatPage.tsx` - Remove separate session sidebar
- `frontend/src/features/chat/components/SessionSidebar.tsx` - Refactor for integration
- `frontend/src/features/chat/components/ThoughtProcess.tsx` - Fix thinking bubble issues
- `frontend/src/features/chat/components/ChatContainer.tsx` - Remove duplicate new chat button
- `frontend/src/features/chat/stores/chatStore.ts` - Add real-time title sync
- `frontend/src/services/api/chatApi.ts` - Add title update polling
- `frontend/src/styles/index.css` - Sidebar layout and scrolling styles

## Updated Task Management

### Implementation Tasks

#### Phase 1: Backend Infrastructure ✅
- [x] **T014-001**: Add GSI to DynamoDB session table
- [x] **T014-002**: Update backend session manager
- [x] **T014-003**: Update session handlers

#### Phase 2: Frontend Components ✅
- [x] **T014-004**: Create SessionSidebar component
- [x] **T014-005**: Update MainLayout integration
- [x] **T014-006**: Update chat store

#### Phase 3: Integration and Coordination ✅
- [x] **T014-007**: Update frontend to coordinate with backend session IDs and lazy session creation
- [x] **T014-008**: Add session caching with fresh backend fetches

#### Phase 4: Testing and Validation ⚠️
- [ ] **T014-009**: Test session persistence, switching, and RTL functionality

#### Phase 5: Fix Double Sidebar Layout ⚠️
- [ ] **T014-010**: Integrate sessions into main navigation sidebar

#### Phase 6: Fix Session Title Synchronization ⚠️
- [ ] **T014-011**: Implement real-time session title updates

#### Phase 7: Fix Thinking Bubble Component ⚠️
- [ ] **T014-012**: Repair thinking bubble rendering and behavior

#### Phase 8: Remove Duplicate New Chat Button ⚠️
- [ ] **T014-013**: Consolidate new chat functionality

#### Phase 9: Fix Sidebar Scrolling and Layout ✅ COMPLETED
- [x] **T014-014**: Fix sidebar scrolling and footer positioning
  - [x] Implement proper flexbox layout structure for sidebar
  - [x] Add scrolling to sessions list with height constraints
  - [x] Fix footer positioning to stay at bottom of sidebar
  - [x] Add custom CSS for proper sidebar behavior
  - [x] Override Ant Design default sidebar styles

### Current Status
- **Completed**: 8/10 tasks (80%)
- **In Progress**: 0 tasks
- **Pending**: 2 tasks (20%)

### Next Actions
1. **T014-010**: Fix double sidebar layout by integrating sessions into main navigation
2. **T014-011**: Implement real-time session title synchronization
3. **T014-012**: Fix thinking bubble component rendering and behavior
4. **T014-013**: Remove duplicate new chat button
5. **T014-009**: Complete testing and validation

### Notes
- All major components are implemented and integrated
- Session ID coordination between frontend and backend is working
- Caching mechanism is implemented with proper invalidation
- Sidebar scrolling and footer positioning issue has been resolved ✅
- New UI issues discovered during testing require immediate attention
- Ready to begin Phase 5-8 fixes for remaining UI issues
