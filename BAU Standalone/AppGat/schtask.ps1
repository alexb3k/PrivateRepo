$trigger = New-ScheduledTaskTrigger -AtLogon
$user = $($env:UserName)
$action = New-ScheduledTaskAction -Execute "C:\Users\%username%\SIG\app.GAT - Documents\gat\gat-watcher-script\Run_App.cmd"
$principal = New-ScheduledTaskPrincipal -UserId "$user" -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries -StartWhenAvailable -DontStopOnIdleEnd -RestartCount 5 -Priority 7 

Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -TaskName "AppGAT" -Description "Test" -Principal $principal