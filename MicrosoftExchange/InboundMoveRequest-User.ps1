#Using an Exchange server 2013
#CrossForest миграции почтового ящика 1 пользователя
$localCredentials = Get-Credential

$RemoteCredentials = Get-Credential

$trdb = "Mailbox1"
$rexch = "ex-001.remote.corp"
$trdomain = "remote.ru"

cd "C:\Program Files\Microsoft\Exchange Server\V15\Scripts"

#Запуск с локального сервера. Inbound Миграция
New-MoveRequest -Identity TestUser -TargetDatabase $trdb -Remote -Remotehostname $rexch `
 -RemoteCredential $RemoteCredentials -TargetDeliverydomain $trdomain -BadItemLimit 200 -AcceptLargeDataLoss -LargeItemLimit 50