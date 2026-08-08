---
name: memsearch-recall
description: "Use when recalling past decisions or sessions via memsearch."
---

# memsearch-recall — Semantic Memory Retrieval

Hermes has no native memsearch hooks; integration is CLI + skill. Memories live in each project's `.memsearch/` (the SAME index Claude/OpenCode write), captured from Hermes's `state.db` by `hermes-capture.py`. Recall = three progressive layers.

## Collection Name

Every project has its own Milvus collection derived from its absolute path. Derive it from the project root:

```bash
bash .memsearch/scripts/derive-collection.sh "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
# e.g. ms_zik_zak_5a5cc524
```

If `.memsearch/scripts/derive-collection.sh` is missing, see the `cross-session-memory` skill for the full setup (derive script, config.toml, capture cron).

## Layer 1 — Search

```bash
memsearch search "<query>" --top-k 5 --json-output --collection <collection>
```

Query captures the user's core intent. Try a second query if the first is weak. Results are hybrid (BM25 + dense + RRF).

## Layer 2 — Expand

For a relevant chunk:
```bash
memsearch expand <chunk_hash> --collection <collection>
```
Shows the full section with session anchors + source. Fallback: results carry `source` + `start_line`/`end_line` — read the `.md` directly.

## Layer 3 — Hermes transcript (deep drill)

An expanded chunk carries `<!-- hermes session_id:<sid> capture:<msgid> -->`. When the original turns matter, read them straight from Hermes's session store:

```bash
sqlite3 ~/.hermes/state.db "SELECT role, substr(content,1,2000), datetime(timestamp,'unixepoch','localtime') FROM messages WHERE session_id='<sid>' AND content!='' ORDER BY id ASC;"
```
Or grep the daily `.md` file for related turns.

## Sharing with the other agents

The `.md` files + Milvus collection are shared: memories captured by Claude Code / Zed / Hermes for the same project land in the same collection. Recall the user mention and answer from ANY agent's past session.

## Pitfalls

- Collection per project + path-derived: if the project path changes, re-map the collection.
- The index is triggered after each capture — if a search feels stale, run `memsearch index .memsearch/memory/ --collection <col>`.
- Vague/absent query: fall back to reading the raw daily files (`ls .memsearch/memory/`, `grep`).