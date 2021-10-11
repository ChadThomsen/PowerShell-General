<#
Changes DNS server settings on machine.  Must be run as local admin with elevated privs.
Push out via GPO to the C:\windows folder, and execute it as a scheduled task running as 
the "system" account.  Change DNS servers to what ever you need. 
CMT 4-14-2020
#>

$curdate = get-date
$chgday = "22"
$chgmonth = "2"
$chgyear = "2020"

if($curdate.day -eq $chgday -and $curdate.Month -eq $chgmonth -and $curdate.year -eq $chgyear){
    $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration `
        | Where-Object {$_.IPEnabled -eq "True" -and $_.servicename -notlike "*loop*"}
    $DNSservers = @("10.0.0.1","10.0.0.2")
    $NICs.SetDNSServerSearchOrder($DNSservers)
}