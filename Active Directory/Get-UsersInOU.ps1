<#
 	.SYNOPSIS
        This script will list all users in a specific OU.
		
    .DESCRIPTION
        This script will list all users in a specific OU.
    
    .PARAMETER  <Path>
		The OU in which to search for the users.
		
		
    .EXAMPLE
        C:\PS> Get-UsersInOU "OU=IT Users,OU=Users,OU=Local Resources,OU=ROCLU,DC=sig,DC=dom"
		
		This example lists all the IT Users in Cluj.
	
	.EXAMPLE
        C:\PS> Get-UsersInOU "OU=Common Users,OU=Users,OU=Local Resources,OU=ROCLU,DC=sig,DC=dom" | Export-Csv "c:\temp\example.csv"
		
		This example lists all the users in the Local Users OU and exports them to a CSV.
#>

Param
(
	[Parameter(Mandatory=$false)]
	[Alias('Path')][String[]]$OU="OU=Common Users,OU=Users,OU=Local Resources,OU=ROCLU,DC=sig,DC=dom"

)

Function Get-UsersInOU($OU)
{
$users = Get-ADUser -SearchBase $OU -filter * | select Name,SAMAccountName
$users
}
