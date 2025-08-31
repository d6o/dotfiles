# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#define zinit home folder
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

#install zinit if not installed
if [ ! -d "$ZINIT_HOME" ]; then
	mekdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

source "${ZINIT_HOME}/zinit.zsh"

export EDITOR=vim

# Vim mode
bindkey -v

# load the theme
zinit ice depth=1; zinit light romkatv/powerlevel10k

#load plugins

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

#load auto complete
autoload -U compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# History
HISTZIZE=100000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt auto_cd
setopt extended_glob
setopt completeinword
setopt nobeep
setopt noshwordsplit


# Completion settings
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:cat:*' fzf-preview 'cat $realpath'

# provide .. as a completion
zstyle ':completion:*' special-dirs ..

# alias
alias ls='ls --color'

# integrations 
eval "$(fzf --zsh)"

# Load personal configuration if it exists
if [[ -f ~/.zshrc.personal ]]; then
    source ~/.zshrc.personal
fi

# Load local configuration if it exists
if [[ -f ~/.zshrc.local ]]; then
    source ~/.zshrc.local
fi

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# Load edit command widget
autoload -Uz edit-command-line
zle -N edit-command-line

# ============================================================================
# KEY BINDINGS FOR VIM MODE WITH EMACS CONVENIENCES
# ============================================================================

# ----------------------------------------------------------------------------
# WORD NAVIGATION (Option/Alt + Arrow Keys)
# ----------------------------------------------------------------------------
# Move forward/backward by word using Option + Arrow keys in both modes
bindkey -M viins '\e[1;3C' forward-word        # Option + Right (insert mode)
bindkey -M viins '\e[1;3D' backward-word       # Option + Left (insert mode)
bindkey -M vicmd '\e[1;3C' forward-word        # Option + Right (command mode)
bindkey -M vicmd '\e[1;3D' backward-word       # Option + Left (command mode)

# ----------------------------------------------------------------------------
# ZSH AUTOSUGGESTIONS
# ----------------------------------------------------------------------------
bindkey -M viins '^ ' autosuggest-accept       # Ctrl + Space: Accept full suggestion
bindkey -M vicmd '^ ' autosuggest-accept       # Ctrl + Space: Accept full suggestion

# ----------------------------------------------------------------------------
# LINE NAVIGATION
# ----------------------------------------------------------------------------
bindkey -M viins '^A' beginning-of-line        # Ctrl + A: Jump to line start
bindkey -M viins '^E' end-of-line              # Ctrl + E: Jump to line end
bindkey -M vicmd '^A' beginning-of-line        # Ctrl + A: Jump to line start
bindkey -M vicmd '^E' end-of-line              # Ctrl + E: Jump to line end

# ----------------------------------------------------------------------------
# TEXT DELETION
# ----------------------------------------------------------------------------
bindkey -M viins '^K' kill-line                # Ctrl + K: Delete from cursor to end
bindkey -M viins '^U' backward-kill-line       # Ctrl + U: Delete from cursor to beginning
bindkey -M viins '^W' backward-kill-word        # Ctrl + W: Delete previous word
bindkey -M vicmd '^K' kill-line                # Ctrl + K: Delete from cursor to end
bindkey -M vicmd '^U' backward-kill-line       # Ctrl + U: Delete from cursor to beginning
bindkey -M vicmd '^W' backward-kill-word       # Ctrl + W: Delete previous word

# ----------------------------------------------------------------------------
# EDITING UTILITIES
# ----------------------------------------------------------------------------
bindkey -M viins '^O' undo                     # Ctrl + O: Undo
bindkey -M viins '^P' redo                     # Ctrl + P: Redo
bindkey -M viins '^L' clear-screen             # Ctrl + L: Clear terminal screen
bindkey -M viins '^V' edit-command-line        # Ctrl + V: Edit in vim
bindkey -M vicmd '^O' undo                     # Ctrl + O: Undo
bindkey -M vicmd '^P' redo                     # Ctrl + P: Redo
bindkey -M vicmd '^L' clear-screen             # Ctrl + L: Clear terminal screen
bindkey -M vicmd '^V' edit-command-line        # Ctrl + V: Edit in vim

