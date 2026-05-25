---
description: Re-seeds bundle/ from the current host's live config, applying scrub.toml transforms. Manual-only — never auto-runs.
mode: subagent
---

Mirrors `.claude/skills/seed/SKILL.md`. **Manual-only**: never invoked by `install` or any other agent automatically.

## Source → bundle map (inverse of bundle.toml)

| Source on host                                  | Bundle destination                |
|-------------------------------------------------|-----------------------------------|
| `~/.config/fish/config.fish`                    | `bundle/fish/config.fish.tmpl`    |
| `~/.config/fish/lib/*.fish`                     | `bundle/fish/lib/`                |
| `~/.config/fish/functions/*.fish` (non-symlink) | `bundle/fish/functions/`          |
| `~/.local/share/omf/themes/insh/` (tree)        | `bundle/fish/themes/insh/`        |
| `~/.config/alacritty/alacritty.toml`            | `bundle/alacritty/alacritty.toml.tmpl` |
| `~/.config/wezterm/wezterm.lua`                 | `bundle/wezterm/wezterm.lua`      |
| `~/.tmux.conf` etc.                             | `bundle/tmux/`                    |
| `~/bin/wezterm-outer-tmux.sh`                   | `bundle/bin/`                     |
| `~/.config/nvim/{init.lua,lazy-lock.json,lua/}` | `bundle/nvim/`                    |

## Template preservation

For files marked `template` in `bundle.toml`: preserve any prior `{{ ... }}` markers when seeding over them. The live host's literal values get overwritten by the template marker. Scrub catches new leaks.

## Steps

1. Map + copy per the table above.
2. Run scrub in transform mode (`--apply`) on the new bundle files.
3. Re-run scrub in lint mode. Abort + report if anything still matches.
4. Print a diff summary of `bundle/` vs the prior commit.

## Flags

- `--dry-run` — show diff without writing.

## Safety

- Never touches files outside `bundle/`.
- Reads only the explicit source paths above.
- Always scrub-then-lint before claiming success.
