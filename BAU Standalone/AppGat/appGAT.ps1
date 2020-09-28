#requires -version 4
<#
.SYNOPSIS
  Partner script for GAT application handling clint side processes.

.DESCRIPTION
  This script uses the .NET FileSystemWatcher class to monitor file events in the specified folder.
  Upon finding the required file(s) it will move it to the SPO synced folder and open it. 

.INPUTS
  None

.OUTPUTS
  None

.NOTES
  Version:        1.0
  Author:         Andrei Alex
  Creation Date:  17.10.2019
  Purpose/Change: Initial script development

  Version:        1.2
  Author:         Frank Luzat
  Creation Date:  10.07.2020
  Purpose/Change: Make the regex more specific - e.g. to not match "WI_869651021_03 (1).pdf"
	
  Version:        1.3
  Author:         Frank Luzat
  Creation Date:  16.07.2020
  Purpose/Change: Introduce event logging. Make file handling more robust

  Version:        1.4
  Author:         Andrei Alex
  Creation Date:  21.07.2020
  Purpose/Change: Create event log within script. Add more logging.
	
  Version:        1.5
  Author:         Frank Luzat
  Creation Date:  21.07.2020
  Purpose/Change: Add Messagebox Output in case the move to SPO folder fails
#>


  #---------------------------------------------------------[Initialisations]--------------------------------------------------------
  
 	$ErrorActionPreference = 'Continue' 
 
 	Add-Type -AssemblyName PresentationFramework # required for MessageBox
 
	#---------------------------------------------------------[Functions]--------------------------------------------------------------

	# Write Log output to console and Windows event log
	function Write-Log ($EventID, $Msg, $EntryType = "Information") {
		# Write-EventLog -LogName $logname -Source $logsrc -EventID $EventID -EntryType $EntryType -Message $Msg
		Write-Host $Msg
	}
 
  #----------------------------------------------------------[Declarations]----------------------------------------------------------
  #Script Version
  $sScriptVersion = '1.5'
 
  #Script  variables
  $logname = "GAT watcher"
	$logsrc = "gat-watcher"
<#
  $logFileExists = Get-EventLog -list | Where-Object {$_.logdisplayname -eq $logname} 
	
	if (! $logFileExists) {
    Write-Host "Creating eventlog $logname with source $logsrc" -fore green
		New-EventLog -LogName $logname -Source $logsrc
		Write-EventLog -LogName $logname -Source $logsrc -EventID 0001 -EntryType Information -Message "Log Created"
	}
	else {
		Write-Host "Eventlog $logname with source $logsrc exists" -fore green
	}
  #>
  
	$userprofile = $env:userprofile
  $global:srcfolder = "$userprofile\Downloads" # Enter the root path to monitor.
	$global:spofolder = "$userprofile\SIG\app.GAT - gat\gat-content" # Root path to the SPO folder
	#$global:spofolder = "c:\temp\gat\dest" # For dev and debugging purposes only
	$filter = "*.pdf"  # Initial filter here.

	Write-Log -EventID 0002 -Msg "Watcher script version $sScriptVersion starting up"

  $fsw = New-Object IO.FileSystemWatcher $srcfolder, $filter -Property @{IncludeSubdirectories = $false;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'} #If needed IncludeSubdirectories can be changed to $true
 
  #-----------------------------------------------------------[Functions]------------------------------------------------------------

	Write-Log -EventID 0003 -Msg "Setting up file system watcher for folder '$srcfolder' with destination '$spofolder'"

	#The event is set as "Renamed" to bypass Chrome browser downloading the file under a different name and then renaming. 
	Register-ObjectEvent $fsw Renamed -SourceIdentifier appGATFileCreated -Action {
		$file = $Event.SourceEventArgs.Name # For testing and extra Dev, the ObjectEvent should be changed to "Created"
		Write-Log -EventID 0004 -Msg "Event triggered for file '$file'"
		Write-Host "The file '$file' was $($Event.SourceEventArgs.ChangeType) at $($Event.TimeGenerated)" -fore green #for debugging purposes
	
		if($file -match "^(MI)_(\d{9}).*\.pdf$") {
			Write-Log -EventID 0005 -Msg "Filename matches pattern for MI. Opening file with default application."
			# MI files will not be moved to the SPO sync folder, only opened in the PDF reader application
			Start-Process ((Resolve-Path "$global:srcfolder\$file").Path)

			if (! $?) {
				Write-Log -EventID 0006 -EntryType Error -Msg "Error while trying to start default application: $($Error[0])"
			}
		}
		elseif($file -match "^((WI)|(SP)|(ONU)|(SN))_\d{9}_\S{2}\.pdf$") {
			Write-Log -EventID 0007 -Msg "Filename matches pattern for document type $($Matches[1])"
			Write-Log -EventID 0008 -Msg "Trying to move '$global:srcfolder\$file' to '$global:spoFolder'"
			Move-Item -Path "$global:srcfolder\$file" -Destination $global:spoFolder -Force
			
			if ($?) {
				Write-Log -EventID 0009 -Msg "Opening file '$global:spoFolder\$file' with default application"
				Start-Process ((Resolve-Path "$global:spoFolder\$file").Path)
				
				if (! $?) {
					Write-Log -EventID 0010 -EntryType Error -Msg "Opening file '$global:spoFolder\$file' with default application failed: $($Error[0])" 
				}
			}
			else {
				Write-Log -EventID 0011 -EntryType Error -Msg "The file move operation failed: $($Error[0])`nThe file will be deleted from source folder."
				# Remove file from the source (download) folder				
				Remove-Item -Path "$global:srcfolder\$file" -Force
				
				if (! $?) {
					Write-Log -EventID 0012 -EntryType Error -Msg "Deleting file '$global:srcfolder\$file' failed: $($Error[0])"
				}
				
				# Output Error to user with a messagebox
				[System.Windows.MessageBox]::Show("Moving the document " + $file + " to the local SharePoint folder " + $global:spoFolder + " failed.`nPlease check that none of your colleagues has the document opened at the same time.`n`nDas Verschieben des Dokuments " + $file + " in den lokalen SharePoint Ordner " + $global:spoFolder + " ist fehlgeschlagen.`nBitte stellen Sie sicher, dass keiner Ihrer Kollegen das Dokument zur selben Zeit geoeffnet hat", 'GAT Error','Ok','Error')
			}	
		}
		else {
			# file is not relevant for GAT
			Write-Log -EventID 0013 -Msg "File is not relevant for GAT and will be ignored"
		}
	}
