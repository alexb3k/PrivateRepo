<#
.SYNOPSIS
Create-SparePartUsers.ps1
.DESCRIPTION 
Creates AD users for the Spare Part Migration, based on XLS file
.NOTES
Created by: Alex Andrei

#>

Import-Module ActiveDirectory 
$Users = Import-Csv -Delimiter "," -Path "C:\Users\ro10029\OneDrive - SIG Information Technology GmbH\zzz.CODE\Usable\SIG Specific\Spare Parts User Migration\External users to be created.csv"  #Path needs to be adjusted
foreach ($User in $Users)  
{  
    $OU = "OU=WAFP Users,OU=SIG Global Resources,DC=sig,DC=dom"  #Hardcoded
    $Password = $User.password
    $name =  $User.lastname
    $Detailedname = $User.firstname + " " + $User.lastname 
    $UserFirstname = $User.Firstname 
    #$FirstLetterFirstname = $UserFirstname.substring(0,1) 
    $SAM = $User.SAM
    $email = $user.email
    $company = $user.Company
    $upn = $SAM + "@sig.dom"
    New-ADUser -Name $Detailedname -SamAccountName $SAM -UserPrincipalName $UPN -DisplayName $Detailedname -GivenName $user.firstname -Surname $user.name -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -ChangePasswordAtLogon $false -passwordNeverExpires $true -EmailAddress $email -Enabled $true -Path $OU -Organization $company 
    Write-Host "Created user: UID: $SAM,UPN = $UPN TemporaryPassword: $Password  , Name: $Detailedname                 ,Email: $email               , Company: $company "
    #Set-ADUser -Identity $SAM -Company $company -Surname $name
    #Write-Host "Added lastName: $name;       Company: $Company      to user $SAM" 
} 
