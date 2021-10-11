<#
Reads in data file, and then alters IP config based on line entries in the data file. 
Dump into c:\admin\powershell\change-dhcp\ folder for scheduled task to work.
CMT  1/9/2020
#>

$curdate = get-date
$chgday = "22"
$chgmonth = "2"
$chgyear = "2020"
$compnames = import-csv -path "c:\windows\ip-data.csv"
$fqdn = $($env:computername) + "." + ((Get-WmiObject Win32_ComputerSystem).Domain)
$logfile = "c:\windows\IP-config.log"
$logfileNA = "c:\windows\IP-config-nochange.txt"
$alreadyran = test-path $logfile

if($curdate.day -eq $chgday -and $curdate.Month -eq $chgmonth -and $curdate.year -eq $chgyear -and $alreadyran -eq $false){
    foreach($compname in $compnames){
        #check host name to determine what IP to use
        if($fqdn -eq $compname.name){        
            #Get adapter name 
            $NICs = Get-WMIObject Win32_NetworkAdapterConfiguration `
            | Where-Object {$_.IPEnabled -eq "True" -and $_.DHCPEnabled -like "False"}

            #Is host to use DHCP or Static
            #write-host "IPaddy is of type $($compname.type)"
            if ($compname.type -eq "dhcp"){
                #Set Adapter to use DCHP
                Foreach($NIC in $NICs) {
                    $NIC.EnableDHCP()
                }
            }
            else{
                #Set static IP Address
                Foreach($NIC in $NICs) {
                    $NIC.EnableStatic($compname.address,$compname.subnet)
                    $NIC.Setgateways($compname.gateway)
                }
            }    
            #change DNS servers 
            $DNSservers = @($compname.dnsone,$compname.dnstwo)
            #write-host "DNS Hosts = $DNSservers"
            Foreach($NIC in $NICs) {
                $NIC.SetDNSServerSearchOrder($DNSservers)   
            }  
            #update DNS
            ipconfig /registerdns
            Write-Output "Script Executed on $curdate" | out-file -force -FilePath $logfile
        }
    }
}
else{Write-Output "Script Executed on $curdate, but did not change anything." | out-file -force -FilePath $logfileNA}