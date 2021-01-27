#requires -version 4
<#
.SYNOPSIS
  Add-UsersToADGroups

.DESCRIPTION
  Imports lists of users and groups and adds all the users to all the groups.

.PARAMETER <Parameter_Name>
  <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS Log File
  The script log file stored in C:\Windows\Temp\<name>.log

.NOTES
  Version:        1.0
  Author:         Alex Andrei
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
cls
#Import Modules & Snap-ins

Import-module ActiveDirectory

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#-----------------------------------------------------------[Execution]------------------------------------------------------------


#Script Execution goes here

$GroupArray= gc ".\groups.txt"
$UsersArray= gc ".\users.txt"

ForEach ($Group in $GroupArray) {   
    Try { 
        ForEach ($User in $UsersArray){
            Try{
               Add-ADGroupMember $Group -Members $User -ErrorAction Stop #-Whatif
               $Result += [PSCustomObject]@{
                Group = $Group
                AddMembers = $User -join ", "
                }
             } 
            Catch {
              Write-Error "Error adding members to $Group because $($Error[0])"
              $Result += [PSCustomObject]@{
                Group = $Group
                AddMembers = $Error[0]
                }
            }
        }
    }
    Catch {
        Write-Error "Error adding members to $Group because $($Error[0])"
        $Result += [PSCustomObject]@{
            Group = $Group
            AddMembers = $Error[0]
        }
    }
}
    