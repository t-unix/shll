# OS detection

Canonical algorithm for resolving the current host to one of the OS keys used in `manifests/tools.toml` and `manifests/bundle.toml`.

## Supported OS keys

`macos`, `debian`, `ubuntu`, `arch`, `fedora`, `freebsd`, `openbsd`, `linux-other`

`linux-other` is a fallback for distros not yet enumerated (CentOS, Alpine, NixOS, etc.). Manifests should provide a `linux-other` row with `action = "manual"` and a doc URL when no automatic install is wired up.

## Algorithm

```
uname=$(uname -s)

case "$uname" in
  Darwin)        echo macos ;;
  FreeBSD)       echo freebsd ;;
  OpenBSD)       echo openbsd ;;
  Linux)
    if [ -r /etc/os-release ]; then
      . /etc/os-release
      case "$ID" in
        ubuntu)              echo ubuntu ;;
        debian)              echo debian ;;
        arch|manjaro|endeavouros) echo arch ;;
        fedora|rhel|centos)  echo fedora ;;
        *)
          case "$ID_LIKE" in
            *debian*) echo debian ;;
            *arch*)   echo arch ;;
            *fedora*|*rhel*) echo fedora ;;
            *)        echo linux-other ;;
          esac
          ;;
      esac
    else
      echo linux-other
    fi
    ;;
  *) echo linux-other ;;
esac
```

## Architecture (secondary key)

Some package commands need an arch suffix. Resolve once and pass through to the install skill:

- `uname -m` → `x86_64`, `arm64`/`aarch64`, etc.
- macOS: also detect Apple Silicon vs Intel for Homebrew prefix:
  - `arm64` → `/opt/homebrew`
  - `x86_64` → `/usr/local`

## Use from skills

Skills should call this algorithm once at the start of a run, store the result in `state/run.json` under `os` and `arch`, and reference those keys when looking up rows in `tools.toml` / `bundle.toml`. No reason to detect twice in one run.
