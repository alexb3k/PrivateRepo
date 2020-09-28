<#
.SYNOPSIS
Get-PublicIPAddress.ps1 - Retrieve the public IP address of local or remote computer.

.DESCRIPTION 
This PowerShell script will retrieve the public IP address of the local computer, or
a remote computer.

.OUTPUTS
Results are output to console.

.PARAMETER Computer
Specifies the remote computer that you want to connect to using PowerShell remoting
and perform the public IP address query. If this parameter is not specified then
the local computer is used.

.EXAMPLE
.\Get-PublicIPAddress.ps1
Retrieves the public IP address for the local computer.

.EXAMPLE
.\Get-PublicIPAddress.ps1 -Computer SERVER01
Retrieves the public IP address for the computer SERVER01.

.NOTES

#>

[CmdletBinding()]
param (
	
	[Parameter( Mandatory=$false)]
	[string]$Computer

	)

#A useful API for retrieving your public IP address
$url = "https://api.ipify.org/?format=json"

#If a remote computer was specified then a PS remote session is used. Otherwies the query
#is run locally.
if ($Computer)
{
    $credential = Get-Credential -Message "Enter credentials for remoting to $Computer"
    $ip = Invoke-Command -ComputerName $Computer -Credential $credential -ScriptBlock {(Invoke-RestMethod $using:url).ip}
}
else
{
    
    $ip = (Invoke-RestMethod $url).ip
}

if ($Computer)
{
    Write-Host "The public IP address of computer $computer is $ip"
}
else
{
    Write-Host "The public IP address of the local computer is $ip"
}