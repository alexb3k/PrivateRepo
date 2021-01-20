function BlueKeep {
    param
    (
        [String]
        [Parameter(Mandatory)]
        $IP,
    
        [String]
        [Parameter(Mandatory)]
        $Mask
    )
    
$ErrorActionPreference = "SilentlyContinue"
$fileappendix = get-date -Format s | foreach {$_ -replace ":", ""}
$filename = $env:TEMP + "\nmapRDPScan" + $fileappendix + ".xml"
$nmappath = 'C:\Program Files (x86)\Nmap\nmap.exe'
#$argScanNet = Read-Host "Type Subnet Address. I.e. '10.0.0.0'"
#$argScanMaskbits = Read-Host "Type Mask Bits. I.e. '16'"

& $nmappath `-sS `-p 3389 `-T5 `-n `-`-open `-`-min`-hostgroup 256 `-`-min`-parallelism 100 `-`-max`-rtt`-timeout 300ms `-`-max`-retries 3 `-`-send-eth $IP`/$Mask `-oX $filename

[xml]$nmapRDPScan=Get-Content $filename

$hosts=$nmapRDPScan.selectnodes("//host")
$list = @()
$hosts | foreach {$_.address | foreach {if ($_.addrtype -eq "ipv4") {$hostip = New-Object psobject ; 
    $hostip | Add-Member -MemberType NoteProperty -Name ip -Value $_.addr} }
    $_.ports | foreach {$_.port | foreach {
        $val = New-Object psobject ;
        $val | Add-Member -MemberType NoteProperty -Name Host -Value $hostip.ip
        $val | Add-Member -MemberType NoteProperty -Name Proto -Value $_.protocol
        $val | Add-Member -MemberType NoteProperty -Name Port -Value $_.portid
        $val | Add-Member -MemberType NoteProperty -Name State -Value $_.state.state
        $val | Add-Member -MemberType NoteProperty -Name Service -Value ($_.service.name + " "+$_.service.tunnel)
        $val | Add-Member -MemberType NoteProperty -Name Servicedesc -Value $_.service.product
if ($val.proto -ne "") {$list += $val}
}}}


Write-Host "`r`n--------------`r`nNow testing all nodes with port 3389 open"
Write-Host "Depending on the number of nodes, this can take a considerable amount of time`r`n--------------`r`n"

$list | Where-Object {$_.State -eq "open"} | ft Host -HideTableHeaders | .\rdpscan-windows\rdpscan.exe `-`-file `-

Write-Host "`r`n--------------`r`nScan complete"
Write-Host "You can find more information on each host in the nmap scan XML file"
Write-Host "Location of file:"
Write-Host " $filename`r`n--------------`r`n "
}

BlueKeep -IP 10.14.0.0 -Mask 15 > ECS.txt
BlueKeep -IP 10.16.0.0 -Mask 13 > cConnect.txt
BlueKeep -IP 10.32.0.0 -Mask 12 > Plant360.txt