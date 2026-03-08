# Frontend Project Structure

## Directory Overview

```
frontend/
├── public/                    # Static assets served directly
│   ├── vite.svg              # Vite logo
│   └── react.svg             # React logo
├── src/                      # Source code root
│   ├── app/                  # Application core
│   ├── features/             # Feature modules
│   ├── shared/               # Shared resources
│   ├── services/             # External service integrations
│   ├── locales/              # Internationalization
│   ├── styles/               # Global styles
│   ├── assets/               # Images, fonts, etc.
│   ├── main.tsx              # Application entry point
│   └── vite-env.d.ts         # Vite type definitions
├── tests/                    # Test files
│   ├── unit/                 # Unit tests
│   ├── integration/          # Integration tests
│   └── e2e/                  # End-to-end tests
├── .env.example              # Environment variables template
├── index.html                # HTML entry point
├── package.json              # Dependencies and scripts
├── tsconfig.json             # TypeScript configuration
├── vite.config.ts            # Vite configuration
└── tailwind.config.js        # Tailwind CSS configuration
```

## Core Directories

### `/src/app/`
The application's core functionality and configuration.

```
app/
├── App.tsx                   # Root component with providers
├── providers/                # Context providers
│   ├── AuthProvider.tsx      # Authentication context
│   ├── ThemeProvider.tsx     # Theme and UI configuration
│   └── index.ts              # Provider exports
└── router/                   # Routing configuration
    ├── index.tsx             # Route definitions
    └── guards/               # Route protection
        ├── ProtectedRoute.tsx # Auth-required routes
        └── index.ts          # Guard exports
```

**Purpose**: Contains application-wide configuration, providers, and routing logic that affects the entire application.

### `/src/features/`
Feature-based modules containing related functionality.

```
features/
├── auth/                     # Authentication feature
│   ├── components/           # Auth UI components
│   │   ├── LoginPage.tsx     # Login interface
│   │   ├── SignupPage.tsx    # Registration interface
│   │   ├── CallbackPage.tsx  # OAuth callback handler
│   │   └── index.ts          # Component exports
│   ├── hooks/                # Auth-specific hooks
│   ├── services/             # Auth API services
│   ├── stores/               # Auth state management
│   └── types/                # Auth TypeScript types
├── chat/                     # Chat feature
│   ├── components/
│   │   ├── ChatPage.tsx      # Main chat interface
│   │   ├── ChatContainer.tsx # Chat message container
│   │   ├── ChatInput.tsx     # Message input component
│   │   ├── MessageBubble.tsx # Individual message display
│   │   ├── ModelSelector.tsx # AI model selection
│   │   ├── ThoughtProcess.tsx # AI thinking display
│   │   ├── TypingIndicator.tsx # Loading indicator
│   │   ├── ConnectionStatus.tsx # WebSocket status
│   │   ├── ErrorMessage.tsx  # Error display
│   │   └── SystemMessage.tsx # System notifications
│   ├── hooks/                # Chat-specific hooks
│   ├── services/             # Chat API services
│   ├── stores/               # Chat state (Zustand)
│   │   └── chatStore.ts      # Message and chat state
│   └── types/                # Chat TypeScript types
├── documents/                # Document management
│   ├── components/
│   │   ├── DocumentsPage.tsx # Document list/grid
│   │   └── index.ts
│   ├── hooks/                # Document hooks
│   ├── services/             # Document API
│   └── types/                # Document types
└── admin/                    # Admin features
    ├── components/
    │   ├── AdminPage.tsx     # Admin dashboard
    │   └── index.ts
    ├── hooks/
    └── types/
```

**Purpose**: Each feature is self-contained with its own components, hooks, services, and types, promoting modularity and maintainability.

### `/src/shared/`
Reusable resources shared across features.

```
shared/
├── components/               # Shared UI components
│   ├── ui/                   # Base UI components
│   │   ├── Button/           # Custom button component
│   │   ├── Input/            # Custom input component
│   │   └── Modal/            # Custom modal component
│   ├── Layout/               # Layout components
│   │   ├── MainLayout.tsx    # Main app layout
│   │   └── index.ts
│   ├── Navigation/           # Navigation components
│   └── LanguageSwitcher.tsx  # Language toggle
├── constants/                # Application constants
│   ├── routes.ts             # Route paths
│   └── config.ts             # App configuration
├── hooks/                    # Shared custom hooks
│   ├── useAuth.ts            # Authentication hook
│   ├── useApi.ts             # API request hook
│   └── useDebounce.ts        # Debounce hook
├── types/                    # Shared TypeScript types
│   ├── auth.ts               # Authentication types
│   ├── chat.ts               # Chat message types
│   └── api.ts                # API response types
└── utils/                    # Utility functions
    ├── pkce.ts               # PKCE helpers
    ├── format.ts             # Formatting utilities
    └── validation.ts         # Input validation
```

