cat config.toml | from toml | load-env
source closures.nu

if $env.cases > 100 {
  print "Warning: high number of test cases could be harm your device"
  exit 1
}

if ("datasets.ml" | path exists) {
  rm datasets.ml
}

let data = (1..$env.cases) | each { |i|
  let vars = random int $env.var_min..$env.var_max
  let raw = create_instance $vars
  let strings = create_spec $i $vars $raw

  print $"generating data: ($i | into string)"
  print $strings
  [$raw $strings]
}
let payload = $data | each { |i|
  $i | get 1
}
let data = $data | each { |i|
  $i | get 0
}

["open Learn"] | append $payload | str join $"(char newline)(char newline)" | save datasets.ml

mkdir temp
cp datasets.ml temp/datasets.ml
cd temp
touch main.ml
$env.files | each { |f|
  let target = $env.hw2_path | path join $f
  cp $target .
}
create_main_ml $env.cases | save -f main.ml
make | ignore
dune exec ./main.exe | save -f result.txt
cat result.txt

print $"Test cases requested: ($env.cases)"
print $"Test cases received: (cat result.txt | lines | length)"

# let result = do $verify_sat $env.cases $data (cat result.txt | lines)
# let success = $result | filter { |e| $e == true} | length
# let fail = $result | filter { |e| $e == false} | length

# print $"Verified: ($success)"
# print $"Fail: ($fail)"
