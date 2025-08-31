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
  - Vi mode with Emacs keybindings for enhanced editing

- **`.zshrc.personal`** - Personal customizations including:
  - Go development environment setup
  - GPG configuration
  - Docker utility functions (stop, remove, clean containers/images)
  - Git workflow automation (`gitRebaseDevelop` function)
  - Go code formatting utilities (`formatgom` with gofumpt and gogroup)

- **`.p10k.zsh`** - Powerlevel10k theme configuration with:
  - Lean prompt style with minimal, clean appearance
  - Left prompt: directory and git status
  - Right prompt: exit codes, execution time, background jobs, and environment indicators
  - Transient prompt for cleaner command history

### Editor Configuration

- **`.ideavimrc`** - IdeaVim configuration for IntelliJ IDEA with:
  - Navigation mappings for Go-to definition, implementation, and type declaration
  - Quick access to recent files, locations, classes, and symbols
  - Error navigation and method navigation shortcuts
  - Enhanced vim-like editing experience in JetBrains IDEs

## Dependencies

The configuration assumes the following tools are installed:
- [Homebrew](https://brew.sh/) (macOS)
- [fzf](https://github.com/junegunn/fzf)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- Go development tools (for Go-related functions)
- Docker (for Docker utility functions)
