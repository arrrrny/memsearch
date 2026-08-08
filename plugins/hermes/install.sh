#!/usr/bin/env bash
# memsearch Hermes plugin installer.
#
# Hermes has no plugin/hook runtime for capture, so this plugin is a
# SKILL + SCRIPTS integration (the same "hookless" model the memsearch docs
# describe):
#   1. Installs the recall skills into ~/.hermes/skills/ (available to every
#      Hermes session).
#   2. Copies the capture scripts into the project's .memsearch/scripts/.
#   3. Prints how to register the capture cron (Hermes cron or launchd).
#
# Usage: install.sh [project_dir]
#   If no project_dir given, uses pwd (must be a project root).
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-$(pwd)}"
HERMES_SKILLS="${HERMES_HOME:-$HOME/.hermes}/skills/software-development"

echo "== memsearch Hermes plugin install =="

# 1. Skills -> ~/.hermes/skills/software-development/
mkdir -p "$HERMES_SKILLS"
for skill in memsearch-recall; do
  cp -R "$PLUGIN_DIR/skills/$skill" "$HERMES_SKILLS/"
  echo "  skill installed: $HERMES_SKILLS/$skill"
done

# 2. Scripts -> <project>/.memsearch/scripts/
mkdir -p "$PROJECT_DIR/.memsearch/scripts" "$PROJECT_DIR/.memsearch/memory"
for script in hermes-capture.py parse-transcript.py derive-collection.sh; do
  cp "$PLUGIN_DIR/scripts/$script" "$PROJECT_DIR/.memsearch/scripts/"
  chmod +x "$PROJECT_DIR/.memsearch/scripts/$script"
  echo "  script installed: .memsearch/scripts/$script"
done

# 3. Capture cron (every 60 min) — print the Hermes cron prompt to register.
COLLECTION=$(bash "$PROJECT_DIR/.memsearch/scripts/derive-collection.sh" "$PROJECT_DIR" 2>/dev/null || echo "<collection>")
cat <<EOF

== Capture cron ==
Register a recurring Hermes cron job (every 60m) to poll the Hermes session
store and write the shared daily memory file:

  Prompt:
    Run: /usr/local/bin/python3 $PROJECT_DIR/.memsearch/scripts/hermes-capture.py $PROJECT_DIR 60
    (collection: $COLLECTION)

Or launchd (macOS): a plist that runs the same command at :00 every hour.

== Done ==
The memsearch-recall skill is now available to Hermes sessions. Ask Hermes
"recall what we decided about X" to search the shared memory.
EOF
