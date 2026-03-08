# Frontend Styling System

## Overview

The styling system combines Tailwind CSS utility classes with Ant Design components, providing a flexible and consistent design system with full RTL (Right-to-Left) support for Hebrew localization.

## Technology Stack

### Tailwind CSS
- **Version**: 4.1.11
- **Purpose**: Utility-first CSS framework for rapid UI development
- **RTL Plugin**: tailwindcss-rtl (0.9.0) for bidirectional support

### Ant Design
- **Version**: 5.26.6
- **Purpose**: Enterprise-class UI components
- **Theme**: Customizable design tokens

### PostCSS
- **Purpose**: CSS processing and optimization
- **Plugins**: autoprefixer, tailwindcss

## Configuration

### Tailwind Configuration (`tailwind.config.js`)
```javascript
module.exports = {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  plugins: [
    require('tailwindcss-rtl'),
    require('@tailwindcss/forms'),
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#e6f7ff',
          100: '#bae7ff',
          200: '#91d5ff',
          300: '#69c0ff',
          400: '#40a9ff',
          500: '#1890ff', // Main brand color
          600: '#096dd9',
          700: '#0050b3',
          800: '#003a8c',
          900: '#002766',
        },
        secondary: {
          50: '#f0f5ff',
          100: '#d6e4ff',
          200: '#adc6ff',
          300: '#85a5ff',
          400: '#597ef7',
          500: '#2f54eb',
          600: '#1d39c4',
          700: '#10239e',
          800: '#061178',
          900: '#030852',
        },
        neutral: {
          50: '#fafafa',
          100: '#f5f5f5',
          200: '#e8e8e8',
          300: '#d9d9d9',
          400: '#bfbfbf',
          500: '#8c8c8c',
          600: '#595959',
          700: '#434343',
          800: '#262626',
          900: '#1f1f1f',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        hebrew: ['Heebo', 'Rubik', 'sans-serif'],
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '128': '32rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-in',
        'slide-up': 'slideUp 0.3s ease-out',
        'pulse-slow': 'pulse 3s ease-in-out infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { transform: 'translateY(10px)', opacity: '0' },
          '100%': { transform: 'translateY(0)', opacity: '1' },
        }
      }
    },
  },
}
```

### PostCSS Configuration (`postcss.config.js`)
```javascript
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
```

## Global Styles

### Main Stylesheet (`src/styles/index.css`)
```css
@import 'tailwindcss/base';
@import 'tailwindcss/components';
@import 'tailwindcss/utilities';

/* Custom Base Styles */
@layer base {
  html {
    @apply antialiased;
  }
  
  body {
    @apply text-gray-900 bg-gray-50;
  }
  
  /* Hebrew font when in RTL mode */
  [dir="rtl"] body {
    font-family: 'Heebo', 'Rubik', system-ui, sans-serif;
  }
  
  /* Smooth scrolling */
  html {
    scroll-behavior: smooth;
  }
  
  /* Focus styles */
  *:focus-visible {
    @apply outline-2 outline-offset-2 outline-primary-500;
  }
}

/* Custom Components */
@layer components {
  /* Button variants */
  .btn-primary {
    @apply px-4 py-2 bg-primary-500 text-white rounded-lg 
           hover:bg-primary-600 transition-colors
           focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2;
  }
  
  .btn-secondary {
    @apply px-4 py-2 bg-white text-primary-500 border border-primary-500 rounded-lg
           hover:bg-primary-50 transition-colors
           focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2;
  }
  
  /* Card component */
  .card {
    @apply bg-white rounded-lg shadow-sm border border-gray-200 p-6;
  }
  
  .card-hover {
    @apply card hover:shadow-md transition-shadow cursor-pointer;
  }
  
  /* Form elements */
  .form-label {
    @apply block text-sm font-medium text-gray-700 mb-1;
  }
  
  .form-input {
    @apply w-full px-3 py-2 border border-gray-300 rounded-md
           focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent;
  }
  
  .form-error {
    @apply text-red-600 text-sm mt-1;
  }
}

/* Custom Utilities */
@layer utilities {
  /* Text selection */
  .text-selection {
    @apply selection:bg-primary-200 selection:text-primary-900;
  }
  
  /* Scrollbar styling */
  .scrollbar-thin {
    scrollbar-width: thin;
    scrollbar-color: theme('colors.gray.400') theme('colors.gray.100');
  }
  
  .scrollbar-thin::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }
  
  .scrollbar-thin::-webkit-scrollbar-track {
    @apply bg-gray-100 rounded;
  }
  
  .scrollbar-thin::-webkit-scrollbar-thumb {
    @apply bg-gray-400 rounded hover:bg-gray-500;
  }
}
```

## Ant Design Theme Configuration

