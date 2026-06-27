if command -q lsd
    alias ls="lsd -l --group-directories-first -h"
else
    alias ls="ls -l --group-directories-first --color=auto -h"
end

if command -q bat
    alias cat="bat --style header --style snip --style changes"
end

if command -q nvim
    alias vi="nvim"
    alias vim="nvim"
else if command -q vim
    alias vi="vim"
    alias vim="vim"
end

if command -q rg
    alias grep="rg --color=auto"
else if command -q grep
    alias grep="grep -E --color=auto"
end
