GetFunction Get-Fib {
    Param([int]$max)
        For ($i = $j = 1; $i -lt $max)
        {
            $i
            $i,$j = ($i + $j),$i
            }
    }

Function Get-Prime {
    $count = 0
    2..1000 | foreach {
        $num = $_
        $div = [math]::Sqrt($num)
        $prime = $true
        2..$div | foreach {
            if ($num % $_ -eq 0) {
                $prime = $false
                }
            }
        If ($prime) {
            Write-Host -NoNewline $num.ToString().PadLeft(4)
            $count++
            If ($count % 10 -eq 0) {
                Write-Host ""
                }
            }
        }
    Write-Host "`n"
    Write-Host "$count primes between 2 and 1000" 
    }

Function Get-Number {
    [int]$i=2
    Do {$i++; Write-Host $i} 
    While ($i -gt 1)
}
