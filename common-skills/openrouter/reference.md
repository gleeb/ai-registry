# OpenRouter Reference

Deep reference for the `openrouter` skill. Read on demand — the agent does not need this loaded for every task. SKILL.md covers the common 80% (model discovery, free filtering, multimodal, web search, basic provider routing).

Sources:
- `https://openrouter.ai/docs/guides/routing/provider-selection`
- `https://openrouter.ai/docs/guides/features/plugins/web-search`
- `https://openrouter.ai/docs/guides/features/server-tools/web-search`
- `https://openrouter.ai/docs/guides/routing/model-variants/free`
- `https://openrouter.ai/docs/guides/routing/model-variants/online`

---

## 1. Full `provider` object

| Field | Type | Default | Purpose |
|---|---|---|---|
| `order` | `string[]` | — | Try these provider slugs first, in order. |
| `allow_fallbacks` | `boolean` | `true` | Allow other providers if those in `order` fail. |
| `require_parameters` | `boolean` | `false` | Only use providers that support every parameter in the request (e.g., `tools`, `response_format`). |
| `data_collection` | `"allow" \| "deny"` | `"allow"` | `deny` skips providers that may train on data. |
| `zdr` | `boolean` | — | When `true`, only Zero-Data-Retention endpoints. ORs with the account-level setting. |
| `enforce_distillable_text` | `boolean` | — | Only models whose author allowed text distillation. |
| `only` | `string[]` | — | Allow-list of provider slugs. |
| `ignore` | `string[]` | — | Block-list of provider slugs. |
| `quantizations` | `string[]` | — | Filter by quantization (`int4`, `int8`, `fp4`, `fp6`, `fp8`, `fp16`, `bf16`, `fp32`, `unknown`). |
| `sort` | `string \| object` | — | `"price"`, `"throughput"`, or `"latency"`. Object form: `{ by, partition }`. |
| `preferred_min_throughput` | `number \| object` | — | Tokens/sec floor. Number applies to p50; object accepts `p50/p75/p90/p99`. |
| `preferred_max_latency` | `number \| object` | — | Latency ceiling in seconds. Same shape as throughput. |
| `max_price` | `object` | — | Hard caps: `{ prompt, completion, request, image }` in USD per million tokens (or per request/image). |

Slug shortcuts:
- `model-id:floor` ≡ `provider.sort = "price"`
- `model-id:nitro` ≡ `provider.sort = "throughput"`
- `model-id:free` ≡ free variant (separate concept from provider routing)
- `model-id:online` ≡ attaches the `web` plugin (deprecated — use the server tool)

### Targeting specific provider endpoints

Provider slugs can be base (`google-vertex`) or include a variant suffix (`google-vertex/us-east5`, `deepinfra/turbo`). Base slugs match all variants; suffixed slugs match exactly.

Example — pin to DeepInfra's turbo endpoint, no fallbacks:

```json
{
  "model": "deepseek/deepseek-r1",
  "provider": { "order": ["deepinfra/turbo"], "allow_fallbacks": false }
}
```

---

## 2. Sort with partition (multi-model fallbacks)

When you pass `models: [...]` (model fallbacks), `sort` accepts an object:

| Field | Type | Default | Purpose |
|---|---|---|---|
| `sort.by` | string | — | `"price"`, `"throughput"`, or `"latency"`. |
| `sort.partition` | string | `"model"` | `"model"` keeps each model's endpoints grouped (try all of model A before model B). `"none"` sorts globally across models. |

Use cases for `partition: "none"`:
1. **Highest throughput across acceptable models** — `sort.by: "throughput"`.
2. **Cheapest acceptable model meeting a perf floor** — combine with `preferred_min_throughput` / `preferred_max_latency`.
3. **Maximize BYOK use** — when your primary model has no BYOK provider but a fallback does, `partition: "none"` lets the router cross the model boundary to use your key.

---

## 3. Percentile-based performance thresholds

`preferred_max_latency` and `preferred_min_throughput` accept either a number (applies to p50) or an object with any of `p50`, `p75`, `p90`, `p99`. All specified percentiles must hold for an endpoint to be in the preferred group; non-preferred endpoints are deprioritized, not excluded.

```json
{
  "provider": {
    "preferred_max_latency": { "p50": 1, "p90": 3, "p99": 5 },
    "preferred_min_throughput": { "p50": 100, "p90": 50 }
  }
}
```

Use percentile thresholds for SLA-style routing; combine with `sort: "price"` for "cheapest provider that meets the SLA".

---

## 4. Web search — full options

### Server tool form (preferred)

```json
{ "tools": [{ "type": "openrouter:web_search" }] }
```

Clients that emit a plain `web_search` tool (e.g., OpenAI SDK) are auto-hoisted to the server tool, so the same code works against any model on OpenRouter.

### Plugin form

```json
{
  "plugins": [
    {
      "id": "web",
      "engine": "exa",
      "max_results": 5,
      "search_prompt": "Some relevant web results:",
      "include_domains": ["example.com", "*.substack.com"],
      "exclude_domains": ["reddit.com"]
    }
  ]
}
```

Engine options: `native`, `exa`, `firecrawl`, `parallel`, or omit (auto = native if supported, else Exa).

| Engine | `include_domains` | `exclude_domains` | Notes |
|---|---|---|---|
| Exa | yes | yes | Both can be used together. |
| Parallel | yes | yes | Mutually exclusive — pick one. |
| Native | varies | varies | See provider notes below. |
| Firecrawl | no | no | Returns 400 if domain filters set. |

