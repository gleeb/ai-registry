# Frontend Setup and Deployment

## Overview

The frontend is a React TypeScript application built with Vite, featuring Ant Design with RTL support for Hebrew, comprehensive internationalization, and modern development tooling. The project follows a feature-based architecture with strict TypeScript configuration and enterprise-grade development practices.

## Prerequisites

### System Requirements
- **Node.js**: Version 18.0.0 or higher
- **npm**: Version 8.0.0 or higher (comes with Node.js)
- **Git**: For version control
- **IDE**: VS Code recommended with TypeScript support

### Required Accounts
- AWS account with Cognito access
- Access to the project repository
- CloudFront distribution (for production)

## Project Architecture

### Technology Stack
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite for fast development and optimized builds
- **UI Library**: Ant Design 5.x with @ant-design/pro-components
- **State Management**: Zustand for lightweight state management
- **Routing**: React Router v6 for navigation
- **HTTP Client**: Axios with interceptors for API calls
- **Internationalization**: react-i18next with Hebrew/English support
- **Styling**: Tailwind CSS with RTL plugin
- **Code Quality**: ESLint, Prettier, TypeScript strict mode

### Directory Structure
The project follows a feature-based architecture:

```
frontend/
├── src/
│   ├── app/                    # Application core
│   │   ├── App.tsx            # Main app component
│   │   ├── providers/         # Context providers
│   │   └── router/            # Routing configuration
│   ├── features/              # Feature modules
│   │   ├── auth/              # Authentication
│   │   ├── chat/              # Chat interface
│   │   ├── documents/         # Document management
│   │   └── admin/             # Admin functionality
│   ├── shared/                # Shared components
│   │   ├── components/        # Reusable components
│   │   ├── hooks/             # Custom hooks
│   │   ├── types/             # TypeScript types
│   │   └── utils/             # Utility functions
│   ├── services/              # API services
│   ├── locales/               # Internationalization
│   └── styles/                # Global styles
├── public/                    # Static assets
├── tests/                     # Test files
└── dist/                      # Build output
```

## Local Development Setup

### 1. Clone the Repository
```bash
# Clone the project
git clone <repository-url>
cd LawInfo/frontend

# Or if already cloned, navigate to frontend
cd frontend
```

### 2. Install Dependencies
```bash
# Install all dependencies
npm install

# Or with yarn
yarn install

# Verify installation
npm list --depth=0
```

### 3. Environment Configuration

#### Create Environment File
```bash
# Copy the example environment file
cp env.example .env

# Edit the .env file with your values
nano .env  # or use your preferred editor
```

#### Required Environment Variables
```env
# Authentication (AWS Cognito)
VITE_COGNITO_USER_POOL_ID=il-central-1_xxxxxxxxx
VITE_COGNITO_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxx
VITE_COGNITO_HOSTED_UI_DOMAIN=https://your-domain.auth.il-central-1.amazoncognito.com

# API Configuration
VITE_API_BASE_URL=https://your-api-gateway-url.execute-api.region.amazonaws.com
VITE_WEBSOCKET_URL=wss://your-websocket-url.execute-api.region.amazonaws.com

# Application Settings
VITE_APP_NAME=Legal Information System
VITE_DEFAULT_LANGUAGE=en
VITE_SUPPORTED_LANGUAGES=en,he

# Feature Flags
VITE_ENABLE_CHAT=true
VITE_ENABLE_DOCUMENTS=true
VITE_ENABLE_ADMIN=false

# Development Settings
VITE_ENABLE_DEBUG=true
VITE_MOCK_API=false
```

#### Environment-Specific Files
For different environments, create:
- `.env.development` - Local development
- `.env.staging` - Staging environment
- `.env.production` - Production environment

### 4. Start Development Server
```bash
# Start the development server
npm run dev

# The application will be available at:
# http://localhost:5173

# With custom port
VITE_PORT=3000 npm run dev
```

### 5. Verify Setup
1. Open browser to `http://localhost:5173`
2. Check console for any errors
3. Verify Cognito redirect works
4. Test language switching
5. Check API connectivity

## Development Workflow

### Available Scripts

```bash
# Start development server with hot reload
npm run dev

# Build for production
npm run build

# Preview production build locally
npm run preview

# Run type checking
npm run type-check

# Run linting
npm run lint

# Format code with Prettier
npm run format

# Check formatting without changing files
npm run format:check

# Run unit tests
npm run test

# Run tests in watch mode
npm run test:watch

# Run E2E tests
npm run test:e2e
```

### Development Tools Setup

#### VS Code Extensions
Recommended extensions for optimal development:
```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "antfu.i18n-ally",
    "ms-vscode.vscode-typescript-next",
    "formulahendry.auto-rename-tag",
    "usernamehw.errorlens"
  ]
}
```

#### VS Code Settings
`.vscode/settings.json`:
```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.tsdk": "node_modules/typescript/lib",
  "tailwindCSS.experimental.classRegex": [
    ["clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)"]
  ]
}
```

### Debugging Configuration

#### Browser DevTools
1. Install React Developer Tools extension
2. Use Components tab to inspect component tree
3. Use Profiler for performance analysis

