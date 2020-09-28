<#
.SYNOPSIS
Get-UniqueVCEvents.ps1
.DESCRIPTION 
This script will output the name of all the unique events that occur between a date range. Helps in filtering the events gathered by Get-VCEvents.ps1
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
$Server = Read-Host 'Specify the vCenter Server or ESXi Host to connect to (IP or FQDN)? 1= DELIN ; 2= CNSOU'

switch ($server) {
    1 { $link = https://delinvaas900.sig.dom:9443 }
    2 { $link = https://cnsouvaas900.sig.dom:9443}
}




Connect-VMwareServer -VMServer $link

#-----------------------------------------------------------------------------
# Get list of unique events over a period of time
#-----------------------------------------------------------------------------
$Events = Get-VIEvent -maxsamples 100000 -Start "01/08/2015" -Finish "05/08/2015"
$aResults = @()

ForEach($Item in $Events){
    $sEventType = $Item.GetType().Name
    If($aResults.Count -ge 1){
        If(!($aResults.Contains($sEventType))){
            $aResults += $sEventType
        }
    }Else{
        $aResults += $sEventType
    }
}
$aResults | Sort-Object