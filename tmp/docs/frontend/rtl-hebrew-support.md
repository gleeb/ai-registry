# RTL Hebrew Support

## Overview

The Legal Information System provides comprehensive Right-to-Left (RTL) support for Hebrew language users, ensuring proper text direction, layout mirroring, and culturally appropriate user interface elements.

## RTL Implementation Architecture

### Core Components
- **ThemeProvider**: Main RTL configuration and direction management (see `frontend/src/app/providers/ThemeProvider.tsx`)
- **Language Detection**: Automatic RTL activation based on selected language (see `frontend/src/locales/i18n.ts`)
- **Component-Level RTL**: Individual component RTL handling (various components in `frontend/src/features/`)

### Direction Management Flow
1. User selects Hebrew language via `LanguageSwitcher` component
2. `ThemeProvider` detects language change and sets RTL configuration
3. Document direction is updated at the HTML level
4. Ant Design components automatically mirror layout
5. Custom components apply RTL-specific styling

## Language Configuration

### Supported Languages
- **English (en)**: Left-to-Right (LTR) - Default
- **Hebrew (he)**: Right-to-Left (RTL)

### Translation Files
- English: `frontend/src/locales/en/translation.json`
- Hebrew: `frontend/src/locales/he/translation.json`

### i18n Configuration
The internationalization setup is managed in `frontend/src/locales/i18n.ts` with:
- Language detection from localStorage and browser preferences
- Fallback language configuration
- Resource loading for both languages

## RTL Implementation Details

### Document-Level RTL
Reference implementation in `ThemeProvider.tsx` lines 16-20:
- Sets `document.documentElement.dir` to 'rtl' or 'ltr'
- Updates `document.documentElement.lang` for accessibility
- Configures Ant Design's direction prop

### Font Configuration
Hebrew-specific font stack is applied when RTL is active:
- Primary: "Heebo" - Modern Hebrew font
- Secondary: "Rubik" - Supporting Hebrew font
- Fallback: System fonts with Hebrew support

### Ant Design RTL Integration
The application uses Ant Design's built-in RTL support:
- `ConfigProvider` direction prop automatically mirrors components
- Hebrew locale (`heIL`) is applied for date/time formatting
- Component layouts automatically reverse for RTL

## Component-Specific RTL Implementation

### Chat Interface RTL
Reference `frontend/src/features/chat/components/`:

#### Message Bubbles (`MessageBubble.tsx`)
- User messages align to the right in RTL (left in LTR)
- Assistant messages align to the left in RTL (right in LTR)
- Avatar positioning mirrors based on text direction
- Text alignment adjusts dynamically

#### Chat Input (`ChatInput.tsx`)
- Input direction set via `dir` attribute
- Send button icon rotates 180° for RTL (arrow direction)
- Placeholder text displays correctly in Hebrew

#### Layout Mirroring
- Flex direction reversal for message containers
- Icon rotation for directional elements
- Spacing and margins adjust automatically

### Navigation RTL
Reference `frontend/src/shared/components/`:

#### Language Switcher (`LanguageSwitcher.tsx`)
- Displays native language names (עברית for Hebrew)
- Icon positioning adjusts for RTL
- Dropdown alignment follows text direction

#### Main Layout (`Layout/MainLayout.tsx`)
- Navigation menu positioning mirrors
- Content area maintains proper RTL flow
- Sidebar placement adjusts for RTL

## CSS and Styling

### RTL-Aware CSS Classes
Custom CSS in `frontend/src/styles/index.css` includes RTL-specific rules:

#### Thought Process RTL Styling (lines 78-81)
- Border direction switches from left to right
- Padding adjusts for RTL text flow
- Border radius adapts to RTL layout

#### Message Bubble RTL Support
- Error indicators position correctly in RTL
- Border styling mirrors for Hebrew text
- Content alignment follows text direction

### Tailwind CSS RTL Support
The application leverages Tailwind's RTL utilities:
- `rtl:` prefix for RTL-specific styles
- Automatic margin/padding mirroring
- Text alignment utilities work with direction

## Development Guidelines

