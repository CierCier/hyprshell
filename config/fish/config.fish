if status is-interactive
    set -g fish_greeting

    if command -q lsd
        alias ls="lsd -l --group-directories-first -h"
    end

    if command -q nvidia-offload
        alias prime-run="nvidia-offload"
    end
end



for dir in "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.cache/.bun/bin" "$HOME/.bun/bin" "$HOME/go/bin" "$HOME/.local/share/silver/bin"
    if test -d "$dir"
        fish_add_path "$dir"
    end
end


if command -q direnv
	direnv hook fish | source
end

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<



# Added by Antigravity CLI installer
set -gx PATH "/home/cier/.local/bin" $PATH

# opencode
fish_add_path /home/cier/.opencode/bin

# >>> kache test runner >>>
if test -z "$CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER"; set -gx CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER 'kache test-runner'; else; set -gx CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER $CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUNNER; end
# <<< kache test runner <<<
# >>> kache compiler cache >>>
if test "$PATH[1]" != '/home/cier/.local/lib/kache/shims'
    set -gx PATH '/home/cier/.local/lib/kache/shims' $PATH
end
# <<< kache compiler cache <<<
