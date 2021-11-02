<#
Restarts a service on multiple remote machines, pauses 10 seconds and then gives feeback on
service status. CMT 7/13/2018
#>

$computernames = Get-Content -path "c:\admin\powershell\start-services-multiple-machines\computers.txt"
$servicename = "splunkforwarder"
write-host "***Restarting $servicename on all computers.***"
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
        write-host "Could not connect to $computername."
    }
}

write-host " "
write-host "***Checking $servicename as service restarts are complete.***"
Start-Sleep -seconds 30

foreach ($computername in $computernames){
    $service = $null
    Try{
    $service = Get-WmiObject -ComputerName $computername -Class Win32_Service `
        -Filter "name='$servicename'"
    }
    Catch {}
    if($service -ne $null){
        write-host "Current service state on $computername is $($service.state)."
    }
}