# Frontend Authentication Documentation

## Overview

The frontend implements a secure OAuth 2.0 Authorization Code Flow with PKCE (Proof Key for Code Exchange) using AWS Cognito as the identity provider. This provides enterprise-grade security for single-page applications without requiring a backend secret, with comprehensive token management and session handling.

## Authentication Flow

### Complete Authentication Sequence

The authentication flow follows OAuth 2.0 Authorization Code Flow with PKCE:

1. **Login Initiation**: User clicks login, frontend generates PKCE parameters
2. **Cognito Redirect**: User redirected to Cognito hosted UI with authorization parameters
3. **User Authentication**: User enters credentials on Cognito hosted UI
4. **Authorization Code**: Cognito redirects back with authorization code
5. **Token Exchange**: Frontend exchanges code for JWT tokens using PKCE verifier
6. **Token Storage**: Tokens stored in localStorage using Cognito SDK format
7. **API Access**: Access token used for authenticated API requests

## Implementation Details

### 1. PKCE Implementation

PKCE adds an extra layer of security to prevent authorization code interception attacks.

#### PKCE Utilities
PKCE implementation is located in `frontend/src/shared/utils/pkce.ts` and provides:

**Code Verifier Generation:**
```typescript
export function generateCodeVerifier(): string {
    const array = new Uint8Array(32)
    crypto.getRandomValues(array)
    return base64UrlEncode(array)
}
```

**Code Challenge Creation:**
```typescript
export async function generateCodeChallenge(verifier: string): Promise<string> {
    const data = new TextEncoder().encode(verifier)
    const hash = await crypto.subtle.digest('SHA-256', data)
    return base64UrlEncode(new Uint8Array(hash))
}
```

**Session Storage Management:**
- Verifier stored with state as key: `pkce_verifier_{state}`
- Cleared after successful authentication
- Survives page refreshes during auth flow

### 2. Login Component

#### Login Page
The login implementation is in `frontend/src/features/auth/components/LoginPage.tsx` and handles:

**PKCE Parameter Generation:**
```typescript
const handleLogin = async () => {
    // Generate PKCE parameters
    const codeVerifier = generateCodeVerifier()
    const codeChallenge = await generateCodeChallenge(codeVerifier)
    const state = generateState()
    
    // Store verifier for later use
    storePKCEVerifier(codeVerifier, state)
    
    // Build authorization URL
    const authUrl = new URL(`${cognitoDomain}/oauth2/authorize`)
    authUrl.searchParams.append('client_id', clientId)
    authUrl.searchParams.append('response_type', 'code')
    authUrl.searchParams.append('redirect_uri', redirectUri)
    authUrl.searchParams.append('scope', 'openid email profile')
    authUrl.searchParams.append('state', state)
    authUrl.searchParams.append('code_challenge', codeChallenge)
    authUrl.searchParams.append('code_challenge_method', 'S256')
    authUrl.searchParams.append('prompt', 'login')
    
    // Redirect to Cognito
    window.location.href = authUrl.toString()
}
```

**Features:**
- PKCE parameter generation and storage
- Authorization URL construction with proper OAuth parameters
- Redirect to Cognito hosted UI
- Error handling and user feedback
- State parameter generation for CSRF protection

### 3. Callback Handler

#### Callback Page
The callback processing is implemented in `frontend/src/features/auth/components/CallbackPage.tsx`:

**Token Exchange Process:**
```typescript
const processCallback = async () => {
    const code = searchParams.get('code')
    const state = searchParams.get('state')
    
    // Retrieve stored PKCE verifier
    const codeVerifier = getPKCEVerifier(state)
    
    // Exchange code for tokens
    const tokens = await exchangeCodeForTokens({
        code,
        codeVerifier,
        redirectUri: `${window.location.origin}/auth/callback`
    })
    
    // Store tokens in Cognito format
    const username = extractUsernameFromIdToken(tokens.id_token)
    storeCognitoTokens(tokens, username)
    
    // Notify AuthProvider
    window.dispatchEvent(new Event('authSuccess'))
    
    // Navigate to protected route
    navigate('/chat', { replace: true })
}
```

**Implementation Steps:**
1. Extract authorization code and state from URL parameters
2. Retrieve stored PKCE verifier using state parameter
3. Exchange authorization code for tokens using verifier
4. Store tokens in Cognito-compatible format
5. Update authentication state in AuthProvider
6. Redirect to original destination or home page

### 4. Token Exchange

#### Cognito Service
Token exchange functionality is implemented in `frontend/src/services/auth/cognito.ts`:

- POST request to Cognito token endpoint
- Proper parameter encoding for OAuth 2.0
- Error handling for failed token exchanges
- Response validation and token parsing

### 5. Token Storage and Management

#### Token Storage Strategy
Tokens are stored in localStorage using the Cognito SDK format for compatibility:

