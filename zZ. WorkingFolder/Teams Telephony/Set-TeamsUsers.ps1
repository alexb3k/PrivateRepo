    #requires -version 5
<#
.SYNOPSIS
  Applies the Microsoft 365 Phone System license and assigns a phone number extension to a group of users.

.DESCRIPTION
  The script Imports a csv file containing the list of user UPNs and the extensions decided for the users.
  It firstly applies the microsoft phone system license and the attributes the corresponding phone extension to the list. 

.INPUTS InputFile
  Mandatory. The list with the users and corresponding extensions

.INPUTS BaseNumber
  Mandatory. The base phone number that the extensions are applied to.

.OUTPUTS
  The properties of the users.

.NOTES
  Version:        1.0
  Author:         Andrei Alex
  Creation Date:  22.09.2020
  Purpose/Change: Initial script development

#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
  
  #Set Error Action to Silently Continue
  $ErrorActionPreference = 'SilentlyContinue'
  
  #Import Modules & Snap-ins
  import-module microsoftteams
  Import-Module MSOnline

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#----------------------------------------------------------[Declarations]----------------------------------------------------------
  
  #Authenticate to MSOLservice
  #Create the CSOnline Session
    function Connect-To-Services {
       
        Begin {
            Write-Host "Create the CSOnline Session and authenticate to MSOnline"
            Write-Host "Input Credentials"
          }
        
        Process {  
        $cred = Get-Credential
        }

        End {
        $Session = New-CsOnlineSession -Credential $cred -Verbose
        Import-PSSession $Session -AllowClobber 
        Connect-MsolService -Credential $cred  
        }   
    }

  
