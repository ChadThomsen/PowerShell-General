<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

#Load Powershell system modules if not already loaded
$LoadedModules = Get-Module | Select-object -ExpandProperty Name
$logfile = "c:\admin\last-login.txt"

ForEach ($LoadedModule in $LoadedModules){
	If($LoadedModule -eq "ActiveDirectory") {$Loaded = $true}
}
If($Loaded -ne $true){Import-module ActiveDirectory}

$datafile = "\\servername\folder\LastLogin-data.csv"
$computers = get-content -path $datafile

foreach ($Qcomputer in $computers){
	$lastlogon = Get-ADComputer $computer -Property lastlogondate | select-object -ExpandProperty lastlogondate
	Write-output "$computer,$lastlogon" | Out-file $logfile -append
	Write-host "$computer --- $lastlogon"  
}