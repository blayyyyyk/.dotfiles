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
1. Fork and clone the repository to your local machines to your home/user directory.
```
cd ~
git clone [your fork url]
```
2. Navigate into the .dotfiles directory and run the install script
```
cd ~/.dotfiles
chmod x+ install.sh
./install.sh
```

# 1.2.0 Manual Setup Guide
**A manual setup guide is coming soon. For the time being, please refer to `brew_pkgs.txt` for homebrew packages.**
