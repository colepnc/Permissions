# The purpose of this script is to clean up silly permissions on a mapped drive, deny most users the ablity to modify the root folder of the drive,
# but grant them near full control (no permissions/ownership changes of course) on subdirectories.

# $Folders is the root of the mapped drive share, $Subfolders will recurse all files/folders below it
# ICACLS to GUI names translation encased below, in canse you need to modify this script for different permissions
<#
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

$Folder = "\\server\rootsharefolder\"
$Subfolders = Get-ChildItem $Folder -Recurse
$UserGroup = "PNC-Permissionstest"
$SUGroup = "SUGroup"

# Sets the owner to the superuser group you intend to use to manage the drive
icacls "$Folder" /setowner $SUGroup /T /C 
# Reset permissions on all files
icacls "$Folder" /reset /T /C 
# Disable inheritance on the root of the mapped drive
icacls "$Folder" /inheritance:d /C 
# Remove "Users" from the defualt permissions
icacls "$Folder" /remove "Authenticated Users" /T /C 
# grant $UserGroup the appropriate permissions (deny modify) to the root of the mapped drive
icacls "$Folder" /grant ("$UserGroup" + ':(X,RD,RA,REA,RC)') /T /C 
# grant $UserGroup the appropriate permissions to the subdirectories (everything but changing permissions/ownership)
icacls "$Subfolders" /grant ("$UserGroup" + ':(WD,AD,WA,WEA,DC,D)') /T /C
