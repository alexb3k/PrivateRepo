################################################################################################################################################################
# This script connects to Office 365 and creates a multiple shared mailboxes based on user input and contents of a txt file.
#
# To run the script
#
# .\New-MultipleSharedMailboxes
#
#  *** Please note you need to have a txt file named SharedMailboxList.txt in the same folder as you run this script from. ***
#  *** The txt file should have each mailbox name on a new line ***
#
#
# Author: 				Darren McCabe
# Version: 				1.0
# Last Modified Date: 	07/01/2015
# Last Modified By: 	Darren McCabe
# Website:				http://www.techmonkeys.co.uk
################################################################################################################################################################


#Remove all existing Powershell sessions
Get-PSSession | Remove-PSSession

Write-Host "This script will create multiple shared mailboxes in Office 365.  You will need to list the mailbox names in the file: SharedMailboxList.txt" -foregroundcolor "yellow"
""

Write-Host "Enter your Office 365 Administrator Username and Password"
$cred = Get-Credential

#Connect to Office 365 Exchange Online
""
Write-Host "Connecting to Office 365..." -foregroundcolor "yellow"
""
$msoExchangeURL = “https://ps.outlook.com/powershell/”
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $msoExchangeURL -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $session

#Prompt for domain extension to be used
$domainname = Read-Host "Enter the domain you wish to add these mailboxes to (e.g domain.com)"


#Prompt user to add permissions to mailbox
$title = "Add Mailbox Permissions"
$message = "Do you want to add permissions for another user to view all these mailboxes??"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Add Mailbox Permissions."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "I'm done for now."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 0) 
	

	""
	#User to add to mailbox
	$UserToPermission = Read-Host "Enter the username for the person or group you want to give access to these mailboxes (e.g you@domain.com)"
		
	#Get Permission Type
	$title = "Permission Type"
	$message = "What kind of Permissions do you want to give this user?"

	$FullAccess = New-Object System.Management.Automation.Host.ChoiceDescription "&Full Access", ""
	$ReadOnly = New-Object System.Management.Automation.Host.ChoiceDescription "&Read Only", ""
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($FullAccess, $ReadOnly)

	$PermissionType = $host.ui.PromptForChoice($title, $message, $options, 0) 
		
	#Send As Permissions?
	$title = "Send As Permissions"
	$message = "Do you want to allow this user to Send As these shared mailboxes?"

	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", ""
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", ""
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

	$SendAs = $host.ui.PromptForChoice($title, $message, $options, 0) 
		
	#AutoMap Mailbox
	$title = "Automap Mailbox"
	$message = "Do you want the Shared Mailboxes to automatically appear in the users Outlook/OWA?"

	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", ""
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", ""
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

	$AutoMap = $host.ui.PromptForChoice($title, $message, $options, 0) 

	

$a=get-content .\SharedMailboxList.txt
foreach($b in $a)
{

New-Mailbox -Name $b -Alias $b –Shared -PrimarySmtpAddress $b@$domainname

#Set the Permissions
	if ($PermissionType -eq 0)
	{
		try
		{
			""
			Write-Host "Setting Full Access permissions on the shared mailbox"
			""
			if ($AutoMap -eq 0)
			{
				Add-MailboxPermission $b -User $UserToPermission -AccessRights FullAccess -AutoMapping $true
			}
			else
			{	
				Add-MailboxPermission $b -User $UserToPermission -AccessRights FullAccess -AutoMapping $false
			}
		}
		catch
		{
			Write-Host "Unable to set permissions" -foregroundcolor "red"
			write-host $error[0]
			return ""
		}
	}
	else
	{
		try
		{
			""
			Write-Host "Setting Read Only permissions on the shared mailbox"
			""
			if ($AutoMap -eq 0)
			{
				Add-MailboxPermission $b -User $UserToPermission -AccessRights ReadPermission -AutoMapping $true
			}
			else
			{	
				Add-MailboxPermission $b -User $UserToPermission -AccessRights ReadPermission -AutoMapping $false
			}
		}
		catch
		{
			Write-Host "Unable to set permissions" -foregroundcolor "red"
			write-host $error[0]
			return ""
		}
	}
		
	#Set sendas permissions if required
	if ($SendAs -eq 0)
	{
		try
		{
			Add-RecipientPermission $b -Trustee $UserToPermission -AccessRights SendAs -confirm:$False
		}
		catch
		{
			Write-Host "Unable to set send as permissions" -foregroundcolor "red"
			write-host $error[0]
			return ""
		}
	}

}
#Clean up session
Get-PSSession | Remove-PSSession