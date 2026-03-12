# Secrets Scanning Checklist

Verify that no secrets, credentials, or sensitive configuration values are exposed in source code, configuration files, or logs.

## Source Code Scan

- [ ] No hardcoded API keys (AWS, GCP, Azure, third-party services)
- [ ] No hardcoded passwords or connection strings
- [ ] No hardcoded JWT secrets or signing keys
- [ ] No hardcoded OAuth client secrets
- [ ] No hardcoded encryption keys or salts
- [ ] No hardcoded webhook URLs with tokens

## Configuration Files

- [ ] `.env` files are listed in `.gitignore`
- [ ] No secrets in committed configuration files (config.json, settings.yaml)
- [ ] Docker Compose files use environment variables, not inline secrets
- [ ] Infrastructure-as-code (CDK, Terraform) references secret managers, not inline values
- [ ] CI/CD configuration uses secret variables, not inline values

## Runtime Behavior

- [ ] Secrets loaded from environment variables or secret managers (AWS Secrets Manager, SSM Parameter Store)
- [ ] Error messages do not expose secrets or connection strings
- [ ] Logs do not contain tokens, passwords, or API keys
- [ ] Debug output does not dump environment variables
- [ ] Stack traces shown to users do not contain secret values

## Common Patterns to Flag

| Pattern | Risk | Fix |
|---------|------|-----|
| `const API_KEY = "sk-..."` | Hardcoded secret in source | Use `process.env.API_KEY` |
| `password: "admin123"` | Hardcoded credential | Use secret manager |
| `Authorization: Bearer eyJ...` | Token in source/test | Use environment variable |
| `console.log(token)` | Secret in logs | Remove or mask |
| `.env` not in `.gitignore` | Secrets committed to repo | Add to `.gitignore` |
| `aws_secret_access_key` in config | AWS credential in file | Use IAM roles or env vars |