#-----------------------------------------------------------[Functions]------------------------------------------------------------
  
  Function Show-Menu {
    Param (
        [String]$Title = "Menu"
    )
  
    Begin {
      Write-Host "================ Chose Option ================"
      Write-Host ""
      Write-Host "1: Press '1' to load CSV file"
      Write-Host "2: Press '2' to show loaded CSV file"
      Write-Host "3: Press '3' to show available licenses"
      Write-Host "4: Press '4' to set base phone number"
      Write-Host "5: Press '5' to assign licenses to users"
      Write-Host "6: Press '6' to set user extensions"
      Write-Host "7: Press '7' to show user properties"
      Write-Host "q: Press 'q' to quit"
    }
  
    Process {
      
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
        '1' {
            'You chose to load CSV file'
            Load-File
        } 
        '2' {
            'You chose to show loaded CSV file'
            Show-File
        } 
        '3' {
            'You chose to show available licenses'
            Show-Licenses
        } 
        '4' {
            'You chose to set base phone number'
            Set-Number
            
        } 
        '5' {
            'You chose to assign licenses to users'
            Assign-Licenses
        } 
        '6' {
            'You chose to set user extensions'
            Set-Users
        } 
        '7' {
            'You chose to show user properties'
            Get-Users
        } 
        
        'q' {
            return
        }
    }
      
    }
  
    End {
      If ($?) {
        Write-Host 'Completed Successfully.'
        Write-Host ' '
      }
    }
  }
    
  Function Load-File {
      
    Begin {
      Write-Host 'Loading CSV File'
    }
  
    Process {
      Try {
        #File prompt to select the userlist txt file
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
        $OFD = New-Object System.Windows.Forms.OpenFileDialog
        $OFD.filter = "CSV File(s)|*.csv"
        $OFD.ShowDialog() | Out-Null
        $OFD.filename

        If ($OFD.filename -eq '')
            {
            Write-Host "You did not choose a file. Try again" -ForegroundColor White -BackgroundColor Red
            }

        $list = Import-CSV $OFD.filename -Delimiter ";"

      }
  
      Catch {
        Write-Host -BackgroundColor Red "Error: $($_.Exception)"
        Break
      }
    }
  
    End {
      If ($?) {
        Write-Host 'Completed Successfully.'
        Write-Host ' '
        Write-Host -NoNewLine 'Press any key to continue...';
        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
        Show-Menu
      }
    }
  }
  
  Function Show-File {
    Begin {
        Write-Host 'Showing CSV File'
      }
    
      Process {
        Try {
          $list | Out-GridView
        }
    
        Catch {
          Write-Host -BackgroundColor Red "Error: $($_.Exception)"
          Break
        }
      }
    
      End {
        If ($?) {
          Write-Host 'Completed Successfully.'
          Write-Host ' '
          Write-Host -NoNewLine 'Press any key to continue...';
          $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
          Show-Menu
        }
      }
  }
  
  Function Show-Licenses {
    Begin {
        Write-Host 'Showing available Licenses'
      }
    
      Process {
        Try {
            Get-MsolAccountSku | Where-Object {$_.skuPartNumber -eq "MCOEV"} | Select -Property AccountSkuId, ActiveUnits,ConsumedUnits

        }
    
        Catch {
          Write-Host -BackgroundColor Red "Error: $($_.Exception)"
          Break
        }
      }
    
      End {
        If ($?) {
          Write-Host 'Completed Successfully.'
          Write-Host ' '
          Write-Host -NoNewLine 'Press any key to continue...';
          $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
          Show-Menu
        }
      }
  }

  Function Set-Number {
    Begin {
        Write-Host 'Setting base phone number'
      }
    
      Process {
        Try {
            $number = Read-Host "Please input phone number (ex: +4152543)"
        }
    
        Catch {
          Write-Host -BackgroundColor Red "Error: $($_.Exception)"
          Break
        }
      }
    
      End {
        If ($?) {
          Write-Host $number
          Write-Host 'Completed Successfully.'
          Write-Host ' '
          Write-Host -NoNewLine 'Press any key to continue...';
          $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
          Show-Menu
        }
      }
  }

  Function Assign-Licenses {
    Begin {
        Write-Host 'Assigning Licenses to users'
      }
    
      Process {
        Try {
            $list | ForEach-Object {
               # Get-CsOnlineUser -Identity $($_.User) | Set-CsUser -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI "tel:$number($_.Extension)" 
               # Get-CsOnlineUser -Identity $($_.User) | Grant-CsOnlineVoiceRoutingPolicy -PolicyName "Sunrise Unlimited"
               Write-Host "Assiging user: $($_.User) the Microsoft 365 Phone System license: SIGITGlobal:MCOEV"
               Set-MsolUserLicense -UserPrincipalName $($_.User) -AddLicenses "SIGITGlobal:MCOEV" 
            }
        }
    
        Catch {
          Write-Host -BackgroundColor Red "Error: $($_.Exception)"
          Break
        }
      }
    
      End {
        If ($?) {
          Write-Host 'Completed Successfully.'
          Write-Host ' '
          Write-Host -NoNewLine 'Press any key to continue...';
          $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
          Show-Menu
        }
      }
  }

  Function Set-Users {
    Begin {
        Write-Host 'Assigning extensions to users'
      }
    
      Process {
        Try {
            $list | ForEach-Object {

                Write-Host "Assiging user: $($_.User) the the extension $($_.Extension), final number: $number$($_.Extension)"


                Grant-CsOnlineVoiceRoutingPolicy -Identity $($_.User) -PolicyName "Sunrise Unlimited"
                #Set-CsOnlineApplicationInstance -Identity $($_.User) -OnpremPhoneNumber "$number$($_.Extension)"
                Get-CsOnlineUser -Identity $($_.User) | Set-CsUser -EnterpriseVoiceEnabled $true -HostedVoiceMail $true -OnPremLineURI "tel:$number$($_.Extension)" 
                #Get-CsOnlineUser -Identity  | Grant-CsOnlineVoiceRoutingPolicy -PolicyName "Sunrise Unlimited"

                
            }
        }
    
        Catch {
          Write-Host -BackgroundColor Red "Error: $($_.Exception)"
          Break
        }
      }
    
      End {
        If ($?) {
          Write-Host 'Completed Successfully.'
          Write-Host ' '
          Write-Host -NoNewLine 'Press any key to continue...';
          $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
          Show-Menu
        }
      }
  }

  Function Get-Users {
    Begin {
        Write-Host 'Showing user properties'
        $csuser = @()
        $msoluser = @()


      }
    
      Process {
        Try {
            $list | ForEach-Object {
            $csuser += Get-CsOnlineUser -Identity $($_.User) | Select-Object DisplayName,UserPrincipalname,OnPremLineUri,OnlineVoiceRoutingPolicy,TeamsUpgradeEffectiveMod 
            $msoluser += Get-MsolUser -UserPrincipalName $($_.User) | Select-Object DisplayName,Licenses 
                }
          $csuser | Out-GridView
          $msoluser | Out-GridView
            }
            
    
        Catch {
          Write-Host -BackgroundColor Red "Error: $($_.Exception)"
          Break
        }
      }
    
      End {

        If ($?) {
          Write-Host 'Completed Successfully.'
          Write-Host ' '
          Write-Host -NoNewLine 'Press any key to continue...';
          $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
          Show-Menu
        }
      }
  }
  #-----------------------------------------------------------[Execution]------------------------------------------------------------
  
  Connect-To-Services
  Show-Menu
  #Script Execution go7es here