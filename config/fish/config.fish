if status is-interactive
    set -g fish_greeting

    if command -q lsd
        alias ls="lsd -l --group-directories-first -h"
    end

    if command -q nvidia-offload
        alias prime-run="nvidia-offload"
    end
end



for dir in "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.cache/.bun/bin" "$HOME/.bun/bin" "$HOME/go/bin"
    if test -d "$dir"
        fish_add_path "$dir"
    end
end




# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<


# Added by Antigravity CLI installer
set -gx PATH "/home/cier/.local/bin" $PATH
