# shll — agent entrypoint (Claude Code)

You are the runtime for **shll**, an installer repo that brings a developer's shell/terminal environment up on a fresh machine: wezterm, alacritty, tmux (outer/inner), fish, fzf, neovim, pass.

## What you do

1. Detect the OS per `lib/os-detect.md`.
2. Read `state/user.toml` (and `state/user.<hostname>.toml` overlay) per `lib/state-merge.md`. Empty → fresh install.
3. If fresh and the user didn't pass `--defaults`, run the `interview` skill (`.claude/skills/interview/`) walking `manifests/interview.schema.toml`.
4. Run the `install` skill (`.claude/skills/install/`) — iterate `manifests/tools.toml`, skip when `check` passes, run the OS-matched `cmd`.
5. Render the bundle — walk `manifests/bundle.toml`, apply each entry's render rule (`copy` | `template` | `symlink`) using `lib/render.md` syntax. Back up existing target files to `~/.shll-backup/<timestamp>/`.
6. If the user wants pass set up, run the `pass-wizard` skill.
7. Run the `persist` skill to commit user state and push (fork-and-branch or downstream repo per interview answer).

## Commands available

- `/shll-install` — full flow (interview-or-resume → install → render → optional pass → persist)
- `/shll-interview` — re-run interview only (writes `state/user.toml`)
- `/shll-pass` — pass + GPG + git-remote wizard
- `/shll-publish` — commit + push user state (persist skill)

## Source of truth

The skills are thin. Decisions live in `manifests/` (TOML) and specs live in `lib/` (Markdown). Adding an OS, a tool, a bundle file, or a scrub rule should never require editing skill bodies — only manifests.

## House rules (from user's global CLAUDE.md)

- Commit messages are **one-liners**, no Claude attribution.
- Never use `~` in paths passed to `kubectl` (or any tool that doesn't shell-expand it) — use `$HOME`.

## Cross-platform note

Linux and Windows have no Cmd key. WezTerm config branches on `wezterm.target_triple` at runtime; Alacritty config is rendered from a template that resolves `{{ cmd_or_super }}` to `"Command"` on macOS, `"Super"` elsewhere. Logical chords are identical: Alt+F fullscreen, Cmd/Super+E → inner tmux prefix (`C-\`), Cmd/Super+R → outer tmux prefix (`C-]`).

## What lives where

```
manifests/         tools.toml, bundle.toml, scrub.toml, interview.schema.toml
lib/               os-detect.md, render.md, state-merge.md
bundle/            reference configs — fish, alacritty, wezterm, tmux, nvim, bin, pass
.claude/skills/    install, interview, pass-wizard, persist, scrub, seed
.claude/commands/  the four slash commands above
state/             user.toml + user.<host>.toml (gitignored upstream, tracked downstream)
```

The OpenCode mirror lives at `.opencode/` and consumes the exact same `manifests/` and `bundle/`. Keep them in sync — when you change a skill body here, mirror to `.opencode/agent/`.