### Theme Provider (`src/app/providers/ThemeProvider.tsx`)
```typescript
import { ConfigProvider, theme } from 'antd'
import { useTranslation } from 'react-i18next'
import heIL from 'antd/locale/he_IL'
import enUS from 'antd/locale/en_US'

export const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { i18n } = useTranslation()
  const isRTL = i18n.language === 'he'
  
  const themeConfig = {
    token: {
      // Colors
      colorPrimary: '#1890ff',
      colorSuccess: '#52c41a',
      colorWarning: '#faad14',
      colorError: '#f5222d',
      colorInfo: '#1890ff',
      
      // Typography
      fontFamily: isRTL ? 'Heebo, Rubik, sans-serif' : 'Inter, system-ui, sans-serif',
      fontSize: 14,
      fontSizeHeading1: 38,
      fontSizeHeading2: 30,
      fontSizeHeading3: 24,
      fontSizeHeading4: 20,
      fontSizeHeading5: 16,
      
      // Layout
      borderRadius: 6,
      boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.03), 0 1px 6px -1px rgba(0, 0, 0, 0.02), 0 2px 4px 0 rgba(0, 0, 0, 0.02)',
      
      // Spacing
      marginXS: 8,
      marginSM: 12,
      margin: 16,
      marginMD: 20,
      marginLG: 24,
      marginXL: 32,
      
      // Components
      controlHeight: 40,
      controlHeightSM: 32,
      controlHeightLG: 48,
    },
    algorithm: theme.defaultAlgorithm,
    components: {
      Button: {
        primaryShadow: '0 2px 0 rgba(0, 0, 0, 0.045)',
        defaultBorderColor: '#d9d9d9',
      },
      Input: {
        activeBorderColor: '#40a9ff',
        hoverBorderColor: '#40a9ff',
      },
      Select: {
        controlOutline: 'rgba(24, 144, 255, 0.2)',
      },
      Table: {
        headerBg: '#fafafa',
        rowHoverBg: '#f5f5f5',
      },
      Card: {
        boxShadow: '0 1px 2px 0 rgba(0, 0, 0, 0.03), 0 1px 6px -1px rgba(0, 0, 0, 0.02), 0 2px 4px 0 rgba(0, 0, 0, 0.02)',
      }
    }
  }
  
  return (
    <ConfigProvider
      theme={themeConfig}
      direction={isRTL ? 'rtl' : 'ltr'}
      locale={isRTL ? heIL : enUS}
    >
      {children}
    </ConfigProvider>
  )
}
```

## RTL Support

### RTL Implementation Strategy

#### 1. Automatic Direction Switching
```css
/* Use logical properties for automatic RTL support */
.sidebar {
  @apply ps-4 pe-6; /* padding-start and padding-end */
  @apply ms-auto; /* margin-start auto */
  @apply border-e-2; /* border-end */
}

/* Instead of: */
.sidebar-old {
  @apply pl-4 pr-6; /* padding-left and padding-right */
  @apply ml-auto; /* margin-left */
  @apply border-r-2; /* border-right */
}
```

#### 2. RTL-Aware Components
```typescript
const NavigationItem: React.FC<{ icon: ReactNode; label: string }> = ({ icon, label }) => {
  const { i18n } = useTranslation()
  const isRTL = i18n.language === 'he'
  
  return (
    <div className={`flex items-center gap-3 ${isRTL ? 'flex-row-reverse' : ''}`}>
      <span className="text-lg">{icon}</span>
      <span>{label}</span>
    </div>
  )
}
```

#### 3. Direction-Specific Styles
```css
/* LTR specific styles */
[dir="ltr"] .chat-message {
  @apply rounded-tl-none;
}

/* RTL specific styles */
[dir="rtl"] .chat-message {
  @apply rounded-tr-none;
}

/* Icons that need flipping in RTL */
[dir="rtl"] .directional-icon {
  transform: scaleX(-1);
}
```

## Component Styling Patterns

### 1. Styled Components with Tailwind
```typescript
// Button component with variants
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  children: React.ReactNode
}

const Button: React.FC<ButtonProps> = ({ 
  variant = 'primary', 
  size = 'md', 
  children 
}) => {
  const baseClasses = 'inline-flex items-center justify-center font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2'
  
  const variantClasses = {
    primary: 'bg-primary-500 text-white hover:bg-primary-600 focus:ring-primary-500',
    secondary: 'bg-white text-primary-500 border border-primary-500 hover:bg-primary-50 focus:ring-primary-500',
    ghost: 'text-gray-600 hover:text-gray-900 hover:bg-gray-100 focus:ring-gray-500'
  }
  
  const sizeClasses = {
    sm: 'px-3 py-1.5 text-sm rounded-md',
    md: 'px-4 py-2 text-base rounded-lg',
    lg: 'px-6 py-3 text-lg rounded-lg'
  }
  
  return (
    <button 
      className={`${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]}`}
    >
      {children}
    </button>
  )
}
```

