#Скрипт предназначен для выгрузки пользователй в CSV файл, фильтрация только включенные {Enabled -eq $True}, если всех - то ставим *
#Можно запусать с любого компьютера, но должен быть доступен DC

#Вводим область поиска, или DistinguisgedName
$sb = "OU=users,DC=example,DC=corp"

# Импортируем модуль Active Directory
Import-Module ActiveDirectory

#Вводим данные для авторизации
$RemoteCredentials = Get-Credential

#Вводим нзавание удаленного сервера
$remotedc = Read-Host "Please, enter remote server FQDname"
#Если отсутствует папка, то создаем ее
if(!(Test-Path $PSScriptRoot\users)){
        New-Item -Path $PSScriptRoot\users -ItemType Directory
    }

#Получаем список OU, необходимо указать параметр SearchBase
$root_ou = @(Get-ADOrganizationalUnit -Credential $RemoteCredentials -Filter 'Name -like "*"' -SearchBase $sb -Server $remotedc )
$root_ou.ForEach({Get-ADUser -Credential $RemoteCredentials -Filter {Enabled -eq $True} -SearchBase $_.DistinguishedName -Server $remotedc  |select SAMaccountname | Export-Csv -NoTypeInformation -Encoding UTF8 -Path "$PSScriptRoot\users\users_$_.Name.csv"})
