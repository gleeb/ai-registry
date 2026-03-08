# Frontend Build Process

## Overview

This document describes the frontend build process, environment configurations, and build optimization strategies for the React application.

## Build System

### Technology Stack

- **Build Tool**: Vite 5.x
- **Framework**: React 18.x with TypeScript
- **Package Manager**: npm
- **Environment**: Node.js 18+

### Build Commands

```bash
# Development
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build locally

# Environment-specific builds
npm run build:dev    # Build for development
npm run build:staging # Build for staging
npm run build:prod   # Build for production
```

## Environment Configuration

### Environment Files

The build process uses environment-specific configuration files:

```
frontend/
├── .env                    # Local development (gitignored)
├── .env.example           # Template for environment variables
├── .env.development       # Development environment
├── .env.staging          # Staging environment
└── .env.production       # Production environment
```

### Environment Variables

#### Required Variables

```bash
# API Configuration
VITE_API_BASE_URL=https://domain.com/api

# Authentication
VITE_COGNITO_USER_POOL_ID=us-east-1_xxxxx
VITE_COGNITO_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxx
VITE_COGNITO_REGION=us-east-1

# Feature Flags
VITE_ENABLE_DEBUG=false
VITE_ENABLE_ANALYTICS=true
```

#### Optional Variables

```bash
# Development
VITE_LOG_LEVEL=debug
VITE_ENABLE_HOT_RELOAD=true

# Production
VITE_ENABLE_SOURCE_MAPS=false
VITE_ENABLE_ERROR_REPORTING=true
```

### Environment-Specific Builds

#### Development Build

```bash
# .env.development
VITE_API_BASE_URL=http://localhost:3000/api
VITE_LOG_LEVEL=debug
VITE_ENABLE_DEBUG=true
```

#### Staging Build

```bash
# .env.staging
VITE_API_BASE_URL=https://staging-domain.cloudfront.net/api
VITE_LOG_LEVEL=info
VITE_ENABLE_DEBUG=false
```

#### Production Build

```bash
# .env.production
VITE_API_BASE_URL=https://production-domain.cloudfront.net/api
VITE_LOG_LEVEL=warn
VITE_ENABLE_DEBUG=false
```

## Build Configuration

### Vite Configuration

```typescript
// vite.config.ts
import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig(({ command, mode }) => {
  // Load environment variables
  const env = loadEnv(mode, process.cwd(), '')
  
  return {
    plugins: [react()],
    
    // Environment-specific settings
    define: {
      __APP_VERSION__: JSON.stringify(process.env.npm_package_version),
    },
    
    // Build optimization
    build: {
      target: 'es2020',
      minify: 'esbuild',
      sourcemap: mode === 'development',
      rollupOptions: {
        output: {
          manualChunks: {
            vendor: ['react', 'react-dom'],
            auth: ['@aws-amplify/auth'],
          },
        },
      },
    },
    
    // Development server
    server: {
      port: 3000,
      host: true,
    },
  }
})
```

### TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

## Build Process Steps

### 1. Pre-build Validation

```bash
# Check Node.js version
node --version  # Must be 18+

# Verify dependencies
npm audit
npm outdated

# Run type checking
npm run type-check

# Run linting
npm run lint
```

### 2. Environment Setup

```bash
# Copy appropriate environment file
cp .env.example .env

# Edit environment variables
nano .env

# Verify environment variables are loaded
npm run env:check
```

### 3. Build Execution

```bash
# Clean previous builds
npm run clean

# Install dependencies (if needed)
npm install

# Build application
npm run build

# Verify build output
ls -la dist/
```

### 4. Build Verification

```bash
# Check build size
npm run build:analyze

# Test build locally
npm run preview

# Run tests against build
npm run test:build
```

## Build Optimization

### Code Splitting

The build process automatically splits code into chunks:

- **Main bundle**: Core application code
- **Vendor chunks**: Third-party libraries
- **Route chunks**: Page-specific code
- **Async chunks**: Dynamically imported modules