### 2. Combining Tailwind with Ant Design
```typescript
import { Button as AntButton } from 'antd'

const CustomButton: React.FC = () => {
  return (
    <AntButton
      type="primary"
      className="tw-shadow-lg tw-rounded-xl hover:tw-scale-105 tw-transition-transform"
    >
      Click Me
    </AntButton>
  )
}
```

### 3. Dynamic Styling with clsx
```typescript
import clsx from 'clsx'

interface MessageProps {
  type: 'user' | 'assistant' | 'system'
  isLoading?: boolean
}

const Message: React.FC<MessageProps> = ({ type, isLoading }) => {
  const messageClasses = clsx(
    'p-4 rounded-lg max-w-2xl',
    {
      'bg-blue-100 text-blue-900 ms-auto': type === 'user',
      'bg-gray-100 text-gray-900 me-auto': type === 'assistant',
      'bg-yellow-50 text-yellow-800 mx-auto text-center': type === 'system',
      'animate-pulse': isLoading
    }
  )
  
  return <div className={messageClasses}>...</div>
}
```

## Responsive Design

### Breakpoint System
```css
/* Tailwind default breakpoints */
sm: 640px   /* Small devices */
md: 768px   /* Medium devices */
lg: 1024px  /* Large devices */
xl: 1280px  /* Extra large devices */
2xl: 1536px /* 2X large devices */
```

### Responsive Patterns
```typescript
const ResponsiveLayout: React.FC = () => {
  return (
    <div className="container mx-auto px-4 sm:px-6 lg:px-8">
      {/* Mobile: 1 column, Tablet: 2 columns, Desktop: 3 columns */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {/* Cards */}
      </div>
      
      {/* Hide on mobile, show on desktop */}
      <aside className="hidden lg:block">
        {/* Sidebar content */}
      </aside>
      
      {/* Different padding for different screens */}
      <main className="py-4 sm:py-6 lg:py-8">
        {/* Main content */}
      </main>
    </div>
  )
}
```

## Dark Mode Support

### Dark Mode Configuration
```typescript
const DarkModeProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [isDark, setIsDark] = useState(() => {
    return localStorage.getItem('theme') === 'dark' ||
      (!localStorage.getItem('theme') && 
       window.matchMedia('(prefers-color-scheme: dark)').matches)
  })
  
  useEffect(() => {
    if (isDark) {
      document.documentElement.classList.add('dark')
      localStorage.setItem('theme', 'dark')
    } else {
      document.documentElement.classList.remove('dark')
      localStorage.setItem('theme', 'light')
    }
  }, [isDark])
  
  return (
    <DarkModeContext.Provider value={{ isDark, setIsDark }}>
      {children}
    </DarkModeContext.Provider>
  )
}
```

### Dark Mode Styles
```css
/* Tailwind dark mode utilities */
.card {
  @apply bg-white dark:bg-gray-800;
  @apply text-gray-900 dark:text-gray-100;
  @apply border-gray-200 dark:border-gray-700;
}

/* Dark mode specific styles */
@media (prefers-color-scheme: dark) {
  .auto-dark {
    @apply bg-gray-900 text-gray-100;
  }
}
```

## Animation and Transitions

### CSS Animations
```css
/* Custom animations */
@keyframes slideIn {
  from {
    transform: translateX(-100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.animate-slide-in {
  animation: slideIn 0.3s ease-out;
}

/* Tailwind animation utilities */
.message-enter {
  @apply animate-fade-in;
}

.loading-dots {
  @apply animate-pulse;
}
```

### React Transitions
```typescript
import { Transition } from '@headlessui/react'

const Modal: React.FC<{ isOpen: boolean }> = ({ isOpen }) => {
  return (
    <Transition
      show={isOpen}
      enter="transition-opacity duration-300"
      enterFrom="opacity-0"
      enterTo="opacity-100"
      leave="transition-opacity duration-200"
      leaveFrom="opacity-100"
      leaveTo="opacity-0"
    >
      <div className="fixed inset-0 bg-black/50">
        {/* Modal content */}
      </div>
    </Transition>
  )
}
```

## Performance Optimization

### CSS Optimization
1. **Purge unused styles**: Tailwind automatically removes unused styles in production
2. **Critical CSS**: Extract and inline critical CSS
3. **Lazy load non-critical CSS**: Defer loading of non-essential styles

### Bundle Size Management
```javascript
// vite.config.ts
export default {
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'ant-design': ['antd'],
          'tailwind': ['tailwindcss']
        }
      }
    }
  }
}
```

## Best Practices

### Do's
1. Use Tailwind utilities for layout and spacing
2. Use Ant Design components for complex UI elements
3. Use logical properties for RTL support
4. Keep custom CSS minimal
5. Use CSS variables for theming
6. Optimize for performance

### Don'ts
1. Don't mix inline styles with Tailwind classes
2. Don't override Ant Design styles directly
3. Don't use fixed left/right properties (use start/end)
4. Don't create unnecessary custom components
5. Don't ignore accessibility
6. Don't forget responsive design