<#$OU = "OU=LAPTOPS,OU=ENDPOINTS,OU=KAU,OU=DEVICES,OU=CORP.SOLVIASONE,DC=corp,DC=solviasone,DC=com"

Get-ADComputer -SearchBase $OU -SearchScope Subtree <#-Filter {
    OperatingSystem -like "*Windows 10*" -and
    Name -notlike "*SO-W*" # Exclude workstations by name pattern 
} #> <#-Property Name,OperatingSystem | Where-Object {
    $_.OperatingSystem -like "*Windows 10*" -and
    $_.Name -notmatch "SO-W" # Exclude workstations by name pattern
} | Select-Object Name,OperatingSystem #>

$OU = "OU=LAPTOPS,OU=ENDPOINTS,OU=KAU,OU=DEVICES,OU=CORP.SOLVIASONE,DC=corp,DC=solviasone,DC=com"

$computers = Get-ADComputer -SearchBase $OU -SearchScope Subtree -Filter * -Property Name,OperatingSystem

$results = foreach ($computer in $computers) {
    $serial = ""
    try {
        $wmi = Get-WmiObject -Class Win32_BIOS -ComputerName $computer.Name -ErrorAction SilentlyContinue
        if ($wmi) { $serial = $wmi.SerialNumber }
    } catch {}
    [PSCustomObject]@{
        Name           = $computer.Name
        OperatingSystem = $computer.OperatingSystem
        SerialNumber    = $serial
    }
    Write-Host "$computer.Name ; $computer.OperatingSystem ; $serial "
}

$results | Export-Csv -Path "C:\Temp\DeviceList.csv" -NoTypeInformation