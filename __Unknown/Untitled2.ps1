Begin {
    $web = New-Object System.Net.WebClient
    $flag = $false
    }
Process {
    While ($flag -eq $false) {
        Try {
            $web.DownloadString("http://google.com")
            $flag = $True
            }
        Catch {
            Write-Host -ForegroundColor Red -NoNewline "Access is down..."
            }
        }
    }
End {
    Write-Host -ForegroundColor Green "Access is back"
    }