- **Key Format**: `CognitoIdentityServiceProvider.{clientId}.{username}.{tokenType}`
- **Token Types**: idToken, accessToken, refreshToken
- **User Tracking**: LastAuthUser key for current user identification
- **Expiration**: Token expiration timestamps for refresh logic

#### Token Retrieval
Token retrieval functions in `frontend/src/services/auth/cognito.ts`:

**Session Restoration:**
```typescript
const restoreSessionFromStorage = (): CognitoUserSession | null => {
    const username = getStoredUsername()
    if (!username) return null
    
    const keyPrefix = `CognitoIdentityServiceProvider.${poolData.ClientId}`
    const idToken = localStorage.getItem(`${keyPrefix}.${username}.idToken`)
    const accessToken = localStorage.getItem(`${keyPrefix}.${username}.accessToken`)
    const refreshToken = localStorage.getItem(`${keyPrefix}.${username}.refreshToken`)
    
    // Create Cognito session
    const session = new CognitoUserSession({
        IdToken: new CognitoIdToken({ IdToken: idToken }),
        AccessToken: new CognitoAccessToken({ AccessToken: accessToken }),
        RefreshToken: new CognitoRefreshToken({ RefreshToken: refreshToken })
    })
    
    return session.isValid() ? session : null
}
```

**Features:**
- Get current user from localStorage
- Retrieve tokens for authenticated user
- Validate token presence and format
- Handle missing or expired tokens

### 6. Auth Provider

#### Auth Context
The authentication state management is implemented in `frontend/src/app/providers/AuthProvider.tsx`:

- **Global State**: User information and authentication status
- **Session Restoration**: Check for existing tokens on app initialization
- **Token Refresh**: Automatic token refresh before expiration
- **Logout Handling**: Clear tokens and redirect to Cognito logout

#### Context Interface
The AuthProvider provides:
- User object with profile information
- Loading state for authentication checks
- Authentication status boolean
- Login and logout functions
- Token refresh functionality

### 7. Route Protection

#### Protected Route Guard
Route protection is implemented in `frontend/src/app/router/guards/ProtectedRoute.tsx`:

- **Authentication Check**: Verify user is authenticated
- **Loading State**: Show loading indicator during auth check
- **Redirect Logic**: Redirect to login if not authenticated
- **Return URL**: Store attempted location for post-login redirect

### 8. API Integration

#### Axios Interceptor Configuration
API integration with authentication headers:

- **Request Interceptor**: Add Authorization header with access token
- **Response Interceptor**: Handle 401 responses with token refresh
- **Error Handling**: Redirect to login on authentication failures
- **Retry Logic**: Retry failed requests after token refresh

## Security Features

### 1. PKCE Implementation
- Code verifier must be cryptographically random
- Minimum 43 characters, maximum 128 characters
- Code challenge uses SHA-256 hashing
- State parameter prevents CSRF attacks

### 2. Token Security
- Access tokens expire in 1 hour
- Refresh tokens expire in 30 days
- Tokens stored in localStorage (consider httpOnly cookies for production)
- Automatic token refresh before expiration

### 3. Session Management
- Automatic session restoration on page refresh
- Token validation before use
- Secure logout clearing all tokens
- Session timeout warnings

### 4. Domain Restrictions
- Email domain validation via Lambda (backend)
- Configurable per environment
- Blocks unauthorized domains

## Configuration

### Environment Variables

Required environment variables in `.env`:

```env
# Required Cognito Configuration
VITE_COGNITO_USER_POOL_ID=il-central-1_xxxxxxxxx
VITE_COGNITO_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxx
VITE_COGNITO_HOSTED_UI_DOMAIN=https://your-domain.auth.region.amazoncognito.com

# Backend API (for authenticated requests)
VITE_API_BASE_URL=http://localhost:3001
```

### Cognito User Pool Settings

Required configuration in AWS Cognito:

1. **App Client Settings**
   - Authorization code grant flow ✓
   - Implicit grant flow ✗ (disabled)
   - PKCE enabled (default for public clients)

2. **Callback URLs**
   ```
   Development: http://localhost:3000/auth/callback
   Production: https://app.testmeout.com/auth/callback
   ```

3. **Sign out URLs**
   ```
   Development: http://localhost:3000/
   Production: https://app.testmeout.com/
   ```

4. **OAuth Scopes**
   - openid
   - email
   - profile

## API Integration

### Adding Authentication Headers

After authentication, include the access token in API requests:

- **Axios Interceptor**: Automatically add Authorization header
- **Manual Requests**: Include Bearer token in headers
- **Error Handling**: Handle 401 responses with refresh logic

### Token Refresh

The AuthProvider includes a refresh token method:

- **Automatic Refresh**: Refresh tokens before expiration
- **Manual Refresh**: Call refreshToken() function when needed
- **Error Handling**: Redirect to login if refresh fails
- **State Update**: Update user state after successful refresh

## Error Handling

### Common Error Scenarios

1. **Invalid or Expired Session**
   - Error shown with retry option
   - User redirected to login