### Adding New RTL-Aware Components

1. **Check Language Direction**
   ```typescript
   const { i18n } = useTranslation()
   const isRTL = i18n.language === 'he'
   ```

2. **Apply Conditional Styling**
   - Use `isRTL` boolean for conditional classes
   - Apply `dir` attribute for text inputs
   - Mirror flex directions when needed

3. **Icon Handling**
   - Rotate directional icons (arrows, chevrons)
   - Position icons based on text direction
   - Use appropriate RTL-aware icon sets

4. **Layout Considerations**
   - Test with long Hebrew text
   - Ensure proper text wrapping
   - Validate spacing and alignment

### Translation Best Practices

1. **Text Length Variations**
   - Hebrew text can be 20-30% longer than English
   - Design flexible layouts that accommodate text expansion
   - Test with actual Hebrew translations, not placeholder text

2. **Cultural Considerations**
   - Use appropriate Hebrew terminology for legal context
   - Consider formal vs. informal Hebrew based on context
   - Validate translations with native Hebrew speakers

3. **Placeholder and Helper Text**
   - Provide meaningful Hebrew placeholders
   - Ensure error messages are culturally appropriate
   - Use proper Hebrew punctuation and formatting

## Testing RTL Implementation

### Manual Testing Checklist
1. **Language Switching**
   - Switch between English and Hebrew
   - Verify immediate layout changes
   - Check localStorage persistence

2. **Component Behavior**
   - Test all interactive elements
   - Verify text input behavior
   - Check dropdown and modal positioning

3. **Content Flow**
   - Verify reading order in Hebrew
   - Check tab navigation direction
   - Test keyboard navigation

### Automated Testing
Reference test files in `frontend/tests/`:
- Component rendering tests for both languages
- RTL layout snapshot testing
- Translation key coverage validation

## Browser Compatibility

### Supported Browsers
- Chrome/Edge: Full RTL support
- Firefox: Full RTL support
- Safari: Full RTL support with minor adjustments

### Known Issues and Workarounds
- Some CSS animations may need RTL-specific adjustments
- Third-party components may require custom RTL handling
- Print styles should be tested separately for RTL

## Performance Considerations

### Font Loading
Hebrew fonts are loaded conditionally to optimize performance:
- Fonts load only when Hebrew is selected
- Font display: swap for better perceived performance
- Preload critical Hebrew fonts for faster switching

### Translation Loading
- Translations are bundled but can be lazy-loaded
- Consider splitting large translation files
- Cache translations in localStorage

## Accessibility (A11y) with RTL

### Screen Reader Support
- `dir` attribute properly set for screen readers
- `lang` attribute updated for language detection
- ARIA labels provided in appropriate language

### Keyboard Navigation
- Tab order follows RTL reading pattern
- Arrow key navigation mirrors for RTL
- Focus indicators position correctly

## Future RTL Enhancements

### Planned Improvements
1. **Additional Language Support**
   - Arabic language support
   - Persian/Farsi support consideration
   - Mixed LTR/RTL content handling

2. **Enhanced Typography**
   - Better Hebrew font selection
   - Typography scale optimization for Hebrew
   - Line-height adjustments for Hebrew text

3. **Advanced RTL Features**
   - Bi-directional text support (mixed content)
   - RTL-aware animations
   - Context-sensitive text direction

### Development Roadmap
- Phase 1: Current implementation (Complete)
- Phase 2: Enhanced typography and fonts (Planned)
- Phase 3: Additional RTL languages (Future)
- Phase 4: Advanced bi-directional features (Future)

## Troubleshooting RTL Issues

### Common Problems
1. **Layout Breaking**: Check flex direction and alignment
2. **Icons Not Rotating**: Verify transform styles are applied
3. **Text Input Issues**: Ensure `dir` attribute is set
4. **Font Loading**: Check Hebrew font availability

### Debug Tools
- Browser DevTools for RTL inspection
- React DevTools for component state
- i18n debug mode for translation issues

### Support Resources
- Ant Design RTL documentation
- React i18next RTL guides
- CSS logical properties for RTL support