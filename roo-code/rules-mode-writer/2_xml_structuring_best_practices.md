# XML Structuring Best Practices

## Overview

XML tags help LLMs parse prompts more accurately, leading to higher-quality outputs.
This guide covers best practices for structuring mode instructions using XML.

## Why Use XML Tags

- **Clarity:** Clearly separate different parts of your instructions and ensure well-structured content
- **Accuracy:** Reduce errors caused by the model misinterpreting parts of your instructions
- **Flexibility:** Easily find, add, remove, or modify parts of instructions without rewriting everything
- **Parseability:** Having the model use XML tags in its output makes it easier to extract specific parts of responses

## Core Principles

### Consistency

Use the same tag names throughout your instructions

**Example:** Always use <step> for workflow steps, not sometimes <action> or <task>

### Semantic Naming

Tag names should clearly describe their content

**Good examples:** detailed_steps, error_handling, validation_rules

**Bad examples:** stuff, misc, data1

### Hierarchical Nesting

Nest tags to show relationships and structure

**Example:**

```xml
<workflow>
  <phase name="preparation">
    <step>Gather requirements</step>
    <step>Validate inputs</step>
  </phase>
  <phase name="execution">
    <step>Process data</step>
    <step>Generate output</step>
  </phase>
</workflow>
```

## Common Tag Patterns

### Workflow Structure

**Usage:** For step-by-step processes

**Template:**

```xml
<workflow>
  <overview>High-level description</overview>
  <prerequisites>
    <prerequisite>Required condition 1</prerequisite>
    <prerequisite>Required condition 2</prerequisite>
  </prerequisites>
  <steps>
    <step number="1">
      <title>Step Title</title>
      <description>What this step accomplishes</description>
      <actions>
        <action>Specific action to take</action>
      </actions>
      <validation>How to verify success</validation>
    </step>
  </steps>
</workflow>
```

### Examples Structure

**Usage:** For providing code examples and demonstrations

**Template:**

```xml
<examples>
  <example name="descriptive_name">
    <description>What this example demonstrates</description>
    <context>When to use this approach</context>
    <code language="typescript">
      // Your code example here
    </code>
    <explanation>
      Key points about the implementation
    </explanation>
  </example>
</examples>
```

### Guidelines Structure

**Usage:** For rules and best practices

**Template:**

```xml
<guidelines category="category_name">
  <guideline priority="high">
    <rule>The specific rule or guideline</rule>
    <rationale>Why this is important</rationale>
    <exceptions>When this doesn't apply</exceptions>
  </guideline>
</guidelines>
```

### Decision Guidance Structure

**Usage:** For documenting decision criteria and guardrails

**Template:**

```xml
<decision_guidance>
  <principles>
    <principle>Do not include runtime implementation details (no function names, command names, UI entry points, or execution syntax)</principle>
    <principle>Prefer the smallest change that satisfies the request</principle>
    <principle>Prefer a single source of truth; avoid duplicated rules across files</principle>
    <principle>Ask a clarifying question only when critical ambiguity remains</principle>
  </principles>

  <constraints>
    Constraints and guardrails (e.g., permissions, file restrictions, or other limits).
  </constraints>

  <validation>
    What to verify after changes (cohesion, examples updated, boundaries clear).
  </validation>
</decision_guidance>
```

## Formatting Guidelines

- **Indentation:** Use consistent indentation (2 or 4 spaces) for nested elements
- **Line breaks:** Add line breaks between major sections for readability
- **Comments:** Use XML comments <!-- like this --> to explain complex sections
- **CDATA sections:** Use CDATA for code blocks or content with special characters: `your code here`
- **Attributes vs elements:** Use attributes for metadata, elements for content. Example (good): `<step number="1" priority="high">` with `<description>The actual step content</description>`
- **Verbosity:** Keep narrative outputs concise; reserve detailed exposition for code, diffs, and structured outputs. Prefer readable, maintainable code with clear names; avoid one-liners unless explicitly requested.

## Anti Patterns

### Flat Structure

**Description:** Avoid completely flat structures without hierarchy

**Bad:**

```xml
<instructions>

<item1>Do this</item1>

<item2>Then this</item2>

<item3>Finally this</item3>

</instructions>
```

**Good:**

```xml
<instructions>
  <steps>
    <step order="1">Do this</step>
    <step order="2">Then this</step>
    <step order="3">Finally this</step>
  </steps>
</instructions>
```

### Inconsistent Naming

**Description:** Don't mix naming conventions

**Bad:** Mixing camelCase, snake_case, and kebab-case in tag names

**Good:** Pick one convention (preferably snake_case for XML) and stick to it

### Overly Generic Tags

**Description:** Avoid tags that don't convey meaning

**Bad:** data, info, stuff, thing, item

**Good:** user_input, validation_result, error_message, configuration

### Over Clarifying Questions

**Description:** Avoid asking the user to confirm obvious next steps on straightforward tasks

**Bad:** Asking multiple clarifying questions before acting when the task is simple

**Good:** Proceed when next steps are clear; ask only when critical ambiguity remains; document assumptions

### Excessive Searching

**Description:** Avoid repetitive or redundant searches when the relevant target is already identified

**Bad:** Running multiple identical searches instead of acting

**Good:** Stop once the change is clearly identified; then implement

### Over Specifying Runtime Behavior

**Description:** Avoid duplicating runtime behavior that is already defined elsewhere

**Bad:** Documenting execution constraints, operation ordering, or invocation details

**Good:** Focus on intent, artifacts, decision criteria, and validation expectations

## Integration Tips

- Reference XML content in instructions: "Using the workflow defined in &lt;workflow&gt; tags..."
- Combine XML structure with other techniques like multishot prompting
- Use XML tags in expected outputs to make parsing easier
- Create reusable XML templates for common patterns
