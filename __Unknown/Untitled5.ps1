function gand {
#$url = "kwws://199.23.253.140/ndb`o0/_Q\xc8gN\x07\x87\xd6\xc0U"
$url = "ndb`oO"
[array]$urlArray = $urlArray = $url.ToCharArray()
$s = "199.23.253.140"

[string]$string = ""
for($x=1;$x -lt 100;$x++){
for($i=0;$i -lt $urlArray.Count; $i++){
    $ch = [int][char]$urlArray[$i]
    $cc = [math]::abs($ch - $x)
    $chh = [char]$cc
    $string += $chh
    }
    write $string
    [string]$string = ""
}
}


function IP-split {
$s = "199.23.253.140"
$s.Split(".")
for($i=0;$i -lt 4;$i++){
    $s = [int]$s[$i] - 7
    write $s
    }
}

function hanoi ([int]$n,[char]$A,[char]$B,[char]$C){
    $Global:c++
    if ($n -eq 1) {
        write "Move disc $n from $A to $B"
        }
    else {
        hanoi($n-1,) $A $C $B
        hanoi 1 $A $B $C
        hanoi ($n -1) $C $B $A
        }
}
$numb = [int](Read-Host "How many disks: ")
$Global:c = 0
hanoi $numb 'A' 'C' 'B'
write "Iterions: $global:c"


90 90 90 90 eb 02 cd 21
