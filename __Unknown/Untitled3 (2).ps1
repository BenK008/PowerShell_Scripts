<#
Written by SrA Koloff

Also, this script does not use PS Remoting
Also, the output really sucks.
Also, I would like to make objects.
Also, I did not make objects, because I spent 12 minutes writing this.
Also, I don't care.
#>

$d = @('555.555.5.5','555.555.55.5')
$cs = gc .\list.txt

ForEach ($c in $cs) {
    If (Test-Connection -Computername $c -Count 1 -Quiet) {
        $b = gwmi Win32_NetworkAdapterConfiguration -ComputerName $c -Filter 'IPEnabled=True'
        $DNS = $b.DNSServerSearchOrder
        Write-Output "The current DNS servers on $c are $DNS"
        $b.SetDNSServerSearchOrder($d) | Out-null
        Write-Output "The new DNS servers on $c are $DNS"
        Write-Output "$c,$DNS" | Out-File -FilePath .\stdout.csv -Force -Append
        }
    Else {
        Write-Output "$c,Offline" | Out-File -FilePath .\stdout.csv -Force -Append
         }
}
        

        
