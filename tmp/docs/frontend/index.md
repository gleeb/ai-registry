# Frontend Documentation

## Overview

The frontend of the Legal Information System is a modern React application built with TypeScript, providing a bilingual (Hebrew/English) interface for legal document management and AI-powered chat interactions. It features a responsive design with RTL support, real-time streaming capabilities, and secure OAuth authentication.

## Architecture Overview

The frontend follows a feature-based architecture pattern with clear separation of concerns:

```
frontend/
├── src/
│   ├── app/           # Application core (providers, routing, configuration)
│   ├── features/      # Feature modules (auth, chat, documents, admin)
│   ├── shared/        # Shared components, utilities, and types
│   ├── services/      # API clients and external service integrations
│   ├── locales/       # Internationalization resources
│   └── styles/        # Global styles and theme configuration
```

## Core Technologies

- **Framework**: React 19 with TypeScript
- **Build Tool**: Vite for fast development and optimized production builds
- **UI Libraries**: Ant Design 5 with Pro Components
- **Styling**: Tailwind CSS with RTL plugin
- **State Management**: Zustand for lightweight state management
- **Routing**: React Router v6
- **Authentication**: AWS Amplify with Cognito
- **Internationalization**: react-i18next with automatic language detection

## Documentation Sections

### 📚 [Technology Stack](./technology.md)
Detailed overview of all frontend technologies, libraries, and tools used in the project, including version information and architectural decisions.

### 📁 [Project Structure](./project-structure.md)
Comprehensive guide to the frontend directory organization, explaining the purpose of each folder and the component hierarchy.

### 🚀 [Setup and Deployment](./setup-and-deployment.md)
Step-by-step instructions for setting up the development environment, running the application locally, and deploying to production.

### 🔐 [Authentication](./authentication.md)
Complete documentation of the frontend authentication flow, including OAuth 2.0/PKCE implementation, token management, and route protection.

### 🎨 [Styles and Theming](./styles.md)
Guide to the styling system, including Tailwind configuration, Ant Design theming, RTL support, and design system components.

### 💬 [Chat Interface](./chat-interface.md)
Documentation of the real-time chat functionality, including WebSocket connections, streaming responses, and message handling.

### 🌍 [Internationalization](./internationalization.md)
How the bilingual support is implemented, including translation management and language switching.

### 🔤 [RTL Hebrew Support](./rtl-hebrew-support.md)
Comprehensive guide to Right-to-Left implementation for Hebrew language, including layout mirroring, text direction, and component-specific RTL handling.

### 📊 [State Management](./state-management.md)
Overview of state management patterns using Zustand, including store organization and data flow patterns.

### 🔧 [Troubleshooting](./troubleshooting.md)
Common frontend issues, debugging techniques, and solutions for development problems.

## Quick Start

### Prerequisites
- Node.js 18+ and npm/yarn
- Git for version control
- VS Code or similar IDE with TypeScript support

### Basic Setup
See [Setup and Deployment](./setup-and-deployment.md) for detailed installation and configuration instructions.

### Environment Configuration
Environment variables are configured in `frontend/.env` based on the template in `frontend/env.example`. See [Setup and Deployment](./setup-and-deployment.md) for complete environment setup.

## Development Workflow

### Component Development
1. Create feature components in `src/features/<feature-name>/components/`
2. Share reusable components in `src/shared/components/`
3. Use TypeScript for all new components
4. Follow the established naming conventions

### State Management
- Use Zustand stores for feature-specific state
- Keep stores small and focused
- Use TypeScript interfaces for store shapes

### Styling Guidelines
- Use Tailwind classes for layout and spacing
- Use Ant Design components for UI elements
- Support RTL by using logical properties
- Maintain consistent theme variables

### Testing
Testing commands and configuration are detailed in the project's `frontend/package.json` scripts section. See [Setup and Deployment](./setup-and-deployment.md) for testing procedures.

## Key Features

### Authentication System
- OAuth 2.0 with PKCE flow
- Secure token storage
- Automatic token refresh
- Protected route handling
- MFA support

### Chat Interface
- Real-time message streaming
- Model selection (Claude, GPT)
- Thought process visualization
- File attachment support
- Message history persistence

### Document Management
- Document upload interface
- Processing status tracking
- Search and filter capabilities
- Preview functionality

### Bilingual Support
- Hebrew and English interfaces
- Automatic RTL switching
- Persistent language preference
- Translated UI components

## Performance Considerations

### Code Splitting
- Route-based code splitting for faster initial loads
- Lazy loading of feature modules
- Dynamic imports for heavy components

### Optimization Techniques
- React.memo for expensive components
- useMemo and useCallback for performance
- Virtual scrolling for long lists
- Image lazy loading

### Bundle Size Management
- Tree shaking with Vite
- Analyze bundle with `npm run build -- --analyze`
- Monitor and optimize dependencies

## Security Best Practices

### Authentication Security
- Never store sensitive tokens in localStorage for production
- Use httpOnly cookies when possible
- Implement CSRF protection
- Validate all user inputs

### Content Security
- Sanitize user-generated content
- Implement Content Security Policy headers
- Use HTTPS in production
- Avoid inline scripts

## Troubleshooting

### Common Issues

1. **Authentication Redirect Issues**
   - Check callback URL configuration in Cognito
   - Verify redirect URI in environment variables

2. **RTL Layout Problems**
   - Ensure Tailwind RTL plugin is configured
   - Check Ant Design ConfigProvider direction

3. **Build Failures**
   - Clear node_modules and reinstall
   - Check for TypeScript errors
   - Verify environment variables

### Debug Tools
- React Developer Tools for component inspection
- Redux DevTools for state debugging
- Network tab for API debugging
- Console for error tracking

## Related Documentation

- [Backend API Reference](../backend/api.md) - API endpoints and contracts
- [CDK Architecture](../other/cdk-architecture.md) - Infrastructure setup
- [Deployment Guide](../other/deployment-guide.md) - Production deployment

## Resources

- [React Documentation](https://react.dev)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Ant Design Components](https://ant.design/components/overview)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)