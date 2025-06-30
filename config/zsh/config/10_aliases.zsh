check_command() {
	if ! command -v "$1" &> /dev/null; then
		return 1
	fi
	return 0
}



if $(check_command lsd); then
	alias ls="lsd -l --group-directories-first -h"
else
	alias ls="ls -l --group-directories-first --color=auto -h"
fi

if $(check_command bat); then
	alias cat="bat --style header --style snip --style changes"
fi


if $(check_command nvim); then
	alias vi="nvim"
	alias vim="nvim"
else
	if $(check_command vim); then
		alias vi="vim"
		alias vim="vim"
	fi
fi


if $(check_command rg); then
	alias grep="rg --color=auto"
else
	if $(check_command egrep); then
		alias grep="grep -E --color=auto"
	fi
fi

unset -f check_command