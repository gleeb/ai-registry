# State Management Documentation

## Overview

The application uses Zustand for lightweight state management, providing a simple and performant alternative to Redux. State is organized into feature-specific stores with TypeScript support for type safety.

## Zustand Architecture

### Why Zustand?
- **Minimal Boilerplate**: No actions, reducers, or providers needed
- **TypeScript First**: Excellent TypeScript integration
- **Performance**: Automatic optimization and selective re-renders
- **DevTools Support**: Redux DevTools compatibility
- **Small Bundle Size**: ~8KB minified

## Store Organization

### Store Structure
```
src/
├── features/
│   ├── auth/
│   │   └── stores/
│   │       └── authStore.ts
│   ├── chat/
│   │   └── stores/
│   │       └── chatStore.ts
│   └── documents/
│       └── stores/
│           └── documentStore.ts
└── shared/
    └── stores/
        ├── appStore.ts      # Global app state
        └── uiStore.ts        # UI state (modals, sidebars)
```

## Core Stores

### Auth Store (`src/features/auth/stores/authStore.ts`)
```typescript
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'
import { immer } from 'zustand/middleware/immer'

interface User {
  id: string
  email: string
  name: string
  role: 'user' | 'admin'
  preferences: {
    language: string
    theme: 'light' | 'dark'
  }
}

interface AuthState {
  // State
  user: User | null
  isAuthenticated: boolean
  isLoading: boolean
  error: string | null
  
  // Actions
  setUser: (user: User) => void
  updateUser: (updates: Partial<User>) => void
  clearUser: () => void
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  
  // Async actions
  login: (email: string, password: string) => Promise<void>
  logout: () => Promise<void>
  refreshToken: () => Promise<void>
}

export const useAuthStore = create<AuthState>()(
  devtools(
    persist(
      immer((set, get) => ({
        // Initial state
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
        
        // Synchronous actions
        setUser: (user) => set((state) => {
          state.user = user
          state.isAuthenticated = true
          state.error = null
        }),
        
        updateUser: (updates) => set((state) => {
          if (state.user) {
            Object.assign(state.user, updates)
          }
        }),
        
        clearUser: () => set((state) => {
          state.user = null
          state.isAuthenticated = false
        }),
        
        setLoading: (loading) => set((state) => {
          state.isLoading = loading
        }),
        
        setError: (error) => set((state) => {
          state.error = error
        }),
        
        // Async actions
        login: async (email, password) => {
          set((state) => {
            state.isLoading = true
            state.error = null
          })
          
          try {
            const response = await authApi.login(email, password)
            const user = await authApi.getCurrentUser(response.token)
            
            set((state) => {
              state.user = user
              state.isAuthenticated = true
              state.isLoading = false
            })
          } catch (error) {
            set((state) => {
              state.error = error.message
              state.isLoading = false
            })
            throw error
          }
        },
        
        logout: async () => {
          set((state) => {
            state.isLoading = true
          })
          
          try {
            await authApi.logout()
            set((state) => {
              state.user = null
              state.isAuthenticated = false
              state.isLoading = false
            })
          } catch (error) {
            set((state) => {
              state.error = error.message
              state.isLoading = false
            })
          }
        },
        
        refreshToken: async () => {
          try {
            const token = await authApi.refreshToken()
            // Token is automatically stored by API interceptor
          } catch (error) {
            // If refresh fails, logout user
            get().clearUser()
            throw error
          }
        }
      })),
      {
        name: 'auth-storage',
        partialize: (state) => ({ 
          user: state.user,
          isAuthenticated: state.isAuthenticated 
        })
      }
    ),
    {
      name: 'AuthStore'
    }
  )
)
```

