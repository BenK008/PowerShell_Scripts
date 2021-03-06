# Multithreaded Port Scanner
#
# Version 1.0
# 7/8/2011
#
# Jeff Graves
# http://www.orcsweb.com/blog/jeff

param(
    $inputFile = ".\firewall_rules.csv", #full path to input data
    $outputFile = ".\results.csv", #full path to output data
    $maxThreads = 64, #maximum number of threads
    $timeout = 5000 #socket timeout in ms
)

$servicesObj = ".\bin\services.xml"
$commonServices = Import-CliXML $servicesObj

function parseService($serviceString)
{
    #Build an object to store the results
    $portList = New-Object PSObject | select tcpPorts, udpPorts
    $portList.tcpPorts = @()
    $portList.udpPorts = @()
    
    #A list of services is delimited by a comma (,)
    $services = $serviceString.split(",")
    
    #Loop through each service in the string
    foreach($service in $services)
    {
        #Get rid of whitespace
        $serviceTmp = $service.trim()
        
        #Is this a well-known service?
        if($serviceTmp -match "/")
        {
            #If not, split the protocol/port pair
            $servicePiece = $serviceTmp.split("/")
            
            #Object to store the port(s)
            $ports = @()
            
            #Check for a port range
            if($servicePiece[1] -match "-")
            {
                #Add each port to the temporary object
                $servicePortsTmp = $servicePiece[1].split("-")
                for ($i= [int] $servicePortsTmp[0]; $i -le [int] $servicePortsTmp[1]; $i++)
                {
                    $ports += $i
                }
            }
            else
            {
                #Just a single port, add it
                $ports += $servicePiece[1]
            }
            
            #Add the port to the proper protocol list
            if($servicePiece[0] -match "tcp")
            {
                $portList.tcpPorts += $ports
            }
            elseif($servicePiece[0] -match "udp")
            {
                $portList.udpPorts += $ports
            }
        }
        else
        {
            #Lookup the well-known port from the commonServices object
            $lookupService = $commonServices | ?{$_.name -contains $serviceTmp}
            
            #Add the port(s) from the well-known service
            $portList.tcpPorts += $lookupService.tcpPorts
            $portList.udpPorts += $lookupService.udpPorts
        }
    }
    
    return $portList
}

