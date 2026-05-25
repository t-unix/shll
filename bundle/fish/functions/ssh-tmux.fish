function ssh-tmux
    ssh -t $argv[1] tmux new -A -s "remote"
end
