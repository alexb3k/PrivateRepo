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

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  #Script parameters go here
  [Parameter(Mandatory=$false)]
  [Alias('Path')][String[]]$OU="OU=Common Users,OU=Users,OU=Local Resources,OU=ROCLU,DC=sig,DC=dom"
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins

Import-Module '.\Active Directory'

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function Get-UsersInOU($OU)
{
$users = Get-ADUser -SearchBase $OU -filter * | select Name,SAMAccountName
$users
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here

Get-UsersInOU