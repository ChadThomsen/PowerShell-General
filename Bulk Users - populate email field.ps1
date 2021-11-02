<#
This script reads users account data from a .csv file and creates the users, 
and sets the password.   
Chad Thomsen 1/28/2015
#>

#$password = "XXXXX"
#$OU = "OU=Production Users,OU=Users,DC=Domain,.DC=COM"
$datafile = "\\servername\directoryname\Email Addresses.csv"

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
 Set-ADUser $User.account -Emailaddress $User.email
write-host $User.account
Write-Host $User.email

  <#$Displayname = $User.Firstname + " " + $User.Lastname            
    $UserFirstname = $User.Firstname            
    $UserLastname = $User.Lastname            
    #$OU = "$User.OU"            
    $SAM = $User.SAM            
    $UPN = $SAM + "@" + $User.Maildomain            
    $Description = $User.Description            
    #$Password = $User.Password            
    New-ADUser -Name "$Displayname" -DisplayName "$Displayname" -SamAccountName $SAM `
      -UserPrincipalName $UPN -GivenName "$UserFirstname" -Surname "$UserLastname" `
      -Description "$Description" -AccountPassword (ConvertTo-SecureString $Password `
      -AsPlainText -Force) -Enabled $true -Path "$OU" -ChangePasswordAtLogon $true `
      -PasswordNeverExpires $false
	Write-Host "$SAM account for $Displayname has been created.#>
	
}
