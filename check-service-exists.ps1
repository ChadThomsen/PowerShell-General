<#
Checks is service exists.  
CMT 29-JULY-2021
#>

$computernames = Get-Content -path "c:\admin\powershell\check-service-exists\data.txt"
$servicename = "SnowInventoryAgent5"

foreach ($computername in $computernames){
    $service = $null
    try {
        $service = Get-WmiObject -ComputerName $computername -Class Win32_Service `
        -Filter "name='$servicename'"
        if($service -ne $null){
            write-host "Current service state on $computername is $($service.state)."
            $service.StartService() | Out-Null
            }
        }
    catch {
        write-host "Could not connect to $computername, or service does not exist."
    }
}