### Tree Shaking

- Unused code is automatically removed
- Dead code elimination reduces bundle size
- ES modules enable efficient tree shaking

### Asset Optimization

- Images are optimized and compressed
- CSS is minified and purged
- JavaScript is minified and compressed
- Fonts are subset and optimized

## Build Output

### Directory Structure

```
dist/
├── index.html              # Main entry point
├── assets/
│   ├── index-xxxxx.js      # Main JavaScript bundle
│   ├── index-xxxxx.css     # Main CSS bundle
│   ├── vendor-xxxxx.js     # Vendor libraries
│   └── images/             # Optimized images
└── _redirects              # SPA routing (if needed)
```

### File Naming

- **Hashed filenames**: Enable long-term caching
- **Content-based hashing**: Files change only when content changes
- **Predictable structure**: Consistent naming convention

## Build Scripts

### Package.json Scripts

```json
{
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "build:dev": "tsc && vite build --mode development",
    "build:staging": "tsc && vite build --mode staging",
    "build:prod": "tsc && vite build --mode production",
    "preview": "vite preview",
    "type-check": "tsc --noEmit",
    "lint": "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "clean": "rm -rf dist",
    "env:check": "node scripts/check-env.js"
  }
}
```

### Custom Build Scripts

```bash
#!/bin/bash
# scripts/build.sh

set -e

echo "🚀 Starting frontend build process..."

# Check environment
if [ -z "$1" ]; then
  echo "Usage: ./build.sh [dev|staging|prod]"
  exit 1
fi

ENV=$1
echo "Building for environment: $ENV"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
npm run clean

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build application
echo "🔨 Building application..."
npm run build:$ENV

# Verify build
echo "✅ Verifying build..."
if [ -d "dist" ] && [ -f "dist/index.html" ]; then
  echo "✅ Build successful!"
  echo "📁 Build output: dist/"
  echo "📊 Build size: $(du -sh dist | cut -f1)"
else
  echo "❌ Build failed!"
  exit 1
fi
```

## Troubleshooting

### Common Build Issues

#### TypeScript Errors

```bash
# Check TypeScript configuration
npx tsc --showConfig

# Run type checking separately
npm run type-check

# Fix type issues
npm run lint:fix
```

#### Dependency Issues

```bash
# Clear dependency cache
rm -rf node_modules package-lock.json
npm install

# Check for conflicting versions
npm ls
```

#### Environment Issues

```bash
# Verify environment variables
npm run env:check

# Check environment file syntax
node -e "require('dotenv').config()"
```

### Performance Issues

#### Large Bundle Size

```bash
# Analyze bundle
npm run build:analyze

# Check for duplicate dependencies
npm ls | grep -E "(react|@aws-amplify)"
```

#### Slow Builds

```bash
# Enable build caching
export VITE_CACHE_DIR=.vite-cache

# Use faster minifier
export VITE_MINIFY=esbuild
```

## Continuous Integration

### GitHub Actions

```yaml
# .github/workflows/frontend-build.yml
name: Frontend Build

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Type check
      run: npm run type-check
    
    - name: Lint
      run: npm run lint
    
    - name: Build
      run: npm run build
    
    - name: Upload build artifacts
      uses: actions/upload-artifact@v3
      with:
        name: frontend-build
        path: dist/
```

### Build Validation

```bash
# Automated build validation
npm run build:validate

# Performance testing
npm run build:perf

# Accessibility testing
npm run build:a11y
```

## Best Practices

### Environment Management

- Never commit `.env` files to version control
- Use `.env.example` as template
- Validate environment variables at build time
- Use different environments for different stages

### Build Optimization

- Enable source maps only in development
- Use appropriate minification for production
- Implement code splitting for large applications
- Optimize images and assets

### Security

- Validate all environment variables
- Use HTTPS in production
- Implement Content Security Policy
- Regular dependency updates

---

**Note**: This build process is designed to work with the CDK infrastructure. Ensure the infrastructure is deployed before building for production environments.
