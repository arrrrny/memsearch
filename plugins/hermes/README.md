# memsearch Hermes plugin

Semantic memory for [Hermes Agent](https://hermes-agent.nousresearch.com) — hookless integration:
capture from Hermes's SQLite session store (`~/.hermes/state.db`) via a cron poller, recall via a
`memsearch-recall` SKILL.md (search → expand → transcript). Shares the same
`.memsearch/` markdown + Milvus collection as the Claude Code / OpenCode / Codex plugins.

```
plugins/hermes/
├── install.sh                 # copies skills + scripts, prints the cron prompt
├── README.md
├── scripts/
│   ├── hermes-capture.py      # state.db poller -> daily .md + index (cron/launchd)
│   ├── parse-transcript.py    # read original turns from ~/.hermes/state.db
│   └── derive-collection.sh   # per-project Milvus collection name
├── skills/
│   └── memsearch-recall/SKILL.md
└── prompts/                   # shared summarize / project_review / user_profile prompts
```

Docs: `docs/platforms/hermes/` (index, how-it-works, memory-tools, installation).

## Why hookless?

Hermes has no plugin hook runtime (unlike Claude Code / OpenCode). Its sessions are in a local
SQLite DB, so capture is a background poller (the OpenCode model), and recall is a skill the agent
loads (the Claude Code model). That combination is what this plugin implements.
