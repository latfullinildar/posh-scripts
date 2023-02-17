#Скрипт для определения DNS сетевых интерфейсов
# Импортируем модуль Active Directory
Import-Module ActiveDirectory

#Вводим область поиска, или DistinguisgedName
$sb = "OU=computers,DC=example,DC=corp"

#Можем взять наименование компьюетров из списка
#$pcs = Import-Csv $PSScriptRoot\pcname.csv


$pcs = Get-ADComputer -Filter {ObjectClass -eq "Computer"} -SearchBase $sb -SearchScope Subtree
Foreach($pc in $pcs){
  Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true -ComputerName $pc.Name |Select-Object -Property DNSServerSearchOrder,DNShostname,DHCPEnabled
 }#Foreach