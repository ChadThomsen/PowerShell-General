<#
This script will unmanage SolarWinds Orion Node(s) from the time the 
script is excuted to the time, in minutes, you choose as "delay" past 
the execution time.  Node names to unmanage must be put in a text file
used in the path parameter, and must match what is in SolarWinds 
Orion.  If there is a name mismatch the script will fail.  Orion uses UTC 
time for unmange.  This needs to be run on the Orion Server as it uses 
local certificates for authentication. Note that unmanage/mange actions 
performed in this scipt do not write to the SolarWinds logs.  This also
requires the swispowershell module.  
Date formate needed = '2021-05-19 01:45:00 PM'
Modified 21-MAY-2021 CMT
#>

[CmdletBinding()]
param(
    #Path to data file that contains hostnames.
    [Parameter(Mandatory)]
    [string]$path,
    
    #Delay in Minutes to turn monitor back on.
    [Parameter(Mandatory)]
    [int]$delay
)
$logpath = "c:\admin\powershell\SW_Unmange_Log.txt"

#Load Module
if (!(Get-Module -Name "SwisPowershell" -ErrorAction SilentlyContinue))  
    {Import-Module SwisPowershell -ErrorAction SilentlyContinue} 

#Start time = now
$start = [datetime]::Now.ToUniversalTime().ToString("yyyy-MM-dd hh:mm:ss tt")
$startlog = [datetime]::Now.ToString("yyyy-MM-dd hh:mm:ss tt")

#End time = now plus what ever the delay parameter equals. 
$end = [datetime]::Now.ToUniversalTime().addminutes($delay).ToString("yyyy-MM-dd hh:mm:ss tt")
$endlog = [datetime]::Now.addminutes($delay).ToString("yyyy-MM-dd hh:mm:ss tt")

#get list of hosts to unmanage.
$machines = get-content -path $path

#Create Connection (Host not declared so default to local host)
$swconnect = connect-swis -certificate

foreach ($machine in $machines) {
    #Connect and get node id and node name
    $uris = Get-SwisData $swconnect "SELECT Uri FROM Orion.Nodes WHERE Caption IN ('$machine')"

    #Disable monitor from start date to end date
    $uris | Set-SwisObject $swconnect -Properties @{UnmanageFrom=$start;UnmanageUntil=$end}

    #Log unmange action
    write-output "$startlog -- $endlog - $machine is set to unmanaged." | out-file $logpath -Append
}