# Frontend Issues Tracker

This document tracks issues discovered during frontend usage that need to be systematically addressed.

## Issue Categories

### UI/UX Issues
- Chat box is partially off screen
- the chat bubbles are too far from each other they need to be slightly left and right but not at the endges of the screen
- the icons next to the bubbles are not really aligned properly
- when using the RTL mode, it completely breaks, the user icon is on the right and the text is on the left and the other way around for the bot response 


### Functionality Issues
- The session cost is not saved anywhere so it zeroed out after loggin in and out, we can save it in the database and show it in the session details in the header 

### Performance Issues
- [ ] 

### Accessibility Issues
- [ ] 

### Browser Compatibility Issues
- [ ] 

### Mobile/Responsive Issues
- [ ] 

## Issue Template

When adding new issues, use this format:

```markdown
### Issue Title
**Date:** YYYY-MM-DD
**Severity:** Low/Medium/High/Critical
**Browser:** Chrome/Firefox/Safari/Edge
**Device:** Desktop/Mobile/Tablet
**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior:**
Description of what should happen

**Actual Behavior:**
Description of what actually happens

**Additional Notes:**
Any additional context, screenshots, or related issues
```

## Completed Issues

### Issue Title
**Date:** YYYY-MM-DD
**Resolution:** Brief description of how it was fixed
**Files Modified:** List of files that were changed

---

## Notes for Systematic Fixing

When ready to systematically address these issues:

1. **Prioritize by severity** - Critical and High priority issues first
2. **Group by category** - Fix all UI/UX issues together, then functionality, etc.
3. **Test thoroughly** - Ensure fixes don't introduce new issues
4. **Update this document** - Move resolved issues to "Completed Issues" section
5. **Update changelog** - Document fixes in CHANGELOG.md

## Current Focus Areas

- [ ] Authentication flow issues
- [ ] Chat interface problems
- [ ] Document upload/processing issues
- [ ] Navigation and routing problems
- [ ] Form validation issues
- [ ] Error handling improvements
