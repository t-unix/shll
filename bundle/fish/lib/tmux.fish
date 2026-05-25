function tmux --description 'Inner tmux: drop outer TMUX env so nested sessions work'
  env -u TMUX command tmux $argv
end

function otmux --description 'Outer tmux: separate socket and config'
  command tmux -L outer -f ~/.tmux-outer.conf $argv
end

function np
  if test -z $argv[1]
    echo 'usage: np <command> [command...]'
    echo 'executes each given command in a new tmux pane'
    return
  end
  set i 1
  for command in $argv
    echo running $i/(count $argv): $command
    tmux split-window "fish -c '$command' ; fish -i"
    tmux select-layout even-vertical
    set i (math $i + 1)
  end
end

function npc
  if test -z $argv[2]
    echo 'usage: npc <command> [argument for exec 1] [argument for exec 2] [...]'
    echo 'executes a command for each given argument in a new tmux pane'
    return
  end
  set command $argv[1]
  set i 1
  for argument in $argv[2..-1]
    echo running $i/(math (count $argv) - 1): $command $argument
    tmux split-window "fish -c '$command $argument' ; fish -i"
    tmux select-layout even-vertical
    set i (math $i + 1)
  end
end

function npssh
  if test -z $argv[1]
    echo 'usage: npssh <host1> [host2] [...]'
    echo 'opens a ssh session for each given host in a new tmux pane'
    return
  end
  npc ssh $argv
end

function nprootssh
  if test -z $argv[2]
    echo 'usage: npssh <host1> [host2] [...]'
    echo 'opens a root ssh session for each given host in a new tmux pane'
    return
  end
  for argument in $argv
    set hosts $hosts root@$argument
  end
  npssh $hosts
end

function npmosh
  if test -z $argv[1]
    echo 'usage: npmosh <host1> [host2] [...]'
    echo 'opens a mosh session for each given host in a new tmux pane'
    return
  end
  npc mosh $argv
end

function nprootmosh
  if test -z $argv[2]
    echo 'usage: npssh <host1> [host2] [...]'
    echo 'opens a root mosh session for each given host in a new tmux pane'
    return
  end
  for argument in $argv
    set hosts $hosts root@$argument
  end
  npmosh $hosts
end
