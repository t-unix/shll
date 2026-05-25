function __c_hex
  if test (count $argv) -lt 1
    return 1
  end
  set v $argv[1]
  if test -z "$v"
    return 1
  end
  set r (map hex $v)
  if test -n "$r"
    echo $r
    return 1
  end
  set s (echo $v | shasum | cut -f 1 -d " ")
  set r (echo $s | string sub -s 1 -l 2)
  set g (echo $s | string sub -s 3 -l 2)
  set b (echo $s | string sub -s 5 -l 2)
  set r $r$g$b
  map hex $v $r
  echo $r
end

function __c_lightness
  if test (count $argv) -lt 1
    return 1
  end
  set v $argv[1]
  if test -z "$v"
    return 1
  end
  set r (map lightness $v)
  if test -n "$r"
    echo $r
    return 1
  end
  set s (echo $v | shasum  | cut -f 1 -d " ")
  set r (echo 'ibase=16; ' (echo $s | string sub -s 1 -l 2 | tr '[:upper:][:lower:]' '[:lower:][:upper:]') | bc)
  set g (echo 'ibase=16; ' (echo $s | string sub -s 3 -l 2 | tr '[:upper:][:lower:]' '[:lower:][:upper:]') | bc)
  set b (echo 'ibase=16; ' (echo $s | string sub -s 5 -l 2 | tr '[:upper:][:lower:]' '[:lower:][:upper:]') | bc)
  set r (printf %.$2f (echo "0.2126*$r+0.7152*$g+0.0722*$b" | bc))
  map lightness $v $r
  echo $r
end

function __c_contrast
  if test (count $argv) -lt 1
    return 1
  end
  if test (__c_lightness $argv[1]) -lt 128
    set c white
  else
    set c black
  end
  echo $c
end

function __c_bg
  echo (__c_hex $argv[1])
end

function __c_fg
  echo (__c_contrast $argv[1])
end
