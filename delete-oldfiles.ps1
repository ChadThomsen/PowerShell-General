<#
This deletes files that are older then a specific dates. 
02-NOV-2021
#>

$logfile = "C:\admin\powershell\delete-file_log.txt"
$retention1 = 14
$retention2 = 7
$directories = @(`
    "\\server1\folder1",`
    "\\server2\folder2",`
    "\\server3\folder3",`
    "\\server4\folder4"
)

foreach($directory in $directories){
    $files = get-childitem -file -path $directory
    foreach($file in $files){
        if ($file.LastWriteTime -lt ((get-date).adddays(-$retention1)) -and $directory -notlike "*sp_filecabinet*"){
            remove-item ($directory + "\" + $file.name) -Force    
            Write-Output "$(get-date) - Older then $retention1 days - deleted $directory\$file" | out-file $logfile -append
        }
        elseif ($file.LastWriteTime -lt ((get-date).adddays(-$retention2)) -and $directory -like "*sp_filecabinet*"){
            remove-item ($directory + "\" + $file.name) -Force   
            Write-Output "$(get-date) - Older then $retention2 days - deleted $directory\$file" | out-file $logfile -append
         }
     }
}