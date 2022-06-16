#Скрипт для изменения DNS на удаленных компьютерах
#Импортируем модуль Active Directory
Import-Module ActiveDirectory

#Вводим область поиска, или DistinguisgedName
$sb = "OU=test,DC=example,DC=corp"

#Ищем компьютеры в AD
$pcs = Get-ADComputer -Filter {ObjectClass -eq "Computer"} -SearchBase $sb -SearchScope Subtree

#Можем взять наименование компьютеров из списка
#$pcs = Import-Csv $PSScriptRoot\pcname.csv

ForEach ($pc in $pcs) {
    Write-Host "Computer $($pc.Name)"
    Invoke-Command -ComputerName $pc.Name -ScriptBlock {
        $NewDnsServerSearchOrder = "10.101.101.10","10.101.101.51"
        $Adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.DHCPEnabled -ne 'True' -and $_.DNSServerSearchOrder -ne $null}
        Write-Host "Old DNS: "
        $Adapters | ForEach-Object {$_.DNSServerSearchOrder}
        $Adapters | ForEach-Object {$_.SetDNSServerSearchOrder($NewDnsServerSearchOrder)} | Out-Null
        $Adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.DHCPEnabled -ne 'True' -and $_.DNSServerSearchOrder -ne $null}
        Write-Host "New DNS: "
        $Adapters | ForEach-Object {$_.DNSServerSearchOrder}
        }
}