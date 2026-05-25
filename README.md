# shll

Reproducible shell + terminal environment for a fresh machine, driven by an AI agent (Claude Code or OpenCode). Tools: **wezterm, alacritty, tmux (outer/inner), fish, fzf, neovim, pass**.

The agent detects your OS, installs missing tools with the right package manager (brew / apt / pacman / pkg), and applies the bundled reference configs — verbatim or customized via an interview. Your final config commits back to git so the same flow re-runs on the next machine.

## Bootstrap

### One-line (fresh box, no agent installed)

```sh
curl -fsSL https://raw.githubusercontent.com/flx/shll/main/bootstrap/install.sh | sh
```

The script installs git + a chosen agent CLI (Claude Code or OpenCode), clones this repo, and hands off.

### Clone-then-run (you already have an agent)

```sh
git clone https://github.com/flx/shll.git
cd shll
claude /shll-install        # or:  opencode run shll-install
```

Pass `--defaults` to skip the interview and install everything as-shipped.

## What gets installed

Driven by `manifests/tools.toml`. v1 covers wezterm, alacritty, tmux, fish, fzf, neovim, pass (+ GPG) across macOS, Debian/Ubuntu, Arch, Fedora, FreeBSD, OpenBSD. Missing OS rows fall through to a documented manual step.

## What gets configured

Driven by `manifests/bundle.toml`. Reference configs in `bundle/` go to `~/.config/<tool>/`, `~/.tmux*`, `~/bin/`, etc. Existing files are backed up to `~/.shll-backup/<timestamp>/` before being overwritten.

## Customization + persistence

The interview captures preferences in `state/user.toml` (+ optional `state/user.<hostname>.toml` overlay for per-machine tweaks). At the end you choose:

- **Fork + user-branch** — `gh repo fork`, push to `<you>/main` on the fork
- **Downstream repo** — `gh repo create <you>/shll-<host>` referencing this as `upstream`

Either way, `state/` is tracked downstream so re-runs on new machines just pull and apply.

## Cross-platform bindings

Linux/Windows have no Cmd key. The configs use **runtime branching** (WezTerm Lua) and **install-time templating** (Alacritty TOML) to pick `Cmd` on macOS, `Super` elsewhere. Same physical chord set everywhere:

- `Alt+F` toggle fullscreen
- `Cmd/Super+E` send inner-tmux prefix (`C-\`)
- `Cmd/Super+R` send outer-tmux prefix (`C-]`)
- `Cmd/Super+W` / `Ctrl+S` send `C-_`

## Repo layout

```
CLAUDE.md AGENTS.md              agent entrypoints
.claude/{skills,commands}/       Claude Code bindings
.opencode/{command,agent}/       OpenCode bindings
manifests/                       tools.toml, bundle.toml, scrub.toml, interview.schema.toml
lib/                             os-detect.md, render.md, state-merge.md (specs)
bundle/                          reference configs — fish, alacritty, wezterm, tmux, nvim, bin
state/                           user.toml etc. (gitignored upstream)
bootstrap/install.sh             curl target
```
