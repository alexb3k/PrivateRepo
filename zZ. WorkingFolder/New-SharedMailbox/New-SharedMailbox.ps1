#requires -version 4
<#
.SYNOPSIS
  Creates new shared mailboxes

.DESCRIPTION
  Creates one or more shared mailboxes and adds permissions to users.

.INPUTS
  Mailbox name
  User names

.OUTPUTS Log File
  The script log file stored in C:\Windows\Temp\<name>.log

.NOTES
  Version:        1.0
  Author:         Alex Andrei
  Creation Date:  26.01.2021
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


#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#-----------------------------------------------------------[Functions]------------------------------------------------------------

function Connect-To-Services {
    
    Begin {
        Write-Host "Create the CSOnline Session and authenticate to MSOnline"
        Write-Host "Input Credentials"
      }
    
    Process {  
    $cred = Get-Credential
    }

    End {
    #Connect to Office 365 Exchange Online
""
Write-Host "Connecting to Office 365..." -foregroundcolor "yellow"
""
$msoExchangeURL = "https://ps.outlook.com/powershell/"
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $session

#Prompt for domain extension to be used
$domainname = Read-Host "Enter the domain you wish to add these mailboxes to (e.g domain.com)"     
    }   
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Get-PSSession | Remove-PSSession

Connect-To-Services

$Users = get-content .\Users.txt

$a=get-content .\mailboxes.txt
foreach($b in $a)
{
New-Mailbox -Name $b -Alias $b -Shared -PrimarySmtpAddress $b@$domainname
#Set the Permissions
  foreach($user in $users){
      try
      {
          Add-MailboxPermission $b -User $User -AccessRights FullAccess -AutoMapping $true
          #Add-MailboxPermission $b -User $UserToPermission -AccessRights FullAccess -AutoMapping $false
          #Add-MailboxPermission $b -User $UserToPermission -AccessRights ReadPermission -AutoMapping $true
          #Add-MailboxPermission $b -User $UserToPermission -AccessRights ReadPermission -AutoMapping $false
          Add-RecipientPermission $b -Trustee $User -AccessRights SendAs -confirm:$False
        }
      catch
      {
      }
  }
}

#Clean up session
Get-PSSession | Remove-PSSession
