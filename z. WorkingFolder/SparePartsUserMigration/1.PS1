$Users = Import-Csv -Delimiter "," -Path "C:\Temp\SPUM\External users to be created.csv"  #Path needs to be adjusted
foreach ($User in $Users) {
    Set-ADUser -Identity $SAM -Company $company -Surname $name
    Write-Host "Added lastName: $name;       Company: $Company      to user $SAM"
}