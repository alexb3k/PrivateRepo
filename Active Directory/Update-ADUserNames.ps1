<#
.SYNOPSIS
  Updates Active Directory user DisplayName and Name attributes in a specified OU based on Surname and GivenName, with logging and WhatIf support.

.DESCRIPTION
  This script searches for all user accounts in a specified Active Directory OU, then updates each user's DisplayName and Name attributes based on their Surname and GivenName. 
  It supports logging actions to a file and includes a WhatIf parameter to simulate changes without modifying any data.

.PARAMETER Location
    Specifies the location of the OU to search for user accounts. Valid values are "KAU", "CAN", "HOM", "REMOTE", "RTP", and "UTR".

.PARAMETER WhatIf
  Simulates the actions of the script without making any changes to Active Directory.

.PARAMETER LogFile
  Specifies the path to the log file where actions and results are recorded.

.INPUTS
  None. You cannot pipe objects to this script; use parameters to specify input.

.OUTPUTS
  Log file. The script writes actions and results to the specified log file.

.NOTES
  Version:        1.0
  Author:         Alex Andrei
  Creation Date:  05.08.2025
  Purpose/Change: Initial script development

..EXAMPLE
  .\Update-ADUserNames.ps1 -Location "KAU" -LogFile "C:\Temp\ADUserUpdate.log"

  Updates DisplayName and Name attributes for all users in the KAU OU and logs actions to C:\Temp\ADUserUpdate.log.

.EXAMPLE
  .\Update-ADUserNames.ps1 -Location "REMOTE" -WhatIf

  Simulates the update process for users in the REMOTE OU without making any changes to Active Directory.

#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param (
  [Parameter(Mandatory=$true)]
     [ValidateSet("KAU", "CAN", "HOM", "REMOTE", "RTP", "UTR")]
    [string]$Location,

    [switch]$WhatIf,

    [string]$LogFile = "C:\Windows\Temp\Update-ADUserNames.log"
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins
Import-Module ActiveDirectory

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

$OU = "OU=REGULAR,OU=INTERNAL,OU=$Location,OU=USERS,OU=CORP.SOLVIASONE,DC=corp,DC=solviasone,DC=com"
#-----------------------------------------------------------[Functions]------------------------------------------------------------

