# Dotfiles

Personal dotfiles for macOS, managed with [mise](https://mise.jdx.dev/)'s
declarative [bootstrap](https://mise.jdx.dev/bootstrap.html) feature -- no
Homebrew or chezmoi required, just mise itself.

![Preview](assets/preview.png)

## What's included

| Tool | Purpose |
|------|---------|
| [Ghostty](https://ghostty.org/) | Terminal emulator |
| [cmux](https://github.com/manaflow-ai/cmux) | Terminal app (tabs/splits/session persistence, built on Ghostty) -- replaces tmux |
| [Neovim](https://www.lazyvim.org/) | Editor (LazyVim distribution) |
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | Tiling window manager |
| [Starship](https://starship.rs/) | Shell prompt |
| [mise](https://mise.jdx.dev/) | Runtime/tool version manager, package installs, machine bootstrap |
| [Oh My Zsh](https://ohmyz.sh/) | Zsh framework, with `zsh-autosuggestions` + `zsh-syntax-highlighting` |
| [Karabiner-Elements](https://karabiner-elements.pqrs.org/) | Keyboard remapping (caps lock -> option, option -> hyper key) |
| [bat](https://github.com/sharkdp/bat) | `cat` replacement with syntax highlighting |
| [k9s](https://k9scli.io/) | Kubernetes TUI |
| [btop](https://github.com/aristocratos/btop) | System monitor |
| [Colima](https://github.com/abiosoft/colima) | Container runtime |
| [LinearMouse](https://linearmouse.app/) | Per-device scroll direction (trackpad vs. mouse) |
| [KeepingYouAwake](https://github.com/newmarcel/KeepingYouAwake) | Menu bar wrapper around `caffeinate` |
| [atuin](https://atuin.sh/) | Shell history (SQLite + encrypted sync) |

**Theme:** Catppuccin Macchiato across terminal, editor, bat, btop, and k9s.

## Prerequisites

- macOS
- [mise](https://mise.jdx.dev/installing-mise.html) -- nothing else. mise's
  `brew`/`brew-cask` backends install Homebrew formulae/casks directly into
  `/opt/homebrew` without needing a real Homebrew install.

```sh
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
```

## Installation

On a fresh Mac:

```sh
mise bootstrap --adopt fapont/dotfiles
```

Or from a checkout of this repo (e.g. this is what running it a second time
looks like, since bootstrap is a sequence you can safely re-run):

```sh
git clone https://github.com/fapont/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
mise bootstrap
```

This runs, in order: system packages (brew/brew-cask/macos-app -- no sudo, no
Homebrew), the `mise-history` watcher service, git repos (Oh My Zsh +
plugins), dotfiles (symlinks app configs into `~/.config`, copies
`~/.gitconfig`, edits the managed blocks in `~/.zshrc`), macOS defaults
(Dock/Finder/keyboard/trackpad), and finally the CLI tool versions declared
in `mise/conf.d/*.toml`.

Run it **twice** on a truly fresh machine: the first run creates the symlink
`~/.config/mise/conf.d/history.toml -> ~/.dotfiles/mise/conf.d/history.toml`;
only after that symlink exists does mise treat that file's `[dotfiles]`
`track`/edit entries and `[history.*]` settings as *global* config (mise
ignores those specific keys when it only sees them in a project-level file).
Everything else -- packages, macOS defaults, tool versions, plain
symlink/copy dotfiles -- applies correctly on the first run.

### Known gaps (upstream mise bugs, not this repo)

- **JetBrains Mono Nerd Font**: mise's font-cask target path rejects
  `$HOME/Library/Fonts` ([jdx/mise#10765](https://github.com/jdx/mise/discussions/10765)).
  Install manually: download `JetBrainsMono.zip` from
  https://github.com/ryanoasis/nerd-fonts/releases and unzip into `~/Library/Fonts`.
- **borders**: builds from source (no bottle for this formula) and needs a
  linker that understands the current macOS SDK's `.tbd` format -- fails with
  `tapi error: malformed file` if your Xcode Command Line Tools are behind
  the SDK. Update CLT (`xcode-select --install`) and re-add
  `"brew:felixkratz/formulae/borders"` to `mise/conf.d/macos.toml` once it builds.
- **Stray root-owned files under `/opt/homebrew`**: if a past `sudo mise ...`
  invocation ran, some paths under the prefix (`Caskroom/.mise.lock`,
  `var/homebrew/locks`, `share/fish`, etc.) can end up owned by root, which
  then blocks *new* installs with `Permission denied (os error 13)`. Fix
  once with `sudo chown -R "$(whoami)":admin /opt/homebrew`; never run `mise
  bootstrap` itself with `sudo`.

AeroSpace used to be on this list (mise can't evaluate the
`nikitabobko/tap/aerospace` cask's Ruby DSL -- `unsupported cask metadata DSL
'staged_path'`) but is now installed directly from its GitHub release as a
pinned `macos-app:` package -- see `mise/conf.d/macos.toml` for the tradeoff
(no automatic "latest" tracking for that package type; bump `version` +
`sha256` by hand on a new release).

## Structure

```
.
├── mise.toml                  # thin bootstrap recipe: git repos to clone, the dotfiles map (what goes where)
├── mise/
│   ├── config.toml            # [settings] only (trusted_config_paths) -> ~/.config/mise/config.toml
│   └── conf.d/
│       ├── tools.toml         # [tools] cross-platform CLI versions (jq, bat, eza, ripgrep, delta, atuin, ...)
│       ├── shell.toml         # [shell_alias] + [env] (XDG_*, CLOUDSDK_PYTHON)
│       ├── history.toml       # [dotfiles] ~/.zshrc track + edit blocks, [history.*] -- "global-only" settings live here
│       ├── agents.toml        # AI/dev-agent CLIs (Claude Code today; room for more)
│       ├── work.toml          # k8s/Docker/AWS/GCloud
│       └── macos.toml         # everything macOS-only: [bootstrap.packages] (tagged os = "macos"), [bootstrap.macos.*], post-defaults hook
├── config/
│   ├── aerospace/             # Tiling WM config
│   ├── bat/                   # Bat config + Catppuccin theme
│   ├── btop/                  # System monitor config + theme
│   ├── colima/                # Container runtime config
│   ├── ghostty/               # Terminal config
│   ├── k9s/                   # Kubernetes TUI config + plugins + theme
│   ├── karabiner/             # Keyboard remapping rules
│   ├── linearmouse/           # Per-device scroll config
│   └── starship.toml          # Prompt config
├── nvim/                      # Neovim (LazyVim)
├── zprofile                   # PATH for /opt/homebrew (no `brew shellenv` -- no brew binary)
├── gitconfig                  # [user] (pro default) + includeIf ~/Perso -> gitconfig-perso
└── gitconfig-perso            # [user.email] override for ~/Perso/**
```

`mise/conf.d/` mirrors the same layout mise uses globally at
`~/.config/mise/conf.d/`, which is why a project-level `mise/` directory here
is auto-discovered the same way -- no need for everything to live in one
`mise.toml`.

## Key design choices

- **mise does everything**: package installs (`[bootstrap.packages]`), macOS
  defaults (`[bootstrap.macos.*]`), git repo clones (`[bootstrap.repos]`), and
  dotfile deployment (`[dotfiles]`) are all mise-native. No chezmoi, no
  Homebrew as a separate dependency.
- **Config split by domain, not by app**: `mise/conf.d/*.toml` is split into
  `tools` (generic CLI), `shell` (aliases/env), `history` (dotfile
  tracking -- constrained to live here, see below), `agents` (AI/dev-agent
  CLIs), `work` (job-specific cloud/k8s tools), and `macos` (anything
  platform-specific). The macOS split exists so a future `linux.toml` can sit
  next to it without reshuffling anything; every package in `macos.toml` is
  tagged `os = "macos"` for exactly that reason.
- **symlink vs. copy vs. track vs. edit**: app configs are `symlink`ed (edit
  in the repo, live immediately). `~/.gitconfig` is `copy`d because `gh auth
  setup-git` and similar tools append machine-local lines to it after
  bootstrap that shouldn't leak into the repo (re-run `gh auth setup-git`
  after any `mise bootstrap` that touches it). `~/.zshrc` is `track`ed in
  place (mise versions it via its own history, without moving the file) *and*
  carries two `edit` entries (`omz-init`, `mise-activate`) that mise owns as
  marker-delimited blocks -- this is also how the Oh My Zsh sourcing line and
  the `mise activate` line get written into `~/.zshrc` without this repo (or
  Claude) needing direct write access to that file.
- **"Global-only" mise settings**: `[dotfiles]` `track`/edit entries,
  `[history.*]`, and `[settings] trusted_config_paths` are only honored by
  mise from its *global* config -- which is exactly what `mise/config.toml`
  and `mise/conf.d/*.toml` become once symlinked into `~/.config/mise/`.
  Declaring them in the *root* `mise.toml` doesn't work (mise treats that as
  a project-level file even when you `cd` into this repo to bootstrap), which
  is why `history.toml` lives under `mise/conf.d/` and the root `mise.toml`
  stays limited to repo clones and the dotfiles map.
- **Dotfiles that save themselves**: the `mise-history` watcher service
  auto-checkpoints tracked files (currently just `~/.zshrc`) so a crash
  between two manual commits doesn't lose config again -- this is what bit
  us with the lost atuin config. `history.sync` starts at `manual`
  (`mise dot save` / `mise dot history`); flip to `sync` in
  `mise/conf.d/history.toml` once proven out, for automatic periodic push.
- **Per-directory git identity**: `~/Doctolib/**` uses the work email (global
  default), `~/Perso/**` overrides to the personal one via `includeIf`.
- **Pinned `macos-app` as an escape hatch**: when mise's Homebrew cask
  evaluation can't handle a particular tap (AeroSpace today), a pinned
  `macos-app:` entry sourced straight from GitHub releases (sha256-verified)
  is the fallback -- no real Homebrew needed, at the cost of manual version
  bumps for that one package.

## Shell aliases

Defined in `mise/conf.d/shell.toml`:

| Alias | Command |
|-------|---------|
| `cat` | `bat` |
| `vim` | `nvim` |
| `diff` | `delta` |
| `ls` | `eza` (with icons, git status) |
| `la` | `eza -a` |
| `python` | `python3` |

Additional work aliases in `mise/conf.d/work.toml` (kubectx, docker compose shortcuts, etc.).
