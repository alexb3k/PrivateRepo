<#
    .SYNOPSIS
        Gets all the teams in your organization.
    .DESCRIPTION
        Author: John Seerden (https://www.srdn.io)
        Version: 1.1

        Gets all Office 365 Groups which are enabled for Microsoft Teams in your organization, whether you belong to the team or not.
    .EXAMPLE
        .\Get-AllMicrosoftTeams.ps1
    .NOTES
        Requires an active connection to Exchange Online with permissions for the Get-UnifiedGroup cmdlet (View-Only Recipients, Mailbox Recipients or Exchange Online Admin).
        Requires the Microsoft Teams module installed (Install-Module MicrosoftTeams)
        Requires an active connection to Microsoft Teams (Connect-MicrosoftTeams)
#>
if (!(Get-PSSession | Where-Object { $_.ConfigurationName -eq "Microsoft.Exchange" })) { 
    Write-Error -Message 'You must connect to Exchange Online first' -ErrorAction Stop
}

try {
    $null = Get-Team -ErrorAction Stop
}
catch {
    if($_.CategoryInfo.Reason -eq 'AadNeedAuthenticationException') {
        Write-Error -Message 'You must call the Connect-MicrosoftTeams cmdlet before calling any other cmdlets.' -ErrorAction Stop
    }
    Write-Error $_ -ErrorAction Stop
}

try {
    $unifiedGroups = Get-UnifiedGroup -ResultSize Unlimited -ErrorAction Stop
}
catch {
    Write-Error $_ -ErrorAction Stop
}

foreach ($unifiedGroup in $unifiedGroups) {
    try {       
         $null = Get-TeamChannel -GroupId $unifiedGroup.ExternalDirectoryObjectId -ErrorAction Stop
         $isTeam = $true
    }
    catch {
        if($_.Exception.ErrorCode -eq '403') {
            $isTeam = $true
        } elseif($_.Exception.ErrorCode -eq '404') {
            $isTeam = $false
        } else {
            $isTeam = $false
            Write-Error $_
        }                 
    }

    if($isTeam) {
        $unifiedGroup
    }
}