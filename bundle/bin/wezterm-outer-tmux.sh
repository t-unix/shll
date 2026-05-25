#!/bin/sh
# Launches (or reattaches to) the "outer" tmux session that hosts the 3-pane
# layout. Designed to be set as wezterm.default_prog.
#
# Resolves `tmux` from PATH so it works on macOS (any arch), Linux, BSD —
# wherever the install skill put the binary.
set -e

TMUX_BIN="${TMUX_BIN:-$(command -v tmux)}"
if [ -z "$TMUX_BIN" ]; then
  echo "tmux not found on PATH. Run /shll-install to install it." >&2
  exit 1
fi

if "$TMUX_BIN" -L outer has-session -t main 2>/dev/null; then
  exec "$TMUX_BIN" -L outer attach -t main
fi

"$TMUX_BIN" -L outer -f "$HOME/.tmux-outer.conf" new-session -d -s main
"$TMUX_BIN" -L outer split-window -h -t main
"$TMUX_BIN" -L outer split-window -h -t main
"$TMUX_BIN" -L outer select-layout -t main even-horizontal
"$TMUX_BIN" -L outer select-pane -t main.0
exec "$TMUX_BIN" -L outer attach -t main
