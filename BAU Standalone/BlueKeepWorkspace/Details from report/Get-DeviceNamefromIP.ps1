$list = gc "C:\Users\RO10029\OneDrive - SIG\zzz.CODE\BlueKeepWorkspace\Details from report\VulnerableIPList.txt"

foreach ($ip in $list) 
{   
    ping -a $ip >> "C:\Users\RO10029\OneDrive - SIG\zzz.CODE\BlueKeepWorkspace\Details from report\Names.txt"
}

