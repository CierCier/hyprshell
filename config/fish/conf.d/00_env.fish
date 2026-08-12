set -gx EDITOR nvim

for dir in "$HOME/.local/bin" "$HOME/.cargo/bin"
    if test -d "$dir"
        fish_add_path "$dir"
    end
end

