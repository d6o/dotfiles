# Dotfiles

Personal dotfiles configuration managed with [GNU Stow](https://www.gnu.org/software/stow/) for easy deployment and synchronization across systems.

## Installation

```bash
git clone https://github.com/d6o/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow .
```

## What's Included

### Shell Configuration

- **`.zshrc`** - Main Zsh configuration featuring:
  - [Zinit](https://github.com/zdharma-continuum/zinit) plugin manager
  - [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme with instant prompt
  - Enhanced plugins: syntax highlighting, autosuggestions, completions, and fzf-tab
  - Optimized history settings and completion styles
  - Integration with fzf and zoxide for enhanced navigation

- **`.zshrc.personal`** - Personal customizations including:
  - Go development environment setup
  - GPG configuration
  - Docker utility functions (stop, remove, clean containers/images)
  - Git workflow automation (`gitRebaseDevelop` function)
  - Go code formatting utilities (`formatgom` with gofumpt and gogroup)

## Features

- **Modular Design**: Separates core shell configuration from personal customizations
- **Plugin Management**: Auto-installs Zinit if not present and loads essential Zsh plugins
- **Development Tools**: Pre-configured functions for Docker management and Go development
- **Enhanced Navigation**: Integrates fzf for fuzzy finding and zoxide for smart directory jumping
- **Git Workflow**: Custom functions to streamline rebasing and code formatting workflows

## Dependencies

The configuration assumes the following tools are installed:
- [Homebrew](https://brew.sh/) (macOS)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- Go development tools (for Go-related functions)
- Docker (for Docker utility functions)