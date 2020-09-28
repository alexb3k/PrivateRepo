<#
.SYNOPSIS

.DESCRIPTION 

.OUTPUTS

.PARAMETER Mailbox

.PARAMETER User

.EXAMPLE


.LINK

.NOTES

#>


Import-Module VMware.PowerCLI

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
# Do Report
#------------------

$report = @()
foreach ($vm in Get-VM){
$view = Get-View $vm
if ($view.config.hardware.Device.Backing.ThinProvisioned -eq $true){
$row = '' | select Name, Provisioned, Total, Used, VMDKs, VMDKsize, DiskUsed, Thin
    $row.Name = $vm.Name
    $row.Provisioned = [math]::round($vm.ProvisionedSpaceGB , 2)
    $row.Total = [math]::round(($view.config.hardware.Device | Measure-Object CapacityInKB -Sum).sum/1048576 , 2)
    $row.Used = [math]::round($vm.UsedSpaceGB , 2)
    $row.VMDKs = $view.config.hardware.Device.Backing.Filename | Out-String
    $row.VMDKsize = $view.config.hardware.Device | where {$_.GetType().name -eq 'VirtualDisk'} | ForEach-Object {($_.capacityinKB)/1048576} | Out-String
    $row.DiskUsed = $vm.Extensiondata.Guest.Disk | ForEach-Object {[math]::round( ($_.Capacity - $_.FreeSpace)/1048576/1024, 2 )} | Out-String
    $row.Thin = $view.config.hardware.Device.Backing.ThinProvisioned | Out-String
$report += $row
}}
$report | Sort Name | Export-Csv -Path "C:\Users\RO10029\Desktop\WorkingDir\vmWareTasksForSPM\thin.csv"

#--------------
#Clean up tasks
#--------------
Write-Host "Disconnecting from vCenter Server : $vCenterName"
Disconnect-VIServer -Server $vCenterName -confirm:$false