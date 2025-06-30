if [ -d /usr/share/zinit   ]; then
	source /usr/share/zinit/zinit.zsh
else
   return 1
fi

zi ice wait lucid


zi ice from"gh-r" as"program"
zi light junegunn/fzf

zi ice depth"1" # git clone depth
zi light romkatv/powerlevel10k

zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

