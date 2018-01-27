 <#
.Synopsis
Gets necessary information to monitor selected servers real-time
.DESCRIPTION
The Get-ServerInfo cmdlet gets necessary information needed when monitoring servers. Get-ServerInfo shows when the servers go offline, or when they are unable to be reached. Additionally, Get-ServerInfo will display pertinent information on all drives on the server.
You can direct Get-ServerInfo to particular servers by adding them after the -ComputerName parameter comma separated. Also, you can add the -LogReport switch parameter to add the latest Event Logs from Security, System and Application that are Warnings or Errors.
.EXAMPLE
Get-ServerInfo -ComputerName (gc .\list.txt)
In the above example, you can iterate through a selected list of servers that are displayed in .\list.txt
.EXAMPLE
gc .\list.txt | Get-ServerInfo
In the above example, you can iterate through a selected list of servers and pipe them to the cmdlet, because -ComputerName is positional and accepts values from the pipeline.
.EXAMPLE
(Import-CSV .\list.csv).Name | Get-ServerInfo
In the above example, you can import a .csv file and pipe the column labeled 'Name' to Get-ServerInfo
.EXAMPLE
Get-ServerInfo -ComputerName (Get-ADComputer -LDAPFilter '(objectClass=Computer)' -SearchBase "OU=Happy,OU=Noodle,DC=Area51,DC=Wookie" | Select-Object -ExpandProperty ComputerName) -LogReport
In the above example, you can grab computers from a specific OU in Active Directory, expand them to strings and pass them to Get-ServerInfo with the full Event Log report switch parameter.
.INPUTS
System.String
You can pipe a string to Get-ServerInfo
.OUTPUTS
HTML page that self-refreshes
.NOTES
Written by SrA Benjamin Koloff over a very long time, because I really don't care that much.
Special thanks to SSgt Christopher Walka for the knowlege bombs and help.
Special thanks to Google for helping me when I always needed it.
Extra special thanks to TSgt Robert Schultz and SSgt Sean McGinty for starting me on the scripting path.
Mucho especial thanks to SSgt Cochran and A1C Cooley for continuing to push me for ideas.
.COMPONENT
SrA Benjamin Koloff...I guess.
.ROLE
Know your role...always.
.FUNCTIONALITY
Monitor servers for uptime, disk space and particular event logs.
#>
function Get-ServerInfo  # Defines the main function 'Get-ServerInfo'
{
    [CmdletBinding()] # Adds the PowerShell common parameters (e.g. -ErrorAction)
    Param # Adds custom parameters to the cmdlet
    (  
        # Add computer names by comma separated values if you wish; Can take strings from the pipeline ByValue and ByPropertyName; has aliases in case you can't remember -ComputerName
        [Parameter(Mandatory=$false,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Alias("Name","Computers","Computer","Server","Servers","Systems","Sys")]
        $ComputerName,

        # View full report with selected Event Logs by just adding '-LogReport' as a parameter; is not mandatory; does not accept values from the pipeline ByValue or ByPropertyName; is a switch parameter
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$false,
                   ValueFromPipeline=$false,
                   Position=1)]
        [switch]$LogReport
    )

    Begin{ #Opens the Begin statement
        #Write-EventLog -ComputerName RemoteServer1,RemoteServer2,RemoteServer3,localhost -Source Koloff_Scripts -LogName Application -Message "Get-ServerInfo started" -EntryType Information -EventId 2  # writes custom event logs so you can tell when it was run (EPR magic)
        $ComputerName = "BENJAMIN-PC","192.168.1.1" # Remove When fully testing
        } # closes the Begin statement
    Process{ # opens the Process statement
        #Server Monitor
        If ($LogReport){ # If -LogReport is switched on, then this will run pulling the event log data for the report
            Write-Host -ForegroundColor Magenta "This may take some time to populate. Please be patient."
            write "<!DOCTYPE html>`n<html>`n<table style=""width:100%"">`n`t<tr style=""font-weight:bold"">`n`t`t<td>Computer Name</td>`n`t`t<td>Net Status</td>`n`t`t<td>DeviceID</td>`n`t`t<td>Size_GB</td>`n`t`t<td>Used_Space_GB</td>`n`t`t<td>Used_Space_%</td>`n`t`t<td>SecLogID</td>`n`t`t<td>SecLogSrc</td>`n`t`t<td>SecLogEntry</td>`n`t`t<td>SecLogTime</td>`n`t`t<td>SysLogID</td>`n`t`t<td>SysLogSrc</td>`n`t`t<td>SysLogEntry</td>`n`t`t<td>SysLogTime</td>`n`t`t<td>AppLogID</td>`n`t`t<td>AppLogSrc</td>`n`t`t<td>AppLogEntry</td>`n`t`t<td>AppLogTime</td>`n`t</tr>`n" | Out-File -FilePath C:\Users\Benjamin\Desktop\Grid.html -Force #This initiates the HTML document by writing all the beginning HTML code and saving the document to the specified path
            Function Get-ServerReport { # This defines the Get-ServerReport subroutine; I used this for ease in the End block
            ForEach ($c in $ComputerName) { # Opens the ForEach loop that iterates through the selected computers
                try{ # standard try statement
                    $p = Test-Connection -Computername $c -Count 1 -ErrorAction SilentlyContinue # Pulls WMI data to see if the computer is on
                    $t = IF ($p) {$p = $p.IPV4Address.IPAddressToString} # since the computer is on, we will get the IPv4 address of the computer
                    $D = Get-WMIObject Win32_LogicalDisk -filter 'DriveType=3' -computer $c | ` #This is one big statement that pulls WMI data for the drives and uses calculated properties to rename the properties of the object and calculate numbers that are not bytes; instead we use GBs
                         Select SystemName,DeviceID,VolumeName,`
                        @{Name=”Size_GB”;Expression={[decimal](“{0:N1}” -f($_.size/1gb))}},`
                        @{Name=”Used_Space_GB”;Expression={[decimal](“{0:N1}” -f(($_.size/1gb)-($_.freespace/1gb)))}},`
                        @{Name=”Used_Space_Percent”;Expression={“{0:P2}” -f((($_.size/1gb) – ($_.freespace/1gb)) / ($_.size/1gb))}}
                    If ($lsec = Get-EventLog -ComputerName $c -LogName Security -EntryType Error,FailureAudit,Warning -After (get-date).AddDays(-1) -ErrorAction SilentlyContinue){
                            $lsecR = $lsec[0] | select EventID, Source, EntryType, TimeWritten
                                        } #This If-Else statement pulls the first, latest Security log from the Event Logs; or, this will show that the logs are Good, Offline or that you don't have rights to the machine
                    Else{
                            $lsecR = New-Object PSObject -Property @{
                                EventID = "Good, Offline, No Creds"
                                Source = "Good, Offline, No Creds"
                                EntryType = "Good, Offline, No Creds"
                                TimeWritten = (get-date)
                                    }
                        }
                    If ($lsys = Get-EventLog -ComputerName $c -LogName System -EntryType Error,FailureAudit,Warning -After (get-date).AddDays(-1) -ErrorAction SilentlyContinue){
                            $lsysR = $lsys[0] | select EventID, Source, EntryType, TimeWritten
                                    } #This If-Else statement pulls the first, latest System log from the Event Logs; or, this will show that the logs are Good, Offline or that you don't have rights to the machine
                    Else{
                            $lsysR = New-Object PSObject -Property @{
                                EventID = "Good, Offline, No Creds"
                                Source = "Good, Offline, No Creds"
                                EntryType = "Good, Offline, No Creds"
                                TimeWritten = (get-date)
                                        }
                        }
                    If ($lapp = Get-EventLog -ComputerName $c -LogName Application -EntryType Error,FailureAudit,Warning -After (get-date).Adddays(-1) -ErrorAction SilentlyContinue){
                            $lappR = $lapp[0] | select EventID, Source, EntryType, TimeWritten
                            } #This If-Else statement pulls the first, latest Application log from the Event Logs; or, this will show that the logs are Good, Offline or that you don't have rights to the machine
                    Else{
                            $lappR = New-Object PSObject -Property @{
                                EventID = "Good or No Creds"
                                Source = "Good or No Creds"
                                EntryType = "Good or No Creds"
                                TimeWritten = (get-date)
                                        }
                        }
                    }
                catch{ #This catch statement shows that the server is offline, writes a warning to the host and writes an event log to Koloff_Scripts to selected servers that shows that will tell the server is offline
                        $p = "Offline"
                        Write-Warning "$c is Offline"
                        Write-EventLog -ComputerName RemoteServer1,RemoteServer2,RemoteServer3,localhost -Source Koloff_Scripts -LogName Application -Message "$c Request Timed Out" -EntryType Information -EventId 1
                    }
                finally{ # This finally statement makes easy-to-read variables from the object properties that will be used in the HTML output
                        $SizeGB = $D.Size_GB
                        $UsedSpaceGB = $D.Used_Space_GB
                        $UsedSpacePerc = $D.Used_Space_Percent
                        $DeviceID = $D.DeviceID
                        $SecLogID = $lsecR.EventID
                        $SecLogSrc = $lsecR.Source
                        $SecLogEntry = $lsecR.EntryType
                        $SecLogTime = $lsecR.TimeWritten
                        $SysLogID = $lsysR.EventID
                        $SysLogSrc = $lsysR.Source
                        $SysLogEntry = $lsysR.EntryType
                        $SysLogTime = $lsysR.TimeWritten
                        $AppLogID = $lappR.EventID
                        $AppLogSrc = $lappR.Source
                        $AppLogEntry = $lappR.EntryType
                        $AppLogTime = $lappR.TimeWritten
                        $lineDID = For ($i = 0; $i -lt $DeviceID.Count;$i++) {$DeviceID[$i]+"<br />"}     # Thanks to SSgt Christopher Walka, I was able to use this type of For loop that grabs each index of drives and writes the appropriate line in the HTML document
                        $lineSizeGB = For ($i = 0;$i -lt $SizeGB.Count;$i++) {[string]$SizeGB[$i]+"<br />"}   # Thanks to SSgt Christopher Walka, I was able to use this type of For loop that grabs each index of drives and writes the appropriate line in the HTML document
                        $lineUsedGB = For ($i = 0; $i -lt $UsedSpaceGB.Count;$i++) {[string]$UsedSpaceGB[$i]+"<br />"}   # Thanks to SSgt Christopher Walka, I was able to use this type of For loop that grabs each index of drives and writes the appropriate line in the HTML document
                        $lineUsedPerc = For ($i = 0; $i -lt $UsedSpacePerc.Count;$i++) {[string]$UsedSpacePerc[$i]+"<br />"}    # Thanks to SSgt Christopher Walka, I was able to use this type of For loop that grabs each index of drives and writes the appropriate line in the HTML document
                        Write "`t<tr style=""background-color:#E6E6FA"">`n`t`t<td>$c</td>`n`t`t<td>$p</td>`n`t`t<td>$lineDID</td>`n`t`t<td>$lineSizeGB</td>`n`t`t<td>$lineUsedGB</td>`n`t`t<td>$lineUsedPerc</td>`n`t`t<td>$SecLogID</td>`n`t`t<td>$SecLogSrc</td>`n`t`t<td>$SecLogEntry</td>`n`t`t<td>$SecLogTime</td>`n`t`t<td>$SysLogID</td>`n`t`t<td>$SysLogSrc</td>`n`t`t<td>$SysLogEntry</td>`n`t`t<td>$SysLogTime</td>`n`t`t<td>$AppLogID</td>`n`t`t<td>$AppLogSrc</td>`n`t`t<td>$AppLogEntry</td>`n`t`t<td>$AppLogTime</td>`n`t</tr>" | Out-File -FilePath C:\Users\Benjamin\Desktop\Grid.html -Append  #This is the final line that writes the bulk of the HTML document; this is essentially the report that you see
                        }
                }
                }
            }
        Else{  # If -LogReport is not switched on, then this will run pulling the standard data for the report
             function Get-ServerReport { # Recognize the defined sub-routine? This is for ease in the End block
             write "<!DOCTYPE html>`n<html>`n<table style=""width:100%"">`n`t<tr style=""font-weight:bold"">`n`t`t<td>Computer Name</td>`n`t`t<td>Net Status</td>`n`t`t<td>DeviceID</td>`n`t`t<td>Size_GB</td>`n`t`t<td>Used_Space_GB</td>`n`t`t<td>Used_Space_%</td>`n`t</tr>`n" | Out-File -FilePath C:\Users\Benjamin\Desktop\Grid.html -Force #This initiates the HTML document by writing all the beginning HTML code and saving the document to the specified path
             ForEach ($c in $ComputerName) {  # Opens the ForEach loop that iterates through the selected computers
                    try{  # standard try statement
                            $p = Test-Connection -ComputerName $c -Count 1 -ErrorAction SilentlyContinue  # Pulls WMI data to see if the computer is on
                            $t = IF ($p.StatusCode -eq "0") {$p = $p.IPV4Address.IPAddressToString}  # since the computer is on, we will get the IPv4 address of the computer
                            $D = Get-WMIObject Win32_LogicalDisk -filter 'DriveType=3' -computer $c | `  ##This is one big statement that pulls WMI data for the drives and uses calculated properties to rename the properties of the object and calculate numbers that are not bytes; instead we use GBs
                                 Select SystemName,DeviceID,VolumeName,`
                                @{Name=”Size_GB”;Expression={[decimal](“{0:N1}” -f($_.size/1gb))}},`
                                @{Name=”Used_Space_GB”;Expression={[decimal](“{0:N1}” -f(($_.size/1gb)-($_.freespace/1gb)))}},`
                                @{Name=”Used_Space_Percent”;Expression={“{0:P2}” -f((($_.size/1gb) – ($_.freespace/1gb)) / ($_.size/1gb))}}
                        }
                    catch{   #This catch statement shows that the server is offline, writes a warning to the host and writes an event log to Koloff_Scripts to selected servers that shows that will tell the server is offline
                            $p = "Offline"
                            Write-Warning "$c is Offline"
                            #Write-EventLog -ComputerName RemoteServer1,RemoteServer2,RemoteServer3,localhost -Source Koloff_Scripts -LogName Application -Message "$s Request Timed Out" -EntryType Information -EventId 1
                        }
                    finally{   # This finally statement makes easy-to-read variables from the object properties that will be used in the HTML output
                            $SizeGB = $D.Size_GB
                            $UsedSpaceGB = $D.Used_Space_GB
                            $UsedSpacePerc = $D.Used_Space_Percent
                            $DeviceID = $D.DeviceID
                            $lineDID = For ($i = 0; $i -lt $DeviceID.Count;$i++) {$DeviceID[$i]+"<br />"} 
                            $lineSizeGB = For ($i = 0;$i -lt $SizeGB.Count;$i++) {[string]$SizeGB[$i]+"<br />"}
                            $lineUsedGB = For ($i = 0; $i -lt $UsedSpaceGB.Count;$i++) {[string]$UsedSpaceGB[$i]+"<br />"}
                            $lineUsedPerc = For ($i = 0; $i -lt $UsedSpacePerc.Count;$i++) {[string]$UsedSpacePerc[$i]+"<br />"}
                            Write "`t<tr style=""background-color:#E6E6FA"">`n`t`t<td>$c</td>`n`t`t<td>$p</td>`n`t`t<td>$lineDID</td>`n`t`t<td>$lineSizeGB</td>`n`t`t<td>$lineUsedGB</td>`n`t`t<td>$lineUsedPerc</td>`n`t</tr>" | Out-File -FilePath C:\Users\Benjamin\Desktop\Grid.html -Append   #This is the final line that writes the bulk of the HTML document; this is essentially the report that you see
                    }
                }
                }
            }
        }
    End{ #This opens the End block that will write the final text to the HTML document, start the page and refresh when needed
           Do {  # This starts the Do-While loop that starts the HTML page
               Get-ServerReport # BOOM City; this is that subroutine that is called
               write "</table>`n</body>`n</html>" | Out-File -FilePath C:\Users\Benjamin\Desktop\Grid.html -Append  #This is final text needed for the HTML report document
               function Refresh-Monitor {  # Uh oh; not another subroutine
                     $ie = New-Object -ComObject InternetExplorer.Application # Calls the InternetExplorer COM (API for IE) to be used
                     $ie.Navigate2("C:\Users\Benjamin\Desktop\Grid.html")  # This uses the Navigate2 method with the path of the report defined
                     $ie.Visible = $True # This is property of the IE COM that is boolean; since it is set to true, it will be true, thus visible. Get it?
                     $doc = $ie.Document # Sets a variable for the document property of the $ie object
                     Do { # a nested Do-While. Hey...I couldn't get past it; this Do-While loops forever and reloads the page every 10 seconds until the document is closed (i.e. Visible equals false)
                         try {
                              for ($i=1;$i -gt 0;$i++) {
                              Test-Connection -ComputerName 127.0.0.1 -count 10 | Out-Null # This is a goofy way to pause something. I started writing in CMD (batch), so this is how guys like me pause things. I don't care what you think
                              Write-Host -ForeGroundColor Yellow "Refreshing server monitor page:  $i instance(s)"
                              $doc.Location.Reload($True)} # This calls the method that reloads the page
                              }
                         catch {
                                Return
                                If (Test-Path C:\Users\Benjamin\Desktop\Grid.html) {Remove-Item C:\Users\Benjamin\Desktop\Grid.html} # Deretes the HTML page to be recreated again
                                }
                         }
                     while ($ie.Visible -eq $true) # This is the inner While that states "Do something while this page is visible"
                    }
               Refresh-Monitor # This calls the Refresh-Monitor subroutine that...you guessed it...refreshes the HTML page
              } 
           While ($ie.Visible -eq $true) #eh...I don't know what to do here
            If (Test-Path C:\Users\Benjamin\Desktop\Grid.html) {Remove-Item C:\Users\Benjamin\Desktop\Grid.html} # Deretes the HTML page to be recreated again
        }
}

<# Easter Egg
Imagine there's no heaven
It's easy if you try
No hell below us
Above us only sky
Imagine all the people
Living for today...

Imagine there's no countries
It isn't hard to do
Nothing to kill or die for
And no religion too
Imagine all the people
Living life in peace...

You may say I'm a dreamer
But I'm not the only one
I hope someday you'll join us
And the world will be as one                         \
Imagine no possessions
I wonder if you can
No need for greed or hunger
A brotherhood of man
Imagine all the people
Sharing all the world...

You may say I'm a dreamer
But I'm not the only one
I hope someday you'll join us
And the world will live as one

End Easter Egg #>