# React Native Security Checklist

Security considerations specific to React Native mobile applications.

## Secure Storage

- [ ] Sensitive data (tokens, credentials) stored in secure storage, NOT AsyncStorage
  - iOS: Keychain Services (via `react-native-keychain` or `expo-secure-store`)
  - Android: Android Keystore (via `react-native-keychain` or `expo-secure-store`)
- [ ] AsyncStorage used only for non-sensitive preferences
- [ ] No sensitive data stored in plain text on device

## Network Security

- [ ] All API communication uses HTTPS
- [ ] Certificate pinning implemented for critical API endpoints (production)
- [ ] No HTTP fallback allowed in production builds
- [ ] Network requests include proper timeout configuration
- [ ] API responses validated before use (don't trust server responses blindly)

## JavaScript Bundle Protection

- [ ] Source maps disabled in production builds
- [ ] Hermes bytecode compilation enabled (obfuscates JS)
- [ ] No sensitive logic in JavaScript that could be extracted from the bundle
- [ ] API keys in JS bundle are limited-scope (public keys only; secret operations server-side)

## Authentication

- [ ] Biometric authentication uses platform APIs (FaceID, TouchID, Android BiometricPrompt)
- [ ] Auth tokens have appropriate expiration
- [ ] Refresh token rotation implemented
- [ ] Session invalidation works on logout (both client and server)
- [ ] Deep links validated before acting on auth parameters

## Data Handling

- [ ] Clipboard does not contain sensitive data after use
- [ ] Screenshots blocked on sensitive screens (Android: FLAG_SECURE; iOS: limited options)
- [ ] Keyboard caching disabled for sensitive input fields (`autoCorrect={false}`, `secureTextEntry`)
- [ ] No sensitive data in app background snapshot (iOS task switcher)

## Build & Distribution

- [ ] Debug mode disabled in release builds
- [ ] React Native dev menu disabled in production
- [ ] ProGuard / R8 enabled for Android release builds
- [ ] App Transport Security (ATS) not globally disabled on iOS
- [ ] Signing keys stored securely, not in repository

## Third-Party Libraries

- [ ] Native modules from trusted sources only
- [ ] Library permissions reviewed (what device APIs does it access?)
- [ ] Dependencies audited for known vulnerabilities (`npm audit`, `yarn audit`)
- [ ] Unused native modules removed to reduce attack surface