**Purpose**: Contains components, utilities, and resources that are used across multiple features.

### `/src/services/`
External service integrations and API clients.

```
services/
├── api/                      # API service layer
│   ├── index.ts              # API client setup
│   └── chatApi.ts            # Chat-specific API calls
├── auth/                     # Authentication services
│   └── cognito.ts            # Cognito integration
├── streaming/                # Real-time services
│   ├── index.ts
│   └── streamingClient.ts    # SSE/WebSocket client
└── websocket/                # WebSocket services
    └── client.ts             # WebSocket connection
```

**Purpose**: Centralizes all external service communications and API integrations.

### `/src/locales/`
Internationalization resources for multi-language support.

```
locales/
├── i18n.ts                   # i18next configuration
├── en/                       # English translations
│   └── translation.json      # English strings
└── he/                       # Hebrew translations
    └── translation.json      # Hebrew strings
```

**Translation Structure**:
```json
{
  "common": {
    "welcome": "Welcome",
    "logout": "Logout"
  },
  "chat": {
    "placeholder": "Type your message...",
    "send": "Send"
  }
}
```

### `/src/styles/`
Global styles and CSS configuration.

```
styles/
├── index.css                 # Global styles and Tailwind imports
├── variables.css             # CSS custom properties
└── antd-overrides.css        # Ant Design customizations
```

## Configuration Files

### `package.json`
Defines project dependencies, scripts, and metadata.

**Key Scripts**:
```json
{
  "scripts": {
    "dev": "vite",                    // Start dev server
    "build": "tsc -b && vite build",   // Production build
    "preview": "vite preview",         // Preview production build
    "lint": "eslint .",                // Run linter
    "format": "prettier --write .",    // Format code
    "type-check": "tsc --noEmit"       // Type checking
  }
}
```

### `tsconfig.json`
TypeScript compiler configuration.

**Key Settings**:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "jsx": "react-jsx",
    "strict": true,
    "paths": {
      "@/*": ["./src/*"]    // Path alias for clean imports
    }
  }
}
```

### `vite.config.ts`
Vite build tool configuration.

```typescript
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': 'http://localhost:8000'
    }
  }
})
```

### `tailwind.config.js`
Tailwind CSS configuration with RTL support.

```javascript
module.exports = {
  content: ['./src/**/*.{js,jsx,ts,tsx}'],
  plugins: [
    require('tailwindcss-rtl'),
    require('@tailwindcss/forms'),
  ],
  theme: {
    extend: {
      colors: {
        primary: '#1890ff',
      }
    }
  }
}
```

## File Naming Conventions

### Components
- **PascalCase**: `ChatContainer.tsx`, `MessageBubble.tsx`
- **Index files**: Use `index.ts` for barrel exports
- **Test files**: `ComponentName.test.tsx`

### Hooks
- **camelCase with 'use' prefix**: `useAuth.ts`, `useWebSocket.ts`

### Services
- **camelCase**: `chatApi.ts`, `authService.ts`

### Types
- **camelCase for files**: `auth.ts`, `chat.ts`
- **PascalCase for interfaces**: `interface User {}`, `interface Message {}`

### Utilities
- **camelCase**: `formatDate.ts`, `validateEmail.ts`

## Import Organization

Recommended import order:
```typescript
// 1. React and core libraries
import React, { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'

// 2. Third-party libraries
import { Button } from 'antd'
import axios from 'axios'

// 3. Absolute imports (using @ alias)
import { useAuth } from '@/shared/hooks/useAuth'
import { ChatMessage } from '@/shared/types/chat'

// 4. Relative imports
import { MessageBubble } from './MessageBubble'
import styles from './Chat.module.css'
```

## Best Practices

### Feature Module Guidelines
1. Keep features self-contained
2. Minimize cross-feature dependencies
3. Export through index.ts files
4. Co-locate related files

### Component Organization
1. Group related components in folders
2. Include styles with components
3. Keep components focused and small
4. Use composition over inheritance

### State Management
1. Local state for component-specific data
2. Zustand stores for feature state
3. Context for cross-cutting concerns
4. Server state with React Query/SWR

### Code Splitting
1. Lazy load route components
2. Dynamic imports for heavy features
3. Separate vendor bundles
4. Optimize chunk sizes