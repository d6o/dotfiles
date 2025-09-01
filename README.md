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

- **`.vimrc`** - Basic Vim configuration with:
  - Syntax highlighting and filetype detection
  - Line numbers and showcmd enabled
  - Desert colorscheme

### Neovim Configuration

- **`.config/nvim/`** - Complete Neovim setup featuring:
  - Lua-based configuration with modular structure
  - Custom LSP configurations and plugins
  - Organized into `lua/`, `after/`, `lsp/`, and `plugin/` directories
  - Modern Neovim development environment

### Terminal Configuration

- **`.config/alacritty/`** - Alacritty terminal emulator configuration:
  - Main configuration in `alacritty.toml`
  - Multiple colorscheme options: Catppuccin Mocha and Tokyo Night themes
  - Optimized for performance and visual appeal

### Window Management & System Productivity

- **`.aerospace.toml`** - AeroSpace window manager configuration with:
  - i3-inspired tiling window management for macOS
  - Vim-style navigation keybindings (hjkl)
  - Workspace assignment rules for different applications
  - Integration with SketchyBar for workspace indicators
  - Custom gaps and layout configurations
  - Service mode for advanced window operations

- **`.config/sketchybar/`** - SketchyBar configuration for menu bar customization:
  - Custom bar appearance and behavior
  - AeroSpace workspace integration
  - Modular Lua configuration files
  - Color scheme and styling definitions

- **`.config/karabiner/karabiner.json`** - Karabiner-Elements configuration:
  - Custom keyboard mappings and shortcuts
  - Enhanced keyboard functionality for macOS

## Dependencies

The configuration assumes the following tools are installed:

### Core Requirements
- [Homebrew](https://brew.sh/) (macOS package manager)
- [GNU Stow](https://www.gnu.org/software/stow/) (symlink management)

### Shell & Terminal
- [fzf](https://github.com/junegunn/fzf) (fuzzy finder)
- [zoxide](https://github.com/ajeetdsouza/zoxide) (smart cd command)
- [Alacritty](https://alacritty.org/) (terminal emulator)

### Window Management & Productivity
- [AeroSpace](https://nikitabobko.github.io/AeroSpace/) (tiling window manager for macOS)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar) (custom menu bar)
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/) (keyboard customization)

### Editors
- [Neovim](https://neovim.io/) (modern vim-based editor)
- [Vim](https://www.vim.org/) (classic text editor)

### Development Tools
- Go development tools (for Go-related functions in .zshrc.personal)
- Docker (for Docker utility functions)
- GPG (for Git signing configuration)
