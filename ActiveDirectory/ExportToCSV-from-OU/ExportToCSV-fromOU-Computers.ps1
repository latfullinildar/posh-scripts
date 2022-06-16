#Скрипт предназначен для выгрузки пользователй в CSV файл
#Можно запусать с любого компьютера, но должен быть доступен домен контролер

#Вводим область поиска, или DistinguisgedName
$sb = "OU=test,DC=example,DC=corp"

# Импортируем модуль Active Directory
Import-Module ActiveDirectory

#Вводим данные для авторизации
$RemoteCredentials = Get-Credential

#Вводим нзавание удаленного сервера
$remotedc = Read-Host "Please, enter remote server FQDname"
#Проверяем есть ли папка computers, если нет создаем
if(!(Test-Path $PSScriptRoot\computers)){
        New-Item -Path $PSScriptRoot\computers -ItemType Directory
    }

#Получаем список OU, необходимо указать параметр SearchBase
$root_ou = @(Get-ADOrganizationalUnit -Credential $RemoteCredentials -Filter 'Name -like "*"' -SearchBase $sb -Server $remotedc )
#Можно использовать select dnshostname 
$root_ou.ForEach({Get-ADComputer -Credential $RemoteCredentials -Filter {ObjectClass -eq "Computer"} -SearchBase $_.DistinguishedName -Server $remotedc  |select name | Export-Csv -NoTypeInformation -Encoding UTF8 -Path "$PSScriptRoot\computers\computers_$_.Name.csv"})
