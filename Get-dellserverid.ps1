<# Gets a list of AD computer objects with an oerating system like "server" and gets the Dell Servcie Tag off of them.  If not 
tag, it lists them as virtual, and if it cannot connect it says firewalled or offline.  Chad Thomsen 3/07/2018"#>

$ErrorActionPreference = "SilentlyContinue"

$servers = get-adcomputer -filter "operatingsystem -like '*Server*' -and enabled -eq 'true'" | select -ExpandProperty name
foreach ($server in $servers) {
    $serial = $null
    $serial = get-wmiobject win32_systemenclosure -ComputerName $server | select -expandproperty serialnumber 
    if ($serial -eq "None") {
        write-Output "$server, is virtual."
    }
    elseif ($serial -eq $null) {
        write-output "$server, appears to be offline or firewalled."
    }
    else {
        Write-Output "$server, has a Dell service id of $serial" 
    }
}
Write-Output "Script has completed. "