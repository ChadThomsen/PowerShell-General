<#
This script reads users account data from a .csv file and creates the users, and sets the password.
Chad Thomsen 9/27/2016
#>

$Password = "XXXXXX"
$OU = "OU=Office,OU=External Users,DC=domain,DC=COM"
$datafile = "c:\admin\powershell\bulkuseradd\bulk-users.csv"

#Load Powershell system modules if not already loaded
$LoadedModules = Get-Module | Select-Object -ExpandProperty Name
ForEach ($LoadedModule in $LoadedModules){
	If($LoadedModule -eq "ActiveDirectory") {$Loaded = $true}
	}
If($Loaded -ne $true){Import-module ActiveDirectory}

#Read Data File in
$Users = Import-Csv -Delimiter "," -Path $datafile

foreach ($User in $Users)            
{            
    $Displayname = $User.Firstname + " " + $User.Lastname            
    $UserFirstname = $User.Firstname            
    $UserLastname = $User.Lastname
    $UserEmail = $User.Email
    $UserPhone = $User.Phone            
    #$OU = "$User.OU"            
    $SAM = $UserFirstname + "." + $UserLastname             
    $UPN = $SAM + "@domain.com"           
    $Description = "External Production Account"            
    #$Password = $User.Password    

Set-ADAccountPassword -Identity $SAM -NewPassword (ConvertTo-SecureString -AsPlainText "XXXXXX" -Force)
write-host "$SAM account password has been reset."
    <#        
    New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM -UserPrincipalName $UPN `
        -GivenName "$UserFirstname" -Surname "$UserLastname" -Description "$Description" -AccountPassword `
        (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OU" `
        -ChangePasswordAtLogon $true -PasswordNeverExpires $false -EmailAddress "$UserEmail" `
        -telephoneNumber "$UserPhone"
	Write-Host "$SAM account for $Displayname has been created." #>
}