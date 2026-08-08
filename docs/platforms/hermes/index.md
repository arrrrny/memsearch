# Hermes Plugin

Semantic memory for [Hermes Agent](https://hermes-agent.nousresearch.com) (Nous Research). Hermes runs in your terminal and stores every session in a local SQLite DB (`~/.hermes/state.db`), which makes its capture model the same as the **OpenCode** plugin (poll the DB, write the shared format). Recall is skill-based (like Claude Code / Codex), because Hermes has no plugin hook runtime.

## Installation

Follow [Installation](./installation.md). The short version:

```bash
plugins/hermes/install.sh <project_dir>
# or, by hand:
# 1. copy skills/memsearch-recall -> ~/.hermes/skills/software-development/
# 2. copy scripts/* -> <project>/.memsearch/scripts/
# 3. register a capture cron (every 60 min)
```

## Key Features

- **Cross-platform memory** — capture into the same `memory/YYYY-MM-DD.md` + Milvus collection all the other plugins write.
- **Capture via state.db poller** — a cron/launchd job reads `~/.hermes/state.db`, appends new user/assistant turns, re-indexes.
- **SKILL.md recall** — the `memsearch-recall` skill exposes the three-layer flow (`search` → `expand` → `transcript`).
- **Per-project isolation** — one Milvus collection per project path, across all agents.

## When Is This Useful?

Hermes is commonly paired with Claude Code / OpenCode in the same repos. With this plugin, a decision you make in a Hermes session is searchable from Claude Code the next day, and vice versa — without relying on Hermes's built-in short-context memory.

## Platform Notes

| Aspect | Hermes |
|--------|--------|
| Plugin type | SKILL.md + scripts (hookless) |
| Capture method | SQLite poller (cron/launchd) on `~/.hermes/state.db` |
| Recall mechanism | `memsearch-recall` SKILL.md |
| L3 transcript | Hermes `state.db` |
| Isolation | Per-project collection |