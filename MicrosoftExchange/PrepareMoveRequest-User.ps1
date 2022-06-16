#Using an Exchange server 2013
#Подготовка пользователей в домене для CrossForest миграции почтового ящика
#Создание почтовых контактов в целевом домене
$localCredentials = Get-Credential

$RemoteCredentials = Get-Credential

cd "C:\Program Files\Microsoft\Exchange Server\V15\Scripts"

#Единичная подготовка почтового ящика
.\Prepare-MoveRequest.Ps1 -Identity Guest1@remote.ru -RemoteForestDomainController dc01.remote.corp -RemoteForestCredential $RemoteCredentials `
 -LocalForestDomainController dc05.local.corp -LocalForestCredential $LocalCredentials `
 -TargetMailUserOU "OU=TargetOU,DC=local,DC=corp"`
 -UseLocalObject -Verbose
