# Complete Examples

## Overview

Canonical examples for creating and editing Roo Code modes. Each example demonstrates structured workflows, least-privilege configuration, contradiction resolution, and completion formatting, without referencing runtime implementation details.

## Mode Editing Enhancement

### Scenario

Edit the Test mode to add benchmark testing and performance guidance using Vitest's bench API.

### User Request

I want to edit the test mode to add benchmark testing support.

### Workflow

### Step 1

**Description:** Clarify scope and features

**Guidance:** Ask the user a focused clarifying question to confirm which scope/features to include; provide 2–4 actionable options. Outcome: selected scope.

**Expected Outcome:** User selects: Add benchmark testing with Vitest bench API

### Step 2

**Description:** Immerse in current mode config and instructions

**Guidance:** Review .roomodes, inventory .roo/rules-test recursively, and review .roo/rules-test/1_workflow.xml. Outcome: confirm roleDefinition, file restrictions, and existing workflows.

**Analysis:** Confirm roleDefinition, file restrictions, and existing workflows.

### Step 3

**Description:** Update roleDefinition in .roomodes

**Guidance:** Edit .roomodes to update the roleDefinition, adding benchmark testing and performance guidance topics. Outcome: roleDefinition updated to include performance/bench themes.

### Step 4

**Description:** Extend file restrictions to include .bench files

**Guidance:** Edit .roomodes to extend the fileRegex to include .bench.(ts|tsx|js|jsx) and update the description accordingly. Outcome: file restrictions now cover benchmark files.

### Step 5

**Description:** Create benchmark guidance file

**Guidance:** Create a new file at .roo/rules-test/5_benchmark_testing.xml with guidance and examples. Outcome: new guidance file available to the mode.

**Artifact Sample:**

Guidelines for performance benchmarks using Vitest bench API

**Basic structure:**

```
import { bench, describe } from 'vitest';


describe('Array operations', () => {
  bench('Array.push', () => {
    const arr: number[] = [];
    for (let i = 0; i < 1000; i++) arr.push(i);
  });

  bench('Array spread', () => {
    let arr: number[] = [];
    for (let i = 0; i < 1000; i++) arr = [...arr, i];
  });
});
```

**Best practices:**

- Use meaningful names and isolate benchmarks
- Document expectations and thresholds

### Completion

Provide a concise summary of what was accomplished and how it addresses the user's request.

### Key Takeaways

- Important lesson from this example
- Pattern that can be reused
