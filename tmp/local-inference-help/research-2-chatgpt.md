# Phase-Based Switching Between Local and Commercial Models on 48GB Apple Silicon

## Executive summary

Your new constraint—**no dynamic routing per agent or per task**, only **phase-level switching** (entire phase runs local *or* commercial), with commercial models “picking up the slack” during **validation checkpoints**—changes the outcome in a decisive way:

- The “best” architecture is no longer “right-fit every agent to the cheapest capable model.” Instead, it becomes: **choose 1–2 local foundation models that can reliably run for hours**, then use **commercial validation gates** to detect mistakes early, produce short actionable deltas, and force corrections before the workflow proceeds. This reduces configuration complexity substantially while keeping quality high. citeturn1view0turn34view1  
- With your provided model list, the local “go-to” conclusion is broadly right: the **Qwen3.5/Qwen3-Coder lines dominate the local Pareto frontier** for Apple Silicon (long context + tool use + strong speed/fit). But the practical shortlist becomes even narrower: **one local generalist** and **optionally one local coder**. citeturn4view0turn22view0turn2search0turn2search1  
- A key correction: some items in your list are **not actually MLX-friendly as-is** (notably the NVFP4 “txn545” checkpoint is described as optimized for entity["company","NVIDIA","gpu company"] Blackwell/Linux and served via SGLang). Treat NVFP4 as **NVIDIA-serving–oriented**, and use the MLX conversions (e.g., **mlx-community**) for Apple Silicon. citeturn1view2turn2search1  

The simplified “phase switch + commercial validation” pattern is feasible and often a good trade: commercial spend shifts from “generate everything” to “spot issues + prescribe corrections,” so **commercial output tokens shrink** (important because output is priced much higher than input for many commercial models). citeturn31search1turn31search0  

## What your new rule implies architecturally

### The workflow becomes a two-engine pipeline

Under phase-only switching, you implicitly define two “engines”:

- **Local engine**: generates most artifacts (plans, code, docs) at effectively zero marginal cost, bounded by your entity["company","Apple","consumer electronics company"] unified memory and the model’s KV-cache behavior. citeturn4view0turn22view0  
- **Commercial engine** (ChatGPT / Claude): runs at **explicit validation boundaries**, where it (1) reads a set of artifacts and (2) emits a structured, prioritized defect list with fixes. It does *not* need to write full artifacts unless local fails repeatedly.

This changes “best model selection” from “per agent” to “per engine”:

- Local: you want the **fewest models possible** (ideally one) to avoid conversion/serving/workflow complexity.
- Commercial: you want the **fewest subscriptions/providers possible** (ideally one) to avoid switching overhead and inconsistent style—unless you have a strong reason to keep both.

### Commercial “picking up the slack” works best when validation outputs are enforced

To get the quality outcome you want without dynamic routing, the validator’s output must be *actionable and binding*. The validator should emit:

- a checklist of **Pass/Fail** gates per artifact section,
- a minimal set of changes required,
- and (crucially) **file/section anchors** so the local model can patch precisely.

This aligns well with high-context commercial validators (Claude Sonnet/Opus) and with your plan to run validation phases as checkpoints. Claude explicitly publishes long-context pricing and a “premium pricing applies over 200k input tokens” rule for Sonnet/Opus tiers, which matters if you validate full plan directories. citeturn31search1turn31search10  

## Local shortlist from your model list for a low-complexity setup

You provided the missing full list. The main goal now is not “best in every category,” but **minimum set that stays stable**. Below are the practical takeaways, grounded in primary model cards/configs and MLX conversion availability.

### One-model local setup: Qwen3.5-35B-A3B as the universal local workhorse

If you want *maximum simplicity*, the strongest candidate is:

- **Qwen/Qwen3.5-35B-A3B**, using an MLX-converted checkpoint such as **mlx-community/Qwen3.5-35B-A3B-4bit**. The MLX community explicitly states it’s converted to MLX format from the base model. citeturn2search0turn4view0  

Why this model is unusually well-suited to your “one local model” goal:

- It is **multimodal (image-text-to-text)** per its config (vision_config present), so you can cover “Design/UI-UX” without a separate local VLM if you accept the model’s vision quality. citeturn4view0  
- It is designed for **very long context** (262,144 tokens), and the model card explicitly recommends keeping at least **128K context** to preserve thinking capability (while acknowledging OOM risk). citeturn1view0turn4view0  
- Architecturally, the config shows **full_attention_interval=4** and a layer_types pattern mixing linear_attention and full_attention. This implies the “classic KV cache” growth pressure is lower than a fully-attentive transformer at the same context, which is favorable for Apple unified memory. citeturn4view0  
- Real-world Apple Silicon benchmarks vary by runtime, but there is active community benchmarking showing meaningful speed differences between MLX-based runtimes and other stacks; the practical implication is: **use MLX-native when possible**, test your serving stack, and treat headline TPS estimates as optimistic until verified. citeturn2search11turn2search4  

