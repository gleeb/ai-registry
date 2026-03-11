# Mode Testing Validation

## Overview

Guidelines for testing and validating newly created modes to ensure they function correctly and integrate well with the Roo Code ecosystem.

## Validation Checklist

### Configuration Validation

- [ ] Mode slug is unique and follows naming conventions **Priority:** critical
  - Validation: No spaces, lowercase, hyphens only
- [ ] All required fields are present and non-empty **Priority:** critical
  - Fields: slug, name, roleDefinition, groups
- [ ] Avoid large customInstructions blocks in .roomodes **Priority:** critical
  - Validation: Prefer storing substantial mode guidance in XML files under `.roo/rules-[slug]/`. Small, high-level glue text in `customInstructions` is acceptable when needed.
- [ ] File restrictions use valid regex patterns **Priority:** high
  - Test Method: Validate by comparing the regex pattern against the intended file sets; confirm patterns match intended files and avoid overbroad matches.
- [ ] whenToUse clearly differentiates from other modes **Priority:** high
  - Validation: Compare with existing mode descriptions

### Instruction Validation

- [ ] XML files are well-formed and valid
  - Validation: No syntax errors, proper closing tags
- [ ] Instructions follow XML best practices
  - Validation: Semantic tag names, proper nesting
- [ ] Examples avoid runtime implementation details
  - Validation: Examples align with current permissions and constraints
- [ ] File paths in examples are consistent
  - Validation: Use project-relative paths

### Functional Testing

- [ ] Mode appears in mode list
  - Test: Switch to the new mode and verify it loads
- [ ] Permissions work as expected
  - Test: Verify representative actions for each permission category
- [ ] File restrictions are enforced
  - Test: Attempt to edit allowed and restricted files
- [ ] Mode handles edge cases gracefully
  - Test: Test with minimal input, errors, edge cases

## Testing Workflow

### Step 1

**Title:** Configuration Testing

**Actions:**

- Verify mode appears in available modes list
- Check that mode metadata displays correctly
- Confirm mode can be activated

**Verification:** Confirm via user feedback. If unclear, ask a focused clarifying question with options like: "Visible and switchable", "Not visible", or "Visible but errors".

### Step 2

**Title:** Permission Testing

**Test Cases:**

- **read_permissions:** Verify read access works for representative files
  - **Expected:** All read operations should work
- **edit_restrictions:** Try editing allowed file types
  - **Expected:** Edits succeed for matching patterns
- **edit_restrictions_negative:** Try editing restricted file types
  - **Expected:** An explicit permission/restriction error for non-matching files

### Step 3

**Title:** Workflow Testing

**Actions:**

- Execute main workflow from start to finish
- Test each decision point
- Verify error handling
- Check completion criteria

### Step 4

**Title:** Integration Testing

**Areas:**

- Orchestrator mode compatibility
- Mode switching functionality
- Capability handoff between modes
- Consistent behavior with other modes

## Common Issues

### Configuration

**Problem:** Mode doesn't appear in list

**Causes:**

- Syntax error in YAML
- Invalid mode slug
- File not saved

**Solution:** Check YAML syntax, validate slug format

### Permissions

**Problem:** File restriction not working

**Causes:**

- Invalid regex pattern
- Escaping issues in regex
- Wrong file path format

**Solution:** Test regex pattern, use proper escaping

**Example:**

```
# Wrong: *.ts (glob pattern)

# Right: .*\.ts$ (regex pattern)
```

### Behavior

**Problem:** Mode not following instructions

**Causes:**

- Instructions not in .roo/rules-[slug]/ folder
- XML parsing errors
- Conflicting instructions

**Solution:** Verify file locations and XML validity

## Debugging Practices

- **Directory/file inventory**
  - **Usage:** Verify instruction files exist in the correct location
  - **Guidance:** Check the .roo directory structure and ensure the expected rules-[slug] folder and XML files exist.

- **Configuration review**
  - **Usage:** Check mode configuration syntax
  - **Guidance:** Review .roomodes to validate YAML structure and entries for the target mode.

- **Regex validation**
  - **Usage:** Test file restriction patterns
  - **Guidance:** Use targeted checks conceptually to confirm fileRegex patterns match intended files and exclude others.

## Best Practices

- Test incrementally as you build the mode
- Start with minimal configuration and add complexity
- Document any special requirements or dependencies
- Consider edge cases and error scenarios
- Get feedback from potential users of the mode
