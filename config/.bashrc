# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export XDG_DATA_DIRS="/usr/local/share:/usr/share:$HOME/.local/share:$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-}"

# ── Bash Completion ──────────────────────────────────────────────────────────
[[ -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE="$HOME/.bash_history"
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL="erasedups:ignoreboth"
HISTTIMEFORMAT="%F %T  "
shopt -s histappend          # append to history, don't overwrite
shopt -s histverify          # edit history line before executing
shopt -s cmdhist             # save multi-line commands as one entry
PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"

# ── Shell Options ─────────────────────────────────────────────────────────────
shopt -s autocd              # cd by typing directory name
shopt -s cdspell             # fix minor typos in cd
shopt -s dirspell            # fix minor typos in directory completion
shopt -s globstar 2>/dev/null # ** matches all files recursively
shopt -s checkwinsize         # update LINES/COLUMNS after each command
shopt -s no_empty_cmd_completion 2>/dev/null

# ── Aliases: xbps / Void Linux ────────────────────────────────────────────────
alias xi='sudo xbps-install'                        # install packages
alias xr='sudo xbps-remove'                         # remove packages
alias xq='xbps-query'                               # query packages
alias xrs='sudo xbps-remove -R'                     # remove + deps
alias xu='sudo xbps-install -Su'                    # full system update
alias xuf='sudo xbps-install -Suf'                  # force full update
alias xh='xbps-query -H'                            # hold (locked) packages
alias xsh='sudo xbps-pkgdb -m'                      # hold a package
alias xunh='sudo xbps-pkgdb -u'                     # unhold a package
alias xcl='sudo xbps-remove -O'                     # clean cache (orphans)
alias xdl='sudo xbps-remove -o'                     # remove orphans
alias xinfo='xbps-query -S'                         # remote info
alias xfind='xbps-query -Rs'                        # remote search
alias xlocal='xbps-query -l | wc -l'                # count installed
alias xrep='sudo xbps-install -S'                   # sync repos

# ── Aliases: general ─────────────────────────────────────────────────────────
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias lt='eza -lah --tree --icons --git --level=2'
alias l='eza --icons'
alias cat='bat --paging=never 2>/dev/null || cat'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias update='sudo xbps-install -Su'
alias install='sudo xbps-install'
alias remove='sudo xbps-remove'
alias search='xbps-query -Rs'
alias nano='micro'
alias term='ghostty'
alias sync-themes='noctalia-sync-themes'
alias cls='clear'

# ── Functions ────────────────────────────────────────────────────────────────

# cd + ls -la using eza with icons
cd() {
    builtin cd "$@" && eza -lah --icons --git
}

# mkdir + cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# extract archives
extract() {
    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz|*.txz)   tar xJf "$1" ;;
        *.tar.zst)        tar --zstd -xf "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.gz)             gunzip "$1" ;;
        *.rar)            unrar x "$1" ;;
        *.tar)            tar xf "$1" ;;
        *.zip)            unzip "$1" ;;
        *.7z)             7z x "$1" ;;
        *.Z)              uncompress "$1" ;;
        *) echo "Unknown archive: $1" ;;
    esac
}

# ── Prompt ───────────────────────────────────────────────────────────────────
export PS1="\[\e[0m\]\[\e[38;5;35m\]╭─(\[\e[38;5;38m\]\t\[\e[38;5;35m\])-(\[\e[38;5;38m\]\j\[\e[38;5;35m\])-(\[\e[38;5;38m\]\H\[\e[38;5;35m\])-(\[\e[38;5;38m\]\w\[\e[38;5;35m\])\n\[\e[38;5;35m\]╰──🚀 \[\e[0m\]"