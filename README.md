# Dotfiles

Personal dotfiles for a macOS work laptop and an [Omarchy](https://omarchy.org)
(Arch + Hyprland) personal laptop, bootstrapped entirely by
[mise](https://mise.jdx.dev/). No Homebrew, no chezmoi.

![Preview](.github/preview.png)

## Install

Same steps on macOS and Omarchy, `<machine>` being a folder of [`machines/`](machines/):

```sh
command -v mise || curl https://mise.run | sh   # Omarchy already ships mise
export PATH="$HOME/.local/bin:$PATH"
mise bootstrap --from https://github.com/fapont/dotfiles.git --from-dir ~/.dotfiles --config-dir machines/<machine> --yes --force-dotfiles --prompt-vars
```

```sh
cd ~/.dotfiles
mise run setup-github-ssh    # SSH key for GitHub auth + commit signing
bw login
mise run restore-secrets     # fnox age key from Bitwarden
mise run setup-obsidian      # Obsidian vault + LiveSync
```

`--config-dir` links `~/.config/mise` to `machines/<machine>/` (it must be
missing or empty: move an existing one aside), so the machine's modules apply
from the first run. `--force-dotfiles` replaces the configs Omarchy pre-seeds.
Needs mise 2026.10.21+. Afterwards:
`mise run --skip-tools update` (pull + bootstrap). On macOS, a few
[permissions](#macos-permissions) stay manual.

## Layout

```
machines/<machine>/       -> ~/.config/mise on that machine
  miserc.toml             its modules: env = ["shell", "git", ...]
  config.toml -> ../../mise/config.toml
  conf.d      -> ../../modules
mise/config.toml          shared settings, `mise run update`
modules/<name>/           one tool or domain, self-contained
  mise.<name>.toml        tools, packages, aliases, env, hooks, its dotfile group
  home/                   files linked into ~, at their path (home/.config/foo -> ~/.config/foo)
  tasks/                  `mise run` tasks
```

| Machine | Modules |
| --- | --- |
| `work-mac` | the shared ones + `macos`, `aerospace`, `docker`, `k8s`, `cloud`, `dev` |
| `omarchy` | the shared ones + `omarchy` |

| Module | Content |
| --- | --- |
| `shell` | zsh, oh-my-zsh, env, login shell, `~/.zshrc` blocks, `.zprofile` |
| `starship`, `eza`, `bat`, `btop`, `tealdeer`, `zoxide`, `fzf`, `atuin` | the tool, its config and aliases |
| `cli` | small CLIs with no config (jq, yq, fd, rg, delta, glow, tree...) |
| `python` | python, uv |
| `git` | git, gh, worktrunk, lazygit, per-machine identities, `setup-github-ssh` |
| `secrets` | fnox, age, Bitwarden, `restore-secrets` |
| `agents` | Claude Code, AGENTS.md, settings fragments, MCP servers, ccstatusline |
| `herdr` | herdr, its skill, `herdr-perso` |
| `nvim`, `ghostty`, `obsidian` | the app and its config |
| `macos`, `aerospace` | macOS apps, system defaults, login items; AeroSpace + borders |
| `omarchy` | missing Arch packages, Catppuccin, Hyprland overrides, Ghostty as default terminal, lid lock |
| `docker`, `k8s`, `cloud`, `dev` | work tooling: Colima, kubectl/k9s, AWS/GCloud (`awsp`), linters |

Where does X go? In the module of its tool, or a new `modules/<name>/` listed by
the machines that want it. A shared module that differs per OS uses
`os = "macos"` / `os = "linux"` on the entry. A zsh function that belongs to a
tool → `home/.config/oh-my-zsh/custom/<name>.zsh` in its module (oh-my-zsh
sources every `*.zsh` there).

## How it works

- **Machines and modules**: `~/.config/mise` is `machines/<machine>/`. mise reads
  its `miserc.toml` before any config, and the `env` list selects config
  environments. `~/.config/mise/conf.d` points at `modules/`, and `modules/<name>/mise.<name>.toml` is the config of environment
  `<name>`: it loads only when the machine lists it. `mise config ls` shows what
  a machine loads. `auto_env` stays off so `macos/mise.macos.toml` never loads
  just because the OS is macOS.
- **Dotfile groups**: each module declares `[dotfile_groups.<name>] root =
  "<name>/home"` (relative to `dotfiles.root`, `~/.dotfiles/modules`), linked file
  by file into `~`. Dirs that hold runtime state or are rewritten by their app
  (nvim, btop, colima) are whole-dir links.
- **Machine-local config**: `*.local.toml` files (e.g. `modules/doctolib.local.toml`)
  are loaded on every machine they sit on, and gitignored.
- **Symlinks**: app configs are symlinked, so edits are live and show up in
  `git status`. `~/.gitconfig` stays untracked for `git config --global` writes.
  `~/.zshrc` is tracked by mise through marker blocks (`mise dot status`/`diff`/`save`).

## Notable choices

- **Git identity**: work email by default, personal one under `~/Perso/`, in this
  repo or for `fapont/*` remotes. Emails stay out of the repo: asked once
  per machine (`--prompt-vars`, or `mise vars prompt`) and rendered into
  `~/.config/git/identity-*`. Commits are SSH-signed with the per-machine key.
- **Supply-chain cooldown**: `minimum_release_age = "3d"`; pin a version to bypass.
- **GitHub API**: mise borrows gh's token (`settings.github.credential_command`),
  so installs don't hit the anonymous rate limit.
- **AI agents** (`modules/agents/`): one `AGENTS.md` linked for each agent.
  Claude's `settings.json` isn't tracked; fragments in `agents/claude/settings.d/`
  are merged into it (`merge = true` enforces, `"missing"` only sets defaults;
  arrays are replaced, and removed keys stay live).
  User-scope MCP servers (`agents/claude/mcp.json`) are merged into `.claude.json`
  the same way, their URL and key as `${VAR}`s from fnox.
  Skills go in `~/.agents/skills/` (read by Codex, pi, Zed...), linked one by one
  into Claude's; the herdr skill is regenerated from `herdr --skill` on bootstrap.
- **Secrets**: `modules/secrets/home/.config/fnox/config.toml`, age-encrypted in
  the repo, decrypted locally.

## Day to day

- New tool or package: add it to its module, `mise bootstrap`, commit.
- New module: `modules/<name>/mise.<name>.toml` (+ `home/`), add `<name>` to the machines that want it.
- New machine: copy a `machines/<machine>/` folder (keep its two links), edit its module list, then the install steps above.
- Try a module for one run: `mise -E <machine's list>,<name> bootstrap` (`-E` replaces the list for that run).
- Drop a module from a machine: remove it from the list, then `mise bootstrap --prune-dotfiles`
  (its dotfiles) and `mise bootstrap unapply <name>` (its system files and services);
  packages stay until `mise bootstrap packages prune`.
- New file in a module's `home/`: `mise dot apply`. Removed one: `mise dot apply --prune`.
- Pull and apply: `mise run --skip-tools update`. Preview anything with `mise bootstrap --dry-run`.

## Migrating a machine from the old layout

```sh
colima stop                                # its VM state moves with ~/.config/colima
mise self-update                           # 2026.10.21+
git -C ~/.dotfiles pull
mv ~/.config/mise ~/.config/mise.old       # keep machine-local fragments:
cp ~/.config/mise.old/conf.d/doctolib.toml ~/.dotfiles/modules/doctolib.local.toml
rsync -a ~/.dotfiles/macos/colima/ ~/.dotfiles/modules/docker/home/.config/colima/   # gitignored VM state
/bin/rm -rf ~/.dotfiles/macos ~/.dotfiles/config ~/.dotfiles/omarchy ~/.dotfiles/work   # leftovers, untracked
ln -s ~/.dotfiles/machines/work-mac ~/.config/mise
unset MISE_AUTO_ENV                        # set by the old config, it would load macos/ on any Mac; new shells drop it
mise bootstrap --force-dotfiles --prune-dotfiles
```

## macOS permissions

Not scriptable: grant in **System Settings > Privacy & Security**, then restart the app.

- **Accessibility**: AeroSpace, Ice, Raycast, Vorssaint.
- **Screen Recording**: Raycast, Ice (again after each update), Vorssaint.
- **Vorssaint settings**: import `modules/macos/home/.config/vorssaint/settings.plist` by hand.
- **Login items**: Ice is added by bootstrap; AeroSpace, Raycast and Bitwarden
  handle it themselves; Brave by hand.

## Known gaps

- Omarchy's `mise use -g` wrappers and `omarchy-reinstall-configs` write through
  the symlinks into this repo: check `git status`.
- Colima's VM state lives (gitignored) in `modules/docker/home/.config/colima/`: stop the VM before moving it.
- A past `sudo mise` can leave root-owned files in `/opt/homebrew`:
  `sudo chown -R "$(whoami)":admin /opt/homebrew`.