function Update-ADUserNames {
    param (
        [Parameter(Mandatory=$true)]
        [string]$OU,
        [switch]$WhatIf,
        [string]$LogFile = "C:\Windows\Temp\Update-ADUserNames.log"
       
    )
    Add-Content -Path $LogFile -Value "Running Update-ADUserNames for OU: $OU with WhatIf=$WhatIf at $(Get-Date)"

    $users = Get-ADUser -Property DisplayName, SamAccountName, Name, GivenName, Surname, CN -SearchBase $OU -Filter * |
        Select-Object DisplayName, SamAccountName, Name, GivenName, Surname, CN
    Add-Content -Path $LogFile -Value "Found $($users.Count) users in OU: $OU at $(Get-Date)"

    $changedNCount = 0
    $changedDCount = 0
    $skippedCount = 0
    $changedCount = 0

    foreach ($user in $users) {
        $newDisplayName = "$($user.Surname) $($user.GivenName)"
        $newName  = "$($user.Surname) $($user.GivenName) ($($user.SamAccountName))"
        Add-Content -Path $LogFile -Value "Processing user: $($user.SamAccountName) with Display Name: '$($user.DisplayName)' and Name: '$($user.Name)'"

        if ($user.DisplayName -eq $newDisplayName) {
            if ($user.Name -eq $newName) {
                Add-Content -Path $LogFile -Value "Display Name and Name for $($user.SamAccountName) are already set to '$newDisplayName' and '$newName', skipping."
                $skippedCount++
                continue
            } else {
                Add-Content -Path $LogFile -Value "Updating Name for $($user.SamAccountName) to '$newName'"
                if (-not $WhatIf) {
                    Set-ADUser -Identity $user.SamAccountName -Name $newName
                }
                $changedCount++
                $changedNCount++
            }
        } elseif ($user.Name -eq $newName) {
            Add-Content -Path $LogFile -Value "Updating Display Name for $($user.SamAccountName) to '$newDisplayName'"
            if (-not $WhatIf) {
                Set-ADUser -Identity $user.SamAccountName -DisplayName $newDisplayName
            }
            $changedCount++
            $changedDCount++

        } else {
            Add-Content -Path $LogFile -Value "Updating Display Name and Name for $($user.SamAccountName) to '$newDisplayName' and '$newName'"
            if (-not $WhatIf) {
                Set-ADUser -Identity $user.SamAccountName -DisplayName $newDisplayName -Name $newName
            }
            $changedCount++
            $changedDCount++
            $changedNCount++
        }
        # Optionally log actions to file
        Add-Content -Path $LogFile -Value "Processed $($user.SamAccountName): DisplayName='$newDisplayName', Name='$newName'"
    }
    Add-Content -Path $LogFile -Value "Summary: $changedCount users changed, $skippedCount users skipped."
    Add-Content -Path $LogFile -Value "Display Name changes: $changedDCount, Name changes: $changedNCount at $(Get-Date)"
    Write-Host "Script completed. Check log file at $LogFile for details."
}
#-----------------------------------------------------------[Logging]-------------------------------------------------------------
# Function to log messages
function Log-Message {
    param (
        [string]$Message,
        [string]$LogFile = "C:\Windows\Temp\Update-ADUserNames.log"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Add-Content -Path $LogFile -Value $logEntry
}
# Function to log errors
function Log-Error {
    param (
        [string]$ErrorMessage,
        [string]$LogFile = "C:\Windows\Temp\Update-ADUserNames.log"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - ERROR: $ErrorMessage"
    Add-Content -Path $LogFile -Value $logEntry
}
# Function to log warnings
function Log-Warning { 
    param (
        [string]$WarningMessage,
        [string]$LogFile = "C:\Windows\Temp\Update-ADUserNames.log"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - WARNING: $WarningMessage"
    Add-Content -Path $LogFile -Value $logEntry
}
# Function to log information
function Log-Info {

    param (
        [string]$InfoMessage,
        [string]$LogFile = "C:\Windows\Temp\Update-ADUserNames.log"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - INFO: $InfoMessage"
    Add-Content -Path $LogFile -Value $logEntry
}
# Function to log debug messages
function Log-Debug {
    param (
        [string]$DebugMessage,
        [string]$LogFile = "C:\Windows\Temp\Update-ADUserNames.log"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - DEBUG: $DebugMessage"
    Add-Content -Path $LogFile -Value $logEntry
}
# Function to log verbose messages
function Log-Verbose {
    param (
        [string]$VerboseMessage,
        [string]$LogFile = "C:\Windows\Temp\Update-ADUserNames.log"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - VERBOSE: $VerboseMessage"
    Add-Content -Path $LogFile -Value $logEntry
}

#-----------------------------------------------------------[Pre-Execution]---------------------------------------------------------
# Check if the OU exists
if (-not (Get-ADOrganizationalUnit -Identity $OU -ErrorAction SilentlyContinue)) {
    throw "The specified OU '$OU' does not exist."
}
# Check if the LogFile path is valid
if (-not (Test-Path -Path (Split-Path -Path $LogFile -Parent))) {
    Log-Error "The specified log file path '$LogFile' is invalid."
    Write-Host "The specified log file path '$LogFile' is invalid."
    exit 1
}
# Log the start of the script execution
Log-Info "Starting script execution for OU '$OU' with WhatIf=$WhatIf. Log file: $LogFile"
# Log the script version
Log-Info "Script version: $sScriptVersion"
# Log the parameters used
Log-Info "Parameters: OU='$OU', WhatIf=$WhatIf, LogFile='$LogFile'"

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# Call the function to update user names
Update-ADUserNames -OU $OU -WhatIf:$WhatIf -LogFile $LogFile
# Log the end of the script execution
Log-Info "Script execution completed for OU '$OU'."


