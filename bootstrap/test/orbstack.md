# Test environment — OrbStack Debian VM

End-to-end test of the install flow on a clean Linux box. Validates apt-based
tool installs, Super-key (not Cmd) binding renders, scrub-lint, and the
"first-machine" interview path. You can also press the keyboard chords for real
in the rendered wezterm/alacritty if you launch the VM's GUI.

Requires [OrbStack](https://orbstack.dev) on the host.

## Create the VM

```sh
orb create debian shll-test
```

This pulls Debian (default: bookworm) and creates a Linux machine named
`shll-test`. The host home (`/Users/<you>/`) is shared into the VM at the
same path, so this repo is accessible at `/Users/<you>/Development/shll`
inside the VM with no clone needed.

## Bootstrap the VM (one-time per VM)

```sh
orb -m shll-test exec -- bash /Users/$USER/Development/shll/bootstrap/test/inside-vm-bootstrap.sh
```

The script:
1. Installs `curl`, `git`, `ca-certificates`, `sudo`, `gnupg`, `locales`
2. Installs Node.js LTS + `@anthropic-ai/claude-code` globally
3. Installs OpenCode (optional)
4. Prints the next-step commands

## Authenticate Claude Code inside the VM

Three options, pick one:

**A. Fresh login inside the VM (recommended — keeps host auth separate):**
```sh
orb -m shll-test shell
claude   # follow the login prompt
```

**B. Reuse host credentials (faster, but the VM gets read/write on your host
Claude state — only do this if you trust the VM):**
```sh
orb -m shll-test exec -- ln -sf /Users/$USER/.claude     /home/$USER/.claude
orb -m shll-test exec -- ln -sf /Users/$USER/.claude.json /home/$USER/.claude.json
```

**C. API key env var (no interactive login):**
```sh
orb -m shll-test exec -- bash -c 'echo "export ANTHROPIC_API_KEY=sk-ant-..." >> ~/.bashrc'
```

## Run the install

```sh
orb -m shll-test shell
cd /Users/$USER/Development/shll
claude /shll-install --defaults     # or omit --defaults to walk the interview
```

The install skill will:
- Detect OS as `debian`
- Iterate `manifests/tools.toml` → apt-get install wezterm/alacritty/tmux/fish/fzf/neovim/pass + gnupg
- Render `bundle/` to `~/.config/...` with `cmd_or_super` resolving to `Super`
- Back up any existing target files to `~/.shll-backup/<ts>/`

Verify rendered output:
```sh
cat ~/.config/alacritty/alacritty.toml | grep mods    # should show "Super"
cat ~/.config/wezterm/wezterm.lua | head -20          # runtime branch picks SUPER
ls -la ~/.tmux.conf ~/.tmux-outer.conf                # symlinked/copied bundle
```

## Visual / chord testing

OrbStack Linux machines support GUI apps via XQuartz forwarding (or via the
OrbStack desktop integration). To launch wezterm visually:

```sh
orb -m shll-test exec -- wezterm
```

Press `Alt+F` (fullscreen), `Super+E` (inner-tmux prefix), `Super+R` (outer).
On Linux the Super key is usually the macOS Cmd key on Apple keyboards.

## Reset the VM

To replay the install from clean:

```sh
orb delete shll-test
orb create debian shll-test
# re-run the bootstrap + install above
```

Or, more surgically, just undo the bundle render:

```sh
orb -m shll-test exec -- bash -c '
  ls ~/.shll-backup/ | tail -1 | xargs -I{} cp -R ~/.shll-backup/{}/.config ~/
  rm -rf ~/.config/alacritty ~/.config/wezterm  # etc
'
```

## Test the other distros

Same flow with a different base image:

```sh
orb create ubuntu shll-test-ubuntu
orb create arch   shll-test-arch
orb create fedora shll-test-fedora
```

The install skill detects each one via `lib/os-detect.md` and picks the
matching row in `tools.toml`. Useful for catching apt vs pacman vs dnf
manifest bugs.