If you adopt this one-model approach, you can still keep specialized models “available,” but you do not need to operationalize them initially.

### Two-model local setup: add Qwen3-Coder-30B-A3B for higher coding quality

If your primary risk is “local planning is fine, but local code quality needs headroom,” add:

- **Qwen3-Coder-30B-A3B-Instruct (MLX quant)** as your coding engine. Its published config (MoE, 48 layers, GQA with 32 Q heads / 4 KV heads, 262K context) plus its model card guidance around OOM/context make it a well-understood local coding candidate. citeturn22view0turn19search6  

Why it’s still compatible with your “phase-only” rule:

- You would switch local models only at **phase boundaries** (“Planning phase uses 35B; Execution phase uses Coder”), not dynamically per agent/task.
- The coding model has a different KV profile than Qwen3.5-35B (because it has more KV heads), so you should impose stricter default context limits in execution to avoid KV explosion. citeturn22view0turn19search6  

### Why the “bigger local” options are not good defaults on 48GB

Your list includes several “marginal” 80B-class MoE models (Qwen3-Coder-Next, Qwen3-Next-80B-A3B). The configs show hybrid/linear attention patterns and only 2 KV heads, which helps long contexts, but the decisive issue is still **weight residency** versus your effective usable memory budget. citeturn1view1turn4view1  

- **Qwen3-Coder-Next** is explicitly 80B total with 3B activated, but it still has 512 experts and large total weights; your list shows ~41GB required before considering OS/IDE overhead. citeturn1view1turn4view1  
- On a workstation where you also run an IDE and background processes, “41GB model + everything else” tends to be fragile unless you fully commit the machine to inference during that phase.

Hence: treat 80B models as **occasional “deep local coding sprint” experiments**, not the stable baseline for phase switching.

### NVFP4 note: why the txn545 Qwen3.5-122B NVFP4 entry is misleading for Apple Silicon

Your list includes **txn545/Qwen3.5-122B-A10B-NVFP4** as “MLX, 33GB.” The actual model page describes:

- quantization using NVIDIA Model Optimizer,
- compatibility with NVIDIA Blackwell,
- preferred OS Linux,
- and serving via SGLang. citeturn1view2  

That description does not match MLX-on-macOS usage. If you want Qwen3.5-122B locally on Apple Silicon, use an MLX conversion such as **mlx-community/Qwen3.5-122B-A10B-4bit/5bit**. citeturn2search1turn2search7  

Even then, 122B is complexity you said you want to avoid right now—so I’d classify it as “later.”

### Where Tongyi DeepResearch fits in a simplified setup

Alibaba-NLP’s Tongyi DeepResearch is designed for deep research and tool/agent paradigms (ReAct / “Heavy” IterResearch). The repo explicitly lists **128K context** and positions it as an agentic research model. citeturn5view1turn5view0  

However, in a phase-only switching system, it’s usually *overkill* because:

- Your “commercial validation” already handles deep cross-document reasoning when needed.
- Introducing Tongyi adds prompt format/tooling assumptions specific to its agentic paradigm, increasing complexity. citeturn5view0turn5view1  

Recommendation: keep it as a **future optional local validator/researcher**, not in the first simplified cut.

## How the phase map changes when you ban dynamic routing

Below is a practical phase allocation that matches your intent: local does most generation; commercial validates at boundaries.

The “phase-only” principle means you should define phases that are *meaningful quality control gates*, not “microsteps.” The phases below correspond closely to your original SDLC breakdown (planning → per-story planning loop → cross-cutting → full validation → execution loop → acceptance). citeturn1view0turn5view1  

### Recommended phase allocation

| Phase | Run on | Local model | Commercial model role | Output style (to reduce cost) |
|---|---|---|---|---|
| Planning draft (PRD + architecture + story decomposition) | Local | Qwen3.5-35B-A3B (MLX 4bit) citeturn2search0turn4view0 | Not used in this phase | Full documents |
| Planning validation gate | Commercial | — | Claude (Sonnet/Opus) reviews entire PRD/arch/story set; outputs issue list | Short structured issue list + required edits citeturn31search1turn31search0 |
| Story-level design loop (HLD/API/Data/Security per story) | Local | Same local model(s) as planning | Not used in this phase | Per-story docs |
| Story-level validation gate | Commercial | — | Commercial checks cross-doc consistency per story | Short deltas; “fix these 5 items” |
| Execution loop (implement + local review + QA) | Local | Option A: one-model (Qwen3.5-35B) Option B: coder-model (Qwen3-Coder-30B) citeturn4view0turn22view0 | Not used in this phase | Code patches + short local checks |
| Story completion validation gate | Commercial | — | Commercial runs high-signal code review + acceptance checklist | Pass/Fail + “must-fix” list |
| Final project validation (full plan + codebase acceptance) | Commercial | — | Commercial is the “quality backstop” if anything is still inconsistent | Final pass/fail with citations |

This preserves your goal: **local phases stay pure local**, and commercial phases are cleanly isolated checkpoints.

