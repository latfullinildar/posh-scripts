#Using an Exchange server 2013
#CrossForest миграции почтового ящика 1 пользователя
$localCredentials = Get-Credential

$RemoteCredentials = Get-Credential

cd "C:\Program Files\Microsoft\Exchange Server\V15\Scripts"

#Запуск с локального сервера. Inbound Миграция
New-MoveRequest -Identity TestUser -TargetDatabase "Mailbox1" -Remote -Remotehostname ex-001.remote.corp `
 -RemoteCredential $RemoteCredentials -TargetDeliverydomain remote.ru -BadItemLimit 200 -AcceptLargeDataLoss -LargeItemLimit 50