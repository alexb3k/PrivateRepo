<#
.SYNOPSIS
Get-UniqueVCEvents.ps1
.DESCRIPTION 
This script will output the name of all the events that occur between a date range.
Can be filtered by event type. 
.OUTPUTS

.EXAMPLE

.LINK

.NOTES

#>

#-----------------------------------------------------------------------------
# Import PowerCLI Module
#-----------------------------------------------------------------------------
Add-PSSnapin VMware.VimAutomation.Core

#-----------------------------------------------------------------------------
# Connect to vCenter Server
#-----------------------------------------------------------------------------
$Server = Read-Host 'Specify the vCenter Server or ESXi Host to connect to (IP or FQDN)?'
Connect-VMwareServer -VMServer $Server

#-----------------------------------------------------------------------------
# Get Events from vCenter (filtering on event type)
#-----------------------------------------------------------------------------
Get-VIEvent -maxsamples 10000 -Start "01/08/2015" -Finish "05/08/2015" | Where-Object {$_.Gettype().Name-eq "VmCreatedEvent" -or $_.Gettype().Name-eq "VmBeingClonedEvent" -or $_.Gettype().Name-eq "VmBeingDeployedEvent"} | Sort-Object CreatedTime -Descending |Select-Object CreatedTime, UserName, FullformattedMessage