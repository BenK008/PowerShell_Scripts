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
