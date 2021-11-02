<#This script checks to see if the VMs are running in the XenServer Envrionment, and if not it reboots them
Chad Thomsen - 12/5/2017#>

import-module XenServerPSModule

$VMnames = @("vm1","vm2","vm2")
$xenhost = @("xenhost1","xenhost2","xenhost3")
$logfilepath = "c:\admin\XenServer_reboot_log.txt"
$reboots = @()
$VMalive = $null
$username = "root"
$CredsFile = "C:\admin\cred.txt"
$address = "engineering@domain.com"
$smtpserver = "mailserver.domain.com"
$from = "servername@domain.com"

#Get encrypted credentials
#Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $CredsFile
$password = get-content $CredsFile | convertto-securestring
$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password

foreach ($VMname in $VMnames) {
    $date = get-date -Format "MM/dd/yyyy HH:mm"
    #Test if the VM is really down with ping, if down value will be $null
    $vmalive = Test-Connection $VMname -Count 3
    if ($vmalive -eq $null) {
        Write-Output "$date - $VMname ping test failed as it is offline." | Out-file -append -FilePath $logfilepath
        $reboots += $VMname
        #Find which host is pool master and authenticate to it
        $count = 0
        $activexensession = Get-XenSession
        if ($activexensession -eq $null) {  
            do {
                Connect-XenServer -Server $xenhost[$count] -Creds $Cred -SetDefaultSession -NoWarnCertificates
                $poolmaster = Get-XenSession
                start-sleep -seconds 5
                if ($poolmaster -eq $null) {
                    $count = $count + 1
                }    
            }until($poolmaster -ne $null)
        }   
               
        #Get VMobject as action commands won't work off of a string variable, but need an object variable
        $VMobject = Get-XenVM | Where-Object {$_.name_label -like $VMname}

        #shutdwown and restart VM..
        invoke-xenvm -VM $VMobject -xenaction shutdown 
        Start-Sleep -seconds 30
        invoke-xenvm -VM $VMobject -xenaction start 
        write-host "$date - $VMname was rebooted." | Out-file -append -FilePath $logfilepath       
    }  
    else {
        Write-Output "$date - $VMname ping test was successful so its online." | Out-file -append -FilePath $logfilepath
    } 
    $vmalive = $null
}
Get-XenSession | Disconnect-XenServer

#Test and notify end user of reboot if there is a reboot
if ($reboots.count -ne 0) {
    #Wait to allow VM to come back online before testing
    Start-Sleep -seconds 600  
    foreach ($reboot in $reboots) {  
        $date = get-date -Format "MM/dd/yyyy HH:mm"
        $vmalive = Test-Connection $reboot -Count 3
        
        if ($vmalive -ne $null) {
            $successbody = "Script has successfully restarted $reboot in XenServer System as it was down on $date."
            Send-MailMessage -To $address -Subject "XenServer - $reboot Server has been restarted." `
                -From $from -Body $successbody -SmtpServer $smtpserver 
            Write-Output "$date - $reboot was successfully restarted as it was down." | Out-file -append -FilePath $logfilepath   
        }
        else {
            $failbody = "Script attempted to restart $reboot in XenServer on $date, but failed.  Please restart it manually."
            Send-MailMessage -To $address -Subject "XenServer - $reboot Server failed to be restarted." `
                -From $from -Body  $failbody -SmtpServer $smtpserver   
            Write-Output "$date - The attempted restart of $reboot failed." | Out-file -append -FilePath $logfilepath  
        }
    }
}
