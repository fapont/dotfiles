# Dotfiles

Personal macOS dotfiles, bootstrapped entirely by [mise](https://mise.jdx.dev/) -- no Homebrew, no chezmoi.

![Preview](assets/preview.png)

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/fapont/dotfiles/main/bootstrap.sh | sh
```

Idempotent: installs `mise` if missing, clones (or `git pull --ff-only`) `~/.dotfiles`,
then runs `mise bootstrap` -- packages (via mise's own `brew`/`brew-cask`/`macos-app`
backends, no real Homebrew involved), Oh My Zsh + plugins, symlinked app configs,
`~/.zshrc`, macOS defaults, CLI tool versions. Safe to re-run any time; preview with
`mise bootstrap --dry-run`.

## Structure

```
mise.toml                    # repo clones + the dotfiles map (what goes where)
mise/
  config.toml                 # -> ~/.config/mise/config.toml
  conf.d/
    tools.toml                 # generic CLI versions
    shell.toml                 # aliases + env
    history.toml                # ~/.zshrc tracking
    agents.toml                  # AI/dev-agent CLIs
    work.toml                    # k8s/Docker/AWS/GCloud
    macos.toml                    # macOS packages + system defaults
config/                        # app configs (ghostty, karabiner, btop, k9s, bat, aerospace, colima, linearmouse, starship)
fnox/config.toml               # secrets-as-env-vars
nvim/                           # Neovim (LazyVim)
zprofile, gitconfig, gitconfig-perso
```

`mise/conf.d/` mirrors `~/.config/mise/conf.d/` (symlinked), split by domain rather
than one big `mise.toml`.

## Notable choices

- App configs are **symlinked** (edit in place, live immediately); `~/.gitconfig` is
  **copied** (tools like `gh auth setup-git` append local-only lines -- re-run bootstrap
  if a copy wipes them); `~/.zshrc` is **tracked** with two marker-delimited edit blocks
  mise owns (Oh My Zsh init, `mise activate`) -- use `mise dot status`/`diff`/`save` for it.
- AeroSpace installs from a pinned GitHub release, not its Homebrew cask (mise can't
  evaluate the cask's Ruby DSL) -- bump `version`/`sha256` by hand on a new release.
- Secrets live in `fnox/config.toml`. `GH_TOKEN`/`GITHUB_TOKEN` use the `age` provider
  (ciphertext committed, decrypted locally, no network/vault needed) so they're in every
  shell without a Bitwarden session; see "Fresh machine" for restoring the decryption key.

## Known gaps

- **Root-owned files under `/opt/homebrew`**: a past `sudo mise ...` run can leave stray
  root-owned paths that block new installs with `Permission denied`. Fix with
  `sudo chown -R "$(whoami)":admin /opt/homebrew`; never run `mise bootstrap` itself with `sudo`.

## Keeping this up to date

- **New tool/package**: add it to the relevant `conf.d/*.toml`, run `mise bootstrap`, commit.
- **Config drifted locally**: symlinked files edit in place already, just `git add` and
  commit from `~/.dotfiles`. For `~/.zshrc`, use `mise dot status`/`mise dot diff`/`mise dot save`.
- **Before a risky change**: `mise bootstrap --dry-run` to preview.

## Fresh machine

```sh
curl -fsSL https://raw.githubusercontent.com/fapont/dotfiles/main/bootstrap.sh | sh
cd ~/.dotfiles
mise run setup-github-ssh                   # per-machine git SSH key, registered with GitHub
bw login                                    # the one step that can't be scripted away
mise run restore-secrets                    # unlocks, pulls id_ed25519_age back from Bitwarden
```

Open a new terminal -- `GH_TOKEN`/`GITHUB_TOKEN` are already there. Both tasks are
idempotent, safe to `mise run` again on an already-set-up machine.
