<# 
Get list IP data of all enabled AD computers.  If WMI connection fails, list message that it failed.
CMT 4-15-2020
#>

#Build a filter here to get the computers you want to check.
$computers = get-adcomputer -filter 'enabled -eq $true' -properties * | Where-Object {$_.Distinguishedname -like "*DATA*"} | Select-Object -ExpandProperty name

foreach($computer in $computers){
    #write-host "Connecting to host $computer"
    try{
        (Get-WMIObject Win32_NetworkAdapterConfiguration -ComputerName $computer -ErrorAction stop | Where-Object {$_.ipenabled -eq $true} | `
            Select-Object pscomputername, DNSServerSearchOrder | Sort-Object DNSServerSearchOrder | Format-Table -hidetableheaders -autosize | out-string).trim()
    }
    catch{Write-Output "$computer could not be reached."}
}   