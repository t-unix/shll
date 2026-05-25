# State merge

How `state/user.toml` and `state/user.<hostname>.toml` combine to form the context passed to the renderer and read by the install/interview skills.

## Files

- **`state/user.toml`** — base. Shared across all the user's machines. Things like git identity, GPG key fingerprint, persistence mode, font preferences.
- **`state/user.<hostname>.toml`** — per-host overlay. Things that legitimately differ per machine: KUBECONFIG paths, monitor-specific font size, OS-specific tool versions, install timestamps and errors.

Hostname is `hostname -s` (short hostname, no domain).

## Merge semantics

Deep merge, overlay wins. Specifically:

- **Tables**: recurse into sub-keys.
- **Scalars** (string, int, bool, float): overlay replaces base.
- **Arrays**: overlay replaces base entirely. (Concatenation is not supported — too easy to get wrong; if you need to extend a list, copy the full list into the overlay.)
- **Missing in overlay**: base value is used.
- **Missing in both**: key resolves to `undefined`. The renderer treats this as a render error unless `| default(...)` is used.

## Schema regions

The state file has a few well-known top-level tables. Skills read/write these by convention:

```toml
[interview]                    # what the user answered, free-form per question id
git_email = "flx@w3.is"
persistence_mode = "fork"      # or "downstream"
fork_branch_strategy = "single" # or "per-host"
pass_setup = true

[git]                          # git identity bits used by render + persist
email = "flx@w3.is"
name  = "Felix Wolf"

[pass]                         # populated by pass-wizard
initialized = false            # set true after wizard completes
gpg_key_id   = ""
git_remote   = ""
cache_ttl    = 28800

[terminal]
font  = "SauceCodePro Nerd Font"
size  = 14

[tmux.prefix]
inner = "C-\\"
outer = "C-]"

[install]
last_run = "2026-05-25T15:30:00Z"

[install.errors]               # populated only when something fails
# wezterm = "brew exit 1: ..."
```

Per-host overlay typically only sets a few keys:

```toml
# state/user.turul.toml
[install]
last_run = "2026-05-25T15:42:00Z"

[terminal]
size = 16                       # external 4K display

[kube]
config = "$HOME/.kube/config-work"
```

## Resume logic

The install skill's "fresh vs resume" decision is:

```
if state/user.toml exists AND has [interview] table:
  resume mode — skip interview unless --reinterview
else:
  fresh mode — run interview
```

The interview itself writes incrementally (one question at a time) so a crash mid-interview is resumable on next run.
