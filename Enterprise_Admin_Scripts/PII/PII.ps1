# PII Script

#gci -rec | ?{findstr.exe /mrc:. $_.FullName} | select-string "([^0-9-]|^)([0-9]{3}-[0-9]{2}-[0-9]{4})([^0-9-]|$)|([^0-9-]|^)([0-9]{9})([^0-9-]|$)|([^0-9-]|^)(XXX-XX-([0-9]{4}))([^0-9-]|$)"

# -----------------------------------------------------------------------------
# CountGuestBloggerArticlesAndWords.ps1
# ed wilson, msft, 7/30/2012
#
# based upon ITalicWordsInWord.ps1 HSG-12-28-09
#
# Keywords: Office, Microsoft Word
# HSG-8-1-12
#
# -----------------------------------------------------------------------------
[cmdletBinding()]
Param($Path = "C:\Scripts\PowerShell\PII\PII_Test") #end param

$matchCase = $false
$matchWholeWord = $true
$matchWildCards = $false
$matchSoundsLike = $false
$matchAllWordForms = $false
$forward = $true
$wrap = 1

$application = New-Object -comobject word.application
$application.visible = $False
$docs = Get-childitem -path $Path -Recurse
$findText = ""

$i = 1
$totalwords = 0
$totaldocs = 0
Foreach ($doc in $docs){
    Write-Progress -Activity "Processing files" -status "Processing $($doc.FullName)" -PercentComplete ($i /$docs.Count * 100)
    $document = $application.documents.open($doc.FullName)
    $range = $document.content
    $null = $range.movestart()
    $wordFound = $range.find.execute($findText,$matchCase,$matchWholeWord,$matchWildCards,$matchSoundsLike,$matchAllWordForms,$forward,$wrap)
    if($wordFound){
            $doc.fullname
            $document.Words.count
            $totaldocs ++
            $totalwords += $document.Words.count
        } #end if $wordFound
    $document.close()
    $i++
} #end foreach $doc
$application.quit()
"There are $totaldocs total potential offending documents" #and $($totalwords.tostring('N')) violations"
#clean up stuff
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($range) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($document) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($application) | Out-Null
Remove-Variable -Name application
[gc]::collect()
[gc]::WaitForPendingFinalizers()

# Test