#### VS Code Debugging
`.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch Chrome against localhost",
      "url": "http://localhost:5173",
      "webRoot": "${workspaceFolder}/frontend/src",
      "sourceMaps": true
    }
  ]
}
```

## Configuration Files

### TypeScript Configuration
The project uses strict TypeScript configuration in `frontend/tsconfig.app.json`:

- **Strict Mode**: All strict checks enabled
- **Path Aliases**: `@/*` for src directory
- **JSX**: React JSX with automatic runtime
- **Module Resolution**: Node.js resolution strategy
- **Target**: ES2020 for modern browser support

### Vite Configuration
Build tool configuration in `frontend/vite.config.ts`:

- **Path Aliases**: Configured for clean imports
- **Environment Variables**: Vite environment variable handling
- **Build Optimization**: Code splitting and tree shaking
- **Development Server**: Hot module replacement
- **Production Build**: Optimized asset handling

### ESLint Configuration
Code quality configuration in `frontend/.eslintrc.cjs`:

- **React Rules**: React and React Hooks rules
- **TypeScript Rules**: TypeScript-specific linting
- **Import Rules**: Import organization and validation
- **Code Style**: Consistent code formatting rules

### Prettier Configuration
Code formatting in `frontend/.prettierrc`:

- **Semi**: No semicolons for cleaner code
- **Single Quote**: Consistent string quotes
- **Tab Width**: 2 spaces for indentation
- **Trailing Comma**: ES5 trailing commas

### Tailwind Configuration
Styling configuration in `frontend/tailwind.config.js`:

- **RTL Support**: RTL plugin for Hebrew support
- **Custom Colors**: Project-specific color palette
- **Custom Fonts**: Hebrew fonts (Heebo, Rubik)
- **Responsive Design**: Mobile-first approach

## RTL Support Implementation

### Ant Design RTL Configuration
RTL support is implemented in `frontend/src/app/providers/ThemeProvider.tsx`:

- **ConfigProvider**: Ant Design RTL configuration
- **Direction Switching**: Dynamic direction based on language
- **Component Adaptation**: RTL-aware component rendering
- **Layout Adjustments**: RTL-specific layout changes

### Tailwind CSS RTL Plugin
RTL styling configuration:

- **RTL Plugin**: Automatic RTL class generation
- **Direction Classes**: `dir-rtl` and `dir-ltr` utilities
- **Text Alignment**: RTL-aware text alignment
- **Margin/Padding**: RTL-aware spacing utilities

### Internationalization Setup
i18n configuration in `frontend/src/locales/i18n.ts`:

- **Language Detection**: Automatic language detection
- **Fallback Language**: English as fallback
- **Namespace Management**: Organized translation structure
- **Pluralization**: Hebrew pluralization support

## Build Process

### Development Build
```bash
# Development build with source maps
npm run build -- --mode development

# Output directory: dist/
# Includes source maps for debugging
```

### Production Build
```bash
# Optimized production build
npm run build

# Analyze bundle size
npm run build -- --analyze

# Build with custom base path
npm run build -- --base=/app/
```

### Build Output
```
dist/
├── assets/           # JS, CSS, and other assets
│   ├── index-[hash].js
│   ├── index-[hash].css
│   └── vendor-[hash].js
├── index.html        # Entry HTML
└── favicon.ico       # Favicon
```

### Build Optimization
- Code splitting by routes
- Tree shaking for unused code
- CSS purging with Tailwind
- Asset compression
- Lazy loading for images

## Deployment

### Deployment to S3 + CloudFront

#### 1. Build the Application
```bash
# Create production build
npm run build

# Verify build output
ls -la dist/
```

#### 2. Configure S3 Bucket
```bash
# Create S3 bucket for hosting
aws s3 mb s3://your-frontend-bucket --profile Eng-Sandbox

# Enable static website hosting
aws s3 website s3://your-frontend-bucket \
  --index-document index.html \
  --error-document index.html \
  --profile Eng-Sandbox
```

#### 3. Upload to S3
```bash
# Sync build files to S3
aws s3 sync dist/ s3://your-frontend-bucket \
  --delete \
  --cache-control max-age=31536000,public \
  --exclude index.html \
  --profile Eng-Sandbox

# Upload index.html with no-cache
aws s3 cp dist/index.html s3://your-frontend-bucket/ \
  --cache-control no-cache,no-store,must-revalidate \
  --profile Eng-Sandbox
```

#### 4. CloudFront Configuration
```bash
# Create CloudFront distribution (via CDK)
cd ../infra
cdk deploy FrontendStack-prod --profile Eng-Sandbox

# Invalidate CloudFront cache after deployment
aws cloudfront create-invalidation \
  --distribution-id YOUR_DISTRIBUTION_ID \
  --paths "/*" \
  --profile Eng-Sandbox
```

### Deployment via CDK

The frontend deployment is managed through AWS CDK:

```bash
# Navigate to infrastructure directory
cd ../infra

# Deploy frontend stack
cdk deploy FrontendStack-${ENVIRONMENT} \
  -c environment=${ENVIRONMENT} \
  --profile Eng-Sandbox

# Example for production
cdk deploy FrontendStack-prod \
  -c environment=prod \
  --profile Eng-Sandbox
```

