# Service Worker Testing

## Table of Contents

1. [Service Worker Basics](#service-worker-basics)
2. [Registration & Lifecycle](#registration--lifecycle)
3. [Cache Testing](#cache-testing)
4. [Offline Testing](#offline-testing)
5. [Push Notifications](#push-notifications)
6. [Background Sync](#background-sync)

## Service Worker Basics

### Waiting for Service Worker Registration

```typescript
test("service worker registers", async ({ page }) => {
  await page.goto("/pwa-app");

  // Wait for SW to register
  const swRegistered = await page.evaluate(async () => {
    if (!("serviceWorker" in navigator)) return false;

    const registration = await navigator.serviceWorker.ready;
    return !!registration.active;
  });

  expect(swRegistered).toBe(true);
});
```

### Getting Service Worker State

```typescript
test("check SW state", async ({ page }) => {
  await page.goto("/");

  const swState = await page.evaluate(async () => {
    const registration = await navigator.serviceWorker.getRegistration();
    if (!registration) return null;

    return {
      installing: !!registration.installing,
      waiting: !!registration.waiting,
      active: !!registration.active,
      scope: registration.scope,
    };
  });

  expect(swState?.active).toBe(true);
  expect(swState?.scope).toContain(page.url());
});
```

### Service Worker Context

```typescript
test("access service worker", async ({ context, page }) => {
  await page.goto("/pwa-app");

  // Get all service workers in context
  const workers = context.serviceWorkers();

  // Wait for service worker if not yet available
  if (workers.length === 0) {
    await context.waitForEvent("serviceworker");
  }

  const sw = context.serviceWorkers()[0];
  expect(sw.url()).toContain("sw.js");
});
```

## Registration & Lifecycle

### Testing SW Update Flow

```typescript
test("service worker updates", async ({ page }) => {
  await page.goto("/pwa-app");

  // Check for update
  const hasUpdate = await page.evaluate(async () => {
    const registration = await navigator.serviceWorker.ready;
    await registration.update();

    return new Promise<boolean>((resolve) => {
      if (registration.waiting) {
        resolve(true);
      } else {
        registration.addEventListener("updatefound", () => {
          resolve(true);
        });
        // Timeout if no update
        setTimeout(() => resolve(false), 5000);
      }
    });
  });

  // If update found, test skip waiting flow
  if (hasUpdate) {
    await page.evaluate(async () => {
      const registration = await navigator.serviceWorker.ready;
      registration.waiting?.postMessage({ type: "SKIP_WAITING" });
    });

    // Wait for controller change
    await page.evaluate(() => {
      return new Promise<void>((resolve) => {
        navigator.serviceWorker.addEventListener("controllerchange", () => {
          resolve();
        });
      });
    });
  }
});
```

### Testing SW Installation

```typescript
test("verify SW install event", async ({ context, page }) => {
  // Listen for service worker before navigating
  const swPromise = context.waitForEvent("serviceworker");

  await page.goto("/pwa-app");

  const sw = await swPromise;

  // Evaluate in SW context
  const swVersion = await sw.evaluate(() => {
    // Access SW globals
    return (self as any).SW_VERSION || "unknown";
  });

  expect(swVersion).toBe("1.0.0");
});
```

### Unregistering Service Workers

```typescript
test.beforeEach(async ({ page }) => {
  await page.goto("/");

  // Unregister all service workers for clean state
  await page.evaluate(async () => {
    const registrations = await navigator.serviceWorker.getRegistrations();
    await Promise.all(registrations.map((r) => r.unregister()));
  });

  // Clear caches
  await page.evaluate(async () => {
    const cacheNames = await caches.keys();
    await Promise.all(cacheNames.map((name) => caches.delete(name)));
  });
});
```

## Cache Testing

### Verifying Cached Resources

```typescript
test("assets are cached", async ({ page }) => {
  await page.goto("/pwa-app");

  // Wait for SW to cache assets
  await page.evaluate(async () => {
    await navigator.serviceWorker.ready;
  });

  // Check cache contents
  const cachedUrls = await page.evaluate(async () => {
    const cache = await caches.open("app-cache-v1");
    const requests = await cache.keys();
    return requests.map((r) => r.url);
  });

  expect(cachedUrls).toContain(expect.stringContaining("/styles.css"));
  expect(cachedUrls).toContain(expect.stringContaining("/app.js"));
});
```

### Testing Cache Strategies

```typescript
test("cache-first strategy", async ({ page }) => {
  await page.goto("/pwa-app");

  // Wait for initial cache
  await page.waitForFunction(async () => {
    const cache = await caches.open("app-cache-v1");
    const keys = await cache.keys();
    return keys.length > 0;
  });

  // Block network for cached resources
  await page.route("**/styles.css", (route) => route.abort());

  // Reload - should work from cache
  await page.reload();

  // Verify page still styled (CSS loaded from cache)
  const hasStyles = await page.evaluate(() => {
    const body = document.body;
    const styles = window.getComputedStyle(body);
    return styles.fontFamily !== ""; // Has custom font from CSS
  });

  expect(hasStyles).toBe(true);
});
```

### Testing Cache Updates

```typescript
test("cache updates on new version", async ({ page }) => {
  await page.goto("/pwa-app");

  // Get initial cache
  const initialCacheKeys = await page.evaluate(async () => {
    const cache = await caches.open("app-cache-v1");
    const keys = await cache.keys();
    return keys.map((r) => r.url);
  });

  // Simulate app update by mocking SW response
  await page.route("**/sw.js", (route) => {
    route.fulfill({
      contentType: "application/javascript",
      body: `
        const VERSION = 'v2';
        self.addEventListener('install', (e) => {
          e.waitUntil(caches.open('app-cache-v2'));
          self.skipWaiting();
        });
      `,
    });
  });

  // Trigger update
  await page.evaluate(async () => {
    const reg = await navigator.serviceWorker.ready;
    await reg.update();
  });

  // Verify new cache exists
  await page.waitForFunction(async () => {
    return await caches.has("app-cache-v2");
  });
});
```

## Offline Testing

This section covers **offline-first apps (PWAs)** that are designed to work offline using service workers, caching, and background sync. For testing **unexpected network failures** (error recovery, graceful degradation), see [error-testing.md](error-testing.md#offline-testing).

### Simulating Offline Mode

```typescript
test("app works offline", async ({ page, context }) => {
  await page.goto("/pwa-app");

  // Ensure SW is active and content cached
  await page.evaluate(async () => {
    await navigator.serviceWorker.ready;
  });
  await page.waitForTimeout(1000); // Allow caching to complete

  // Go offline
  await context.setOffline(true);

  // Navigate to cached page
  await page.reload();

  // Verify content loads
  await expect(page.getByRole("heading", { name: "Dashboard" })).toBeVisible();

  // Verify offline indicator
  await expect(page.locator(".offline-badge")).toBeVisible();

  // Go back online
  await context.setOffline(false);
  await expect(page.locator(".offline-badge")).not.toBeVisible();
});
```

### Testing Offline Fallback

```typescript
test("shows offline page for uncached routes", async ({ page, context }) => {
  await page.goto("/pwa-app");
  await page.evaluate(() => navigator.serviceWorker.ready);

  // Go offline
  await context.setOffline(true);

  // Navigate to uncached page
  await page.goto("/uncached-page");

  // Should show offline fallback
  await expect(page.getByText("You are offline")).toBeVisible();
  await expect(page.getByRole("button", { name: "Retry" })).toBeVisible();
});
```

### Testing Offline Form Submission

```typescript
test("queues form submission offline", async ({ page, context }) => {
  await page.goto("/pwa-app/form");

  // Go offline
  await context.setOffline(true);

  // Submit form
  await page.getByLabel("Message").fill("Offline message");
  await page.getByRole("button", { name: "Send" }).click();

  // Should show queued status
  await expect(page.getByText("Queued for sync")).toBeVisible();

  // Go online
  await context.setOffline(false);

  // Trigger sync (or wait for automatic)
  await page.evaluate(async () => {
    const reg = await navigator.serviceWorker.ready;
    // Manually trigger sync for testing
    await (reg as any).sync?.register("form-sync");
  });

  // Verify submission completed
  await expect(page.getByText("Message sent")).toBeVisible({ timeout: 10000 });
});
```

## Push Notifications

### Mocking Push Subscription

```typescript
test("handles push subscription", async ({ page, context }) => {
  // Grant notification permission
  await context.grantPermissions(["notifications"]);

  await page.goto("/pwa-app");

  // Subscribe to push
  const subscription = await page.evaluate(async () => {
    const reg = await navigator.serviceWorker.ready;
    const sub = await reg.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: "test-key",
    });
    return sub.toJSON();
  });

  expect(subscription.endpoint).toBeDefined();
});
```

### Testing Push Message Handling

```typescript
test("handles push notification", async ({ context, page }) => {
  await context.grantPermissions(["notifications"]);
  await page.goto("/pwa-app");

  // Wait for SW
  const swPromise = context.waitForEvent("serviceworker");
  const sw = await swPromise;

  // Simulate push message to service worker
  await sw.evaluate(async () => {
    // Dispatch push event
    const pushEvent = new PushEvent("push", {
      data: new PushMessageData(
        JSON.stringify({ title: "Test", body: "Push message" }),
      ),
    });
    self.dispatchEvent(pushEvent);
  });

  // Note: Actual notification display testing is limited in Playwright
  // Focus on verifying the SW handles the push correctly
});
```

### Testing Notification Click

```typescript
test("notification click opens page", async ({ context, page }) => {
  await context.grantPermissions(["notifications"]);
  await page.goto("/pwa-app");

  // Store notification URL target
  let notificationUrl = "";

  // Listen for new pages (notification click opens new page)
  context.on("page", (newPage) => {
    notificationUrl = newPage.url();
  });

  // Trigger notification via SW
  await page.evaluate(async () => {
    const reg = await navigator.serviceWorker.ready;
    await reg.showNotification("Test", {
      body: "Click me",
      data: { url: "/notification-target" },
    });
  });

  // Simulate clicking notification (via SW)
  const sw = context.serviceWorkers()[0];
  await sw.evaluate(() => {
    self.dispatchEvent(
      new NotificationEvent("notificationclick", {
        notification: { data: { url: "/notification-target" } } as any,
      }),
    );
  });

  // Verify navigation occurred
  await page.waitForTimeout(1000);
  // Check if new page opened or current page navigated
});
```

## Background Sync

### Testing Background Sync Registration

```typescript
test("registers background sync", async ({ page }) => {
  await page.goto("/pwa-app");

  // Register sync
  const syncRegistered = await page.evaluate(async () => {
    const reg = await navigator.serviceWorker.ready;
    if (!("sync" in reg)) return false;

    await (reg as any).sync.register("my-sync");
    return true;
  });

  expect(syncRegistered).toBe(true);
});
```

### Testing Sync Event

```typescript
test("sync event fires when online", async ({ context, page }) => {
  await page.goto("/pwa-app");

  // Queue data while offline
  await context.setOffline(true);

  await page.evaluate(async () => {
    // Store data in IndexedDB for sync
    const db = await openDB();
    await db.put("sync-queue", { id: 1, data: "test" });

    // Register sync
    const reg = await navigator.serviceWorker.ready;
    await (reg as any).sync.register("data-sync");
  });

  // Track sync completion
  await page.evaluate(() => {
    window.syncCompleted = false;
    navigator.serviceWorker.addEventListener("message", (e) => {
      if (e.data.type === "SYNC_COMPLETE") {
        window.syncCompleted = true;
      }
    });
  });

  // Go online
  await context.setOffline(false);

  // Wait for sync to complete
  await page.waitForFunction(() => window.syncCompleted, { timeout: 10000 });
});
```

## PWA Smoke Against the Preview Bundle (not the Dev Server)

### Why `vite preview`, not `vite` (dev)

PWA smoke that exercises the service worker lifecycle — offline relaunch, precache behavior, installability — must run against the **production bundle** served by `vite preview`. The Vite dev server's plugin-managed SW shim does not precisely match production semantics on the lifecycle edges (install, activate, skipWaiting, offline navigation).

Tests that pass against `vite` dev and fail against `vite preview` are routine. Tests that pass against `vite preview` and fail against dev rarely matter for the user experience you're protecting.

### Pattern: build once in `beforeAll`, serve via preview

```typescript
import { test, expect, type ChildProcess } from "@playwright/test";
import { spawn } from "node:child_process";
import { once } from "node:events";

let preview: ChildProcess;
const PREVIEW_PORT = 4180;

test.beforeAll(async () => {
  // Build once for the whole smoke suite. The build is typically 15-60s;
  // putting it in beforeAll amortizes the cost across every test.
  await new Promise<void>((resolve, reject) => {
    const build = spawn("npm", ["run", "build"], { stdio: "inherit" });
    build.on("exit", (code) =>
      code === 0 ? resolve() : reject(new Error(`build failed: ${code}`)),
    );
  });

  preview = spawn(
    "npm",
    ["run", "preview", "--", "--port", String(PREVIEW_PORT), "--strictPort"],
    { stdio: ["ignore", "pipe", "pipe"] },
  );

  // Wait for the preview server to log its readiness line before proceeding.
  const stdout = preview.stdout!;
  await new Promise<void>((resolve) => {
    stdout.on("data", (chunk: Buffer) => {
      if (chunk.toString().includes(`localhost:${PREVIEW_PORT}`)) resolve();
    });
  });
});

test.afterAll(async () => {
  preview?.kill("SIGTERM");
  if (preview) await once(preview, "exit");
});

test("offline reload serves the cached app shell", async ({ page, context }) => {
  await page.goto(`http://localhost:${PREVIEW_PORT}/`);
  await page.evaluate(() => navigator.serviceWorker.ready);
  await context.setOffline(true);
  await page.reload();
  await expect(page.getByRole("heading", { name: /welcome/i })).toBeVisible();
});
```

Key points:

- `strictPort` on the preview server turns port collisions into a loud failure instead of a silent fallback.
- Tracking the child process explicitly lets `afterAll` guarantee cleanup — leaving a `vite preview` zombie running is the single most common cause of the next run failing.
- Build before the suite, not per-test; the build output is what you're validating.

### Clear existing SW registrations and caches before asserting current bundle

If Playwright is run against a persistent browser context (or a preview server was left running from a prior session), the browser may still have a previously registered service worker precached. The tab loads the *old* shell, and your assertions look at stale UI.

```typescript
test.beforeEach(async ({ page }) => {
  // Clear SW registrations and all caches before navigating.
  // Do this in a throwaway about:blank context so it affects the origin we're about to test.
  await page.goto("about:blank");
  await page.evaluate(async () => {
    if ("serviceWorker" in navigator) {
      const regs = await navigator.serviceWorker.getRegistrations();
      await Promise.all(regs.map((r) => r.unregister()));
    }
    if ("caches" in window) {
      const keys = await caches.keys();
      await Promise.all(keys.map((k) => caches.delete(k)));
    }
  });
});
```

Symptom signature for this gotcha: routes that are clearly present in the current build return a blank or stripped-down shell in the browser, while `curl` against the same URL returns the correct HTML. The browser is serving a cached old registration; the fix is to unregister before navigating.

### Chromium CDP manifest enums are `k`-prefixed

`Page.getAppManifest()` over the Chrome DevTools Protocol surfaces manifest display-mode values with a `k` prefix (`kStandalone`, `kFullscreen`, `kMinimalUi`, `kBrowser`) — not the lowercase strings that appear in the manifest JSON (`standalone`, `fullscreen`, `minimal-ui`, `browser`).

```typescript
test("manifest declares standalone display", async ({ page }) => {
  await page.goto(`http://localhost:${PREVIEW_PORT}/`);

  const cdp = await page.context().newCDPSession(page);
  const { manifest } = await cdp.send("Page.getAppManifest");
  await cdp.detach();

  // ❌ BAD — this assertion looks right but will always fail
  // expect(manifest.display).toBe('standalone');

  // ✅ GOOD — CDP returns the k-prefixed enum name
  expect(manifest.display).toBe("kStandalone");
});
```

Why: the CDP field reflects Chromium's internal `blink::mojom::DisplayMode` enum identifiers, not the web-platform string values. If you need the web-platform value for downstream code, map it yourself:

```typescript
const cdpToWeb: Record<string, string> = {
  kStandalone: "standalone",
  kFullscreen: "fullscreen",
  kMinimalUi: "minimal-ui",
  kBrowser: "browser",
};
const displayMode = cdpToWeb[manifest.display] ?? manifest.display;
```

## Anti-Patterns to Avoid

| Anti-Pattern                   | Problem                 | Solution                                     |
| ------------------------------ | ----------------------- | -------------------------------------------- |
| Not clearing SW between tests  | Tests affect each other | Unregister SW in beforeEach                  |
| Not waiting for SW ready       | Race conditions         | Always await `navigator.serviceWorker.ready` |
| Testing in isolation only      | Misses real SW behavior | Test with actual caching                     |
| Hardcoded timeouts for caching | Flaky tests             | Wait for cache to populate                   |
| Ignoring SW update cycle       | Missing update bugs     | Test install, activate, update flows         |
| PWA smoke against `vite` dev   | Dev SW shim masks real lifecycle bugs | Run against `vite preview` of the built bundle |
| Asserting CDP manifest display as `'standalone'` | CDP returns `'kStandalone'` | Use the k-prefixed enum or map it explicitly |
| Persistent profile with stale SW | Loads old shell, assertions look at wrong UI | Unregister + cache-delete in a `beforeEach` pre-navigate step |

## Related References

- **Network Failures**: See [error-testing.md](error-testing.md#offline-testing) for unexpected network failure patterns
- **Browser APIs**: See [browser-apis.md](browser-apis.md) for permissions
- **Network Mocking**: See [network-advanced.md](../advanced/network-advanced.md) for network interception
- **Browser Extensions**: See [browser-extensions.md](../testing-patterns/browser-extensions.md) for extension service worker patterns
