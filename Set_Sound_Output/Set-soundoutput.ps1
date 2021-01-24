<#
This is used to prevent windows from changing the default audio.  Create a job in the Event log
that looks for and run under the SYSTEM account: Applications and servcies 
logs/Microsoft/Audio/Operational Event ID 65 and set task to not run multiple instances. 
AudioDeviceCmdlets module is needed for this script.

Install-Module -Name AudioDeviceCmdlets -Force -Verbose -Scope allusers
CMT 24-JAN-2020
#>

<#
If (! (Get-Module -Name "AudioDeviceCmdlets" -ListAvailable)) {
    #    The version in Powershell Gallery is currently Broken so need to do a manual download/install
     
        Install-Module -Name AudioDeviceCmdlets -Force -Verbose  
        get-module -Name "AudioDeviceCmdlets" -ListAvailable | Sort-Object Version | select -last 1 | Import-Module -Verbose
     
        #$url='https://github.com/frgnca/AudioDeviceCmdlets/releases/download/v3.0/AudioDeviceCmdlets.dll'
       # $location = ($profile | split-path)+ "\Modules\AudioDeviceCmdlets\AudioDeviceCmdlets.dll"
        #New-Item "$($profile | split-path)\Modules\AudioDeviceCmdlets" -Type directory -Force
     
        [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
        (New-Object System.Net.WebClient).DownloadFile($url, $location)
    }
#>

#Load Module
import-module AudioDeviceCmdlets

#Change index to 2 as that is the physical speaker sound card
set-audiodevice -index 2