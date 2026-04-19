# Repository-Boundary Error Normalization

**Load this reference when:** writing a repository, data-access layer, or storage adapter that wraps Dexie / IndexedDB / Prisma / Knex / fetch / any async I/O. Also applies to any function whose contract promises "returns data or a typed error" but currently lets the underlying library's rejection escape unchanged.

## Core principle

Async backend errors must be normalized at the repository boundary. The repository's caller must never have to `try/catch` a third-party library rejection to find out whether an operation succeeded. Every public repository method returns a discriminated `Result` shape; rejections from the underlying driver are caught and mapped to the domain error kind.

```
caller --> repository.get(id) --> returns { ok: true, value } | { ok: false, error }
                                        ^
                                  never throws
```

If the repository throws, the caller has to duplicate error classification at every call site. That's how a "local-storage" concern leaks into UI layers, services, and tests.

## The Dexie case (the motivating gotcha)

Dexie rejects its promises for read failures, write failures, and delete failures. If you return the Dexie promise directly from your repository, those rejections become the caller's problem. The fix is one small helper that every operation goes through.

```typescript
// ✅ GOOD — one helper, consistent shape

type Result<T, E> = { ok: true; value: T } | { ok: false; error: E };

type LocalStorageError = {
  kind: 'local-storage';
  op: 'get' | 'list' | 'put' | 'delete';
  message: string;
  cause?: unknown;
};

function toLocalStorageFailure(
  op: LocalStorageError['op'],
  cause: unknown,
): Result<never, LocalStorageError> {
  return {
    ok: false,
    error: {
      kind: 'local-storage',
      op,
      message: cause instanceof Error ? cause.message : String(cause),
      cause,
    },
  };
}

async function catchToResult<T>(
  op: LocalStorageError['op'],
  run: () => Promise<T>,
): Promise<Result<T, LocalStorageError>> {
  try {
    return { ok: true, value: await run() };
  } catch (err) {
    return toLocalStorageFailure(op, err);
  }
}

// Repository methods compose with the helper — no try/catch at the call site.
export class ItemRepository {
  constructor(private readonly db: AppDatabase) {}

  get(id: string) {
    return catchToResult('get', () => this.db.items.get(id));
  }

  list() {
    return catchToResult('list', () => this.db.items.orderBy('createdAt').toArray());
  }

  put(item: Item) {
    return catchToResult('put', () => this.db.items.put(item));
  }

  delete(id: string) {
    return catchToResult('delete', () => this.db.items.delete(id));
  }
}
```

**Why this pattern:**

- Every method has the same shape: `Promise<Result<T, LocalStorageError>>`. Callers can use a single discriminant check.
- Every failure is classified at the boundary, next to the code that produced it. No `try/catch` duplication upstream.
- Library-specific details (`DexieError`, `IDBRequest` events) stay inside the repository. Swapping Dexie for a different IndexedDB wrapper changes zero call sites.

## Anti-pattern: returning raw promise rejections

```typescript
// ❌ BAD — repository leaks driver rejections

export class ItemRepository {
  constructor(private readonly db: AppDatabase) {}

  get(id: string) {
    return this.db.items.get(id); // rejects on transaction abort, quota exceeded, blocked db, etc.
  }

  list() {
    return this.db.items.orderBy('createdAt').toArray(); // same
  }

  async delete(id: string) {
    await this.db.items.delete(id); // rejects on quota / blocked
    return; // no Result shape
  }
}
```

Symptoms when you do this:

- Some callers `try/catch`, others don't. The ones that don't drop UI into an unhandled-rejection state on the first quota-exceeded hit.
- Error classification happens in service / UI code, so "is this a Dexie error?" logic appears in 4 different files.
- Tests that exercise the happy path pass; failure paths are silent until production data produces a real rejection.
- Type signatures claim `Promise<Item | undefined>` but actually fulfil with that *or* reject with an untyped unknown.

## Where else this applies

The Dexie-specific kind is an example; the shape generalises:

| Boundary                          | Typical error kind         | Typical ops                    |
|-----------------------------------|----------------------------|--------------------------------|
| IndexedDB / Dexie                 | `local-storage`            | `get`, `list`, `put`, `delete` |
| Prisma / Knex / Postgres pool     | `database`                 | `get`, `query`, `mutate`       |
| `fetch` to an HTTP API            | `network` / `remote-api`   | `get`, `post`                  |
| Filesystem via `node:fs/promises` | `filesystem`               | `read`, `write`, `remove`      |
| Cache backends (Redis, etc.)      | `cache`                    | `get`, `set`, `del`            |

The helper is always the same shape. The `kind` discriminator is what tells the caller whether a retry / fallback / user-facing message is appropriate.

## Testing the boundary

One test per failure path is enough — assert the returned shape, not the thrown exception.

```typescript
// ✅ GOOD — assert the Result, don't let the rejection escape the test
it('returns local-storage error when Dexie rejects delete', async () => {
  const db = {
    items: {
      delete: vi.fn().mockRejectedValueOnce(new Error('QuotaExceededError')),
    },
  } as unknown as AppDatabase;
  const repo = new ItemRepository(db);

  const result = await repo.delete('id-1');

  expect(result.ok).toBe(false);
  if (!result.ok) {
    expect(result.error.kind).toBe('local-storage');
    expect(result.error.op).toBe('delete');
  }
});
```

Do not `await expect(repo.delete(...)).rejects...` — that contract is exactly what this pattern is designed to make impossible.

## Gate function

```
BEFORE returning a promise from a repository method:
  Ask: "If the underlying driver rejects this, does every caller handle the rejection?"

  IF no (or unknown):
    Wrap the operation in the catchToResult helper.
    Return Result<T, E>, not Promise<T>.

  IF yes:
    You have proof the contract is consistent. Document the expected rejection type.
    Most of the time, "yes" is aspirational — prefer the helper.
```

## Red flags

- A repository method signature is `Promise<T>` (not `Promise<Result<T, E>>`).
- A service or UI layer contains `catch (err) { if (err.name === 'DexieError' ...) }`.
- Tests assert `.rejects.toThrow(...)` against repository methods (you're testing the driver, not the contract).
- Two repositories in the same codebase classify the same failure differently.

## Related

- Task-context template convention for "Risks / Local storage failure modes" — every story that touches IndexedDB should enumerate which ops can fail and how they surface.
- `@testing-anti-patterns.md` Anti-Pattern 4 (Incomplete Mocks) — when stubbing the driver, mirror its full contract including the rejection path you care about.
