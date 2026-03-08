# React Native (Mobile — Expo)

Use Expo for mobile apps targeting iOS, Android, and optionally web from a single codebase. Expo is the recommended approach for all new React Native projects in 2026.

## Decision: Managed vs Bare

| Scenario | Workflow |
|----------|----------|
| Most projects, prototypes, standard features | **Managed** (default) |
| Custom native modules (Swift/Kotlin), advanced native SDK | **Bare** or CNG with config plugins |

Start with managed workflow; eject later only if needed via `npx expo prebuild`.

## Scaffold

```bash
npx create-expo-app@latest <app-name>
cd <app-name>
```

For a **bare-minimum** template (includes native dirs immediately):

```bash
npx create-expo-app@latest <app-name> --template bare-minimum
```

## Platform Prerequisites

Before running the app on a device or simulator, the native toolchains must be installed.

### iOS (macOS only)

```bash
xcode-select --install              # Xcode command-line tools
sudo gem install cocoapods           # Or use Bundler (preferred):
# gem install bundler && bundle install && cd ios && bundle exec pod install
```

Open Xcode at least once to accept the license and install components. Verify simulators: `xcrun simctl list devices`.

### Android

1. Install [Android Studio](https://developer.android.com/studio).
2. In SDK Manager, install: Android SDK, SDK Build-Tools, SDK Platform-Tools, NDK.
3. Set `ANDROID_HOME` in shell profile:

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk   # macOS
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
```

4. Create an emulator via AVD Manager, or connect a physical device with USB debugging.

### Troubleshooting Initial Build

| Issue | Fix |
|-------|-----|
| Pod install fails | `cd ios && bundle exec pod install --repo-update` |
| Gradle sync fails | `cd android && ./gradlew clean` then retry |
| Metro cache stale | `npx react-native start --reset-cache` or `npx expo start --clear` |
| Can't find simulator | `xcrun simctl list` to verify name |
| Build fails after native change | `npx expo prebuild --clean` (CNG) or clean via Xcode/Gradle |

## Post-Scaffold Checklist

1. **Install dependencies** — `npx expo install` to ensure compatible versions.
2. **TypeScript** — Expo templates include TS by default. Verify `tsconfig.json` has strict mode.
3. **Expo Router** — file-based routing (similar to Next.js App Router):

```bash
npx expo install expo-router expo-linking expo-constants
```

4. **Environment variables** — use `app.config.ts` (dynamic config) for env-dependent values:

```ts
export default ({ config }) => ({
  ...config,
  extra: { apiUrl: process.env.API_URL },
});
```

5. **EAS Build** — set up cloud builds for CI/CD:

```bash
npm install -g eas-cli
eas build:configure
```

## Recommended Folder Structure (Expo Router)

```
app/
├── _layout.tsx          # Root layout
├── index.tsx            # Home screen
├── (tabs)/
│   ├── _layout.tsx      # Tab navigator layout
│   ├── home.tsx
│   ├── profile.tsx
│   └── settings.tsx
├── (auth)/
│   ├── login.tsx
│   └── signup.tsx
└── [id].tsx             # Dynamic route
src/
├── components/
│   └── ui/
├── hooks/
├── lib/                 # API clients, storage wrappers
├── stores/              # State management
├── types/
└── utils/
```

### Key Conventions

- **File-based routing** — files in `app/` map to screens, just like Next.js.
- **Layouts** — `_layout.tsx` defines navigation structure (Stack, Tabs, Drawer).
- **Groups** — `(groupName)/` for logical grouping without affecting navigation.
- **Typed routes** — Expo Router generates typed route params.

## Performance-Aware Defaults

Decisions best made at project creation, not retrofitted:

- **Lists** — use `FlashList` from `@shopify/flash-list` instead of `FlatList`. Drop-in replacement, significantly better perf.
- **Animations** — use `react-native-reanimated` from day one. Runs animations on the UI thread, avoids JS thread blocking.
- **Barrel exports** — avoid `index.ts` re-export files. Import directly from source (`import { Button } from '@/components/Button'`), not barrel files. This improves tree shaking and startup time.
- **React Compiler** — enable it in `app.json` if using Expo SDK 52+. Automates memoization, removes the need for manual `useMemo`/`useCallback`.
- **State** — prefer atomic state (Zustand selectors or Jotai atoms) over large context providers to minimize re-renders.

## Key Libraries (2026)

| Purpose | Recommended | Notes |
|---------|-------------|-------|
| Navigation | Expo Router | File-based, built on React Navigation |
| State | Zustand or Jotai | Atomic updates to minimize re-renders |
| Data fetching | TanStack Query | Works on RN identically |
| Forms | React Hook Form + Zod | Same as web |
| Lists | FlashList (`@shopify/flash-list`) | Use instead of FlatList from the start |
| Animations | Reanimated | UI-thread animations, gesture handler integration |
| Styling | NativeWind (Tailwind for RN) or StyleSheet | NativeWind for Tailwind-like DX |
| Storage | expo-secure-store / MMKV | MMKV for performance-critical storage |
| Testing | Jest + React Native Testing Library | Expo default |

## Continuous Native Generation (CNG)

For projects needing native customization without maintaining native dirs permanently:

```bash
npx expo prebuild          # Generate ios/ and android/
npx expo prebuild --clean  # Regenerate from scratch
```

Add native dirs to `.gitignore` when using CNG — they become build artifacts generated from `app.json`/`app.config.ts` + config plugins.

## See Also

- [callstackincubator/agent-skills](https://github.com/callstackincubator/agent-skills) — agent-optimized React Native performance skills (profiling, FPS, TTI, bundle size, memory). Install as a complementary skill for post-scaffolding optimization work.
