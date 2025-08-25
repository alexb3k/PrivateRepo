$OU = "OU=REGULAR,OU=INTERNAL,OU=KAU,OU=USERS,OU=CORP.SOLVIASONE,DC=corp,DC=solviasone,DC=com"

Get-ADUser -SearchBase $OU -Filter { City -eq "Kaiseraugst" } -Property StreetAddress, City, SamAccountName |
    Select-Object SamAccountName, StreetAddress, City