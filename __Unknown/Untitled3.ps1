$date = (get-date).AddDays(-365)
gci \\server\folder -Recurse -Force | where {!$_.PSIsContainer -and $_.LastWriteTime -ge $date} | move -Destination \\server\folder\folder2
gci \\server\folder -Recurse -Force | where {$_.PSIsContainer -and (gci -path $_.FullName -Recurse | where {!$_.PSIsContainer}) -eq $null} | Remove-Item -Force -Recurse