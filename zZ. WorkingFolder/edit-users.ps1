# Load required modules

Install-Module ImportExcel
Import-Module ActiveDirectory
Import-Module ImportExcel  
# Path to Excel file
$excelPath = "C:\temp\persons (2).xlsx"

# Import Excel data
$users = Import-Excel -Path $excelPath

foreach ($user in $users) {
    $sam = $user.SamAccountName
    $props = @{
        GivenName   = $user.Vorname
        sn     = $user.Nachname
        Title       = $user.Position
        Department  = $user.Abteilung
        Description = $user.Description
        physicalDeliveryOfficeName = $user.Office
        scanPath = "\\userhome1\Userhome$\$user.Benutzername\Scans"
        name = "$($user.Vorname) $($user.Nachname) ($($user.Benutzername))"
        mail = $user.EMail    #need to change this in the excel, otherwise you will get errors
        userPrincipalName = $user.userPrincipalName #same here
        facsimileTelephoneNumber = $user.Fax
        DisplayName = "$($user.Vorname) $($user.Nachname)"

    }

    # Update AD user
    Set-ADUser -Identity $sam @props
    Write-Host "Updated $sam"
}
