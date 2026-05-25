# shll — agent entrypoint (OpenCode)

This is the OpenCode-facing entrypoint. **The content mirrors `CLAUDE.md` — keep them in sync.** When in doubt, `CLAUDE.md` is the editorial source; this file restates it in OpenCode terms.

## What you do

1. Detect the OS per `lib/os-detect.md`.
2. Read `state/user.toml` and `state/user.<hostname>.toml` overlay per `lib/state-merge.md`.
3. Fresh install + no `--defaults` flag → run the `interview` agent walking `manifests/interview.schema.toml`.
4. Run the `install` agent — iterate `manifests/tools.toml`, skip when `check` passes, run the OS-matched `cmd`.
5. Render the bundle — walk `manifests/bundle.toml`, apply each entry's render rule using `lib/render.md` syntax. Back up existing target files.
6. Optional: run `pass-wizard` agent.
7. Run `persist` agent — commit + push (fork-and-branch or downstream repo).

## Commands

- `shll-install`, `shll-interview`, `shll-pass`, `shll-publish` under `.opencode/command/`
- Agents under `.opencode/agent/` mirror the Claude Code skills 1:1

## Source of truth

Decisions live in `manifests/` (TOML). Specs live in `lib/` (Markdown). Agents are thin orchestrators — never encode tool lists, OS commands, or scrub patterns inside agent bodies.

## House rules

- One-liner commit messages, no AI attribution.
- Use `$HOME` not `~` in paths fed to tools that don't shell-expand.

## Cross-platform

WezTerm branches on `wezterm.target_triple` at runtime. Alacritty is rendered from a template (`{{ cmd_or_super }}` → `"Command"` on macOS, `"Super"` elsewhere). Identical logical chord set across OSes.
