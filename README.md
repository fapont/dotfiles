# Dotfiles

Personal macOS dotfiles, bootstrapped entirely by [mise](https://mise.jdx.dev/) -- no Homebrew, no chezmoi.

![Preview](assets/preview.png)

## Install

```sh
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
mise bootstrap --adopt fapont/dotfiles
```

Or from a checkout:

```sh
git clone https://github.com/fapont/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && mise bootstrap
```

One command, safe to re-run any time. It installs packages (via mise's own
`brew`/`brew-cask`/`macos-app` backends -- no real Homebrew involved),
clones Oh My Zsh + plugins, symlinks app configs into `~/.config`, wires
`~/.zshrc`, applies macOS defaults, and installs CLI tool versions.

## Structure

```
mise.toml                    # repo clones + the dotfiles map (what goes where)
mise/
  config.toml                 # [settings] -> ~/.config/mise/config.toml
  conf.d/
    tools.toml                 # generic CLI versions
    shell.toml                 # aliases + env
    history.toml                # ~/.zshrc tracking + [history.*]
    agents.toml                  # AI/dev-agent CLIs
    work.toml                    # k8s/Docker/AWS/GCloud
    macos.toml                    # macOS packages + system defaults
config/                        # app configs (ghostty, karabiner, btop, k9s, bat, aerospace, colima, linearmouse, starship)
fnox/config.toml               # secrets-as-env-vars, see below
nvim/                           # Neovim (LazyVim)
zprofile, gitconfig, gitconfig-perso
```

`mise/conf.d/` mirrors `~/.config/mise/conf.d/`, so it's auto-discovered the
same way without needing one big `mise.toml`. Files are split by domain, not
by app -- `macos.toml` holds everything platform-specific (each package
tagged `os = "macos"`) so a `linux.toml` could sit next to it later.

## Notable choices

- **symlink** for app configs (edit here, live immediately); **copy** for
  `~/.gitconfig` (tools like `gh auth setup-git` append local-only lines
  after bootstrap -- re-run it if a bootstrap wipes them); **track + edit
  blocks** for `~/.zshrc` (mise owns two marker-delimited blocks --
  Oh My Zsh init, `mise activate` -- the rest of the file is yours).
- `[dotfiles]` track/edit entries and `[history.*]` only work from mise's
  *global* config, which is exactly what `mise/conf.d/*.toml` become once
  symlinked -- `[tasks.bootstrap]` re-runs the dotfiles phase once bootstrap
  finishes so this works in a single `mise bootstrap`, not two.
- **History**: the `mise-history` service checkpoints `~/.zshrc`
  automatically (this is what should have saved the atuin config lost in the
  last crash). `sync = "manual"` in `history.toml`; switch to `"sync"` for
  automatic periodic push once proven out.
- **Per-directory git identity**: `~/Doctolib/**` -> work email (default),
  `~/Perso/**` -> personal, via `includeIf`.
- **AeroSpace** installs as a pinned `macos-app:` package straight from its
  GitHub release (sha256-verified) because mise can't evaluate its cask's
  Ruby DSL yet -- no "latest" tracking for that entry, bump `version` +
  `sha256` by hand on a new release.
- **Secrets**: `fnox` + Bitwarden, referenced (not stored) in `fnox/config.toml`.
  `bw login` once, then `fnox exec -- <cmd>` (or `ghx` for `gh`) injects
  secrets into that one subprocess only -- never a global env var.

## Known gaps (upstream mise, not this repo)

- **JetBrains Mono Nerd Font**: font-cask rejects `$HOME/Library/Fonts`
  ([jdx/mise#10765](https://github.com/jdx/mise/discussions/10765)). Install
  by hand from [nerd-fonts releases](https://github.com/ryanoasis/nerd-fonts/releases).
- **Root-owned files under `/opt/homebrew`**: a past `sudo mise ...` run can
  leave stray root-owned paths that block new installs with `Permission
  denied`. Fix with `sudo chown -R "$(whoami)":admin /opt/homebrew`; never
  run `mise bootstrap` itself with `sudo`.

## Keeping this up to date

- **New tool/package**: add it to the relevant `conf.d/*.toml`, run `mise
  bootstrap`, commit.
- **Config drifted locally** (you tweaked `~/.config/ghostty/config`
  directly): symlinked files edit in place already, just `git add` and
  commit from `~/.dotfiles`. For `~/.zshrc`, use `mise dot status` / `mise
  dot diff` / `mise dot save` -- it's tracked, not symlinked.
- **Before a risky change**: `mise bootstrap --dry-run` to preview.
- **New machine**: `mise bootstrap --adopt fapont/dotfiles`.
