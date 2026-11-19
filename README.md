# Dotfiles

Shell, git, tmux and terminal config for the macOS and Linux machines I use,
managed with [GNU Stow](https://www.gnu.org/software/stow/). Originally forked
from [kelsin/dotfiles](https://github.com/kelsin/dotfiles).

## New machine

```sh
curl -fsSL https://raw.githubusercontent.com/iantruslove/dotfiles/master/bootstrap | sh
```

(With wget: `wget -qO- <url> | sh`.) The same setup is used on every machine.

`bootstrap` installs git and stow (brew, apt, dnf, pacman or pkg), clones this
repo to `~/.dotfiles` over HTTPS (pushes go over SSH), then runs `sync`, which
stows the packages, installs [tpm](https://github.com/tmux-plugins/tpm) (and
Spacemacs if emacs is present), and lists any manual follow-ups. Any existing files that
would be replaced, such as a distro's default `~/.bashrc`, are moved to
`~/.dotfiles-backup/<timestamp>/`.

Then finish up by hand:

- `chsh -s "$(command -v zsh)"`
- Create `~/.git_identities/.gitconfig` (see [Git identities](#git-identities));
  git refuses to commit until you do
- In tmux, `<prefix> I` to install plugins
- Optional: `fzf`, `zoxide`, `mosh`, [herdr](https://herdr.dev) and
  [Ghostty](https://ghostty.org). On macOS, `brew bundle` installs them (and
  the GUI apps in the Brewfile); `update` runs it on every later update

zsh plugins are listed in `zsh/.zsh_plugins.txt` and managed by
[antidote](https://antidote.sh), which installs itself and the plugins on the
first shell start; `antidote update` updates them. If a machine still has
`~/.zplug` from the old setup, delete it.

## Packages

| Package | Contents |
|---------|----------|
| `main`  | Shared environment (`.env.sh`), `.aliases`, `.functions`, git, ssh, WezTerm, Ghostty, `~/bin` scripts |
| `zsh`   | zsh startup files, prompt, plugin list |
| `bash`  | bash fallback config (for machines/containers without zsh) |
| `tmux`  | tmux config (prefix is `C-z`) plus Linux-specific bits |
| `herdr` | [herdr](https://herdr.dev) config, ported from the tmux one (prefix is `C-z`) |
| `spacemacs` | Spacemacs dotfile (`~/.spacemacs.d/init.el`) plus the org helpers it loads |

```sh
cd ~/.dotfiles
./install            # stow all packages
stow -R zsh          # restow one package
stow -D zsh          # remove one package
```

`.stowrc` sets `--no-folding`, so directories such as `~/.ssh` and `~/bin` are
real directories containing symlinks, never symlinks into this repo.

## Machine-local config

Things specific to one machine stay out of git:

- **`~/.site/`**: every *executable* file in here is sourced by both bash and zsh
  at the end of startup. Use it for per-machine aliases, PATH additions, and so on.
- **`~/.ssh/*.config`**: included by `~/.ssh/config`.
- **`~/.git_identities/.gitconfig`**: git identities (below).
- **`main/.env.secrets`, `main/.env.secrets.sh`**: sourced by `.env.sh` if present.
  Both are gitignored.

### Spacemacs

`~/.emacs.d` is a checkout of [Spacemacs](https://www.spacemacs.org) (bootstrap
clones it when emacs is installed). The config is `~/.spacemacs.d/init.el`; make
sure there is no `~/.spacemacs`, which would take precedence.

The org agenda is every `.org` file at the top of `org-directory` (only the
newest `rocks_YYYY.org`), plus the last 12 months of `journal/journal-YYYY-MM.org`,
recomputed each time the agenda opens. Adding a file to the org directory puts it
in the agenda on every machine; there's no need for `C-c [`.

Per-machine settings go in `~/.spacemacs.d/local.el`, loaded at the end of
`dotspacemacs/user-config`. For example:

```elisp
(setq org-directory "~/Dropbox/org"
      ian/org-agenda-journal-months 3)
(setq ian/org-agenda-exclude-regexp "\\`scratch")
(add-to-list 'ian/org-agenda-extra-files "~/work/client-x.org")
```

GUI Emacs gets its environment from `~/.spacemacs.d/.spacemacs.env` (also
per-machine; regenerate it from a shell with `SPC f e E`).

### Git identities

`.gitconfig` sets `user.useConfigOnly`, so each repo has to choose an identity.
Define the identities in `~/.git_identities/.gitconfig`:

```ini
[user "github"]
    name = Ian Truslove
    email = you@example.com
    signingkey = <keyID>
    gpgsign = true
```

and choose one per repo with `git identity github`.

## Updating

```sh
~/.dotfiles/sync   # pull, restow, prune stale links, install extras, list follow-ups
update             # OS + package updates: softwareupdate/brew bundle on macOS, apt/dnf/pacman on Linux
```

`sync` is safe to re-run. It pulls with `--ff-only` (so it stops if you have
local commits or a diverged branch), shows the commits it pulled, restows every
package, and removes dangling symlinks into the repo left behind by files or
packages that have since been deleted. On a machine whose clone predates
`sync`, run `git -C ~/.dotfiles pull` once first, or just re-run `bootstrap`.
