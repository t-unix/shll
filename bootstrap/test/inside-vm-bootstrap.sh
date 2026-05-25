#!/usr/bin/env bash
# Runs INSIDE an OrbStack Linux VM (Debian/Ubuntu). Installs the prerequisites
# needed before `claude /shll-install` can run.
#
# Idempotent — safe to re-run.
#
# Usage (from the host):
#   orb -m shll-test exec -- bash /Users/$USER/Development/shll/bootstrap/test/inside-vm-bootstrap.sh
set -euo pipefail

log() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }

# --- base packages -----------------------------------------------------------
log 'apt: base packages'
sudo apt-get update -qq
sudo apt-get install -y -qq \
  curl git ca-certificates gnupg locales tzdata less

# --- locale ------------------------------------------------------------------
if ! locale -a 2>/dev/null | grep -qi 'en_US.utf8'; then
  log 'locale: enabling en_US.UTF-8'
  sudo sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
  sudo locale-gen
fi

# --- Node.js (via NodeSource, current LTS) -----------------------------------
if ! command -v node >/dev/null 2>&1; then
  log 'node: installing Node.js LTS via NodeSource'
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >/dev/null
  sudo apt-get install -y -qq nodejs
else
  log "node: already present ($(node --version))"
fi

# --- Claude Code -------------------------------------------------------------
if ! command -v claude >/dev/null 2>&1; then
  log 'claude: installing @anthropic-ai/claude-code'
  sudo npm install -g --silent @anthropic-ai/claude-code
else
  log "claude: already present ($(claude --version 2>/dev/null | head -1))"
fi

# --- OpenCode (optional) -----------------------------------------------------
if ! command -v opencode >/dev/null 2>&1; then
  log 'opencode: installing'
  curl -fsSL https://opencode.ai/install | bash >/dev/null 2>&1 || \
    log 'opencode: install failed (non-fatal; Claude Code path still works)'
else
  log 'opencode: already present'
fi

# --- Summary -----------------------------------------------------------------
printf '\n\033[1;32m=== Bootstrap complete ===\033[0m\n\n'
cat <<EOF
Next steps (run inside the VM with \`orb -m shll-test shell\`):

  1. Authenticate Claude Code:
       claude

  2. Run the shll install:
       cd /Users/$USER/Development/shll
       claude /shll-install --defaults     # or omit for the interview

  3. Verify the rendered configs:
       grep mods ~/.config/alacritty/alacritty.toml    # → "Super"
       head ~/.config/wezterm/wezterm.lua               # → SUPER branch
       cat ~/.tmux.conf | head -5                       # inner tmux prefix

EOF
