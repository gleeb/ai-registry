#!/usr/bin/env python3
"""
OpenCode Full Transcript Exporter

Connects to the OpenCode HTTP API, recursively walks the session tree from a
root session, fetches all messages/parts (including thinking, tool calls, code
diffs) from every sub-agent, and assembles a complete chronologically-ordered
markdown transcript.

Usage:
    python export_transcript.py <session_id> [--url URL] [-o FILE] [--json] [--max-depth N]
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import textwrap
from datetime import datetime, timezone
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

# ---------------------------------------------------------------------------
# HTTP helpers (stdlib only — no requests dependency)
# ---------------------------------------------------------------------------

def api_get(base_url: str, path: str) -> Any:
    url = f"{base_url.rstrip('/')}{path}"
    req = Request(url, headers={"Accept": "application/json"})
    try:
        with urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode())
    except HTTPError as exc:
        body = exc.read().decode() if exc.fp else ""
        print(f"HTTP {exc.code} from {url}: {body}", file=sys.stderr)
        raise SystemExit(1)
    except URLError as exc:
        print(f"Connection failed ({url}): {exc.reason}", file=sys.stderr)
        print("Is the OpenCode server running? Start it with: opencode serve", file=sys.stderr)
        raise SystemExit(1)

# ---------------------------------------------------------------------------
# Data fetching
# ---------------------------------------------------------------------------

def fetch_session(base_url: str, session_id: str) -> dict:
    return api_get(base_url, f"/session/{session_id}")


def fetch_children(base_url: str, session_id: str) -> list[dict]:
    return api_get(base_url, f"/session/{session_id}/children")


def fetch_messages(base_url: str, session_id: str) -> list[dict]:
    return api_get(base_url, f"/session/{session_id}/message")


def fetch_diff(base_url: str, session_id: str) -> list[dict]:
    try:
        return api_get(base_url, f"/session/{session_id}/diff")
    except SystemExit:
        return []


def fetch_session_tree(
    base_url: str,
    root_id: str,
    max_depth: int = 20,
) -> dict[str, dict]:
    """Recursively fetch root + all descendants. Returns {id: session}."""
    sessions: dict[str, dict] = {}

    def _walk(sid: str, depth: int) -> None:
        if sid in sessions or depth > max_depth:
            return
        sess = fetch_session(base_url, sid)
        sessions[sid] = sess
        for child in fetch_children(base_url, sid):
            cid = child.get("id", "")
            if cid:
                sessions[cid] = child
                _walk(cid, depth + 1)

    _walk(root_id, 0)
    return sessions


def discover_child_sessions_from_messages(
    base_url: str,
    sessions: dict[str, dict],
    messages_cache: dict[str, list[dict]],
    max_depth: int = 20,
) -> None:
    """Scan task tool outputs for child session IDs not found via the children API.

    Iterates until no new sessions are discovered (fixed-point), so deeply
    nested task-spawned sub-agents are captured even when the /children
    endpoint doesn't link them.
    """
    visited: set[str] = set()

    while True:
        new_ids: set[str] = set()
        for sid in list(sessions):
            if sid in visited:
                continue
            visited.add(sid)
            if sid not in messages_cache:
                messages_cache[sid] = fetch_messages(base_url, sid)
            for msg in messages_cache[sid]:
                for part in msg.get("parts", []):
                    if part.get("type") == "tool" and part.get("tool") == "task":
                        state = part.get("state", {})
                        for text in [state.get("output", ""), state.get("error", "")]:
                            child_id = extract_child_session_id(text)
                            if child_id and child_id not in sessions:
                                new_ids.add(child_id)
        if not new_ids:
            break
        for cid in new_ids:
            try:
                sess = fetch_session(base_url, cid)
                sessions[cid] = sess
                print(f"  Discovered child session {cid} from task output", file=sys.stderr)
            except SystemExit:
                print(f"  Warning: could not fetch child session {cid}", file=sys.stderr)


# ---------------------------------------------------------------------------
# Formatting helpers
# ---------------------------------------------------------------------------

def ts_to_dt(ts: int | float | None) -> datetime | None:
    if not ts:
        return None
    if ts > 1e12:
        ts = ts / 1000.0
    return datetime.fromtimestamp(ts, tz=timezone.utc)


def fmt_time(ts: int | float | None) -> str:
    dt = ts_to_dt(ts)
    return dt.strftime("%H:%M:%S") if dt else "??:??:??"


def fmt_datetime(ts: int | float | None) -> str:
    dt = ts_to_dt(ts)
    return dt.isoformat(timespec="seconds") if dt else "unknown"


def fmt_duration_ms(start: int | float | None, end: int | float | None) -> str:
    if not start or not end:
        return ""
    ms = end - start
    if ms < 0:
        ms = abs(ms)
    if ms > 1e10:
        ms = ms / 1.0
    if ms > 1e12:
        start_s = start / 1000.0 if start > 1e12 else start
        end_s = end / 1000.0 if end > 1e12 else end
        secs = end_s - start_s
    else:
        secs = ms / 1000.0

    if secs < 0:
        secs = abs(secs)
    if secs < 60:
        return f"{secs:.1f}s"
    minutes = int(secs // 60)
    remaining = secs % 60
    if minutes < 60:
        return f"{minutes}m{remaining:.0f}s"
    hours = minutes // 60
    mins = minutes % 60
    return f"{hours}h{mins}m{remaining:.0f}s"


def fmt_cost(cost: float | None) -> str:
    if cost is None or cost == 0:
        return ""
    return f"${cost:.4f}"


def fmt_tokens(tokens: dict | None) -> str:
    if not tokens:
        return ""
    parts = []
    inp = tokens.get("input", 0)
    out = tokens.get("output", 0)
    reas = tokens.get("reasoning", 0)
    cache = tokens.get("cache", {})
    cr = cache.get("read", 0)
    cw = cache.get("write", 0)
    if inp:
        parts.append(f"{inp:,} in")
    if out:
        parts.append(f"{out:,} out")
    if reas:
        parts.append(f"{reas:,} reasoning")
    if cr:
        parts.append(f"{cr:,} cache-read")
    if cw:
        parts.append(f"{cw:,} cache-write")
    return " / ".join(parts)


def indent(text: str, depth: int) -> str:
    prefix = "> " * depth
    if not prefix:
        return text
    lines = text.split("\n")
    return "\n".join(prefix + line if line.strip() else prefix.rstrip() for line in lines)


CHILD_SESSION_RE = re.compile(r"(ses_[A-Za-z0-9]{5,})")


def extract_child_session_id(output: str) -> str | None:
    """Extract a session ID from task tool output."""
    m = CHILD_SESSION_RE.search(output or "")
    return m.group(1) if m else None

# ---------------------------------------------------------------------------
# Aggregation
# ---------------------------------------------------------------------------

class SessionStats:
    def __init__(self) -> None:
        self.total_cost: float = 0.0
        self.total_input: int = 0
        self.total_output: int = 0
        self.total_reasoning: int = 0
        self.total_cache_read: int = 0
        self.total_cache_write: int = 0
        self.tool_counts: dict[str, int] = {}
        self.child_count: int = 0
        self.child_completed: int = 0
        self.child_aborted: int = 0
        self.child_error: int = 0
        self.earliest_ts: float | None = None
        self.latest_ts: float | None = None

    def add_message(self, info: dict) -> None:
        self.total_cost += info.get("cost", 0) or 0
        tokens = info.get("tokens", {})
        self.total_input += tokens.get("input", 0) or 0
        self.total_output += tokens.get("output", 0) or 0
        self.total_reasoning += tokens.get("reasoning", 0) or 0
        cache = tokens.get("cache", {})
        self.total_cache_read += cache.get("read", 0) or 0
        self.total_cache_write += cache.get("write", 0) or 0

        created = info.get("time", {}).get("created")
        completed = info.get("time", {}).get("completed")
        for t in [created, completed]:
            if t:
                if self.earliest_ts is None or t < self.earliest_ts:
                    self.earliest_ts = t
                if self.latest_ts is None or t > self.latest_ts:
                    self.latest_ts = t

    def add_tool(self, tool_name: str) -> None:
        self.tool_counts[tool_name] = self.tool_counts.get(tool_name, 0) + 1

    def merge(self, other: "SessionStats") -> None:
        self.total_cost += other.total_cost
        self.total_input += other.total_input
        self.total_output += other.total_output
        self.total_reasoning += other.total_reasoning
        self.total_cache_read += other.total_cache_read
        self.total_cache_write += other.total_cache_write
        for k, v in other.tool_counts.items():
            self.tool_counts[k] = self.tool_counts.get(k, 0) + v
        self.child_count += other.child_count
        self.child_completed += other.child_completed
        self.child_aborted += other.child_aborted
        self.child_error += other.child_error
        if other.earliest_ts:
            if self.earliest_ts is None or other.earliest_ts < self.earliest_ts:
                self.earliest_ts = other.earliest_ts
        if other.latest_ts:
            if self.latest_ts is None or other.latest_ts > self.latest_ts:
                self.latest_ts = other.latest_ts

    def summary_line(self) -> str:
        parts = []
        if self.total_cost:
            parts.append(f"**Total cost:** {fmt_cost(self.total_cost)}")
        tok = fmt_tokens({
            "input": self.total_input,
            "output": self.total_output,
            "reasoning": self.total_reasoning,
            "cache": {"read": self.total_cache_read, "write": self.total_cache_write},
        })
        if tok:
            parts.append(f"**Tokens:** {tok}")
        if self.earliest_ts and self.latest_ts:
            dur = fmt_duration_ms(self.earliest_ts, self.latest_ts)
            if dur:
                parts.append(f"**Duration:** {dur}")
        return " | ".join(parts)

    def tools_line(self) -> str:
        if not self.tool_counts:
            return ""
        items = sorted(self.tool_counts.items(), key=lambda x: -x[1])
        return "**Tools:** " + ", ".join(f"{name} ({count})" for name, count in items)

    def children_line(self) -> str:
        if not self.child_count:
            return ""
        parts = [f"**Child sessions:** {self.child_count}"]
        breakdown = []
        if self.child_completed:
            breakdown.append(f"{self.child_completed} completed")
        if self.child_aborted:
            breakdown.append(f"{self.child_aborted} aborted")
        if self.child_error:
            breakdown.append(f"{self.child_error} errored")
        if breakdown:
            parts.append(f"({', '.join(breakdown)})")
        return " ".join(parts)


# ---------------------------------------------------------------------------
# Transcript rendering
# ---------------------------------------------------------------------------

def render_part(part: dict, depth: int) -> str:
    """Render a single message part to markdown."""
    ptype = part.get("type", "")
    lines: list[str] = []

    if ptype == "text":
        text = part.get("text", "")
        if text.strip():
            lines.append(text)

    elif ptype == "reasoning":
        text = part.get("reasoning", "") or part.get("text", "")
        if text and text.strip():
            truncated = text
            if len(truncated) > 5000:
                truncated = truncated[:5000] + "\n... [truncated, full content in --json output]"
            lines.append(f"_Thinking:_\n{truncated}")
        else:
            lines.append("_Thinking: (empty/redacted)_")

    elif ptype == "tool":
        tool_name = part.get("tool", "unknown")
        state = part.get("state", {})
        status = state.get("status", "unknown")
        inp = state.get("input", {})
        output = state.get("output", "")
        error = state.get("error", "")
        title = state.get("title", "")
        time_info = state.get("time", {})
        duration = fmt_duration_ms(time_info.get("start"), time_info.get("end"))
        dur_str = f" ({duration})" if duration else ""

        header = f"**Tool: {tool_name}**{dur_str}"
        if status == "error":
            header += " -- ERROR"
        lines.append(header)

        if title:
            lines.append(f"_{title}_")

        if inp:
            inp_str = json.dumps(inp, indent=2, ensure_ascii=False)
            lines.append(f"<details><summary>Input</summary>\n\n```json\n{inp_str}\n```\n</details>")

        if output:
            out_str = str(output)
            if len(out_str) > 3000:
                out_str = out_str[:3000] + "\n... [truncated]"
            lines.append(f"<details><summary>Output</summary>\n\n```\n{out_str}\n```\n</details>")

        if error:
            lines.append(f"**Error:** `{error}`")

    elif ptype == "step-start":
        snapshot = part.get("snapshot", "")
        if snapshot:
            lines.append(f"_Step start · snapshot: `{snapshot[:12]}`_")

    elif ptype == "step-finish":
        reason = part.get("reason", "")
        cost = part.get("cost", 0)
        tokens = part.get("tokens", {})
        snapshot = part.get("snapshot", "")
        meta_parts = []
        if reason:
            meta_parts.append(f"reason: {reason}")
        if cost:
            meta_parts.append(f"cost: {fmt_cost(cost)}")
        tok_str = fmt_tokens(tokens)
        if tok_str:
            meta_parts.append(tok_str)
        if snapshot:
            meta_parts.append(f"snapshot: `{snapshot[:12]}`")
        if meta_parts:
            lines.append(f"_Step finish · {' · '.join(meta_parts)}_")

    elif ptype == "file":
        filename = part.get("filename", "")
        mime = part.get("mime", "")
        lines.append(f"**File:** `{filename}` ({mime})")

    elif ptype == "patch":
        lines.append("**Patch applied**")

    elif ptype == "subtask":
        prompt = part.get("prompt", "")
        agent = part.get("agent", "")
        desc = part.get("description", "")
        lines.append(f"**Subtask:** {desc} (agent: {agent})")
        if prompt:
            short = prompt[:500] + "..." if len(prompt) > 500 else prompt
            lines.append(f"<details><summary>Prompt</summary>\n\n{short}\n</details>")

    elif ptype == "compaction":
        lines.append("_--- Context compacted ---_")

    elif ptype == "retry":
        lines.append("_--- Retry ---_")

    else:
        lines.append(f"_[{ptype} part]_")

    block = "\n\n".join(lines)
    return indent(block, depth) if depth > 0 else block


def render_message_header(info: dict, depth: int) -> str:
    """Render the header for a message (user or assistant)."""
    role = info.get("role", "unknown")
    time_created = info.get("time", {}).get("created")
    ts = fmt_time(time_created)

    if role == "user":
        header = f"## [{ts}] User"
    else:
        provider = info.get("providerID", "")
        model = info.get("modelID", "")
        model_str = f"{provider}/{model}" if provider else model
        mode = info.get("mode", "")
        cost = info.get("cost", 0)
        tokens = info.get("tokens", {})
        time_info = info.get("time", {})
        duration = fmt_duration_ms(time_info.get("created"), time_info.get("completed"))

        label_parts = []
        if mode:
            label_parts.append(mode)
        if model_str:
            label_parts.append(model_str)
        if cost:
            label_parts.append(fmt_cost(cost))
        if duration:
            label_parts.append(duration)

        header = f"## [{ts}] Assistant"
        if label_parts:
            header += f" ({' · '.join(label_parts)})"

        tok_str = fmt_tokens(tokens)
        if tok_str:
            header += f"\n_{tok_str}_"

        error = info.get("error")
        if error:
            ename = error.get("name", "Error")
            emsg = error.get("data", {}).get("message", "")
            header += f"\n**Error [{ename}]:** {emsg}"

    if depth > 0:
        hashes = "#" * min(depth + 2, 6)
        header = header.replace("## ", f"{hashes} ", 1)

    return indent(header, depth) if depth > 0 else header


def render_diff(diffs: list[dict], depth: int) -> str:
    if not diffs:
        return ""
    total_add = sum(d.get("additions", 0) for d in diffs)
    total_del = sum(d.get("deletions", 0) for d in diffs)
    n_files = len(diffs)
    header = f"Code Diff (+{total_add} / -{total_del}, {n_files} file{'s' if n_files != 1 else ''})"

    diff_blocks = []
    for d in diffs:
        fname = d.get("file", "unknown")
        before = d.get("before", "")
        after = d.get("after", "")
        adds = d.get("additions", 0)
        dels = d.get("deletions", 0)
        diff_blocks.append(f"### {fname} (+{adds} / -{dels})")
        if after and not before:
            diff_blocks.append(f"```\n{after[:2000]}\n```")
        elif before and not after:
            diff_blocks.append("_(file deleted)_")
        else:
            diff_blocks.append(f"```\n{(after or before)[:2000]}\n```")

    body = "\n\n".join(diff_blocks)
    block = f"<details><summary>{header}</summary>\n\n{body}\n</details>"
    return indent(block, depth) if depth > 0 else block


def render_session(
    base_url: str,
    session_id: str,
    sessions: dict[str, dict],
    messages_cache: dict[str, list[dict]],
    diffs_cache: dict[str, list[dict]],
    depth: int = 0,
    global_stats: SessionStats | None = None,
    max_depth: int = 20,
) -> tuple[str, SessionStats]:
    """Render a full session transcript, inlining child sessions at task call sites."""
    if depth > max_depth:
        return indent("_[max depth reached]_", depth), SessionStats()

    session = sessions.get(session_id, {})
    title = session.get("title", "")
    stats = SessionStats()

    # Fetch messages if not cached
    if session_id not in messages_cache:
        messages_cache[session_id] = fetch_messages(base_url, session_id)
    msgs = messages_cache[session_id]

    # Fetch diff if not cached
    if session_id not in diffs_cache:
        diffs_cache[session_id] = fetch_diff(base_url, session_id)
    diffs = diffs_cache[session_id]

    # Track children for matching task calls -> child sessions
    children = fetch_children(base_url, session_id)
    child_ids = {c["id"] for c in children if "id" in c}
    stats.child_count = len(child_ids)

    # Index children by their ID for quick lookup
    child_sessions_by_id: dict[str, dict] = {}
    for c in children:
        cid = c.get("id", "")
        if cid:
            child_sessions_by_id[cid] = c
            if cid not in sessions:
                sessions[cid] = c

    # Track which child sessions we've inlined (to catch stragglers)
    inlined_children: set[str] = set()

    # Pre-sort children by creation time for fallback matching
    children_by_time = sorted(
        [c for c in children if c.get("id")],
        key=lambda c: c.get("time", {}).get("created", 0),
    )
    unmatched_child_iter = iter(children_by_time)

    output_parts: list[str] = []

    # Session header (only for child sessions rendered inline)
    if depth > 0:
        agent_name = ""
        model_str = ""
        # Try to get agent/model from first assistant message
        for msg in msgs:
            info = msg.get("info", {})
            if info.get("role") == "assistant":
                agent_name = info.get("mode", "")
                provider = info.get("providerID", "")
                model = info.get("modelID", "")
                model_str = f"{provider}/{model}" if provider else model
                break

        hashes = "#" * min(depth + 1, 6)
        subheader = f"{hashes} Sub-agent: {agent_name or 'unknown'}"
        if title:
            subheader += f' -- "{title}"'
        output_parts.append(indent(subheader, depth))

        meta_parts = []
        if model_str:
            meta_parts.append(f"**Model:** {model_str}")
        meta_parts.append(f"**Session:** `{session_id}`")
        created = session.get("time", {}).get("created")
        if created:
            meta_parts.append(f"**Created:** {fmt_datetime(created)}")
        if meta_parts:
            output_parts.append(indent(" | ".join(meta_parts), depth))

    # Render each message
    for msg in msgs:
        info = msg.get("info", {})
        parts = msg.get("parts", [])

        if info.get("role") == "assistant":
            stats.add_message(info)

        output_parts.append("")
        output_parts.append(render_message_header(info, depth))

        for part in parts:
            ptype = part.get("type", "")

            # Special handling for task tool calls -- inline child session
            if ptype == "tool" and part.get("tool") == "task":
                stats.add_tool("task")
                state = part.get("state", {})
                output_text = state.get("output", "")
                error_text = state.get("error", "")
                inp = state.get("input", {})
                time_info = state.get("time", {})
                duration = fmt_duration_ms(time_info.get("start"), time_info.get("end"))
                dur_str = f" ({duration})" if duration else ""
                desc = inp.get("description", "")
                agent = inp.get("subagent_type", "")

                child_sid = extract_child_session_id(output_text or error_text or "")

                # On-demand fetch: if the session wasn't in the pre-built tree,
                # try fetching it directly from the API.
                if child_sid and child_sid not in sessions:
                    try:
                        sess = fetch_session(base_url, child_sid)
                        sessions[child_sid] = sess
                    except SystemExit:
                        child_sid = None

                # Fallback: if we can't extract from output, try next unmatched child
                if not child_sid or child_sid not in sessions:
                    for fallback in unmatched_child_iter:
                        fid = fallback.get("id", "")
                        if fid and fid not in inlined_children and fid in sessions:
                            child_sid = fid
                            break

                tool_header = f"**Tool: task**{dur_str}"
                if child_sid:
                    tool_header += f" -> `{child_sid}`"
                if desc:
                    tool_header += f'\n_{desc}_'
                output_parts.append("")
                output_parts.append(indent(tool_header, depth))

                if error_text and not child_sid:
                    output_parts.append(indent(f"**Error:** `{error_text}`", depth))

                # Inline the child session
                if child_sid and child_sid in sessions:
                    inlined_children.add(child_sid)
                    child_transcript, child_stats = render_session(
                        base_url, child_sid, sessions,
                        messages_cache, diffs_cache,
                        depth=depth + 1,
                        global_stats=global_stats,
                        max_depth=max_depth,
                    )
                    stats.merge(child_stats)
                    # Classify child
                    child_sess = sessions.get(child_sid, {})
                    # Check last message for error
                    child_msgs = messages_cache.get(child_sid, [])
                    has_error = any(
                        m.get("info", {}).get("error") for m in child_msgs
                        if m.get("info", {}).get("role") == "assistant"
                    )
                    if error_text:
                        stats.child_aborted += 1
                    elif has_error:
                        stats.child_error += 1
                    else:
                        stats.child_completed += 1

                    output_parts.append("")
                    output_parts.append(child_transcript)
                elif child_sid:
                    output_parts.append(indent("_[child session not found in tree]_", depth + 1))
                elif error_text:
                    stats.child_aborted += 1

                continue

            # Regular tool call
            if ptype == "tool":
                stats.add_tool(part.get("tool", "unknown"))

            rendered = render_part(part, depth)
            if rendered.strip():
                output_parts.append("")
                output_parts.append(rendered)

    # Render any child sessions not matched to a task call
    for cid in child_ids - inlined_children:
        if cid in sessions:
            output_parts.append("")
            orphan_note = indent(f"_[child session not matched to a task call]_", depth + 1)
            output_parts.append(orphan_note)
            child_transcript, child_stats = render_session(
                base_url, cid, sessions,
                messages_cache, diffs_cache,
                depth=depth + 1,
                global_stats=global_stats,
                max_depth=max_depth,
            )
            stats.merge(child_stats)
            output_parts.append(child_transcript)

    # Render diffs at the end of the session
    if diffs:
        output_parts.append("")
        output_parts.append(render_diff(diffs, depth))

    # Session footer
    if depth > 0:
        summary = stats.summary_line()
        if summary:
            output_parts.append("")
            output_parts.append(indent(f"_{summary}_", depth))

    return "\n".join(output_parts), stats


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def build_full_transcript(base_url: str, root_id: str, max_depth: int = 20) -> tuple[str, dict]:
    """Build the complete transcript markdown + raw data for optional JSON dump."""
    print(f"Fetching session tree from {root_id}...", file=sys.stderr)
    sessions = fetch_session_tree(base_url, root_id, max_depth=max_depth)
    print(f"  Found {len(sessions)} session(s) via API children", file=sys.stderr)

    messages_cache: dict[str, list[dict]] = {}
    diffs_cache: dict[str, list[dict]] = {}

    # Discover child sessions embedded in task tool outputs (the /children
    # API often doesn't link them).  This also pre-populates messages_cache.
    discover_child_sessions_from_messages(base_url, sessions, messages_cache, max_depth)
    print(f"  Found {len(sessions)} session(s) total (after task-output scan)", file=sys.stderr)

    # Pre-fetch messages for any sessions not yet cached
    for i, sid in enumerate(sessions):
        if sid in messages_cache:
            continue
        print(f"  Fetching messages for {sid} ({i+1}/{len(sessions)})...", file=sys.stderr)
        messages_cache[sid] = fetch_messages(base_url, sid)

    root_session = sessions.get(root_id, {})
    title = root_session.get("title", root_id)
    created = root_session.get("time", {}).get("created")
    updated = root_session.get("time", {}).get("updated")

    # Get first assistant message for model info
    root_model = ""
    root_agent = ""
    root_msgs = messages_cache.get(root_id, [])
    for msg in root_msgs:
        info = msg.get("info", {})
        if info.get("role") == "assistant":
            provider = info.get("providerID", "")
            model = info.get("modelID", "")
            root_model = f"{provider}/{model}" if provider else model
            root_agent = info.get("mode", "")
            break

    transcript_body, stats = render_session(
        base_url, root_id, sessions,
        messages_cache, diffs_cache,
        depth=0,
        max_depth=max_depth,
    )

    # Build header
    header_lines = [
        f"# Session Transcript: `{root_id}`",
        f"**Title:** {title}",
    ]
    time_parts = []
    if created:
        time_parts.append(f"**Created:** {fmt_datetime(created)}")
    if updated:
        time_parts.append(f"**Updated:** {fmt_datetime(updated)}")
    if time_parts:
        header_lines.append(" | ".join(time_parts))

    meta = []
    if root_model:
        meta.append(f"**Model:** {root_model}")
    if root_agent:
        meta.append(f"**Agent:** {root_agent}")
    if meta:
        header_lines.append(" | ".join(meta))

    summary = stats.summary_line()
    if summary:
        header_lines.append(summary)

    tools = stats.tools_line()
    if tools:
        header_lines.append(tools)

    children = stats.children_line()
    if children:
        header_lines.append(children)

    header_lines.append(f"**Sessions in tree:** {len(sessions)}")
    header_lines.append("")
    header_lines.append("---")

    full_transcript = "\n".join(header_lines) + "\n" + transcript_body

    raw_data = {
        "root_session_id": root_id,
        "sessions": sessions,
        "messages": {sid: msgs for sid, msgs in messages_cache.items()},
        "diffs": {sid: d for sid, d in diffs_cache.items() if d},
        "stats": {
            "total_cost": stats.total_cost,
            "total_input_tokens": stats.total_input,
            "total_output_tokens": stats.total_output,
            "total_reasoning_tokens": stats.total_reasoning,
            "total_cache_read": stats.total_cache_read,
            "total_cache_write": stats.total_cache_write,
            "tool_counts": stats.tool_counts,
            "session_count": len(sessions),
            "child_count": stats.child_count,
        },
    }

    return full_transcript, raw_data


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export a full OpenCode session transcript including all sub-agent activity.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
            Examples:
              %(prog)s ses_2bab465acffe1bBB39t85P9rZK
              %(prog)s ses_abc123 --url http://localhost:4096
              %(prog)s ses_abc123 -o transcript.md --json
        """),
    )
    parser.add_argument("session_id", help="Root session ID (format: ses_...)")
    parser.add_argument(
        "--url", default="http://localhost:4096",
        help="OpenCode server URL (default: http://localhost:4096)",
    )
    parser.add_argument("-o", "--output", help="Output file path (default: stdout)")
    parser.add_argument(
        "--json", action="store_true",
        help="Also dump raw JSON data alongside the markdown",
    )
    parser.add_argument(
        "--max-depth", type=int, default=20,
        help="Maximum recursion depth for child sessions (default: 20)",
    )
    args = parser.parse_args()

    transcript, raw_data = build_full_transcript(args.url, args.session_id, args.max_depth)

    if args.output:
        out_path = Path(args.output)
        out_path.write_text(transcript, encoding="utf-8")
        print(f"Transcript written to {out_path}", file=sys.stderr)

        if args.json:
            json_path = out_path.with_suffix(".json")
            json_path.write_text(
                json.dumps(raw_data, indent=2, ensure_ascii=False, default=str),
                encoding="utf-8",
            )
            print(f"Raw JSON written to {json_path}", file=sys.stderr)
    else:
        print(transcript)

        if args.json:
            json_path = Path(f"transcript-{args.session_id}.json")
            json_path.write_text(
                json.dumps(raw_data, indent=2, ensure_ascii=False, default=str),
                encoding="utf-8",
            )
            print(f"Raw JSON written to {json_path}", file=sys.stderr)


if __name__ == "__main__":
    main()
