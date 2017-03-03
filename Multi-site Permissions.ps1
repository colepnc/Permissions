# The purpose of this script is to clean up silly permissions on a mapped drive, deny most users the ablity to modify the root folder of the drive,
# but grant them near full control (no permissions/ownership changes of course) within subdirectories.

# $Folders is the root of the mapped drive share, $Subfolders will recurse all files/folders below it

# ICACLS to GUI names translation encased below, in case you need to modify this script for different permissions
<#
This folder only
This folder, subfolders and files (OI)(CI)
This folder and subfolders (CI)
This folder and files (OI)
Subfolders and files only (OI)(CI)(NP)(IO)
Subfolders only (CI)(IO)
Files only (OI)(IO)

Full Control (F)
Traverse folder / execute file (X)
List folder / read data (RD)
Read attributes (RA)
Read extended attributes (REA)
Create file / write data (WD)
Create folders / append data (AD)
Write attributes (WA)
Write extended attributes (WEA)
Delete subfolders and files (DC)
Delete (D)
Read permissions (RC)
Change permissions (WDAC)
Take ownership (WO)
#>

# Begin log file, this will be placed on the client the script is being run from, do not modify unless you want to disable logging
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\Users\Cole\MappedDriveCleanupMulti-Site.txt -append

$Folder = "\\server\share"
$Subfolders = Get-ChildItem $Folder | 
              Where-Object {$_.PSIsContainer} | 
              Select-Object -ExpandProperty FullName
$UserGroup = "remote1" # remote-site group
$UserGroup2 = "remote2" # remote-site2 group
$SUGroup = "local" # Site-local group

# Phase 1 Sets the owner to the site-local user group
Write-Host "Phase 1: Giving ownership to $SUGroup"
icacls "$Folder" /setowner $SUGroup /T /C 

# Phase 2 Reset permissions on all files
Write-Host "Phase 2: Resetting possibly messy permissions, disabling inheritance on $Folder, and removing defualt usergroup"
icacls "$Folder" /reset /T /C 
# Remove "Users" from the defualt permissions
icacls "$Folder" /remove "Authenticated Users" /T /C 

# Phase 3 grant $UserGroup & $UserGroup2 the appropriate permissions (deny modify) to the root of the mapped drive
Write-Host "Phase 3: Granting permissions to $UserGroup and $SUGroup"
icacls "$Folder" /grant ("$UserGroup" + ':(OI)(CI)(X,RD,RA,REA,RC)') /C
icacls "$Folder" /grant ("$UserGroup2" + ':(OI)(CI)(X,RD,RA,REA,RC)') /C 
# grant $SUGroup full control and domain admins
icacls "$Folder" /grant ("$SUGroup" + ':(OI)(CI)(F)') /C
icacls "$Folder" /grant ("Domain Admins" + ':(OI)(CI)(F)') /C

# End log file
Stop-Transcript
