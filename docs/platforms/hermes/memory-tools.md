# Memory Tools

Hermes exposes memory through the **`memsearch-recall` skill** rather than a
runtime tool API. The skill instructs the agent to run the memsearch CLI in
three progressive layers.

## Skill Reference

| Step | What the agent runs | What it returns |
|------|---------------------|-----------------|
| **Search** | `memsearch search "<query>" --top-k 5 --json-output --collection <col>` | Top-K chunks with scores, dates, snippets (hybrid BM25 + dense + RRF) |
| **Expand** | `memsearch expand <chunk_hash> --collection <col>` | Full markdown section with session anchors + source |
| **Transcript** | `python3 .memsearch/scripts/parse-transcript.py <session_id> [--turn <msgid>]` | Original Hermes turns from `~/.hermes/state.db` |

## How to Trigger

Ask naturally: *"recall what we decided about X"*, *"have I seen this before"*, or *"what did past sessions say about Y"*. The agent detects the memory need, loads the skill (installed in `~/.hermes/skills/`), and runs the flow. No slash command or plugin UI needed — it's context-driven like the Claude Code skill recall.

## Three-Layer Progressive Recall

1. **Search** — broad semantic query first. The agent should try 1-2 alternate phrasings if the first query is weak.
2. **Expand** — for the most relevant hit, expand to see the full section + surrounding context.
3. **Transcript** — when the chunk's `<!-- hermes session_id:... -->` anchor matters (e.g. a decision's exact reasoning), read the original turns from state.db.

## Cross-Agent Recall

Because all platforms write the same `.md` format + collection, `memsearch search` returns Claude Code, OpenCode, and Hermes memories mixed by relevance — a Hermes session can recall what Claude Code decided in the same project.

## Tips

- Collection is per project path: `bash .memsearch/scripts/derive-collection.sh "$(pwd)"`.
- If search feels stale, the index only runs after capture — force with `memsearch index .memsearch/memory/ --collection <col>`.
- Vague queries: fall back to reading the daily files directly (`ls .memsearch/memory/`).