if status is-interactive
    # Starship custom prompt
    starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls
    alias ls='eza --icons --group-directories-first -1'

    # Custom colours (skip background when inside tmux to preserve transparency)
    if set -q TMUX
        cat ~/.local/state/caelestia/sequences.txt 2> /dev/null | string replace -ra '\x1b\]11;[^\x1b]*\x1b\\\\' ''
    else
        cat ~/.local/state/caelestia/sequences.txt 2> /dev/null
    end

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end
end
