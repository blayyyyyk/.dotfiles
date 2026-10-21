# My Personal Development Configuration Files
This is my repository for tracking all of my configuration files for my current development environment. Using this repository allows me to quickly begin development on new Linux and Unix-based devices. For a guide on installation, please refer to the [Quickstart Guide](#1.1.0-quickstart-guide)

# Table of Contents
- [Environment Info](#100-environment-info)
    - [Operating System](#101-operating-system)
    - [Terminal](#102-terminal)
    - [Editor](#103-editor)
    - [Languages](#104-languages)
- [Quickstart Guide](#110-quickstart-quide)
- [Manual Setup Guide](#120-manual-setup-guide)

# 1.0.0 Environment Info
## 1.0.1 Operating System
I am originally a Windows native, however most of my work now is done on the latest version of MacOS. For server projects, I run [Ubuntu Server 24.04 LTS](https://ubuntu.com/download/server).
## 1.0.2 Terminal
For my terminal setup, I use a terminal emulator called [Kitty](https://sw.kovidgoyal.net/kitty/) with a shell called [Zsh](https://en.wikipedia.org/wiki/Z_shell). I chose Kitty for its speed (i.e. GPU support), image support, font ligature support, and further customizability features. Additionally, Zsh has plugin support (i.e. [OhMyZsh](https://ohmyz.sh/)), syntax highlighting, and autocompletion. I've also configured Zsh with [powerlevel10k](https://github.com/romkatv/powerlevel10k) theming. For productivity, I've configured Tmux for multiplexing and preserving my running development processes (i.e. dev web pages). I'm beginning to learn Vim, along with [Neovim](https://neovim.io/) keymappings for improved development efficiency. Additonally, I use [Zoxide](https://github.com/ajeetdsouza/zoxide) for fast file navigation.
## 1.0.3 Editor
I mainly use [Zed](https://zed.dev/) for my editor of choice, occasionally using [Visual Studio Code](https://code.visualstudio.com/) for their refactoring tools. I chose Zed for its lightweight design and fast performance, free of [Electron](https://en.wikipedia.org/wiki/Electron_(software_framework)) (i.e. literal bloatware). I use a stock [Prettier](https://prettier.io/) configuration for code formatting.
## 1.0.4 Languages
I mainly work with [Python 3.11](https://www.python.org/) for my current research projects. I use [Miniconda](https://www.anaconda.com/docs/getting-started/miniconda/main) for my environment management. I am a supporter of the experimental, AI-focused, Python superset called Mojo and use it in my free time. Most of my conda environments are started with Pytorch, Pandas, Numpy, and OpenCV. For web development, I use NextJS app router configured with TypeScript and TailwindCSS, and FastAPI paired with SQLite for backend services.

# 1.1.0 Quickstart Guide
Works on macOS (Apple Silicon or Intel) and Linux (apt, dnf or pacman).

1. Clone the repository into your home directory.
```
git clone https://github.com/blayyyyyk/.dotfiles.git ~/.dotfiles
```
2. Run the setup script. It is safe to re-run: finished steps are skipped, and any file it
   would replace with a link is moved to `~/.dotfiles-backup/<timestamp>/` first.
```
cd ~/.dotfiles
./setup.sh            # or ./setup.sh --dry-run to see what it would do
```

`setup.sh` installs the system prerequisites (Xcode Command Line Tools, or build tools via the
Linux package manager), Homebrew and the `Brewfile` (macOS apps only on macOS), rustup and uv,
Oh My Zsh with powerlevel10k, links the packages below with GNU Stow, writes the machine-local
`~/.gitconfig.local`, installs the tmux plugins, and installs and verifies the Neovim language
servers, formatters and parsers. Options: `--upgrade`, `--no-brew`, `--no-nvim`, `--ci`.

| Package | Links |
| --- | --- |
| `config` | `~/.config/{nvim,kitty,tmux,prettier,zed,cmux,opencode,iterm2}` |
| `zsh` | `~/.zshrc`, `~/.p10k.zsh` |
| `git` | `~/.gitconfig`, `~/.config/git/ignore` |
| `bin` | `~/.local/bin/claude-trust-dev` |
| `vscode` | `~/.vscode` |
| `hammerspoon` (macOS) | `~/.hammerspoon/init.lua` |

Machine-specific settings stay out of the repo: `~/.gitconfig.local` and `~/.zshrc.local`.

To try the Linux path in a throwaway Ubuntu container: `./setup_container.sh`.

# 1.2.0 Manual Setup Guide
Install the packages in `Brewfile` with `brew bundle`, then link what you want with
`stow --target="$HOME" <package>` from `~/.dotfiles`. See
[config/.config/nvim/README.md](config/.config/nvim/README.md) for the Neovim setup.
