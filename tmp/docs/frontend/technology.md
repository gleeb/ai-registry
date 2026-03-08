# Frontend Technology Stack

## Core Technologies

### React 19
**Version**: ^19.1.0

React is the core UI library powering the application's component-based architecture. We use React 19 for its improved performance, concurrent features, and enhanced developer experience.

**Key Features Used**:
- Function components with hooks
- Concurrent rendering for better performance
- Suspense for code splitting
- Error boundaries for robust error handling
- Context API for cross-component state

**Why React?**
- Large ecosystem and community support
- Excellent TypeScript integration
- Component reusability and composability
- Virtual DOM for efficient updates
- Strong tooling support

### TypeScript
**Version**: ^5.2.2

TypeScript provides static typing for JavaScript, enhancing code quality and developer productivity.

**Configuration**: TypeScript configuration is defined in `frontend/tsconfig.json` with strict type checking and modern ES features enabled.

**Benefits**:
- Type safety and early error detection
- Enhanced IDE support with IntelliSense
- Better refactoring capabilities
- Self-documenting code through types

### Vite
**Version**: ^5.4.1

Vite serves as our build tool and development server, providing lightning-fast HMR (Hot Module Replacement) and optimized production builds.

**Configuration Features**:
- Path aliases for clean imports
- Environment variable handling
- Automatic code splitting
- CSS preprocessing
- Plugin ecosystem

**Why Vite?**
- Instant server start
- Fast HMR updates
- Optimized production builds
- Native ES modules support
- Built-in TypeScript support

## UI Framework

### Ant Design 5
**Version**: ^5.26.6

Ant Design provides a comprehensive set of high-quality React components following a consistent design language.

**Components Used**:
- Form components for data entry
- Table for data display
- Modal and Drawer for overlays
- Message and Notification for feedback
- Layout components for structure

**Pro Components**: ^2.8.10
- ProTable for advanced tables
- ProForm for complex forms
- ProLayout for application layouts

**Customization**: Theme configuration and RTL support are implemented in `frontend/src/app/providers/ThemeProvider.tsx`. See [RTL Hebrew Support](./rtl-hebrew-support.md) for detailed RTL implementation.

### Tailwind CSS
**Version**: ^4.1.11

Tailwind provides utility-first CSS classes for rapid UI development without leaving your HTML.

**Configuration**:
- Custom color palette aligned with brand
- RTL support via tailwindcss-rtl plugin
- Responsive breakpoints
- Custom utilities for common patterns

**RTL Plugin**: ^0.9.0
- Automatic RTL class generation
- Logical property utilities
- Direction-aware spacing

## State Management

### Zustand
**Version**: ^5.0.6

Zustand is a lightweight state management solution that provides a simple and performant alternative to Redux.

**Store Organization**: Store implementations can be found in `frontend/src/features/*/stores/` directories, with the main chat store in `frontend/src/features/chat/stores/chatStore.ts`.

**Why Zustand?**
- Minimal boilerplate
- TypeScript-first design
- No providers needed
- DevTools support
- Excellent performance

## Routing

### React Router DOM
**Version**: ^7.7.1

React Router handles client-side routing with support for nested routes, lazy loading, and route guards.

**Features Used**:
- Nested routing
- Route parameters
- Protected routes
- Lazy route loading
- Navigation guards

**Route Structure**: Application routing is configured in `frontend/src/app/router/index.tsx` with protected routes and lazy loading.

## Authentication

### AWS Amplify
**Version**: ^6.15.4

AWS Amplify provides authentication integration with AWS Cognito, handling OAuth flows and token management.

**Features**:
- OAuth 2.0 with PKCE
- Token auto-refresh
- Secure credential storage
- MFA support
- Social provider integration

### Amazon Cognito Identity JS
**Version**: ^6.3.15

Direct Cognito SDK for fine-grained control over authentication flows when needed.

## HTTP Client

### Axios
**Version**: ^1.11.0

Axios handles HTTP requests with interceptors for authentication and error handling.

**Configuration**: HTTP client setup and interceptors are configured in `frontend/src/services/api/index.ts` with authentication token handling.

**Features Used**:
- Request/response interceptors
- Automatic JSON transformation
- Request cancellation
- Progress tracking
- Error handling

## Internationalization

### react-i18next
**Version**: ^15.6.1

Handles translations and language switching for Hebrew/English support.

**Configuration**: i18n setup is in `frontend/src/locales/i18n.ts` with Hebrew and English translations. See [RTL Hebrew Support](./rtl-hebrew-support.md) for comprehensive RTL implementation details.

### i18next-browser-languagedetector
**Version**: ^8.2.0

Automatically detects user's preferred language from browser settings.

## Utility Libraries

### UUID
**Version**: ^11.1.0

Generates unique identifiers for messages and temporary IDs.

### date-fns
Lightweight date manipulation library for formatting and parsing dates.

## Development Tools

### ESLint
**Version**: ^9.30.1

Enforces code quality and consistency standards.

**Configuration**:
- React and TypeScript rules
- Import order enforcement
- Accessibility checks
- Custom team rules

### Prettier
**Version**: ^3.6.2

Automatic code formatting for consistent style.

**Configuration**:
```json
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
```

### TypeScript ESLint
Provides TypeScript-specific linting rules.

## Build Optimization

### Code Splitting
- Route-based splitting with React.lazy
- Dynamic imports for heavy components
- Vendor chunk optimization

### Tree Shaking
- Removal of unused code
- ES module imports for better elimination
- Production-only optimizations

### Asset Optimization
- Image compression
- SVG optimization
- Font subsetting
- CSS minification

## Testing Tools

### Vitest
Fast unit testing framework with Vite integration.

### React Testing Library
Testing utilities focused on user behavior rather than implementation details.

### Playwright
End-to-end testing for critical user flows.

## Performance Monitoring

### Web Vitals
Tracking Core Web Vitals for performance monitoring:
- LCP (Largest Contentful Paint)
- FID (First Input Delay)
- CLS (Cumulative Layout Shift)

### Bundle Analysis
- Vite's built-in bundle analyzer
- Monitoring bundle size trends
- Identifying optimization opportunities

## Version Management

### Package Management
- npm for dependency management
- Lock file for reproducible builds
- Regular dependency updates
- Security audit checks

### Upgrade Strategy
- Minor updates monthly
- Major updates quarterly
- Security patches immediately
- Testing before production updates