### Chat Store (`src/features/chat/stores/chatStore.ts`)
```typescript
interface Message {
  id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  timestamp: Date
  model?: string
  thoughtProcess?: string
}

interface ChatState {
  // State
  messages: Message[]
  conversations: Conversation[]
  activeConversationId: string | null
  isLoading: boolean
  streamingMessage: Message | null
  selectedModel: string
  
  // Actions
  addMessage: (message: Message) => void
  updateMessage: (id: string, updates: Partial<Message>) => void
  deleteMessage: (id: string) => void
  clearMessages: () => void
  setStreamingMessage: (message: Message | null) => void
  setSelectedModel: (model: string) => void
  
  // Conversation actions
  createConversation: (title?: string) => string
  loadConversation: (id: string) => void
  deleteConversation: (id: string) => void
  
  // Computed values
  getCurrentConversation: () => Conversation | null
  getMessageCount: () => number
}

export const useChatStore = create<ChatState>((set, get) => ({
  // State
  messages: [],
  conversations: [],
  activeConversationId: null,
  isLoading: false,
  streamingMessage: null,
  selectedModel: 'claude-3-sonnet',
  
  // Message actions
  addMessage: (message) => set((state) => ({
    messages: [...state.messages, message]
  })),
  
  updateMessage: (id, updates) => set((state) => ({
    messages: state.messages.map(msg => 
      msg.id === id ? { ...msg, ...updates } : msg
    )
  })),
  
  deleteMessage: (id) => set((state) => ({
    messages: state.messages.filter(msg => msg.id !== id)
  })),
  
  clearMessages: () => set({ messages: [] }),
  
  setStreamingMessage: (message) => set({ streamingMessage: message }),
  
  setSelectedModel: (model) => set({ selectedModel: model }),
  
  // Conversation actions
  createConversation: (title) => {
    const id = uuidv4()
    const conversation = {
      id,
      title: title || `Conversation ${get().conversations.length + 1}`,
      createdAt: new Date(),
      messages: []
    }
    
    set((state) => ({
      conversations: [...state.conversations, conversation],
      activeConversationId: id,
      messages: []
    }))
    
    return id
  },
  
  loadConversation: (id) => {
    const conversation = get().conversations.find(c => c.id === id)
    if (conversation) {
      set({
        activeConversationId: id,
        messages: conversation.messages
      })
    }
  },
  
  deleteConversation: (id) => set((state) => ({
    conversations: state.conversations.filter(c => c.id !== id),
    activeConversationId: state.activeConversationId === id 
      ? null 
      : state.activeConversationId
  })),
  
  // Computed values
  getCurrentConversation: () => {
    const state = get()
    return state.conversations.find(c => c.id === state.activeConversationId) || null
  },
  
  getMessageCount: () => get().messages.length
}))
```

### UI Store (`src/shared/stores/uiStore.ts`)
```typescript
interface UIState {
  // Sidebar
  sidebarOpen: boolean
  sidebarWidth: number
  
  // Modals
  modals: {
    [key: string]: boolean
  }
  
  // Notifications
  notifications: Notification[]
  
  // Theme
  theme: 'light' | 'dark' | 'auto'
  
  // Loading states
  globalLoading: boolean
  loadingMessage: string | null
  
  // Actions
  toggleSidebar: () => void
  setSidebarWidth: (width: number) => void
  openModal: (modalId: string) => void
  closeModal: (modalId: string) => void
  addNotification: (notification: Notification) => void
  removeNotification: (id: string) => void
  setTheme: (theme: 'light' | 'dark' | 'auto') => void
  setGlobalLoading: (loading: boolean, message?: string) => void
}

export const useUIStore = create<UIState>()(
  persist(
    (set) => ({
      // Initial state
      sidebarOpen: true,
      sidebarWidth: 280,
      modals: {},
      notifications: [],
      theme: 'auto',
      globalLoading: false,
      loadingMessage: null,
      
      // Actions
      toggleSidebar: () => set((state) => ({
        sidebarOpen: !state.sidebarOpen
      })),
      
      setSidebarWidth: (width) => set({ sidebarWidth: width }),
      
      openModal: (modalId) => set((state) => ({
        modals: { ...state.modals, [modalId]: true }
      })),
      
      closeModal: (modalId) => set((state) => ({
        modals: { ...state.modals, [modalId]: false }
      })),
      
      addNotification: (notification) => set((state) => ({
        notifications: [...state.notifications, {
          ...notification,
          id: notification.id || uuidv4()
        }]
      })),
      
      removeNotification: (id) => set((state) => ({
        notifications: state.notifications.filter(n => n.id !== id)
      })),
      
      setTheme: (theme) => set({ theme }),
      
      setGlobalLoading: (loading, message) => set({
        globalLoading: loading,
        loadingMessage: message || null
      })
    }),
    {
      name: 'ui-storage',
      partialize: (state) => ({
        sidebarOpen: state.sidebarOpen,
        sidebarWidth: state.sidebarWidth,
        theme: state.theme
      })
    }
  )
)
```

