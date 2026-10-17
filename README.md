# Dotfiles

Personal dotfiles for a macOS work laptop and an [Omarchy](https://omarchy.org)
(Arch + Hyprland) personal laptop, bootstrapped entirely by
[mise](https://mise.jdx.dev/). No Homebrew, no chezmoi.

![Preview](assets/preview.png)

## Install

`mise bootstrap --from` clones this repo into `~/.dotfiles` and applies it.
`MISE_AUTO_ENV=1` makes mise load `mise.macos.toml` or `mise.linux.toml`, which
pick the machine's [dotfile groups](#dotfile-groups): no local file to write.
Bootstrap is idempotent and previewable with `--dry-run`.

### macOS (work laptop)

```sh
curl https://mise.run | sh
MISE_AUTO_ENV=1 ~/.local/bin/mise bootstrap --from https://github.com/fapont/dotfiles.git --from-dir ~/.dotfiles --yes
```

This installs packages through mise's own `brew`/`brew-cask` backends (no real
Homebrew involved), Oh My Zsh and its plugins, symlinked app configs,
`~/.zshrc`, macOS defaults and CLI tools. Some macOS permissions still need
[granting by hand](#macos-permissions).

### Omarchy (personal laptop)

Omarchy already ships mise (`/usr/bin/mise`) and seeds its own
`~/.config/{git,starship.toml,btop,ghostty}`, so the first run has to replace
them (`--force-dotfiles`). It also switches the login shell to zsh:

```sh
MISE_AUTO_ENV=1 mise bootstrap --from https://github.com/fapont/dotfiles.git --from-dir ~/.dotfiles --yes --force-dotfiles
```

On top of the shared configs, this machine gets:

- Arch packages Omarchy doesn't ship (`mise/conf.d/omarchy.toml`): zsh, Ghostty,
  Zed, Bitwarden, Telegram, Brave.
- Ghostty as the SUPER+RETURN terminal (`omarchy/xdg-terminals.list`), following
  the Omarchy theme switcher through an optional `config-file` include.
- Omarchy's Catppuccin theme, applied once by the first bootstrap. A theme picked
  later from the menu is never overridden.
- Hyprland overrides in `omarchy/hypr/`: `input.lua` (AZERTY, natural scroll) and
  `looknfeel.lua` (rounded corners, blur, dimmed inactive windows, resize on
  border). Bindings, gaps and monitors stay Omarchy's defaults.

### Then, on both

```sh
cd ~/.dotfiles
mise run setup-github-ssh    # per-machine SSH key, registered with GitHub for auth + commit signing
bw login                     # the one step that can't be scripted away
mise run restore-secrets     # pulls the fnox age key (id_ed25519_age) back from Bitwarden
mise run setup-obsidian      # ~/Obsidian vault + LiveSync, CouchDB creds from the fnox "obsidian" profile
```

Open a new terminal: `GH_TOKEN`/`GITHUB_TOKEN` are already there, and so is
`MISE_AUTO_ENV` (from `shell.toml`), so later runs are a plain `mise bootstrap`
from `~/.dotfiles`. All three tasks are idempotent.

## Layout

```
mise.toml                   # repo clones, dotfile groups and the dotfiles map (what goes where)
mise.macos.toml             # dotfile groups on macOS
mise.linux.toml             # dotfile groups on Linux
mise/
  config.toml               # -> ~/.config/mise/config.toml
  conf.d/                   # -> ~/.config/mise/conf.d/, one fragment per domain
    tools.toml              #    CLI tools
    shell.toml              #    aliases, env, login shell
    history.toml            #    ~/.zshrc blocks
    macos.toml              #    macOS packages + system defaults
    omarchy.toml            #    Arch packages + Omarchy theme
    agents/                 #    AI agent CLIs, AGENTS.md, Claude settings fragments
    obsidian/               #    Obsidian app + setup-obsidian task
  tasks/                    # `mise run` tasks: restore-secrets, setup-github-ssh
config/                     # group `config`: shared app configs (git, ghostty, btop, bat, starship...)
macos/                      # group `macos`: aerospace, karabiner, vorssaint, colima
omarchy/                    # group `omarchy`: Hyprland overrides, default terminal
work/                       # group `work`: k9s + mise/conf.d/work.toml (k8s, Docker, AWS, GCloud)
fnox/config.toml            # secrets as env vars
nvim/                       # Neovim (LazyVim)
zprofile
```

## How it works

### Dotfile groups

Each group folder (`config/`, `macos/`, `omarchy/`, `work/`) is linked file by
file into `~/.config`. The OS picks the groups, through platform files that
mise loads when `MISE_AUTO_ENV=1` (on by default from mise 2027.6):

| File | Groups |
|---|---|
| `mise.macos.toml` | `config`, `macos`, `work` |
| `mise.linux.toml` | `config`, `omarchy` |

Without `MISE_AUTO_ENV`, every group applies.

### One config, two OSes

- **Packages** are OS-gated: `os = "macos"` on `brew`/`brew-cask` entries, and
  `pacman:`/`aur:` entries are skipped where those managers don't exist.
- **CLI tools** that Omarchy already installs with pacman (jq, bat, eza, fd,
  zoxide, ripgrep, neovim, lazygit, starship, fzf) are `os = "macos"` in
  `tools.toml`, so mise doesn't install them twice.
- **Hooks and tasks** that call macOS-only tools (`osascript`, `pbcopy`,
  `scutil`) either check the OS or have a Linux fallback.

### mise fragments

`mise/conf.d/` is split by domain rather than kept in one big file, and each
file is linked individually (`symlink-each`). Machine-local fragments (e.g.
`doctolib.toml`) can sit next to the links without being tracked. A domain that
needs more than config (scripts, helpers) becomes a **folder fragment** like
`conf.d/obsidian/`: a `mise.toml` plus the files it uses, with the folder as
config root (`$MISE_CONFIG_ROOT`) and its `tasks/` runnable from any directory.

### Symlinks and tracked files

- App configs are **symlinked**: edits are live immediately and show up in
  `git status` here.
- Git's shared config is `~/.config/git/config`. `~/.gitconfig` stays a plain,
  untracked file, read last so it wins, that catches `git config --global`
  writes such as `gh auth setup-git`.
- `~/.zshrc` is **tracked** by mise: it owns marker-delimited blocks (Oh My Zsh,
  `mise activate`, starship, fnox, zoxide, atuin, fzf, worktrunk) and leaves the
  rest alone. Use `mise dot status`/`diff`/`save` for it.

## Notable choices

- **Git identity per context**: work email by default; personal email
  (`config/git/perso`) under `~/Perso/`, in this checkout, or in any repo with a
  `fapont/*` GitHub remote. Adding a context is one file with a `[user]` block
  plus one `includeIf` in `config/git/config`. Commits and tags are SSH-signed
  with the per-machine key from `setup-github-ssh`.
- **Supply-chain cooldown**: `minimum_release_age = "3d"`, so `latest` never
  resolves to a release younger than 3 days. Pin a version explicitly to bypass
  it for one tool.
- **AI agents** live in `mise/conf.d/agents/`: one `AGENTS.md` linked under each
  agent's expected name (`~/.config/claude/CLAUDE.md`...), one folder per agent.
  Claude's `settings.json` is **not** tracked (this repo is public, and Claude
  writes to it). Its shared parts are fragments in `agents/claude/settings.d/`,
  merged *into* the live file by `merge` entries in the root `mise.toml`:
  - each fragment owns only its keys; everything else (e.g. work-only `autoMode`)
    is left alone;
  - `merge = true` enforces (permissions), `merge = "missing"` only sets defaults,
    so `/config` and `/plugin` changes stick;
  - arrays are replaced, not unioned: `mise dot diff` shows "always allow"
    entries worth promoting into a fragment;
  - deleting a key from a fragment doesn't delete it from the live file.
- **Secrets** live in `fnox/config.toml` with the `age` provider: ciphertext is
  committed and decrypted locally, with no network or vault needed. Tokens
  (`GH_TOKEN`, `GITHUB_TOKEN`, `AI_PROVIDER_TOKEN`) are in every shell without a
  Bitwarden session; the `obsidian` profile holds the LiveSync credentials.

## Day to day

- **New tool or package**: add it to the relevant `conf.d/*.toml`, run
  `mise bootstrap`, commit.
- **New file in a group or in `conf.d/`**: run `mise bootstrap --only dotfiles`
  to link it.
- **Config drifted**: symlinked files are edited in place, so just commit from
  `~/.dotfiles`. For `~/.zshrc`, use `mise dot status`/`diff`/`save`.
- **Risky change**: preview with `mise bootstrap --dry-run`.

## macOS permissions

Bootstrap installs the apps, and `macos.toml`'s `post-packages` hook opens the
background and menu-bar ones once so macOS shows their permission prompts.
Granting those prompts isn't scriptable: do it in **System Settings > Privacy &
Security**, then quit and reopen the app (or reboot).

- **Vorssaint** (replaces AltTab, Stats, KeepingYouAwake, LinearMouse): grant
  Accessibility and Screen Recording, then import its settings by hand via
  Settings > Import > `macos/vorssaint/settings.plist`. Re-export to the same
  file after changing settings.
- **Accessibility**: AeroSpace (also needed for `start-at-login` and its
  `borders` startup command), Ice, Raycast (hotkeys, snippets),
  Karabiner-Elements (event capture; recent versions don't need a separate
  Input Monitoring grant).
- **Screen Recording**: Raycast (window management, Screen Awareness), Ice
  (menu bar item images; re-grant after every update, it ships ad-hoc-signed
  builds), and cmux's `cmux-cua` helper if its Computer Use feature is used.
- **Karabiner driver extension**: its `.pkg` install needs `sudo`; without a TTY
  (agent or CI), `mise bootstrap` prints the exact `sudo installer -pkg ...`
  command to run by hand. Then approve `Karabiner-DriverKit-VirtualHIDDevice`
  under **System Settings > General > Login Items & Extensions > Driver
  Extensions**, allow Karabiner to run in the background in the same pane, and
  **reboot**: the caps lock / left option hyper key only works after that.
- **Launch at login**:
  - Ice is added as a regular Login Item by the `post-packages` hook (the first
    run asks to let the terminal control System Events under **Automation**).
  - AeroSpace handles it itself (`start-at-login = true`, once Accessibility is
    granted) and starts `borders` from its `after-startup-command`.
  - Raycast and Bitwarden register their own login item the first time they're
    opened.
  - Brave has no scriptable option: toggle it by hand if wanted.
  - Karabiner-Elements has no toggle: its installer registers LaunchDaemons
    that start it at every login. Quit it (or remove them) if unwanted.

## Known gaps

- **Omarchy writes to the global mise config**: its lazy wrappers (`gh`,
  `codex`...) and dev-env installer run `mise use -g`, which lands in
  `~/.config/mise/config.toml`, i.e. in this repo through the symlink. Review
  with `git diff` before committing.
- **`omarchy-reinstall-configs`** copies Omarchy's defaults over `~/.config`,
  and so through the symlinks into this repo. Avoid it, or check `git status`
  afterwards.
- **Colima runtime state** (VM disk, sockets) lives in `macos/colima/`, because
  `~/.config/colima` is a whole-directory symlink. It's gitignored, but moving
  that folder means stopping the VM first.
- **Root-owned files under `/opt/homebrew`**: a past `sudo mise ...` run can leave
  root-owned paths that make installs fail with `Permission denied`. Fix with
  `sudo chown -R "$(whoami)":admin /opt/homebrew`, and never run `mise bootstrap`
  itself with `sudo`.
- **Old keyboards in `macos/karabiner/karabiner.json`**: the default profile
  still lists an Apple keyboard (`vendor_id` 1452, `product_id` 591) and a
  Keychron (13364 / 2832) from a previous machine. Harmless if they're not
  plugged in; prune them once they're gone for good. The hyper-key remap
  applies whatever keyboard is connected.
