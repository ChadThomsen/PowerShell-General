Script files are pushed to the client via group policy to c:\windows.  
The script files are then executed via scheduled task on the client machine
which is also pushed to the client via GPO. Depending on how its done, you 
can read in the file ip-data.csv to set static IPs or DHCP. The 
change-ip-address.ps1 file also contains a date check to make sure that 
the file is allowed to execute the iP address change as one methoed is 
to have the scheduled job execute on computer boot if doing a data 
center relocation. Note that powershell can be started with the .bat file
so that you can run the script to bypass the "remote execution policy" 
check should the remote exection policy not be set on the client machine. 
Default setting is to not allow, so if not set via manually or GPO it must 
be used or this will fail.

File can be pushed to the windows clients via GPO. 
    >>Computer configuration>Preferences>Windows Settings>Files
Scheduled Task can be pushed to the window clients via GPO.
    >>Computer configuration>control panel settings>Scheduled Tasks      

You can also modify the same group policy to remove the files after the IP 
address change mods are done. 

Chad Thomsen 16-APRIL-2021