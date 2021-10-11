To use this script all machines that will have their IP config altered
must be members of the domain you are working with because it this process
utilizes group policy to distribute and execute the script files.  
Script and data files are pushed to the client via group policy to c:\windows
from a share you must define.  All machines must have read access to this share. 

The script files are then executed via scheduled task on the client machine
which is also pushed to the client via GPO.  If the date in the script does not match, 
then the script does nothing. Depending on how its done, you can read in the file 
ip-data.csv to set static IPs or DHCP. 

The change-ip-address.ps1 file also contains a date check to make sure that 
the file is allowed to execute the iP address change as one methoed is 
to have the scheduled job execute on computer boot if doing a data 
center relocation. Note that powershell can be started with the .bat file
so that you can run the script to bypass the "remote execution policy" 
check should the remote exection policy not be set on the client machine. 
Default setting is to not allow, so if not set via manually or GPO it must 
be used or this will fail.  If th execution policy is set to allow execution 
then you can bypass the batch file. 

The change DNS servers works like the change-ipaddress.ps1 file but it only changes 
DNS servers. It too has a date check in it. 

GPO Stuff:
File can be pushed and removed from windows clients via GPO. 
    >>GPO Applet>Computer configuration>Preferences>Windows Settings>Files
Scheduled Task can be pushed and removed from window clients via GPO.
    >>GPO Applet>Computer configuration>control panel settings>Scheduled Tasks      

Set the Scheduled task to run under the NT AUTHORITY\SYSTEM account.  

A few quick notes on GPOs and pushing files and scheduled tasks:
    Create – a file/task is copied to a target directory only if the file doesn’t 
        exist in it;
    Replace – a target file/task on a user computer is always replaced by a source file.
        Every GPO update cycle, the target is updated no matter what.  This iw what 
        you want when you are making frequent changes during testing.
    Update (a default policy) – if a file/task already exists, it is not replaced with 
        the source file;
    Delete – delete the target file/task.  Use this option to clean up after the entire 
        process is complete. 
***For this particular application I suggest using replace, and then delete when you are completely done.

Order of operations:
1. Modify the scripts and data files to suit your needs. 
2. Create share that is accessible by the machines you are changing the IPs on, and place files in there. 
3. Build GPO to push files from step 2, and GPO to push sheduled task (Reboot or scheduled time for task). 
4. Force VMs to reboot if using reboot time to change IP. 
5. Execute the get-ip-addresses.ps1 to check the IPs actually got changed. 
6. Modify GPOs to delete the files and scheduled task pushed to machines from step two and three. 
8. Unshare the files from step 2. 

Chad Thomsen 10-OCT-2021