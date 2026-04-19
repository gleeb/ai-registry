# React Hook-Dependency Purity: Default Props and Render-Path Identity

**Load this reference when:** a `useEffect` / `useMemo` / `useCallback` appears to re-run more than it should, especially when the triggering dependency is a prop that has a default value, or when the symptom appears only in the code path where a specific prop is *not* passed.

**Parked home note:** this lives under `webapp-testing/` for now because it's a single-file reference. If React-specific gotchas accumulate into their own cluster, this moves to a dedicated `common-skills/react/` skill.

## The failure mode

A React prop with a default value computed inside the component body:

```tsx
// ❌ BAD — fresh repository identity every render

import { createSettingsRepository } from "../data/settings-repository";
import { getAppDatabase } from "../data/db";

interface SettingsFormProps {
  repository?: SettingsRepository;
}

export function SettingsForm({
  repository = createSettingsRepository(getAppDatabase()),
}: SettingsFormProps) {
  const [settings, setSettings] = useState<Settings | null>(null);

  // This effect has `repository` in its deps. Because the default is
  // recomputed every render, the repository identity changes every render,
  // so this effect re-runs every render — even when `setSettings` just
  // updated local state and the "real" dependency did not change.
  useEffect(() => {
    let cancelled = false;
    repository.get().then((result) => {
      if (!cancelled && result.ok) setSettings(result.value);
    });
    return () => {
      cancelled = true;
    };
  }, [repository]);

  // ...
}
```

**Why:** default-parameter expressions are evaluated each time the function runs. A React function component re-runs every render. So a default like `createSettingsRepository(getAppDatabase())` produces a brand-new repository instance every render, and any effect keyed on `repository` re-runs.

The symptom hides in plain sight when the caller *does* pass `repository` as a prop (because then the prop is stable by reference from the parent). The failure only surfaces when the prop is omitted, which is typically the common, intended default path.

## The fix

Hoist the default to a stable location: a module-level singleton, a memoized value, or an explicit factory that the parent passes in.

### Option 1: module-level singleton (cleanest when a single instance is correct)

```tsx
// ✅ GOOD — one repository identity for the lifetime of the module

import { createSettingsRepository } from "../data/settings-repository";
import { getAppDatabase } from "../data/db";

const defaultRepository = createSettingsRepository(getAppDatabase());

interface SettingsFormProps {
  repository?: SettingsRepository;
}

export function SettingsForm({
  repository = defaultRepository,
}: SettingsFormProps) {
  const [settings, setSettings] = useState<Settings | null>(null);

  useEffect(() => {
    let cancelled = false;
    repository.get().then((result) => {
      if (!cancelled && result.ok) setSettings(result.value);
    });
    return () => {
      cancelled = true;
    };
  }, [repository]);
}
```

Use this when the app genuinely wants one repository instance and tests can inject a different one via the prop.

### Option 2: `useMemo` inside the component (when the default genuinely depends on something local)

```tsx
// ✅ GOOD — memoized default, stable across renders unless a real input changes

export function SettingsForm({ repository }: { repository?: SettingsRepository }) {
  const resolvedRepository = useMemo(
    () => repository ?? createSettingsRepository(getAppDatabase()),
    [repository],
  );

  useEffect(() => {
    let cancelled = false;
    resolvedRepository.get().then((result) => {
      if (!cancelled && result.ok) setSettings(result.value);
    });
    return () => {
      cancelled = true;
    };
  }, [resolvedRepository]);
}
```

Use this when you can't pull the default to module scope — e.g. it depends on context, on a prop, or on runtime config that isn't available at import time.

### Option 3: require the prop (when the component has no reasonable default)

Sometimes the right answer is "there is no correct default, so don't provide one." Making the prop required pushes the decision to the caller, who typically has a stable identity already. This eliminates the problem at the source.

## Anti-patterns

- **Default parameter that constructs an object.** `function X({ config = { foo: 1 } })` — same bug, every render has a fresh `config`.
- **Default that calls a factory.** `function X({ repo = makeRepo() })` — as above.
- **"Fixing" it by removing the dep from the effect.** Adds a lint-disable line and a race condition; the effect now reads a stale closure. Not a fix.
- **Wrapping the offending default in `useRef(createThing())`.** The ref captures the *first* call's value and never re-evaluates, which masks the symptom but introduces module-initialization-order bugs when the ref is used inside a code path that needs a fresh instance.
- **Using `useCallback`/`useMemo` on every render-path allocation reflexively.** Memoization has its own cost and can hide the real issue (which is often "this shouldn't be in the render path at all").

## How this shows up in tests

The gotcha can be hard to catch at the unit level because component tests usually pass an explicit `repository` prop (the stable reference path). To surface it, exercise the default path:

```tsx
it("loads settings on mount without re-running on local state updates", async () => {
  const mockGet = vi.fn().mockResolvedValue({ ok: true, value: { theme: "dark" } });

  // Install a test double at the module-singleton level, NOT via a prop.
  // This is what forces the default-path to be the path under test.
  vi.spyOn(settingsRepositoryModule, "createSettingsRepository").mockReturnValue({
    get: mockGet,
    // ... other methods
  } as unknown as SettingsRepository);

  render(<SettingsForm />);

  await screen.findByDisplayValue("dark");

  // Local state updates that should NOT re-trigger load.
  fireEvent.change(screen.getByLabelText(/preview/i), { target: { value: "on" } });
  fireEvent.change(screen.getByLabelText(/preview/i), { target: { value: "off" } });

  expect(mockGet).toHaveBeenCalledTimes(1);
});
```

If the default is unstable, `mockGet` will be called multiple times. If it's stable (fix applied), it's called exactly once.

Observable failure symptoms in real use:

- Extra spinner flashes as the effect re-runs between local state updates.
- Duplicate network calls on interaction, even when the component hasn't remounted.
- Flaky E2E tests that pass on fast machines and fail on slow ones (the race between re-runs becomes visible under load).

## Gate function

```
BEFORE adding a default value to a prop whose type is "object-ish"
(function, repository, service, config object, array):
  Ask: "Will this default expression be evaluated on every render?"

  IF yes (any expression that constructs / calls / allocates):
    Move the default to module scope, memoize, or make the prop required.

  IF no (primitive literal — string, number, boolean, null):
    Proceed. Primitive identity is stable by value.
```

## Red flags

- Default parameters whose RHS contains `new`, `()`, `[]`, `{}`, or any function call.
- `useEffect` deps that include a prop with such a default.
- A comment like `// re-run when repository changes` on an effect whose repository is a default-prop construction (the effect is doing that, yes — every render).
- Tests that only ever exercise the "prop passed in" path; no coverage of the default.

## Related

- [vite-react-preamble.md](./vite-react-preamble.md) — the error "Invalid hook call" can come from preamble issues OR from multiple React copies; the hook-purity bug produces *excessive* hook calls, not invalid ones. Different failure mode.
- `test-driven-development/test-patterns.md` — pattern "Mocking browser globals" shows the `Object.defineProperty` + restore shape that the module-level spy pattern in this doc uses.
