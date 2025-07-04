if status is-interactive
    # Commands to run in interactive sessions can go here
end


alias neofetch "/usr/bin/fastfetch"
alias vi "/usr/bin/nvim"
alias emacs "/usr/bin/emacs -nw"

if test -f /usr/bin/lsd
    alias ls "/usr/bin/lsd -l --group-directories-first -h "
else
	alias ls "/usr/bin/ls -l --group-directories-first --color=auto -h "
end

if test -f /usr/bin/bat
    alias cat "/usr/bin/bat --style header --style snip --style changes --style header"
end

if test -f /usr/bin/rg
    alias grep "/usr/bin/rg"
end


# Path Manipulation

if test -d $HOME/.local/bin
	fish_add_path $HOME/.local/bin
end

if test -d $HOME/.cargo/bin
	fish_add_path $HOME/.cargo/bin
end

if test -d $HOME/.rye
	fish_add_path $HOME/.rye/shims
end

if test -d $HOME/.encore
	fish_add_path $HOME/.encore/bin
end

