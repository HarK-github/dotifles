# Path exports
export PATH="$HOME/.linuxbrew/bin:$PATH"
export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1
export PATH=$PATH:/usr/local/go/bin
export OLLAMA_MODELS="/mnt/wwn-0x50014ee6092e2a12-part3/ollama_models"
export PATH=/mnt/DE94962594960067/Users/kandp/Documents/Work/College/CSL251_LAB/spike-demo/build:$PATH
export RISCV=/home/harshit-kandpal/RISCV

# pnpm
export PNPM_HOME="/home/harshit-kandpal/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Cargo
. "$HOME/.cargo/env"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Zsh options (equivalent to bash's shopt)
setopt APPEND_HISTORY           # equivalent to shopt -s histappend
setopt CHECK_JOBS               # check jobs before exiting
setopt EXTENDED_GLOB             # equivalent to shopt -s globstar (but different)
setopt NO_CHECK_JOBS            # don't warn about bg jobs
setopt NO_HUP                   # don't kill bg jobs on exit

# History settings
HISTSIZE=1000
SAVEHIST=2000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY            # share history between sessions
setopt HIST_IGNORE_DUPS         # ignore duplicate commands
setopt HIST_IGNORE_SPACE        # ignore commands starting with space

# Completion system (equivalent to bash completion)
autoload -Uz compinit
compinit

# Useful aliases (ported from bash)
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Zsh prompt (more powerful than bash's PS1)
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST

# Custom prompt with git info
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{red}${vcs_info_msg_0_}%f$ '
RPROMPT='%F{cyan}%*%f'

# Load aliases from separate file if it exists
[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'


# Load Angular CLI autocompletion.
source <(ng completion script)