### The key shift in mindset

In the earlier “dynamic routing” approach, you would try to prevent rework by always choosing the right model upfront per agent.

In this new approach, you accept that **local may be “good enough but imperfect,”** and you control quality via:

- structured commercial validation gates,
- short, explicit correction requirements,
- and limited retries before a manual escalation (e.g., “rerun the whole planning phase directly on Claude”).

This is often psychologically and operationally simpler.

## Practical implications for memory, context, and serving

### Why Qwen3.5-35B is a sweet spot for long-context work on Apple Silicon

Qwen3.5-35B’s config indicates:

- **full_attention_interval=4**
- **num_hidden_layers=40**
- **num_key_value_heads=2**
- **head_dim=256**
- mixed attention layer_types including linear_attention and periodic full_attention. citeturn4view0  

For long-context “thinking,” this structure is favorable because (even if we only consider full-attention layers in the classic KV-cache sense) KV growth is less punishing than a model with full attention at every layer. Practically: you can run 64K–128K contexts more comfortably than you might expect at this parameter count, assuming the MLX-converted weights fit your memory envelope. citeturn1view0turn2search0  

### Why Qwen3-Coder-30B is still the safer local execution default than Coder-Next

Qwen3-Coder-Next is architecturally efficient (hybrid layout, 2 KV heads, 262K context), but it’s still 80B total parameters and a large expert set; the config shows 512 experts and 10 experts per token. citeturn1view1turn4view1  

For a 48GB Mac that also runs an IDE, the operational risk is:

- memory tightness,
- increased sensitivity to background memory pressure,
- and the inability to keep even a second small model resident.

That’s why, for a low-complexity “phase-only” setup, the 30B coder is the safer default. citeturn22view0turn1view1  

### Serving stack: keep it minimal—and compatible with your IDE

Given your desire to keep things simple, you want one local server that:

- serves MLX models,
- exposes **OpenAI-compatible** endpoints so your tooling can switch with minimal friction. citeturn15search16turn13view0  

The baseline “simple” option remains:

- MLX-LM server (OpenAI-like API) for development use, with the explicit caveat that it’s not positioned as production-grade. citeturn15search16  

If you later reintroduce complexity (multi-model concurrency, caching, robust agent support), projects like oMLX exist specifically to tackle multi-model serving and caching constraints, but you explicitly said “complex for my taste right now,” so I’d defer that. citeturn16view0  

## Recommended next steps and a minimal deliverable set

### The simplest “good” configuration to start with

- Local: Qwen3.5-35B-A3B (MLX 4bit) as **the only local model**. citeturn2search0turn4view0  
- Commercial: pick **one** primary validator (either Claude or ChatGPT) and stick to it across validation gates to reduce style variance and operational friction.

If you discover that code quality is the limiting factor, introduce **one more local model**:

- Qwen3-Coder-30B-A3B for the entire execution loop phase (still phase-only switching). citeturn22view0turn19search6  

### A concrete “commercial gate” specification that keeps costs down

For commercial validations, constrain outputs to:

- a fixed schema (“Issue ID, severity, file/section, evidence, required fix, acceptance test”),  
- and set a hard max output length (e.g., 800–1500 tokens per gate).

This exploits the fact that Claude pricing is output-heavy relative to input (and long-context premium pricing triggers above 200k input), so keeping outputs short matters. citeturn31search1turn31search0  

### Visual timeline of phase switching

```mermaid
flowchart TB
  A[Local Planning Phase\n(Qwen3.5-35B)] --> B[Commercial Validation Gate\n(Claude/ChatGPT)]
  B --> C[Local Story Design Loop\n(Qwen3.5-35B)]
  C --> D[Commercial Story Validation Gate]
  D --> E[Local Execution Loop\n(Qwen3.5-35B or Qwen3-Coder-30B)]
  E --> F[Commercial Story Completion Gate]
  F --> G[Commercial Final Validation]
```

### What changed versus the original research direction

- You no longer need a 17-row per-agent routing matrix with local/free/commercial fallbacks.
- You do need a **small number of well-defined “handoff packages”** (what artifacts are passed into each commercial gate).
- The “best local model” question collapses into: **Which single local model can cover planning + light validation + (maybe) coding without you thinking about it?** Your list strongly supports Qwen3.5-35B-A3B as that answer right now, especially given MLX-ready conversions. citeturn2search0turn4view0  

### Remaining missing info that would materially affect the final decision

- Which exact Apple Silicon chip (M2 vs M3 vs M4) and your preferred runtime (LM Studio MLX engine vs raw MLX libraries) — community reports show meaningful differences. citeturn2search11turn2search4  
- Whether your validation gates require **Responses API** compatibility in a specific IDE mode (Cursor Agent vs VS Code extension ecosystems may differ). If you keep validation “human-in-the-loop” (copy/paste artifacts into Claude/ChatGPT), this becomes irrelevant and the system becomes much simpler. citeturn14search1turn14search11