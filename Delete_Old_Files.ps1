<#Deletes files oder then X number of days.  CMT - 6/27/2017#> 

$path = "C:\directory\"
Get-ChildItem -Path $path -Recurse | Where-Object CreationTime -lt  (Get-Date).AddDays(-3)  | Remove-Item -Force