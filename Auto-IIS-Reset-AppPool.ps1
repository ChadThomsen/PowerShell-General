<# Checks the status of a web page for a string of text.  If it is not found, the site is assumed down
and is restarted the app pool.  4/14/2020 - CMT#>

Import-Module WebAdministration
$logfile = "C:\admin\AppPool-reset-log.txt"
$website = "https://web-url.com"
$validtext = "We're sorry, but an error"
$validtextlength = $validtext.length
$emailto = @("email@user.com","email2@user.com")
$emailfrom = "anemail@user.com"
$pool = (Get-Item "IIS:\Sites\Production"| Select-Object applicationPool).applicationPool
$date = get-date
$smtpserver = "SMTPMAIL.DOMAIN.COM"

#Do a screen scrape of web page and check for $valid text 
$webpage = Invoke-WebRequest $website #-Credential $creds
write-host $webpage

#get character count
$arraymax = $webpage.content.length
$testmax = $arraymax - $validtextlength
$count = 0

do {
    #check for the first character of the string $validtext"
    if ($webpage.content[$count] -ceq $validtext[0]) {
        $acount = 1
        $data = $webpage.content[$count]
        #write-host "`$data = $data"
        #Parse the next $validtextlength characters and see if they match the $validtext string
        do {
            $data = $data + $webpage.content[$count + $acount]
            #write-host "`$data = $data"
            $acount = $acount + 1
            #write-host "`$acount = $acount"
        } until ($acount -eq $validtextlength)
        [string]$string = $data
    }
    $count = $count + 1 

} until ($count -eq $testmax -or $string -eq $validtext)

#write-host "`$string = $string"

if ($string -eq $validtext) {
    write-output "$date - Performing IIS AppPool reset for Production as the page was not up." | Out-file -append -FilePath $logfile
    #Write-EventLog -LogName Application -Source "Microsoft IIS" -EventId 7776 -EntryType Information -message `
        #"Script restarted the Apache Tomcat 4.1 Service as `"The Service is Unavailable condition`" was met." -Category 1 
    Send-MailMessage -To $emailto -Subject "IIS App Pool was reset for WebApp." -From $emailfrom `
        -Body "IIS AppPool was RESET for WebApp as it was down on $date." -SmtpServer $smtpserver
    write-host "Would invoke IISRESET for WebApp AppPool here. "
    Restart-WebAppPool $pool
}   
#write-host "Script is done."