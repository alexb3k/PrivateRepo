<#
.SYNOPSIS
Clone-VM-Machines.ps1
.DESCRIPTION 

.OUTPUTS

.PARAMETER 

.PARAMETER 

.EXAMPLE

.LINK

.NOTES

#>

#-----------------
#Login to vCenter
#-----------------

#Get vCenter Details : vCenter name, User, password
Write-Host "Please enter the vCenter Host Name :"
Write-Host " "
$vCenterName = Read-Host vCenter Host Name
$Username = Read-Host Username
$SecurePassword = Read-Host Password -AsSecureString

#Convert Secure Password to Plain Text
$PASS = `
[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($PASS)
#Connect to vCenter
Connect-VIServer -Server $vCenterName -User $Username -Password $PlainPassword

#Remove Password from Session
Remove-Variable PlainPassword
Remove-Variable SecurePassword
Remove-Variable PASS

#------------------
# Do Cloning Tasks
#------------------

#Define all the Variables for Clone VM

$DSKT = "DSKT-"                     # This defines the VM Prefixed that will be used for the name of the VM
$CloneVMName = "DSKT-001"           # This is the VM name that must be used for cloning
$ResourcePool = "VDI-Desktops"      # The Resource Pool where the new VM's will be placed
$DataStore = "DSCL-Resource"        # The Datastore name where the VM's should be pleased 
$FolderLocation = "VDI-Desktops"    # Folder where the VM's must be placed into
$x = 100                            # This the start suffix number that will be used for the VM name (thus DSKT-100 will be the first VM Name)

#-----------------
# Cloning Command
#-----------------

do
{
$NewVMName = $DSKT + $x

Write-Host "Creating new VM : $NewVMName "

New-VM -name $NewVMName -VM $CloneVMName -ResourcePool $ResourcePool -Datastore $DataStore -Location $FolderLocation
Start-VM -VM $NewVMName              # This will Power On the New VM
$x = $x + 1                          # Increment $x by 1
} until ($x -eq 1000)                # Can change the 1000 to own number. This defines the number of VM's that will be created
#--------------
#Clean up tasks
#--------------
Write-Host "Disconnecting from vCenter Server : $vCenterName"
Disconnect-VIServer -Server $vCenterName -confirm:$false