### CI/CD Pipeline

#### GitHub Actions Workflow
`.github/workflows/frontend-deploy.yml`:
```yaml
name: Deploy Frontend

on:
  push:
    branches: [main]
    paths:
      - 'frontend/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        working-directory: ./frontend
        run: npm ci
      
      - name: Run tests
        working-directory: ./frontend
        run: npm run test
      
      - name: Build application
        working-directory: ./frontend
        run: npm run build
        env:
          VITE_COGNITO_USER_POOL_ID: ${{ secrets.COGNITO_USER_POOL_ID }}
          VITE_COGNITO_CLIENT_ID: ${{ secrets.COGNITO_CLIENT_ID }}
      
      - name: Deploy to S3
        run: |
          aws s3 sync frontend/dist/ s3://${{ secrets.S3_BUCKET }} --delete
          aws cloudfront create-invalidation --distribution-id ${{ secrets.CF_DISTRIBUTION_ID }} --paths "/*"
```

## Environment-Specific Configurations

### Development Environment
- Hot module replacement enabled
- Source maps included
- Debug logging enabled
- CORS proxy configured
- Mock data available

### Staging Environment
- Production build optimizations
- Limited debug logging
- Real API endpoints
- Test user accounts
- Performance monitoring

### Production Environment
- Maximum optimizations
- No debug logging
- Production API endpoints
- Security headers enabled
- CDN caching configured

## Health Checks and Monitoring

### Application Health Check
Health check implementation in `frontend/src/utils/healthCheck.ts`:

- **API Connectivity**: Check backend API availability
- **Auth Configuration**: Verify Cognito configuration
- **WebSocket Status**: Check real-time connection
- **Feature Flags**: Validate feature availability

### Performance Monitoring
Core Web Vitals monitoring:

- **CLS**: Cumulative Layout Shift
- **FID**: First Input Delay
- **FCP**: First Contentful Paint
- **LCP**: Largest Contentful Paint
- **TTFB**: Time to First Byte

## Troubleshooting

### Common Issues

#### 1. Build Failures
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
npm run build
```

#### 2. Environment Variable Issues
```bash
# Verify environment variables are loaded
npm run dev -- --debug

# Check in browser console
console.log(import.meta.env)
```

#### 3. TypeScript Errors
```bash
# Check for type errors
npm run type-check

# Generate missing types
npm run generate-types
```

#### 4. Cognito Redirect Issues
- Verify callback URL in Cognito console
- Check redirect URI in environment variables
- Ensure HTTPS in production

#### 5. CORS Errors
- Check API Gateway CORS configuration
- Verify CloudFront headers
- Use proxy in development

#### 6. RTL Layout Issues
- Check Ant Design ConfigProvider setup
- Verify Tailwind RTL plugin configuration
- Test language switching functionality

### Debug Mode
Enable debug mode for detailed logging:
```env
VITE_ENABLE_DEBUG=true
VITE_LOG_LEVEL=debug
```

## Security Considerations

### Production Deployment
1. Use HTTPS everywhere
2. Enable security headers
3. Implement CSP (Content Security Policy)
4. Sanitize user inputs
5. Use environment variables for secrets
6. Enable CloudFront WAF
7. Regular dependency updates

### Security Headers
Configure in CloudFront or via meta tags:
```html
<meta http-equiv="X-Content-Type-Options" content="nosniff">
<meta http-equiv="X-Frame-Options" content="DENY">
<meta http-equiv="X-XSS-Protection" content="1; mode=block">
```

## Implementation Files

### Core Configuration Files
- `frontend/package.json` - Dependencies and scripts
- `frontend/tsconfig.app.json` - TypeScript configuration
- `frontend/vite.config.ts` - Vite build configuration
- `frontend/.eslintrc.cjs` - ESLint configuration
- `frontend/.prettierrc` - Prettier configuration
- `frontend/tailwind.config.js` - Tailwind CSS configuration
- `frontend/postcss.config.js` - PostCSS configuration

### Application Files
- `frontend/src/app/App.tsx` - Main application component
- `frontend/src/app/providers/` - Context providers
- `frontend/src/app/router/` - Routing configuration
- `frontend/src/locales/i18n.ts` - Internationalization setup
- `frontend/src/locales/*/translation.json` - Translation files

### Environment Files
- `frontend/env.example` - Environment variables template
- `frontend/.env` - Local environment variables
- `frontend/.gitignore` - Git ignore configuration

### Documentation
- `frontend/README.md` - Frontend documentation
- `frontend/.vscode/settings.json` - VS Code settings
- `frontend/.vscode/launch.json` - Debug configuration

## Related Documentation

- [Frontend Technology Stack](./technology.md) - Technology overview
- [Frontend Project Structure](./project-structure.md) - Architecture details
- [Frontend Authentication](./authentication.md) - Authentication implementation
- [Frontend Internationalization](./internationalization.md) - i18n setup
- [Frontend Styling](./styles.md) - CSS and styling approach