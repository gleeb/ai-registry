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

---

## Scaffolding Verification Checklist

Run through every item before marking the scaffold complete.

### Project Structure

- [ ] `app/_layout.tsx` root layout with Stack or Tabs navigator configured
- [ ] `app/index.tsx` home screen renders without errors
- [ ] `src/components/`, `src/hooks/`, `src/lib/`, `src/stores/`, `src/types/`, `src/utils/` directories created
- [ ] `tsconfig.json` with `"strict": true`
- [ ] `app.json` with `name`, `slug`, `version`, `icon`, `splash` fields configured

### Asset Setup

- [ ] `assets/icon.png` exists at root level (separate from `assets/images/icon.png` if the template creates that)
- [ ] `assets/splash.png` exists at root level
- [ ] Paths in `app.json` `"icon"` and `"splash.image"` fields match actual file locations on disk

### Environment

- [ ] Node version matches Expo SDK requirement — pin in `.nvmrc` or `.node-version`
  - SDK 54: Node 20.x
  - SDK 55: Node 20.x
- [ ] `npx expo install` run after scaffold to ensure version-compatible packages
- [ ] Project NOT scaffolded inside iCloud Drive, Dropbox, or OneDrive

### Performance Defaults (install at scaffold time, painful to retrofit)

- [ ] `@shopify/flash-list` installed — use for ALL list components; do NOT use `FlatList`
- [ ] `react-native-reanimated` installed and configured as the LAST plugin in `babel.config.js`
- [ ] No barrel `index.ts` re-export files created (import directly from source)

### Testing Infrastructure

- [ ] Jest configured with `jest-expo` preset
- [ ] `@testing-library/react-native` installed
- [ ] At least one smoke test passes (`pnpm test` or `npx jest` exits 0)

### Verification Scripts

- [ ] `scripts/verify.sh` created (see template below) — silent on success, prints only the failing gate
- [ ] `package.json` `scripts` includes `"verify:full"` and `"verify:quick"`

```bash
# package.json scripts additions
"verify:full": "bash scripts/verify.sh full",
"verify:quick": "bash scripts/verify.sh quick"
```

```bash
#!/usr/bin/env bash
# scripts/verify.sh — silent verification for React Native (Expo + Jest)
set -euo pipefail

TIER="${1:-full}"

run_gate() {
  local name="$1"; shift
  local output
  if output=$("$@" 2>&1); then
    return 0
  else
    echo "=== ${name} FAILED ==="
    echo "$output"
    exit 1
  fi
}

run_gate "LINT"       pnpm lint
run_gate "TYPECHECK"  pnpm typecheck

if [ "$TIER" = "full" ]; then
  run_gate "TEST" npx jest --coverage --coverageReporters=text --coverageReporters=html --coverageReporters=json-summary
  if [ -f coverage/coverage-summary.json ]; then
    node -e "const s=require('./coverage/coverage-summary.json'); for(const[k,v] of Object.entries(s)){ if(k==='total')continue; const p=k.replace(process.cwd()+'/',''); console.log('COVERAGE: '+p+' L='+v.lines.pct+'% B='+v.branches.pct+'% F='+v.functions.pct+'%'); }"
  fi
else
  run_gate "TEST" npx jest
fi

# Note: no build step — Expo builds via EAS, not a local npm script
echo "=== ALL GATES PASSED ==="
```

Make it executable: `chmod +x scripts/verify.sh`

### Verification Gate (all must pass before scaffold is done)

```bash
npx expo install              # Resolves compatible package versions, no errors (run first)
npm run verify:full           # Silent: lint + typecheck + jest (with coverage)
                              # Exits 0 and prints "=== ALL GATES PASSED ===" on success
npx expo start                # Manual check: Metro bundler starts, QR code appears
# Run on iOS simulator or Android emulator (NOT just Expo Go) — manual device check
```

### Documentation Structure

- [ ] `docs/mobile/index.md`, `docs/mobile/technology.md`, `docs/mobile/project-structure.md`
- [ ] `docs/staging/README.md`
- [ ] `docs/specs/.gitkeep` and `docs/archive/.gitkeep`

---

## Known Gotchas


### Never scaffold inside cloud-synced directories

Creating an Expo project inside iCloud Drive, Dropbox, or OneDrive causes Metro bundler asset resolution failures. Cloud sync services modify file attributes and timestamps, confusing Metro's file watcher. Asset errors surface as `FileNotFound` at runtime, not at scaffold time. Always scaffold in a local directory: `~/Dev/`, `~/workspace/`, or `/tmp/`.

### Icon and splash asset path mismatch

Expo Router templates may place icons at `assets/images/icon.png`, but the `app.json` fields `"icon"` and `"splash.image"` expect files at `assets/icon.png` and `assets/splash.png` respectively. The mismatch does not cause an immediate error during `expo start`, but produces "Asset not found" build failures during `eas build`. Always verify the `app.json` paths match actual file locations immediately after scaffold.

### Expo Go vs development builds differ significantly

Expo Go runs in a sandboxed environment that differs from production and development builds:
- **Push notifications**: NOT supported in Expo Go (SDK 54+). Requires a development build.
- **Custom native modules**: Any module with native code (Swift/Kotlin) silently fails or causes crashes in Expo Go.
- **Custom fonts**: Must use `useFonts()` hook with explicit loading check (`if (!fontsLoaded) return null`). Without the loading check, fonts fail silently in production builds.

Always run at least one verification on a development build (via `eas build --profile development` or `npx expo prebuild`) during scaffold verification.

### `react-native-reanimated` plugin must be LAST in babel.config.js

`react-native-reanimated/plugin` must always be the last plugin in `babel.config.js`. Placing it before other plugins (Expo Router, NativeWind, etc.) causes transform failures with cryptic error messages. The error is not obviously about plugin order. Correct configuration:

```js
// babel.config.js
module.exports = function(api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      // other plugins first
      'react-native-reanimated/plugin', // MUST be last
    ],
  };
};
```


### FlashList instead of FlatList — install at scaffold time

`FlatList` is React Native's built-in virtualized list but performs poorly at scale (JS-thread-based windowing, high memory usage). `FlashList` from `@shopify/flash-list` is a drop-in replacement with native-thread rendering and significantly better FPS. Retrofitting from `FlatList` to `FlashList` across an existing codebase requires touching every list component. Install `@shopify/flash-list` at scaffold time and enforce its use from day 1.

### Barrel exports kill startup time

`index.ts` re-export files (`export * from './Button'; export * from './Input'`) prevent tree shaking and cause Metro to load every module in the barrel at startup, even if only one export is used. On large codebases this significantly increases Time to Interactive (TTI). Import directly from source files: `import { Button } from '@/components/Button/Button'` not `import { Button } from '@/components'`. Do not create barrel files during scaffold.

### Node version mismatch causes Metro failures

Expo SDK 54 and 55 require Node 20.x. Using Node 18.x or 22.x can cause Metro bundler failures, native module compilation errors, or dependency resolution issues that are not obviously related to the Node version. Pin the Node version at scaffold time in `.nvmrc` (for nvm users) or `.node-version` (for fnm/volta users).
