Import-Module ActiveDirectory

$Computers = Get-Content ./computers.txt

foreach ($Computer in $Computers){

    New-ADComputer -Name "CHNEU-C-$Computer" -SamAccountName "CHNEU-C-$Computer" -path "OU=POOL,OU=Notebooks,OU=Local Resources,OU=CHNEU,DC=sig,DC=dom"
    Remove-ADGroupMember -Identity "Domain Admins" -Members "CHNEU-C-$Computer"
    Add-ADGroupMember -Identity "Domain Computers"

}



                                           