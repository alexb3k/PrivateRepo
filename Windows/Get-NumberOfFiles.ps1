<#
 	.SYNOPSIS
        This script can list all files of a specific type in a folder and all subfolders and count them
		
    .DESCRIPTION
        This script will list all files in a path tree according to the filters set and count them. 
    
    .PARAMETER  <Path>
		Parent folder to start the count.
		
	.PARAMETER	<Extension>
		The file extension to look for (can also specify a file name)
		
    .EXAMPLE
        C:\PS> Get-NumberOfFiles C:\ *ps1
		
		This example lists all the ps1 files on the local computer.
		
#>

Param
(
	[Parameter(Mandatory=$false)]
	[Alias('Path')][String[]]$Folder="C:\Users\RO10029\Documents\Egnyte\Private\ro10029",

	[Parameter(Mandatory=$false)]
    [Alias('Extension')][String[]]$Ext="*ps1"
)

Function Get-NumberOfFiles($Folder, $Extension)
{
	$items = Get-ChildItem -Path $Folder -recurse -filter $Extension
	$items | Group-Object -Property Directory
    $items.count

}