## Advanced Patterns

### Slices Pattern
```typescript
// Create slices for complex stores
const createAuthSlice = (set, get) => ({
  user: null,
  login: async (credentials) => {
    // Implementation
  }
})

const createProfileSlice = (set, get) => ({
  profile: null,
  updateProfile: (updates) => {
    // Implementation
  }
})

// Combine slices
const useStore = create((set, get) => ({
  ...createAuthSlice(set, get),
  ...createProfileSlice(set, get)
}))
```

### Computed Values and Selectors
```typescript
// Computed values in store
const useDocumentStore = create((set, get) => ({
  documents: [],
  filter: 'all',
  
  // Computed getter
  get filteredDocuments() {
    const { documents, filter } = get()
    if (filter === 'all') return documents
    return documents.filter(doc => doc.status === filter)
  },
  
  // Selector function
  getDocumentById: (id: string) => {
    return get().documents.find(doc => doc.id === id)
  }
}))

// Using selectors in components
const MyComponent = () => {
  // Subscribe to specific slice
  const documents = useDocumentStore(state => state.filteredDocuments)
  
  // Use shallow comparison for arrays/objects
  const documentIds = useDocumentStore(
    state => state.documents.map(d => d.id),
    shallow
  )
  
  return <div>{/* Component JSX */}</div>
}
```

### Middleware

#### Redux DevTools
```typescript
import { devtools } from 'zustand/middleware'

const useStore = create(
  devtools(
    (set) => ({
      // Store implementation
    }),
    {
      name: 'MyStore',
      enabled: process.env.NODE_ENV === 'development'
    }
  )
)
```

#### Persist Middleware
```typescript
import { persist } from 'zustand/middleware'

const useStore = create(
  persist(
    (set) => ({
      // Store implementation
    }),
    {
      name: 'app-storage',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        // Only persist specific fields
        user: state.user,
        preferences: state.preferences
      }),
      version: 1,
      migrate: (persistedState, version) => {
        // Handle migrations between versions
        if (version === 0) {
          // Migration logic
        }
        return persistedState
      }
    }
  )
)
```

#### Immer for Immutability
```typescript
import { immer } from 'zustand/middleware/immer'

const useStore = create(
  immer((set) => ({
    nested: {
      deep: {
        value: 0
      }
    },
    
    // Direct mutation with Immer
    updateDeepValue: (value) => set((state) => {
      state.nested.deep.value = value
    })
  }))
)
```

### Async Actions
```typescript
const useDataStore = create((set, get) => ({
  data: null,
  isLoading: false,
  error: null,
  
  fetchData: async (id: string) => {
    set({ isLoading: true, error: null })
    
    try {
      const response = await api.getData(id)
      set({ data: response, isLoading: false })
    } catch (error) {
      set({ error: error.message, isLoading: false })
    }
  },
  
  // With abort controller
  fetchWithAbort: () => {
    const controller = new AbortController()
    
    const fetch = async () => {
      set({ isLoading: true })
      try {
        const response = await api.getData({
          signal: controller.signal
        })
        set({ data: response, isLoading: false })
      } catch (error) {
        if (error.name !== 'AbortError') {
          set({ error: error.message, isLoading: false })
        }
      }
    }
    
    fetch()
    
    return () => controller.abort()
  }
}))
```

### Subscriptions
```typescript
// Subscribe to store changes
const unsubscribe = useStore.subscribe(
  (state) => state.user,
  (user) => {
    console.log('User changed:', user)
  }
)

// Subscribe to entire store
const unsubscribeAll = useStore.subscribe((state) => {
  console.log('State changed:', state)
})

// Clean up
unsubscribe()
unsubscribeAll()

// Subscribe with selector
const unsubscribeMessages = useChatStore.subscribe(
  (state) => state.messages.length,
  (length) => {
    console.log(`Message count: ${length}`)
  }
)
```

