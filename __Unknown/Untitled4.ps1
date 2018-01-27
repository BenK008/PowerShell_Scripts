function ProjEuler_1 {$s = 0
for ($i=0;$i -lt 1000;$i++) {
    if (($i % 5 -eq 0) -or ($i % 3 -eq 0)) {
        $s = $s + $i
        }
}
write $s}

function ProjEuler_2 {
function fib {
$f = $s = 1;
while ($s -le 4000000) {
    $s;
    $s, $f = ($s + $f),$s}
}
$sum = fib
$main = 0
ForEach ($i in $sum) {
    if ($i % 2 -eq 0) {
        $main = $main + $i
    }
}
$main}

function ProjEuler_3 {
    $num = 600851475143
    for ($i = 2;$i * $i -le $num; $i++){
        if ($num % $i -eq 0) {
            $fact0 = $i
            $fact1 = $num / $i

            for ($k = 0; $k -le 2; $k++){
                $prime = $true
                for ($j = 2; $j * $j -le $fact
            }
        }
    }
}