# The purpose of this script is to report on folder ownership for all folders/subfolders

# $Folders is the root of the mapped drive share, $Subfolders will recurse all files/folders below it

$Folder = "C:\Share"
$Subfolders = Get-ChildItem $Folder -Recurse | 
              Where-Object {$_.PSIsContainer} | 
              Select-Object -ExpandProperty FullName

foreach ($Subfolder in $Subfolders) {Get-Acl "$Subfolder" | Select-Object Path,Owner | Export-CSV c:\admin\owners.csv -Append}