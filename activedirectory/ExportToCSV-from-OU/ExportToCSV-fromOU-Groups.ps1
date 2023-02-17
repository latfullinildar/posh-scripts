#Скрипт предназначен для выгрузки пользователй в CSV файл
#Можно запусать с любого компьютера, но должен быть доступен DC

#Вводим область поиска, или DistinguisgedName
$sb = "OU=SecurityGroups,DC=example,DC=corp"

# Импортируем модуль Active Directory
Import-Module ActiveDirectory

#Вводим данные для авторизации
$RemoteCredentials = Get-Credential

#Вводим нзавание удаленного сервера
$remotedc = Read-Host "Please, enter remote server FQDname"

#Если отсутствует папка, то создаем ее
if(!(Test-Path $PSScriptRoot\groups)){
        New-Item -Path $PSScriptRoot\groups -ItemType Directory
    }

#Получаем список OU, необходимо указать параметр SearchBase
$root_ou = @(Get-ADOrganizationalUnit -Credential $RemoteCredentials -Filter 'Name -like "*"' -SearchBase $sb -Server $remotedc )
$root_ou.ForEach({Get-ADGroup -Credential $RemoteCredentials -Filter {ObjectClass -eq "Group"} -SearchBase $_.DistinguishedName -Server $remotedc  |select SAMaccountname | Export-Csv -NoTypeInformation -Encoding UTF8 -Path "$PSScriptRoot\groups\groups_$_.Name.csv"})