2. **Network Errors**
   - Graceful error messages
   - Retry mechanisms

3. **Token Expiration**
   - Automatic refresh attempt
   - Re-authentication if refresh fails

4. **PKCE Verification Failed**
   - Security error message
   - Clear storage and retry login

### Error Display

The CallbackPage includes a user-friendly error screen:

- **Error Messages**: Clear, actionable error descriptions
- **Retry Options**: Buttons to retry authentication
- **Fallback Navigation**: Links to login page
- **Debug Information**: Development-only error details

## Testing Authentication

### Unit Testing

Test key authentication functions:

- **PKCE Generation**: Validate code verifier and challenge creation
- **Token Storage**: Test token storage and retrieval
- **AuthProvider**: Test authentication state management
- **Route Protection**: Test protected route behavior

### Integration Testing

Test the full authentication flow:

- **Login Flow**: Complete OAuth flow with Cognito
- **Callback Processing**: Token exchange and storage
- **API Integration**: Authenticated API requests
- **Session Management**: Token refresh and logout

### E2E Testing

End-to-end authentication testing:

- **Browser Testing**: Test in real browser environment
- **Network Conditions**: Test with various network scenarios
- **Error Scenarios**: Test authentication failures
- **Cross-Browser**: Test in multiple browsers

## Troubleshooting

### Common Issues and Solutions

1. **"redirect_mismatch" Error**
   - **Cause**: Callback URL doesn't match Cognito configuration
   - **Solution**: Ensure callback URLs match exactly in Cognito and frontend

2. **"Invalid or expired authentication session"**
   - **Cause**: PKCE verifier missing or expired
   - **Solution**: Clear browser storage and retry login

3. **Authentication Loop**
   - **Cause**: Token validation failing
   - **Solution**: Check token expiration settings and clock synchronization

4. **Missing User After Login**
   - **Cause**: Session not properly restored
   - **Solution**: Verify token storage keys match Cognito SDK format

### Debug Mode

Enable debug logging:

- **Development Logging**: Console logs for authentication events
- **Token Debugging**: Log token information (without sensitive data)
- **Network Debugging**: Log API requests and responses
- **State Debugging**: Log authentication state changes

### Browser DevTools

Check authentication state:

- **localStorage Inspection**: Check stored tokens
- **Network Tab**: Monitor authentication requests
- **Console Logs**: View authentication debug information
- **Application Tab**: Clear storage for testing

## Best Practices

1. **Always use HTTPS in production** - OAuth requires secure connections
2. **Keep tokens secure** - Never log or expose tokens
3. **Handle errors gracefully** - Show user-friendly error messages
4. **Test token expiration** - Ensure refresh logic works correctly
5. **Monitor authentication metrics** - Track login failures and success rates
6. **Implement proper CORS** - Configure CORS for API requests
7. **Use Content Security Policy** - Add CSP headers for security
8. **Regular security audits** - Review dependencies and configurations

## Migration from Implicit Flow

If migrating from implicit flow to authorization code flow with PKCE:

1. Update Cognito app client settings
2. Implement PKCE parameter generation
3. Add token exchange endpoint call
4. Update token storage logic
5. Test thoroughly in all environments

## Future Enhancements

Planned improvements:

1. **Biometric Authentication** - TouchID/FaceID support
2. **Remember Me** - Optional persistent sessions
3. **Session Timeout Warnings** - Notify users before logout
4. **Device Management** - Track and manage logged-in devices
5. **Social Login** - Additional OAuth providers
6. **Advanced MFA** - Hardware token support
7. **Risk-Based Authentication** - Adaptive authentication
8. **Audit Logging** - Comprehensive security logging

## Related Documentation

- [Backend Authentication](../backend/authentication.md) - Backend JWT validation and security
- [Frontend Setup](./setup-and-deployment.md) - Development environment setup
- [API Integration](./chat-interface.md) - Real-time API communication
- [State Management](./state-management.md) - Application state management

## Implementation Files

### Core Authentication Files
- `frontend/src/app/providers/AuthProvider.tsx` - Authentication context provider
- `frontend/src/features/auth/components/LoginPage.tsx` - Login page implementation
- `frontend/src/features/auth/components/CallbackPage.tsx` - OAuth callback handler
- `frontend/src/features/auth/components/SignupPage.tsx` - Signup page
- `frontend/src/shared/utils/pkce.ts` - PKCE utility functions
- `frontend/src/services/auth/cognito.ts` - Cognito service integration

### Route Protection
- `frontend/src/app/router/guards/ProtectedRoute.tsx` - Route protection component
- `frontend/src/app/router/guards/index.ts` - Guard exports

### Types and Interfaces
- `frontend/src/shared/types/auth.ts` - Authentication type definitions
- `frontend/src/features/auth/types/` - Auth-specific types

### Testing
- `frontend/tests/unit/` - Unit tests for authentication components
- `frontend/tests/integration/` - Integration tests for auth flow
- `frontend/tests/e2e/` - End-to-end authentication tests