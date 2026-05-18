# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Akatsuki aliases and functions
# (don't mess with these directly, just overwrite them here!)
export PATH="$HOME/.config/akatsuki/bin:$PATH"
source ~/.local/share/akatsuki/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

. "$HOME/.local/share/../bin/env"

# opencode
export PATH=/home/obito/.opencode/bin:$PATH

#pokemon colorscripts
#pokemon-colorscripts --no-title --small -r 1,3,6
if [ "$LINES" -gt 28 ]; then
    pokemon-colorscripts --no-title -n "$(shuf -n 1 -e \
    eevee vulpix growlithe cyndaquil umbreon \
    mudkip torchic treecko spheal pikachu cubone \
    teddiursa shinx numel)"
fi

#alias shortcuts
alias ff='fastfetch' #fastfetch
alias c='clear' #clear the terminal
alias l='eza -lh --icons=auto' #long list
alias ls='eza -1 --icons=auto' #short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' #long list all
alias ls='eza -lhD --icons=auto' #long list dirs
alias lt='eza --icons=auto --tree' #list folder as tree
alias up='sudo pacman -Syu' #update system
alias vc='code' #visual studio code
alias v='nvim' #neovim
alias man='batman' #batman
alias lsbc='lsblk | bat -l conf -p'


#directory navigation shorts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'



#completion
source /usr/share/bash-completion/bash_completion

# windows:
alias win='~/.config/windows/launch-windows.sh'