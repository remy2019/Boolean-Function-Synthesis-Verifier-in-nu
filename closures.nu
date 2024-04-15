def to_01 [n: int, l: int] {
  mut x = $n
  mut buf = []
  while $x > 0 {
    $buf = ($buf | insert 0 ($x mod 2))
    $x = $x // 2
  }
  if $n == 0 { $buf = [0] }
  let res = $buf | str join
  let left_pad = $l - ($res | str length)
  $"((0..<$left_pad) | each {|_| "0"} | str join)($res)"

}

def create_instance [vars: int] {
  let power_2 = 2 ** $vars
  mut limit = 40 # change this number if you wish
  if ($limit > $power_2) { $limit = $power_2 }

  let assigns = (0..<$power_2) | each { |e| $e} | shuffle | take $limit | sort

  let results = (1..$limit) | each { |i|
    random int 0..1 | into string
  }
  let assignments = $assigns | each { |i|
    to_01 $i $vars
  }
  let zipped = $assignments | zip $results
  let mixed = $zipped | reduce --fold [[assignments, result];['' '']] { |it, acc|
    let entry = [[assignments, result]; [($it | get 0) ($it | get 1)]]
    $acc | append $entry
  }

  let pos = $mixed | filter { |e| $e.result == '1'}
  let neg = $mixed | filter { |e| $e.result == '0'}
  let res = [$pos $neg]
  $res
}

def create_spec [n, vars, data] {
  let first = $"let data($n) : specification = \(3, ($vars)," # change number
  let second = "["

  let pos = $data | get 0
  let third = if ($pos | is-empty) { "" } else {
    $pos | get assignments | each { |e|
      $"  [($e | split chars | str join ';')];"
    } | str join (char newline)
  }

  let fourth = "],"
  let fifth = "["

  let neg = $data | get 1
  let sixth = if ($neg | is-empty) { "" } else {
    $neg | get assignments | each { |e|
      $"  [($e | split chars | str join ';')];"
    } | str join (char newline)
  }
  let seventh = "])"

  [$first $second $third $fourth $fifth $sixth $seventh] | str join (char newline)
}

def create_main_ml [n: int] {
  let b = "open Learn"
  let c = "open Datasets"
  let d = (1..$n) | each { |i|
  $'let _ =
  match synthesize data($i) with 
  | None -> print_endline "No solution"
  | Some dnf -> let res = string_of_dnf dnf in print_endline res'
  } | str join (char newline)
  [$b $c $d] | str join (char newline)
}

def test [] {
  let cases = 10
  let var_min = 2
  let var_max = 10

  # for $i in 1..$cases {
  #   let $vars = random int $var_min..$var_max
  #   let data = create_instance $vars
  #   let res = create_spec $i $vars $data
  #   print $res
  # }

  print (create_main_ml 2)
}

test
