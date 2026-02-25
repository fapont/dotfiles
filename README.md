# Dotfiles

Personal dotfiles for macOS, managed with [chezmoi](https://www.chezmoi.io/).

![Preview](assets/preview.png)

## What's included

| Tool | Purpose |
|------|---------|
| [Ghostty](https://ghostty.org/) | Terminal emulator |
| [tmux](https://github.com/tmux-plugins/tpm) | Terminal multiplexer with TPM, session persistence, and fzf integration |
| [Neovim](https://www.lazyvim.org/) | Editor (LazyVim distribution) |
| [AeroSpace](https://github.com/nikitabobko/AeroSpace) | Tiling window manager |
| [Starship](https://starship.rs/) | Shell prompt |
| [mise](https://mise.jdx.dev/) | Runtime/tool version manager and shell aliases |
| [Oh My Zsh](https://ohmyz.sh/) | Zsh framework with syntax highlighting and autosuggestions |
| [Karabiner-Elements](https://karabiner-elements.pqrs.org/) | Keyboard remapping (caps lock -> option, option -> hyper key) |
| [bat](https://github.com/sharkdp/bat) | `cat` replacement with syntax highlighting |
| [k9s](https://k9scli.io/) | Kubernetes TUI |
| [btop](https://github.com/aristocratos/btop) | System monitor |
| [Colima](https://github.com/abiosoft/colima) | Container runtime |
| [borders](https://github.com/FelixKratz/JankyBorders) | Window borders |

**Theme:** Catppuccin Macchiato across terminal, editor, tmux, bat, btop, and k9s.

## Prerequisites

- macOS
- [Homebrew](https://brew.sh/)
- [chezmoi](https://www.chezmoi.io/install/)

## Installation

```sh
chezmoi init --apply fapont
```

This will:

1. Clone this repo into `~/.local/share/chezmoi`
2. Apply all dotfiles to their target locations
3. Install Homebrew packages and casks via `brew bundle` (git, tmux, btop, AeroSpace, Ghostty, Raycast, etc.)

## Structure

```
.
├── .chezmoidata/
│   └── packages.yaml          # Homebrew brews & casks
├── .chezmoiexternal.toml      # Oh My Zsh + plugins (fetched from GitHub)
├── dot_config/
│   ├── aerospace/             # Tiling WM config
│   ├── bat/                   # Bat config + Catppuccin theme
│   ├── btop/                  # System monitor config + theme
│   ├── colima/                # Container runtime config
│   ├── ghostty/               # Terminal config
│   ├── k9s/                   # Kubernetes TUI config + plugins + theme
│   ├── karabiner/             # Keyboard remapping rules
│   ├── mise/                  # Tool versions, aliases, and env vars
│   │   └── conf.d/            # Modular mise configs (work tools, claude)
│   ├── nvim/                  # Neovim (LazyVim)
│   ├── starship.toml          # Prompt config
│   └── tmux/                  # Tmux config + key reset
├── dot_zprofile               # Homebrew shell init
└── run_onchange_darwin-install-packages.sh.tmpl  # Auto-installs packages on change
```

## Key design choices

- **mise for CLI tools**: Most CLI tools (eza, fd, ripgrep, lazygit, starship, etc.) are installed via mise rather than Homebrew, keeping brew for GUI apps and tools that need early shell availability.
- **Modular mise configs**: Work tools (k8s, Docker, AWS/GCloud) and Claude Code are split into separate `conf.d/` files.
- **External dependencies**: Oh My Zsh and its plugins are pulled automatically via `.chezmoiexternal.toml` -- no submodules needed.
- **Auto package install**: The `run_onchange_` script re-runs `brew bundle` whenever `packages.yaml` changes.

## Shell aliases

Defined in `mise.toml`:

| Alias | Command |
|-------|---------|
| `cat` | `bat` |
| `vim` | `nvim` |
| `ls` | `eza` (with icons, git status) |
| `la` | `eza -a` |
| `python` | `python3` |

Additional work aliases in `conf.d/work.toml` (kubectx, docker compose shortcuts, etc.).
