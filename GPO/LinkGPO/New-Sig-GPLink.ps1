#requires -version 4
<#
.SYNOPSIS
  Links created group policies to OUs in our environment.

.DESCRIPTION
  Links created group policies to different OUs in our environment based on OU collections stored in CSV files

.PARAMETER GPO
  Name of GPO to be linked

.PARAMETER CSV
  Path to CSV file containing OUS

.INPUTS
  GP Name
  CSV file

.OUTPUTS
  None

.NOTES
  Version:        1.0
  Author:         Alex Andrei
  Creation Date:  27.02.2019
  Purpose/Change: Initial script development

.EXAMPLE
  New-SIG-GPLink.ps1 -csv "./Computers-OU.csv" -gpo "SIG-Computers-Citrix Receiver"
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  [Parameter( Mandatory=$true)]
  [string]$GPO,
  
  [Parameter( Mandatory=$true)]
	[string]$CSV
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'Inquire'

#Import Modules & Snap-ins

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Any Global Declarations go here

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#-----------------------------------------------------------[Execution]------------------------------------------------------------

$ous = Get-Content $CSV
foreach ($ou in $ous) {
      Write-Host "Linking $GPO to $ou"
      Get-gpo -Name $GPO | New-GPLink -Target $ou -LinkEnabled Yes -Enforced No
    }
