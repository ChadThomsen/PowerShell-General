<# 
Get list IP data of all enabled AD computers.  If WMI connection fails, list message that it failed.
CMT 4-15-2020
#>

#$computers = get-adcomputer -filter "enabled -eq 'true'" | select -ExpandProperty name
$computers = get-adcomputer -filter 'enabled -eq $true' -properties * | ? {$_.Distinguishedname -like "*DCCAR2*"} | select -ExpandProperty name

foreach($computer in $computers){
    #write-host "Connecting to host $computer"
    try{
        (Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName $computer -ErrorAction stop | where {$_.ipenabled -eq $true} | `
            Select pscomputername, DNSServerSearchOrder | sort DNSServerSearchOrder | ft -hidetableheaders -autosize | out-string).trim()
            #Select pscomputername,IPAddress,DefaultIPGateway,DNSServerSearchOrder 
    }
    catch{Write-Output "$computer could not be reached."}
}   