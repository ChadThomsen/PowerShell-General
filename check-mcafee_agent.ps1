<#
.SYNOPSIS
	Checks for McAfee agent, and gets date it was installed.   
.NOTES
	 Created on:   	06/12/2020
	 Created by:   	Chad Thomsen
	 Filename:     	check-mcafee_agent.ps1
.EXAMPLE
    xxxx
.PARAMETER PARAM1
 	xxxx
.PARAMETER PARAM2
	xxxx
.PARAMETER PARAM3
	xxxx
.PARAMETER PARAM4
	xxxx
#>

[CmdletBinding()]
[OutputType()]  

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

$computers = get-adcomputer -filter  'operatingsystem -like "*server*" -and enabled -eq $true'
$logfilepath = "C:\admin\powershell\detect_mcafee_agent_"+(get-date).hour+"-"+(get-date).minute+"_"+(get-date).month +"-"+ (get-date).day+"-"+(get-date).year+".txt"

foreach($computer in $computers){
    $exists = Test-Connection $computer.name -Count 2
    if($exists -ne $null){
        $installdate = Get-ChildItem -Directory -Path "\\$($computer.name)\C$\Program Files\McAfee" | ? {$_.name -eq "Agent"}
        if($installdate -eq $null){
            Write-Output "ERROR - $($computer.name) does not have the McAfee Agent update installed."
            Write-Output "ERROR - $($computer.name) does not have the McAfee Agent update installed." | out-file -append -FilePath $logfilepath
        }
        else {
            write-output "$($computer.name) got the Mcafee Agent installed on $($installdate.creationtime)"
            write-output "$($computer.name) got the Mcafee Agent installed on $($installdate.creationtime)" | out-file -append -FilePath $logfilepath
        }
    }
    else{
        Write-Output "ERROR - $($computer.name) could not be reached."
        Write-Output "ERROR - $($computer.name) could not be reached." Write-Output "ERROR - $($computer.name) could not be reached."
    }
}
