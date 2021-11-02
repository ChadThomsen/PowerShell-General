<#
Gets open file counts and, and network connection counts and logs it to a file.  CMT 10/27/2017
#>

$openfiles = get-smbopenfile | Select-Object -ExpandProperty path
$filecount = $openfiles.length
$date = Get-Date
$connections = Get-WmiObject win32_serverconnection
$connectioncount = $connections.length
$logfile = "C:\admin\powershell\Get_Open_File_count\File_count.log"

Write-Output "$date - There are $filecount files open and $connectioncount active connections." `
    | Out-File -FilePath $logfile -Append