## Integration with React

### Custom Hooks
```typescript
// Custom hook for auth
export const useAuth = () => {
  const { user, isAuthenticated, login, logout } = useAuthStore()
  
  const isAdmin = user?.role === 'admin'
  const hasPermission = (permission: string) => {
    return user?.permissions?.includes(permission) || false
  }
  
  return {
    user,
    isAuthenticated,
    isAdmin,
    hasPermission,
    login,
    logout
  }
}

// Custom hook with computed values
export const useDocuments = () => {
  const documents = useDocumentStore(state => state.documents)
  const filter = useDocumentStore(state => state.filter)
  
  const stats = useMemo(() => ({
    total: documents.length,
    processed: documents.filter(d => d.status === 'processed').length,
    pending: documents.filter(d => d.status === 'pending').length
  }), [documents])
  
  return { documents, filter, stats }
}
```

### Context Bridge
```typescript
// Bridge Zustand with React Context for SSR
const StoreContext = createContext()

export const StoreProvider = ({ children, initialState }) => {
  const storeRef = useRef()
  
  if (!storeRef.current) {
    storeRef.current = createStore(initialState)
  }
  
  return (
    <StoreContext.Provider value={storeRef.current}>
      {children}
    </StoreContext.Provider>
  )
}

export const useStore = (selector) => {
  const store = useContext(StoreContext)
  return useZustandStore(store, selector)
}
```

## Testing

### Store Testing
```typescript
import { renderHook, act } from '@testing-library/react-hooks'
import { useAuthStore } from './authStore'

describe('AuthStore', () => {
  beforeEach(() => {
    useAuthStore.setState({ 
      user: null, 
      isAuthenticated: false 
    })
  })
  
  it('should login user', async () => {
    const { result } = renderHook(() => useAuthStore())
    
    await act(async () => {
      await result.current.login('test@example.com', 'password')
    })
    
    expect(result.current.isAuthenticated).toBe(true)
    expect(result.current.user).toBeDefined()
  })
  
  it('should handle login error', async () => {
    const { result } = renderHook(() => useAuthStore())
    
    await act(async () => {
      try {
        await result.current.login('invalid', 'invalid')
      } catch (error) {
        // Expected error
      }
    })
    
    expect(result.current.error).toBeDefined()
    expect(result.current.isAuthenticated).toBe(false)
  })
})
```

### Mocking Stores
```typescript
// Mock store for testing
const mockStore = {
  user: { id: '1', name: 'Test User' },
  isAuthenticated: true,
  login: jest.fn(),
  logout: jest.fn()
}

jest.mock('./authStore', () => ({
  useAuthStore: () => mockStore
}))
```

## Performance Optimization

### Selective Subscriptions
```typescript
// Subscribe only to specific state slices
const user = useAuthStore(state => state.user)
const isLoading = useAuthStore(state => state.isLoading)

// Use shallow comparison for arrays/objects
import { shallow } from 'zustand/shallow'

const { documents, filter } = useDocumentStore(
  state => ({ 
    documents: state.documents, 
    filter: state.filter 
  }),
  shallow
)
```

### Memoization
```typescript
const useOptimizedStore = create((set, get) => ({
  items: [],
  
  // Memoized selector
  getExpensiveComputation: () => {
    const state = get()
    
    if (!state._memoized || state._memoizedItems !== state.items) {
      state._memoized = expensiveComputation(state.items)
      state._memoizedItems = state.items
    }
    
    return state._memoized
  }
}))
```

## Best Practices

### Do's
1. Keep stores focused and feature-specific
2. Use TypeScript for type safety
3. Implement proper error handling
4. Use middleware for cross-cutting concerns
5. Memoize expensive computations
6. Clean up subscriptions

### Don'ts
1. Don't mutate state directly (without Immer)
2. Don't create huge monolithic stores
3. Don't subscribe to entire store unnecessarily
4. Don't forget to handle async errors
5. Don't store derived state
6. Don't ignore TypeScript warnings