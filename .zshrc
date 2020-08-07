# add to PATH
# brew python
path=('/usr/local/opt/python/libexec/bin' $path)
# doom emacs
path+=('/Users/soren/.doomemacs.d/bin')

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
  command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
  command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
  print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
  print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

# powerlevel10k promt
zinit ice depth=1; zinit light romkatv/powerlevel10k

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# bind -x '"\C-e": vim $(fzf);'
# Sensible defaults
zstyle ':prezto:*:*' color 'yes'
zinit light-mode for \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/environment/init.zsh \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/history/init.zsh \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/directory/init.zsh

# Performance optimization
setopt HIST_FCNTL_LOCK

## from bash
## TODO refactor
# editor
export ALTERNATE_EDITOR='nvim'
export EDITOR='emacsclient -n'
alias e='emacsclient -n'

export PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig

# Environment variables
export LANG='en_US.UTF-8'
export WORDCHARS='*?'
export PAGER='less'
export LESS='-g -i -M -R -S -w -z-4'

# Bash/Readline compatibility
# zsh's default kills the whole line.
bindkey '^U' backward-kill-line

# zsh-vim-mode
zinit light softmoth/zsh-vim-mode

# ZUI
zinit light zdharma/zui

# Browse enviroment with ^b
zinit light zdharma/zbrowse

# Auto-completion
# rm -f ~/.zcompdump
# unsetopt AUTO_CD
# source ~/.zinit/plugins/marlonrichert---zsh-autocomplete/zsh-autocomplete.plugin.zsh
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
bindkey '^ ' autosuggest-accept

# Enable alt-h help function.
export HELPDIR=$MANPATH
unalias run-help
autoload -Uz  run-help    run-help-git  run-help-ip   run-help-openssl \
              run-help-p4 run-help-sudo run-help-svk  run-help-svn

# Better `cd`
# Duplicates must be saved for this to work correctly.
# unsetopt PUSHD_IGNORE_DUPS
# zinit light-mode for id-as'zoxide/init' atclone'zoxide init zsh > zoxide-init.zsh' \
#   atpull'!%atclone' run-atpull src'zoxide-init.zsh' zdharma/null
# alias cd='z'

# Color `grep`
alias grep='grep --color=always'

# Syntax highlighting in `less`
# Requires `brew install bat`.



# Better `ls` and `tree`
# Requires `brew install exa`.
alias ls='exa -aF --git --color=always --color-scale -s=extension --group-directories-first'
ll() {
  ls -ghlm --time-style=long-iso $@ | $PAGER
}
alias tree='ll -T -L=2'

# Log file highlighting in `tail`
# Requires `brew install multitail`.
alias tail='multitail -Cs --follow-all'

# Safer alternative to `rm`
# Requires `brew install trash`.
alias trash='trash -F'

# Command-line syntax highlighting
# Must be AFTER after all calls to `compdef`, `zle -N` or `zle -C`.
# export ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
# zinit light-mode for zsh-users/zsh-syntax-highlighting
# ZSH_HIGHLIGHT_STYLES[path]=none
# ZSH_HIGHLIGHT_STYLES[path_prefix]=none
zinit light zdharma/fast-syntax-highlighting
FAST_HIGHLIGHT_STYLES[path-to-dir]='fg=blue'

# Colors for 'ls' and completions
# Requires `brew install coreutils`.
zinit light-mode for atclone'gdircolors -b LS_COLORS > clrs.zsh' atpull'%atclone' pick'clrs.zsh' \
  nocompile'!' atload'zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"' trapd00r/LS_COLORS

# Auto-suggest how to install missing commands.
zinit light-mode for is-snippet \
  https://github.com/Homebrew/homebrew-command-not-found/blob/master/handler.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
