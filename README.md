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
repo to `~/.dotfiles` over HTTPS (pushes go over SSH), runs `install`, and
installs [tpm](https://github.com/tmux-plugins/tpm). Any existing files that
would be replaced, such as a distro's default `~/.bashrc`, are moved to
`~/.dotfiles-backup/<timestamp>/`.

Then finish up by hand:

- `chsh -s "$(command -v zsh)"`
- Create `~/.git_identities/.gitconfig` (see [Git identities](#git-identities));
  git refuses to commit until you do
- In tmux, `<prefix> I` to install plugins
- Optional: `fzf`, `zoxide`, `mosh` (on macOS, `brew bundle` installs them)

zsh plugins are listed in `zsh/.zsh_plugins.txt` and managed by
[antidote](https://antidote.sh), which installs itself and the plugins on the
first shell start; `antidote update` updates them. If a machine still has
`~/.zplug` from the old setup, delete it.

## Packages

| Package | Contents |
|---------|----------|
| `main`  | Shared environment (`.env.sh`), `.aliases`, `.functions`, git, ssh, WezTerm, `~/bin` scripts |
| `zsh`   | zsh startup files, prompt, plugin list |
| `bash`  | bash fallback config (for machines/containers without zsh) |
| `tmux`  | tmux config (prefix is `C-z`) plus Linux-specific bits |
| `emacs` | Old config, not currently stowed |

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
git -C ~/.dotfiles pull && ~/.dotfiles/install
update   # OS + package updates: softwareupdate/brew bundle on macOS, apt/dnf/pacman on Linux
```
