function Invoke-Monitor {
    $ie = New-Object -ComObject InternetExplorer.Application
    $ie.Navigate2("C:\Users\Benjamin\Desktop\Grid.html")
    $ie.Visible = $True
    $doc = $ie.Document
    Do {
        Test-Connection -ComputerName 127.0.0.1 -count 10 | Out-Null
        $doc.Location.Reload($True)
        }
    while ($true -eq $true)
}

function New-HTML {
    [string]$width100 = "width:100%"
    write "<!DOCTYPE html>`n<html>`n<table style=""$width100"">`n`t<tr style=""font-weight:bold"">`n`t`t<td>Computer Name</td>`n`t`t<td>Net Status</td>`n`t`t<td>DeviceID</td>`n`t`t<td>Size_GB</td>`n`t`t<td>Used_Space_GB</td>`n`t`t<td>Used_Space_%</td>`n`t</tr>"
    }
New-HTML