set -gx EDITOR nvim

for dir in "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.bun/bin"
    if test -d "$dir"
        fish_add_path "$dir"
    end
end

if test "$TERM_PROGRAM" = "kiro"
    source (kiro --locate-shell-integration-path fish) 2>/dev/null
end
