<#
Changes DNS server settings on machine... must be run as local admin with elevated privs.
CMT 4-14-2020
#>

# push out via GPO, and do it as a scheduled task.  Change DNS servers to what ever you need. 
$NICs = Get-WMIObject Win32_NetworkAdapterConfiguration | where {$_.IPEnabled -eq "True" -and $_.servicename -notlike "*loop*"}
#$DNSservers = @("10.3.68.141","10.2.77.8")
$DNSservers = @("10.2.72.14","10.2.72.12")
$NICs.SetDNSServerSearchOrder($DNSservers)