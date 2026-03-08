# T-042: Frontend S3 + CloudFront Deployment

## Context Gathered
- `backlog.yaml` - Task T-042 created for frontend deployment
- `infra/stacks/application/api_stack.py` - Existing CloudFront and WAF configuration
- `infra/config.json` - Environment configurations with OAuth callback URLs
- `frontend/env.example` - Frontend environment variables configuration
- `frontend/src/services/auth/cognito.ts` - Authentication service implementation
- `infra/app.py` - CDK application structure and stack organization

## Completed Tasks
- [x] Created task T-042 in backlog.yaml
- [x] Created task document
- [x] Created feature branch: `feature/T-042-frontend-s3-cloudfront-deployment`
- [x] Updated task status to in-progress

## In Progress Tasks
- [x] Analyze current CloudFront stack implementation
- [x] Plan S3 bucket integration with existing CloudFront
- [x] Design authentication redirect URL strategy
- [x] Create implementation plan
- [x] Implement S3 bucket creation and configuration
- [x] Update CloudFront distribution to serve frontend
- [x] Modify Cognito OAuth configuration for multiple redirect URLs
- [x] Implement clean API path architecture (remove origin_path, use $default stage)
- [x] Remove redundant CloudFront behaviors (/chat/*, /health)
- [x] Update all API Gateway routes to include /api prefix
- [x] Update all Lambda permission ARNs to match new routes
- [x] Create comprehensive deployment documentation with examples
- [x] Update Makefile with frontend build and deployment scripts
- [x] Create environment-specific build configurations

## Future Tasks
- [ ] Update frontend build and deployment process
- [ ] Test authentication flow in both environments
- [ ] Update documentation and environment configurations
- [ ] Document S3 upload and CloudFront cache invalidation procedures

## Next Steps
1. **Review Implementation Plan**: The comprehensive plan has been created and documented
2. **Begin Implementation**: Start with S3 bucket integration in existing CloudFront stack
3. **Update Authentication**: Modify Cognito configuration for multiple redirect URLs
4. **Create Deployment Process**: Implement frontend build and S3 upload scripts
5. **Testing**: Verify authentication works in both local and CloudFront environments

## Implementation Status
- ✅ **Task Created**: T-042 added to backlog with proper tagging
- ✅ **Branch Created**: `feature/T-042-frontend-s3-cloudfront-deployment`
- ✅ **Analysis Complete**: Current CloudFront + WAF infrastructure analyzed
- ✅ **Plan Documented**: Comprehensive implementation plan created
- ✅ **Staging Doc**: Documentation workflow requirements met
- 🔄 **Ready for Implementation**: All planning complete, ready to begin coding

## Implementation Plan

### Current State Analysis
The project already has a comprehensive CloudFront + WAF setup in the API stack that:
- Serves API endpoints through CloudFront with proper CORS
- Implements WAF protection with IP restrictions
- Uses CloudFront Functions for CORS handling
- Has authentication integration with JWT + CloudFront header validation

### Proposed Solution
1. **Extend existing CloudFront stack** rather than create a new one
2. **Add S3 bucket as additional origin** to the existing CloudFront distribution
3. **Configure CloudFront behaviors** to route frontend requests to S3 and API requests to API Gateway
4. **Update Cognito OAuth configuration** to support both localhost:3000 and CloudFront domain
5. **Maintain WAF protection** for the frontend through the existing CloudFront setup

### Technical Approach
- **S3 Bucket**: Create in the existing API stack as a new origin
- **CloudFront Behaviors**: 
  - Default behavior: Serve frontend from S3
  - Path-based behavior: Route `/api/*` to API Gateway
- **Authentication**: Support multiple redirect URLs in Cognito
- **Security**: Leverage existing WAF rules and CloudFront security headers

### Files to Modify
- `infra/stacks/application/api_stack.py` - Add S3 bucket and frontend origin
- `infra/config.json` - Update OAuth callback URLs for all environments
- `frontend/package.json` - Add build and deploy scripts
- `frontend/env.example` - Update with CloudFront domain variables
- `docs/frontend/deployment.md` - Create comprehensive deployment documentation
- `Makefile` - Add frontend build and deployment scripts (there is a make file in the root of the project)
- `frontend/scripts/` - Create deployment and build utility scripts
- `docs/frontend/build-process.md` - Document build process and environment configurations

### Authentication Strategy
- **Development**: Continue using localhost:3000 for OAuth callbacks
- **Production**: Use CloudFront domain for OAuth callbacks
- **Cognito Configuration**: Support multiple callback URLs simultaneously
- **Token Validation**: Maintain existing JWT + CloudFront header validation

### Deployment Process
1. **Build**: `npm run build` creates optimized production bundle
2. **Upload**: Sync build artifacts to S3 bucket
3. **Invalidate**: Clear CloudFront cache for updated files
4. **Verify**: Test authentication flow in both environments

### Build and Deployment Documentation
- **Comprehensive deployment guide** with step-by-step instructions
- **Build process documentation** including environment-specific configurations
- **S3 upload examples** using AWS CLI and CDK deployment
- **CloudFront cache invalidation** procedures
- **Environment variable management** for different deployment targets
- **Troubleshooting guide** for common deployment issues

### Makefile Integration
- **Build scripts**: `make frontend-build` for production builds
- **Deploy scripts**: `make frontend-deploy` for S3 upload and cache invalidation
- **Environment scripts**: `make frontend-dev` and `make frontend-prod` for different targets
- **Clean scripts**: `make frontend-clean` for build artifact cleanup
- **Watch scripts**: `make frontend-watch` for development builds

### Deployment Documentation Structure
```
docs/frontend/
├── deployment.md           # Main deployment guide with step-by-step instructions
├── build-process.md        # Build process documentation and environment configs
└── troubleshooting.md      # Common issues and solutions
```

### Makefile Scripts Overview
```makefile
# Frontend Development
frontend-dev:          # Start development server
frontend-build:        # Build production bundle
frontend-watch:        # Watch mode for development builds

# Frontend Deployment
frontend-deploy:       # Deploy to S3 and invalidate CloudFront
frontend-deploy-dev:   # Deploy to development environment
frontend-deploy-prod:  # Deploy to production environment

# Frontend Maintenance
frontend-clean:        # Clean build artifacts
frontend-install:      # Install dependencies
frontend-test:         # Run frontend tests
```

### Deployment Process Documentation
- **Prerequisites**: AWS CLI setup, CDK deployment, environment variables
- **Build Process**: Environment-specific builds, optimization, bundle analysis
- **S3 Upload**: AWS CLI sync commands, bucket policies, CORS configuration
- **CloudFront**: Cache invalidation, distribution updates, monitoring
- **Verification**: Health checks, authentication testing, performance validation
- **Rollback**: Quick rollback procedures, version management

## Relevant Files
- `infra/stacks/application/api_stack.py` - Main API stack with CloudFront configuration
- `infra/config.json` - Environment-specific configurations
- `frontend/src/services/auth/cognito.ts` - Authentication service
- `frontend/env.example` - Environment variables template
- `infra/app.py` - CDK application entry point

## Questions to Resolve
1. Should the S3 bucket be in the same stack as CloudFront or separate?
2. How to handle CloudFront cache invalidation during deployments?
3. What's the best approach for managing multiple OAuth redirect URLs?
4. Should we implement blue-green deployment for the frontend?
5. How to handle environment-specific frontend builds?

## Next Steps
1. Review and approve this implementation plan
2. Create feature branch for implementation
3. Begin with S3 bucket integration in existing CloudFront stack
4. Update Cognito configuration for multiple redirect URLs
5. Implement frontend build and deployment process