Function Get-IPRange {
    param([string]$ipaddress="",[switch]$AsString,[switch]$AsDecimal,[switch]$AsIPAddress)
    
    begin {
 
        # support functions
        function ToDecimal {
            # Convert a string IP ("192.168.1.1") to it's Decimal Equivalent
            # Convert a Binary IP ("11011011111101011101110001111111") to it's Decimal Equivalent
            param([string]$paddress)
 
            if ($paddress.length -gt 15) {
                # Possibly Binary as it's too long for Dot-Decimal
                return [system.Convert]::ToInt64($paddress.replace(".",""),2)
             } else {
                # Possibly Dot-Decimal. 
                # Converting an IP address to decimal involves shifting bits
                # for each octect. Powershell doesn't have any bit shifting operators
                # so we'll use some math (YUCK!)
                [byte[]]$b = ([system.Net.IPAddress]::Parse($paddress)).GetAddressBytes()
                $longip = 0
                for ($i = 0; $i -lt 4; $i++) {
                   $num = $b[$i]
                   $longip += (($num % 256) * ([math]::pow(256,3-$i)))
                }
                return [int64]$longip
            }
        }
    
        function ToIP {
            param ($paddress)

            if ($paddress.Length -gt 15) {
                # Possibly Binary as it's too long for Decimal
                # If it's not a string, it'll also fail this test
                 return [system.Net.IPAddress]::Parse( (ToDecimal $paddress) )
            } else {
                # Most likely Decimal which the Parse method understands on its own.
                return [system.Net.IPAddress]::Parse($paddress) 
            } 
        }

        function ToBinary {
            param($paddress)
 
            if ($paddress.GetType().Name -eq "string") {
                 #Dot-Decimal
                return ([system.Convert]::ToString((ToDecimal $paddress),2)).padleft(32,[char]"0") 
            } else { 
                #Decimal
                return ([system.Convert]::ToString($paddress,2)).padleft(32,[char]"0")
            }
        }
 
        function SplitAddress {
            param([string]$paddress)
            $address = ($paddress.split("/")[0])
            $cidr = ([int]($paddress.split("/")[1]))
            if (($cidr -lt 0) -or ($cidr -gt 32)) {
                #invalid CIDR.
                throw "$_ is not a valid CIDR notation for a range of IP addresses."
            } else {
                write-Output $address
                write-Output $cidr
            }
        }
    }
 
    process {
        ################################################
        # Support both pipeline and argument input.
        if ($_) {
            # Pipeline Input
            $address,$cidr = SplitAddress $_
        } else {
            # Argument Input
            if (!$ipaddress) { Throw "You must specify an IP Range in CIDR notation (I.e. `"192.168.1.0/24`")" }
            $address,$cidr = SplitAddress $ipaddress
        } 
 
        $binaddress = ToBinary ( ToDecimal $address )
        $binmask = ("1" * $cidr).padright(32,[char]"0")

        $binnetwork = ""
        $binbroadcast = ""
 
        for ($i = 0; $i -lt 32; $i++) {
            # faking a bitwise comparison since powershell's -BAND only handles Int32.
            # Determine the Network Address (first in range) by doing a bitwise AND
            # between the address and mask specified.
            $binnetwork += [string]( $binmask.Substring($i,1) -band $binaddress.substring($i,1) )
            # Determine the Broadcast Address by flipping only the HOST bits to 1
            if ($i -lt $cidr) {
                $binbroadcast += [string]( $binaddress.Substring($i,1) )
            } else {
                $binbroadcast += [string]"1"
            }
        }

        # Convert the binary results back to Decimal
        $longnetwork =  ToDecimal $binnetwork
        $longbroadcast =  ToDecimal $binbroadcast

        #Pipe each IP object up the pipeline:
        # I'm skipping the network address and the Broadcast address
       for ($i = $longnetwork+1; $i -lt $longbroadcast; $i++) {
             if ($AsString) { 
                write-Output (ToIP $i).IPAddressToString
             } elseif ($AsDecimal) {
                 write-Output $i
            } else {
                 #AsIPAddress
                 write-Output (ToIP $i)
            }
        }
    }
}

function parseInput()
{
    #Grab CSV data
    $data = Import-CSV $inputFile
    
    #Array to store targets
    $targets = @()
    
    foreach($rule in $data)
    {
        #Entry could be cidr or an IP range. Array to store that data
        $ips = @()
        
        if($rule.Dest -match "/")
        {
            #Break CIDR into array of IP's
            if($rule.Dest -notmatch "0.0.0.0/0") { 
                $ips += ((Get-IPRange -IPAddress $rule.Dest) | select IpAddressToString) | % { $_.IPAddressToString }
            }
        }
        elseif($rule.Dest -match "-")
        {
            #Break range into array of IP's
            $ips += $($rule.Dest.split("-")[0].split(".")[3])..$($rule.Dest.split("-")[1]) | % { $rule.Dest.split("-")[0].split(".")[0] + "." + $rule.Dest.split("-")[0].split(".")[1] + "." + $rule.Dest.split("-")[0].split(".")[2] + "." + $_ }
        }
        else
        {
            #Single IP
            $ips += $rule.Dest
        }
        
        #Parse the service string
        $ports = parseService($rule.Service)
        
        foreach($ip in $ips)
        {
            #Build a target for each IP
            $target = New-Object PSObject | select ip, tcpPorts, udpPorts, action
            $target.ip = $ip
            $target.tcpPorts = $ports.tcpPorts
            $target.udpPorts = $ports.udpPorts
            $target.action = $rule.Action
            
            if($target.tcpPorts.Count -gt 0 -or $target.udpPorts.Count -gt 0)
            {
                #Only a valid target if there are ports to scan
                $targets += $target
            }
        }
    }
    
    return $targets
}



function getEndpoints($targets)
{
    #Flatten array of targets into endpoints
    $endpoints = @()
    
    foreach($target in $targets)
    {
        #Loop through each tcpPort and add as an endpoint
        foreach($tcpPort in $target.tcpPorts)
        {
            $endpoint = New-Object PSObject | select ip, port, portType, timeout
            $endpoint.ip = $target.ip
            $endpoint.port = $tcpPort
            $endpoint.portType = "TCP"
            $endpoint.timeout = $timeout
            
            $endpoints += $endpoint
        }
        
        #Loop through each udpPort and add as an endpoint
        foreach($udpPort in $target.udpPorts)
        {
            $endpoint = New-Object PSObject | select ip, port, portType, timeout
            $endpoint.ip = $target.ip
            $endpoint.port = $udpPort
            $endpoint.portType = "UDP"
            $endpoint.timeout = $timeout
            
            $endpoints += $endpoint
        }
    }
    
    return $endpoints

}

write-host "Importing Data from $inputfile"

#Parse input CSV file
$myTargets = parseInput
write-host "Imported $($myTargets.count) targets"

write-host "Flattening targets into endpoints"
#Flatten targets into endpoints
$myEndpoints = getEndpoints($myTargets)
write-host "There are $($myEndpoints.count) to scan"

$endpointResults = @()

#ScriptBlock to execute asynchronously
$ProcessTarget = {
        param($endpoint)
        
        #Code to test TCP ports
        function testTCP($endpoint)
        {
            $result = $false
            
            #Create a TCP client
            $tcpObj = New-Object System.Net.Sockets.TcpClient
            #Set receive timeout
            $tcpObj.client.ReceiveTimeout = $endpoint.timeout
            
            try {
                #Attempt connection
                $tcpObj.Connect($endpoint.ip, $endpoint.port)
                #Set result to status
                $result = $tcpObj.Connected 
            }
            
            catch {
                #Timeout or connection refused
                $result = $false
            }

            finally {
                #Cleanup
                $tcpObj.Close()
            }

            $result
        }

        function testUDP($endpoint)
        {
            $result = $false
            
            #Create a UDP client
            $udpObj = New-Object System.Net.Sockets.UdpClient
            #Set receive timeout
            $udpObj.client.ReceiveTimeout = $endpoint.timeout
            #Open the connection
            $udpObj.Connect($endpoint.ip, $endpoint.port)
            
            #Some bogus data to send over UDP
            $data = New-Object System.Text.ASCIIEncoding
            $byte = $data.GetBytes("$(Get-Date)")

            #Send the data to the endpoint
            [void] $udpObj.Send($byte,$byte.length)

            #Create a listener to listen for response
            $myEndpoint = New-Object System.Net.IPEndPoint([system.net.ipaddress]::Any,0)

            try {
                #Attempt to receive a response indicating the port was open
                $receivebytes = $udpobj.Receive([ref] $myEndpoint)
                [string] $returndata = $data.GetString($receivebytes)
                
                $result = $true
            }
            
            catch {
                #Timeout or connection refused
                $result = $false
            }

            finally {
                #Cleanup
                $udpObj.Close()
            }
            
            return $result
        }
        
        #Object to store result    
        $endpointResult = New-Object PSObject | select ip, port, portType, timeout, status
        
        #Call appropriate method based on port type
        if($endpoint.portType -eq "TCP") {
            $result = testTCP($endpoint)
        }
        elseif($endpoint.portType -eq "UDP") {
            $result = testUDP($endpoint)
        }
        
        #Build the result object to return
        $endpointResult.ip = $endpoint.ip
        $endpointResult.port = $endpoint.port
        $endpointResult.portType = $endpoint.portType
        $endpointResult.timeout = $endpoint.timeout
        if($result) { $endpointResult.status = "OPEN" } else { $endpointResult.status = "CLOSED" }
                
        return $endpointResult
}

$jobs = @()

$start = get-date
write-host "Begin Scanning at $start"

#Multithreading setup

# create a pool of maxThread runspaces   
$pool = [runspacefactory]::CreateRunspacePool(1, $maxThreads)   
$pool.Open()
  
$jobs = @()   
$ps = @()   
$wait = @()

$i = 0

#Loop through the endpoints starting a background job for each endpoint
foreach ($endpoint in $myEndpoints)
{
    while ($($pool.GetAvailableRunspaces()) -le 0) {
        Start-Sleep -milliseconds 500
    }
    
    # create a "powershell pipeline runner"   
    $ps += [powershell]::create()

    # assign our pool of 3 runspaces to use   
    $ps[$i].runspacepool = $pool

    # command to run
    [void]$ps[$i].AddScript($processTarget)
    [void]$ps[$i].AddParameter("endpoint", $endpoint)
    
    # start job
    $jobs += $ps[$i].BeginInvoke();
     
    # store wait handles for WaitForAll call   
    $wait += $jobs[$i].AsyncWaitHandle
    
    $i++
}

write-host "Waiting for scanning threads to finish..."

$waitTimeout = get-date

while ($($jobs | ? {$_.IsCompleted -eq $false}).count -gt 0 -or $($($(get-date) - $waitTimeout).totalSeconds) -gt 60) {
        Start-Sleep -milliseconds 500
    } 
  
# end async call   
for ($y = 0; $y -lt $i; $y++) {     
  
    try {   
        # complete async job   
        $endpointResults += $ps[$y].EndInvoke($jobs[$y])   
  
    } catch {   
       
        # oops-ee!   
        write-warning "error: $_"  
    }
    
    finally {
        $ps[$y].Dispose()
    }    
}

$pool.Dispose()
    
#Statistics
$end = get-date
$totaltime = $end - $start

write-host "We scanned $($myEndpoints.count) endpoints in $($totaltime.totalseconds)"

write-host "Exporting data to $outputfile"
$endpointResults | Export-CSV $outputFile