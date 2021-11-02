<# Sets IP address parameters of remote machines based on external data file. 
Note that you will have to change the variables for $logfile and $datafile.
This script also encrypts the your credentials on your hard drive with a filename of
usernam.domain-PowershellCreds.txt.  If your password should change, you will have to delete
this file so it can be recreated.  Note that the data file must be in a .csv format 
with no spaces in the following order:  hostname,ipaddress,mask, gateway,primarydns,secondarydns
Chad Thomsen 12/03/2014
#>

#Variables that need to be changed by the operator
$logfile = "C:\powershell\ip_change_log.txt"
$datafile = "C:\powershell\ip_data.csv"

#Program variables
$AdminName = Read-Host "Enter your Admin AD username"
$domain = Read-Host "Enter in the domain you are logging into"
$CredsFile = "C:\$AdminName.$domain-PowershellCreds.txt"
$FileExists = Test-Path $CredsFile

#Get user credentials, or use existing encrypted credentials file
if ($FileExists -eq $false) {
	Write-Host 'Credential file not found. Enter your password:' -ForegroundColor Red
	Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $CredsFile
	$password = get-content $CredsFile | convertto-securestring
	$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $domain\$AdminName,$password}
	else
	{		Write-Host 'Using your stored credential file' -ForegroundColor Green
		$password = get-content $CredsFile | convertto-securestring
		$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $domain\$AdminName,$password}
		sleep 2

		#Import data
		$hostdata = Import-Csv $datafile -Header hostname,ipaddress,mask,gateway,primarydns,secondarydns

		foreach($line in $hostdata){
			$hostname = $line.hostname
			add-content -path $logfile -value "Hostname = $hostname"

			Try{
				#Setup remote session
				$RemoteSesssion = New-PSSession -ComputerName $line.hostname -Credential $Cred 
				If($RemoteSesssion){
					Write-Host "Connection to $hostname established"
				}
				else{
					Write-Host "Connection to $hostname failed"
				}

				#Get interface name - we need NetConnectID as netsh uses that name INVOKE ON REMOTE MACHINE
				$interface = invoke-command -session $RemoteSesssion -scriptblock {Get-WmiObject win32_NetworkAdapter `
					-filter "netconnectionstatus = 2" | select -ExpandProperty NetConnectionID} 
				add-content -path $logfile -value "Network Adapter name = $interface"
				Write-Host "Network Adapter name = $interface"

				#Change DNS settings 
				invoke-command -session $RemoteSesssion -scriptblock {netsh interface ip set dns `
					($args[0]) static ($args[1]) validate=no} -Argumentlist @($interface, $line.primarydns) >> c:\admin\log.txt
				invoke-command -session $RemoteSesssion -scriptblock {netsh interface ip add dnsserver($args[0]) `
					($args[1]) index=2 validate=no} -Argumentlist @($interface, $line.secondarydns) >> c:\admin\log.txt
				add-content -path $logfile -value "$hostname DNS Changed"
				Write-Host $hostname "DNS Changed" 

				#Change interface IP - have to do with elevated privlidges Used "asjob" to speed up command, as command 
				#hangs a long time with out that optio
				invoke-command -asjob -session $RemoteSesssion -scriptblock {netsh interface ip set address `
					($args[0]) static ($args[1]) ($args[2]) ($args[3]) 1} -Argumentlist `
					@($interface, $line.ipaddress, $line.mask, $line.gateway) >> c:\admin\log.txt
				add-content -path $logfile -value "$hostname IP Address, subnet mask, and gateway changed." 
				Write-Host $hostname "IP Address, subnet mask, and gateway changed."

				#Close session to remote server
				Get-PSSession | Remove-PSSession
			}
			Catch{ 

				add-content -path $logfile -value "------- Connection failed to host $hostname -------"
				Write-host "------- Connection failed to host $hostname -------" 
			} 
			add-content -path $logfile -value "*************************************************"
			Write-Host "*************************************************"
		}