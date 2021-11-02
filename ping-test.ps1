$computers = Get-Content -path "U:\Powershell\Scripts\Windows Infrastructure\2008-servers.txt"

foreach ($computer in $computers){
    $test = $null
    $test = Test-Connection $computer -Count 2 -ErrorAction SilentlyContinue
    if($test -eq $null){
        write-host "**** $computer could not be reached. ****"
    }
    else {
        write-host "$computer is alive"
    }
}

