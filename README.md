# Dotfiles

Personal macOS dotfiles, bootstrapped entirely by [mise](https://mise.jdx.dev/) -- no Homebrew, no chezmoi.

![Preview](assets/preview.png)

## Install

```sh
curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
git clone https://github.com/fapont/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && mise bootstrap
```

No GitHub auth needed for this clone -- the repo is public, plain HTTPS.
`mise bootstrap --adopt owner/repo` looks tempting but clones straight into
`~/.config/mise`, which doesn't match this repo's layout (`nvim/`, `config/`,
`fnox/`, etc. live at the root) -- don't use it here.

Safe to re-run `mise bootstrap` any time. It installs packages (via mise's own
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
- **Secrets**: `fnox`, configured in `fnox/config.toml` with two providers --
  `bitwarden` (live vault lookups, dormant: nothing uses it today, kept for
  a future secret that genuinely needs to stay fresh rather than committed)
  and `age` (encrypt once, commit the ciphertext, decrypt locally with
  `id_ed25519_age` -- no network, no vault, no session). `GH_TOKEN`/
  `GITHUB_TOKEN` use `age`: a PAT barely rotates, so it fits the "static,
  committed" shape far better than a live lookup. The file's top-level
  `env = "exec"` keeps any future secret scoped to `fnox exec -- <cmd>` by
  default; these two opt into `env = true` so `eval "$(fnox activate zsh)"`
  (in `~/.zshrc`) exports them into every shell -- plain `gh`/`git push`
  just work, offline, no Bitwarden involved.
- **BW_SESSION caching**: only matters for the dormant `bitwarden` provider
  and for `mise run restore-secrets` (see "Fresh machine"). `bwu` unlocks
  Bitwarden and caches the session, age-encrypted, at
  `~/.local/state/bw-session.age` (outside the repo, never committed).
  `mise/conf.d/shell.toml`'s `[env]` decrypts it fresh into every shell,
  uncached by mise itself. Deliberate tradeoff: convenience over re-entering
  the master password per terminal -- the cache is only as safe as
  `id_ed25519_age` already is, no new exposure introduced.

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

## Fresh machine

```sh
curl https://mise.run | sh
git clone https://github.com/fapont/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && mise bootstrap             # everything: packages, defaults, tools, dotfiles
mise run setup-github-ssh                   # per-machine git SSH key, registered with GitHub
bw login                                    # the one step that can't be scripted away
mise run restore-secrets                    # unlocks, pulls id_ed25519_age back from Bitwarden
```

That's it -- open a new terminal and `GH_TOKEN`/`GITHUB_TOKEN` are already
there (`fnox`'s `age` provider decrypts them straight from `fnox/config.toml`,
no Bitwarden needed once the key above is restored). `bw` only matters for
that one restore step and for any *future* secret that's deliberately
sourced live from Bitwarden instead of committed -- day-to-day, nothing
here needs a Bitwarden session at all.

Both tasks are idempotent -- safe to `mise run` again on an already-set-up
machine, they just no-op. `setup-github-ssh` still needs a browser the
*first* time (`gh auth refresh` for the `admin:public_key` scope), and
`bw login` needs your master password -- neither can be scripted away
without giving up the thing that makes them secure. The GitHub SSH key is
fine to regenerate per machine (each one just gets added to the account);
the age key, by contrast, must be restored, never regenerated -- a new one
would make every previously-encrypted secret in this repo unreadable.
