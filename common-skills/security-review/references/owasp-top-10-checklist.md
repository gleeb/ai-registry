# OWASP Top 10 Review Checklist

Review implementation against the OWASP Top 10 (2021) categories relevant to the task. Not every category applies to every task — focus on the ones that match the code being reviewed.

## A01: Broken Access Control

- [ ] Every protected endpoint has server-side authorization checks
- [ ] Users cannot act outside their intended permissions
- [ ] CORS is configured to allow only expected origins
- [ ] Directory listing is disabled on file-serving endpoints
- [ ] JWT tokens are validated for signature, expiration, and issuer
- [ ] Access control defaults to deny

## A02: Cryptographic Failures

- [ ] Sensitive data is encrypted at rest and in transit
- [ ] No deprecated algorithms (MD5, SHA1 for security, DES)
- [ ] TLS is enforced for all external communication
- [ ] Passwords are hashed with bcrypt/scrypt/argon2, not plain SHA/MD5
- [ ] Encryption keys are not hardcoded

## A03: Injection

- [ ] SQL queries use parameterized statements or ORM
- [ ] User input is never interpolated into commands (OS, LDAP, XPath)
- [ ] Template rendering uses auto-escaping
- [ ] GraphQL queries have depth/complexity limits

## A04: Insecure Design

- [ ] Threat model exists for security-critical flows (from plan/security.md)
- [ ] Rate limiting on authentication and sensitive endpoints
- [ ] Business logic abuse scenarios considered

## A05: Security Misconfiguration

- [ ] No default credentials in configuration
- [ ] Error messages do not expose stack traces or internal details to users
- [ ] Unnecessary features/endpoints are disabled
- [ ] Security headers are set (CSP, X-Frame-Options, X-Content-Type-Options)

## A06: Vulnerable and Outdated Components

- [ ] Dependencies are recent versions without known CVEs
- [ ] No unnecessary dependencies included
- [ ] Lock files (package-lock.json, yarn.lock) are committed

## A07: Identification and Authentication Failures

- [ ] Brute force protection on login (rate limiting, account lockout)
- [ ] Session tokens are invalidated on logout
- [ ] Password requirements meet minimum standards
- [ ] Multi-factor authentication supported where appropriate

## A08: Software and Data Integrity Failures

- [ ] CI/CD pipeline verifies integrity of dependencies
- [ ] Deserialization of untrusted data is avoided or validated
- [ ] Code and data are verified before execution

## A09: Security Logging and Monitoring Failures

- [ ] Authentication events are logged (login, logout, failed attempts)
- [ ] Authorization failures are logged
- [ ] Logs do not contain sensitive data (passwords, tokens, PII)
- [ ] Log injection is prevented (user input sanitized before logging)

## A10: Server-Side Request Forgery (SSRF)

- [ ] URLs from user input are validated against allowlists
- [ ] Internal network access from user-supplied URLs is blocked
- [ ] Redirect responses are not blindly followed
