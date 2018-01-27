$reports = gci .\XCCDF;$repArray = @()
for($i=0;$i -lt $reports.Count;$i++){[xml]$tmp = gc ".\XCCDF\$($reports[$i].Name)";$repArray += $tmp}
