#requires -version 4
<#
.SYNOPSIS
  Get-NestedGroupMember 

.DESCRIPTION
  

.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS Log File
  The script log file stored in C:\Windows\Temp\<name>.log

.NOTES
  Version:        1.0
  Author:        Andrei Alex
  Creation Date:  27.01.2021
  Purpose/Change: Initial script development

.EXAMPLE
  <Example explanation goes here>
  
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  #Script parameters go here
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

function Get-NestedGroupMember {
  [CmdletBinding()] 
  param (
  [Parameter(Mandatory)] 
  [string]$Group )

  ## Find all members  in the group specified 
  
  $members = Get-ADGroupMember -Identity $Group 

  foreach ($member in $members) {
  ## If any member in  that group is another group just call this function again 
    if ($member.objectClass -eq 'group'){
      Get-NestedGroupMember -Group $member.Name
    }
    else {
      ## otherwise, just  output the non-group object (probably a user account) 
      $member | select Name,SAMAccountName  }
  }
}
#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Script Execution goes here
  
Get-NestedGroupMember 