Native quirks:
- **Anthropic**: both supported, but mutually exclusive.
- **OpenAI**: only `include_domains`; `exclude_domains` silently ignored.
- **xAI**: both supported, mutually exclusive, max 5 each.

### Search context size (native)

```json
{ "web_search_options": { "search_context_size": "low" | "medium" | "high" } }
```

Higher tiers retrieve more results and cost more. Refer to provider docs for exact pricing (OpenAI, Anthropic, Perplexity, xAI).

### Result annotations

All engines normalize results into the OpenAI annotation schema:

```json
{
  "message": {
    "annotations": [{
      "type": "url_citation",
      "url_citation": {
        "url": "...",
        "title": "...",
        "content": "...",
        "start_index": 100,
        "end_index": 200
      }
    }]
  }
}
```

### Pricing summary

| Engine | Source of cost |
|---|---|
| Native | Provider-passthrough (see provider docs). |
| Exa | OpenRouter credits at $4 / 1000 results. Default 5 results = $0.02. |
| Parallel | Same rate as Exa ($4 / 1000 results). |
| Firecrawl | BYOK — Firecrawl credits, no OpenRouter markup. |

---

## 5. xAI X-search filters

When using xAI models with web search, OpenRouter exposes an `x_search` tool alongside `web_search`. Configure via top-level `x_search_filter`:

| Field | Type | Notes |
|---|---|---|
| `allowed_x_handles` | `string[]` | Max 10. Mutually exclusive with `excluded_x_handles`. |
| `excluded_x_handles` | `string[]` | Max 10. |
| `from_date` | string | ISO 8601 (`"2025-01-01"`). |
| `to_date` | string | ISO 8601. |
| `enable_image_understanding` | boolean | Analyze images in posts. |
| `enable_video_understanding` | boolean | Analyze videos in posts. |

If validation fails, the filter is silently dropped and a basic `x_search` is used instead.

---

## 6. Anthropic beta headers

Pass via the `x-anthropic-beta` request header (comma-separate to combine):

| Feature | Header value | Effect |
|---|---|---|
| Fine-grained tool streaming | `fine-grained-tool-streaming-2025-05-14` | Granular streaming events while tool args are generated. |
| Interleaved thinking | `interleaved-thinking-2025-05-14` | Reasoning interleaved with normal output. |
| Structured outputs | `structured-outputs-2025-11-13` | Strict tool use; required for `strict: true` on tools. |

OpenRouter auto-applies the structured-outputs header when `response_format.type === "json_schema"`. For `strict: true` on tools, you must pass the header explicitly or OpenRouter strips `strict`. Prompt caching and extended context are managed automatically by OpenRouter based on model capabilities.

---

## 7. BYOK behavior

When you have a BYOK API key configured for a provider, OpenRouter prioritizes endpoints that can use it. Combined with `partition: "none"` on multi-model requests, this lets the router cross model boundaries to keep using your key — useful when your primary model has no BYOK provider but a fallback does.

---

## 8. Quantization

`provider.quantizations` accepts: `int4`, `int8`, `fp4`, `fp6`, `fp8`, `fp16`, `bf16`, `fp32`, `unknown`. Lower bit-widths reduce cost but can degrade quality on certain prompts. Validate empirically before pinning a quantization in production.

---

## 9. `max_price` shape

```json
{
  "provider": {
    "max_price": {
      "prompt": 1,
      "completion": 2,
      "request": 0.005,
      "image": 0.01
    }
  }
}
```

- `prompt` / `completion`: USD per million tokens.
- `request`: USD per request (only some providers support per-request pricing).
- `image`: USD per image.

Unlike `preferred_*` thresholds, `max_price` is **hard** — if no provider qualifies, the request fails rather than running on a more expensive provider.

---

## 10. Free Models Router (`openrouter/free`)

`openrouter/free` is a router slug, not a model. Setting `model: "openrouter/free"` causes OpenRouter to randomly select an available free model and forward the request. The response's `model` field reports which model actually ran.

Per the docs, the router filters available free models by request capability (vision, tools, structured outputs) before random selection. **Empirically this filter is unreliable** — the router can return a model that lacks the requested capability. Treat `openrouter/free` as text-only safe; for anything that needs a specific capability, pin a `:free` slug instead.

Pricing: zero. Both the router and the routed-to free model are free.

Limitations:
- Lower rate limits than paid endpoints; can be unavailable at peak.
- No control over which specific model runs — the response varies request-to-request.
- Not appropriate for tests/CI where reproducible model behavior matters.

When to use:
- Plain text chat / completion.
- Experimentation, prototyping, learning.

When **not** to use:
- Image, audio, or file input.
- Requests with `tools`, `response_format`, structured-output schemas.
- Requests that need web search.
- Workloads requiring a specific model family or predictable behavior.

---

## 11. Practical defaults the agent should write into apps

| Concern | Default |
|---|---|
| Dev model slug, plain text | `openrouter/free` (Free Models Router) |
| Dev model slug, capability-specific | `<base-model>:free` (verify in `/models`) |
| Prod model slug | base slug + `provider.sort: "price"` (or `:floor`) + `max_price` ceiling |
| Tools / JSON | `provider.require_parameters: true` |
| Privacy-sensitive | `provider.data_collection: "deny"`, optionally `provider.zdr: true` |
| Identification headers | `HTTP-Referer: <app-url>`, `X-Title: <app-name>` on every request |
| Web search | `tools: [{ "type": "openrouter:web_search" }]` (server tool) |
| Image input | check `architecture.input_modalities` includes `"image"` before committing the slug |
