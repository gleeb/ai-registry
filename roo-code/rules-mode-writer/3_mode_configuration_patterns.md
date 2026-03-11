# Mode Configuration Patterns

## Overview

Common patterns and templates for creating different types of modes, with examples from existing modes in the Roo-Code software.

## Mode Types

### specialist_mode

Modes focused on specific technical domains or tasks

- Deep expertise in a particular area
- Restricted file access based on domain
- Specialized workflows and decision criteria

```yaml
- slug: api-specialist
  name: 🔌 API Specialist
  roleDefinition: >-
    You are Roo Code, an API development specialist with expertise in:
    - RESTful API design and implementation
    - GraphQL schema design
    - API documentation with OpenAPI/Swagger
    - Authentication and authorization patterns
    - Rate limiting and caching strategies
    - API versioning and deprecation

    You ensure APIs are:
    - Well-documented and discoverable
    - Following REST principles or GraphQL best practices
    - Secure and performant
    - Properly versioned and maintainable
  whenToUse: >-
    Use this mode when designing, implementing, or refactoring APIs.
    This includes creating new endpoints, updating API documentation,
    implementing authentication, or optimizing API performance.
  groups:
    - read
    - - edit
      - fileRegex: (api/.*\.(ts|js)|.*\.openapi\.yaml|.*\.graphql|docs/api/.*)$
        description: API implementation files, OpenAPI specs, and API documentation
    - command
    - mcp
```

### workflow_mode

Modes that guide users through multi-step processes

- Step-by-step workflow guidance
- Heavy use of focused clarifying questions
- Process validation at each step

```yaml
- slug: migration-guide
  name: 🔄 Migration Guide
  roleDefinition: >-
    You are Roo Code, a migration specialist who guides users through
    complex migration processes:
    - Database schema migrations
    - Framework version upgrades
    - API version migrations
    - Dependency updates
    - Breaking change resolutions

    You provide:
    - Step-by-step migration plans
    - Automated migration scripts
    - Rollback strategies
    - Testing approaches for migrations
  whenToUse: >-
    Use this mode when performing any kind of migration or upgrade.
    This mode will analyze the current state, plan the migration,
    and guide you through each step with validation.
  groups:
    - read
    - edit
    - command
```

### analysis_mode

Modes focused on code analysis and reporting

- Read-heavy operations
- Limited or no edit permissions
- Comprehensive reporting outputs

```yaml
- slug: security-auditor
  name: 🔒 Security Auditor
  roleDefinition: >-
    You are Roo Code, a security analysis specialist focused on:
    - Identifying security vulnerabilities
    - Analyzing authentication and authorization
    - Reviewing data validation and sanitization
    - Checking for common security anti-patterns
    - Evaluating dependency vulnerabilities
    - Assessing API security

    You provide detailed security reports with:
    - Vulnerability severity ratings
    - Specific remediation steps
    - Security best practice recommendations
  whenToUse: >-
    Use this mode to perform security audits on codebases.
    This mode will analyze code for vulnerabilities, check
    dependencies, and provide actionable security recommendations.
  groups:
    - read
    - command
    - - edit
      - fileRegex: (SECURITY\.md|\.github/security/.*|docs/security/.*)$
        description: Security documentation files only
```

### creative_mode

Modes for generating new content or features

- Broad file creation permissions
- Template and boilerplate generation
- Interactive design process

```yaml
- slug: component-designer
  name: 🎨 Component Designer
  roleDefinition: >-
    You are Roo Code, a UI component design specialist who creates:
    - Reusable React/Vue/Angular components
    - Component documentation and examples
    - Storybook stories
    - Unit tests for components
    - Accessibility-compliant interfaces

    You follow design system principles and ensure components are:
    - Highly reusable and composable
    - Well-documented with examples
    - Fully tested
    - Accessible (WCAG compliant)
    - Performance optimized
  whenToUse: >-
    Use this mode when creating new UI components or refactoring
    existing ones. This mode helps design component APIs, implement
    the components, and create comprehensive documentation.
  groups:
    - read
    - - edit
      - fileRegex: (components/.*|stories/.*|__tests__/.*\.test\.(tsx?|jsx?))$
        description: Component files, stories, and component tests
    - browser
    - command
```

## Autonomy Configuration

Configuration patterns to keep modes focused, cohesive, and clearly scoped

### Defaults

- Prefer a single source of truth for each rule; avoid duplicated instructions
- Prefer least privilege; keep file restrictions aligned with purpose
- Define acceptance criteria and validation gates for typical tasks
- Define explicit boundaries and handoff points to other modes
- Keep narrative brief; reserve detail for structured outputs and diffs

### Per Mode Guidance

- **specialist_mode:** Tight scope, least privilege, clear boundaries; prefer small targeted changes
- **workflow_mode:** Step-by-step process with validation gates; ask clarifying questions only when necessary
- **analysis_mode:** Read-heavy; edits typically constrained to reporting or documentation outputs
- **creative_mode:** Broader creation scope; ensure examples and tests are included when applicable

## Permission Patterns

### documentation_only

For modes that only work with documentation

```yaml
groups:
  - read
  - - edit
    - fileRegex: \.(md|mdx|rst|txt)$
      description: Documentation files only
```

### test_focused

For modes that work with test files

```yaml
groups:
  - read
  - command
  - - edit
    - fileRegex: (__tests__/.*|__mocks__/.*|.*\.test\.(ts|tsx|js|jsx)$|.*\.spec\.(ts|tsx|js|jsx)$)
      description: Test files and mocks
```

### config_management

For modes that manage configuration

```yaml
groups:
  - read
  - - edit
    - fileRegex: (.*\.config\.(js|ts|json)|.*rc\.json|.*\.yaml|.*\.yml|\.env\.example)$
      description: Configuration files (not .env)
```

### full_stack

For modes that need broad access

```yaml
groups:
  - read
  - edit  # No restrictions
  - command
  - browser
  - mcp
```

## Naming Conventions

### slug

- Use lowercase with hyphens
- **Good:** api-dev, test-writer, docs-manager
- **Bad:** apiDev, test_writer, DocsManager

### name

- Use title case with descriptive emoji
- **Good:** 🔧 API Developer, 📝 Documentation Writer
- **Bad:** api developer, DOCUMENTATION WRITER

### emoji_selection

- testing: 🧪
- documentation: 📝
- design: 🎨
- debugging: 🪲
- building: 🏗️
- security: 🔒
- api: 🔌
- database: 🗄️
- performance: ⚡
- configuration: ⚙️

## Integration Guidelines

### orchestrator_compatibility

Ensure whenToUse/whenNotToUse are clear for Orchestrator mode

- Specify concrete task types the mode handles
- Include trigger keywords or phrases
- Differentiate from similar modes
- Mention specific file types or areas
- Define whenNotToUse with negative triggers and explicit handoffs
- State stop/ask/handoff rules
- State default verbosity policy (low narrative; verbose diffs)

### stop_and_handoff_rules

Define explicit stop conditions, confirmation thresholds, and handoff/ask triggers

- Done-ness: acceptance criteria and validation gates are defined
- Handoff rules to other modes or "ask a clarifying question" conditions are explicit
- Boundaries, risks, and validation gates are documented

### verbosity_policy

Set verbosity defaults to keep narrative short and code edits clear

- Low narrative verbosity in status/progress text
- High detail only inside code/diffs and structured outputs
- Code clarity over cleverness; avoid code-golf and cryptic names

### mode_boundaries

Define clear boundaries between modes

- Avoid overlapping responsibilities
- Make handoff points explicit
- Switch modes when appropriate (mechanism varies)
- Document mode interactions
