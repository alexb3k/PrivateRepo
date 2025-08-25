``` powershell
$computerName = $env:COMPUTERNAME
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$bios = Get-CimInstance -ClassName Win32_BIOS
$cpu = Get-CimInstance -ClassName Win32_Processor
$ram = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB
$disk = (Get-CimInstance -ClassName Win32_DiskDrive | Measure-Object -Property Size -Sum).Sum / 1GB

# TPM check
$tpm = Get-WmiObject -Namespace "Root\CIMv2\Security\MicrosoftTpm" -Class Win32_Tpm -ErrorAction SilentlyContinue

# Secure Boot check
$secureBoot = $false
try {
    $sb = Confirm-SecureBootUEFI -ErrorAction Stop
    $secureBoot = $sb
} catch {}

# Extract Intel generation
$intelGen = if ($cpu.Name -match '(\d{1,2})(?:th Gen)? Intel\(R\) Core\(TM\) i[3579]-\d+') {
    $matches[1]
} elseif ($cpuName -match 'i[3579]-([0-9]{4,5})') {
    $modelNum = $matches[1]
    if ($modelNum.Length -eq 4) {
        $modelNum.Substring(0,1)
    } elseif ($modelNum.Length -eq 5) {
        $modelNum.Substring(0,2)
    } else {
        "Unknown"
    }
} else {
    "Unknown"
}

[PSCustomObject]@{
    Name            = $computerName
    OperatingSystem = $os.Caption
    OSBuild         = $os.BuildNumber
    SerialNumber    = $bios.SerialNumber
    Processor       = $cpu.Name
    IntelGeneration = $intelGen
    ProcessorCores  = $cpu.NumberOfCores
    ProcessorSpeedGHz = [math]::Round($cpu.MaxClockSpeed / 1000, 2)
    RAM_GB          = [math]::Round($ram, 2)
    Disk_GB         = [math]::Round($disk, 2)
    TPM_Present     = if ($tpm) { $true } else { $false }
    TPM_Version     = if ($tpm) { $tpm.SpecVersion } else { "N/A" }
    SecureBoot      = $secureBoot
    MeetsWin11RAM   = ($ram -ge 4)
    MeetsWin11Disk  = ($disk -ge 64)
    MeetsTPM        = ($tpm -and ($tpm.SpecVersion -match "2\.0"))
    MeetsSecureBoot = $secureBoot
}
```