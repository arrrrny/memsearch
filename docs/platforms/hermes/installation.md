# Installation

## Prerequisites

- memsearch CLI installed (`uv tool install "memsearch[onnx]"`).
- Hermes Agent installed (`~/.hermes/state.db` exists after first run).
- A shell `.memsearch/scripts/derive-collection.sh` — provided by this plugin.

## Install

```bash
cd <project-root>
plugins/hermes/install.sh "$(pwd)"
```

That will:

1. Copy `skills/memsearch-recall` → `~/.hermes/skills/software-development/memsearch-recall` (available to every Hermes session).
2. Copy `scripts/{hermes-capture.py, parse-transcript.py, derive-collection.sh}` → `<project>/.memsearch/scripts/`.
3. Print the capture-cron prompt.

### Manual install (skip install.sh)

```bash
HERMES_SKILLS=~/.hermes/skills/software-development
mkdir -p "$HERMES_SKILLS"
cp -R plugins/hermes/skills/memsearch-recall "$HERMES_SKILLS/"

mkdir -p .memsearch/scripts .memsearch/memory
cp plugins/hermes/scripts/hermes-capture.py .memsearch/scripts/
cp plugins/hermes/scripts/parse-transcript.py .memsearch/scripts/
cp plugins/hermes/scripts/derive-collection.sh .memsearch/scripts/
```

## Configure

The capture reads Hermes's session store directly, so no extra API keys beyond
the memsearch embedding setup. Optional per-agent summarization overrides in
`~/.memsearch/config.toml`:

```toml
[plugins.hermes.summarize]
enabled = true
provider = "openai"
model = "deepseek-flash"        # your embedding/host model

[plugins.hermes.user_profile]
enabled = true
min_interval_hours = 24
```

## Capture cron

Register a recurring job so the session store is captured on an interval:

**Hermes cron** — create a job (every 60m) with the prompt:
```
Run: /usr/local/bin/python3 <project>/.memsearch/scripts/hermes-capture.py <project> 60
```

**launchd (macOS)** — a plist that runs the same command each hour:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>Label</key><string>com.zikzak.memsearch-hermes-capture</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/python3</string>
    <string><PROJECT>/.memsearch/scripts/hermes-capture.py</string>
    <string><PROJECT></string>
    <string>60</string>
  </array>
  <key>StartInterval</key><integer>3600</integer>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
```

## Verify

```bash
COLL=$(bash .memsearch/scripts/derive-collection.sh "$(pwd)")
memsearch stats --collection "$COLL"          # indexed chunks grow
memsearch search "hello world" --top-k 3 --collection "$COLL"
```

Then ask Hermes: *"recall what we worked on recently"* to exercise the skill.