<#
 	.SYNOPSIS
        This script will export XML report for active GPs.
		
    .Notes
    Version 1.0
    Andrei Alex
    31.12.2018

        
#>

Get-GPResultantSetOfPolicy -ReportType xml -path C:\temp\rsop.xml