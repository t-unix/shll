function map
  if test (count $argv) -lt 2
    return 1
  end
  set m $argv[1]
  set k $argv[2]
  set v $argv[3]
  set ks map_(echo $m-$argv[2] | shasum | cut -f 1 -d " ")
  if test -n "$v"
    set -Ux $ks $v
    return 0
  else 
    set v (eval "echo \$$ks")
    if test -n "$v"
      echo $v
    else
      return 1
    end
  end
end
