# Internationalization (i18n) Documentation

## Overview

The application supports full internationalization with Hebrew and English languages. The implementation uses react-i18next for translation management and automatic language detection. For comprehensive RTL (Right-to-Left) layout implementation details, see [RTL Hebrew Support](./rtl-hebrew-support.md).

## Technology Stack

- **react-i18next**: ^15.6.1 - React bindings for i18next
- **i18next**: ^25.3.2 - Core internationalization framework
- **i18next-browser-languagedetector**: ^8.2.0 - Automatic language detection

## Configuration

### i18n Setup
The main i18n configuration is located in `frontend/src/locales/i18n.ts` and includes:
- Language detection from localStorage and browser preferences
- Resource loading for Hebrew and English translations
- Development debug mode configuration
- Fallback language handling

## Translation Structure

### Translation Files
Translation files are organized by language code:
- **English**: `frontend/src/locales/en/translation.json`
- **Hebrew**: `frontend/src/locales/he/translation.json`

Each translation file contains structured JSON with nested keys for different application sections:

- **common**: Basic UI elements (buttons, labels, actions)
- **navigation**: Menu and routing labels
- **auth**: Authentication-related messages
- **chat**: Chat interface text and status messages
- **documents**: Document management interface
- **validation**: Form validation messages
- **errors**: Error handling messages

### Key Features
- **Interpolation**: Support for dynamic values using `{{variable}}` syntax
- **Nested Keys**: Hierarchical organization for better maintainability
- **Pluralization**: Automatic plural forms for Hebrew and English
      "reconnecting": "מתחבר מחדש..."
    },
    "errors": {
      "sendFailed": "שליחת ההודעה נכשלה",
      "connectionLost": "החיבור אבד. מנסה להתחבר מחדש...",
      "modelUnavailable": "המודל שנבחר אינו זמין כרגע"
    }
## Language Switching

### Language Switcher Component
The language switching functionality is implemented in `frontend/src/shared/components/LanguageSwitcher.tsx` and provides:
- Language selection dropdown with native language names
- Automatic RTL switching for Hebrew
- Persistent language preference storage
- Document-level language and direction updates

See [RTL Hebrew Support](./rtl-hebrew-support.md) for detailed RTL implementation.

## Using Translations

### Basic Usage
Translation usage is implemented throughout the application using the `useTranslation` hook from react-i18next. See component files in `frontend/src/features/` for usage examples.

### Translation Keys
Translation keys follow a hierarchical structure organized by feature area. See the translation files for the complete key structure.

### Advanced Features

#### Pluralization
The translation system supports automatic pluralization for both English and Hebrew. Plural forms are defined in the translation files with `_one`, `_other`, and `_zero` suffixes.

#### Interpolation
Dynamic values can be inserted into translations using the `{{variable}}` syntax. This supports both simple string interpolation and complex formatting.

#### Nested Keys
Translation keys are organized hierarchically and can be accessed using dot notation for better organization and maintainability.

## RTL Support

For comprehensive RTL implementation details, see [RTL Hebrew Support](./rtl-hebrew-support.md).

## Date and Number Formatting

### Internationalization Formatting
The application uses JavaScript's built-in `Intl` API for locale-aware formatting of dates, numbers, and currencies. Implementation examples can be found in various components throughout `frontend/src/features/`.

## Language Detection

### Detection Order
1. **localStorage**: Check for saved preference
2. **Navigator**: Browser language setting
3. **HTML Tag**: Document language attribute
4. **Fallback**: Default to English

### Custom Detection
Language detection can be customized beyond the default browser and localStorage detection. Custom detection logic can be implemented for domain-based language selection or user profile integration.

## Advanced Features

### Dynamic Loading
The application supports dynamic translation loading and namespace management for performance optimization. Implementation details can be found in the i18n configuration file.

### Integration with Backend
Language preferences can be synchronized with user profile data stored in the backend database for consistent experience across sessions.

## Testing

### Testing Internationalization
Testing for internationalization features should cover language switching, translation key coverage, and RTL layout behavior. Test implementations can be found in `frontend/tests/` directory.

## Best Practices

### Do's
1. Keep translation keys hierarchical and semantic
2. Use interpolation for dynamic values
3. Implement proper RTL support with logical properties
4. Cache language preference
5. Provide fallback translations
6. Test all languages

### Don'ts
1. Don't hardcode text in components
2. Don't use language-specific CSS classes
3. Don't forget to escape HTML in translations
4. Don't mix languages in the same view
5. Don't assume text direction
6. Don't ignore cultural differences