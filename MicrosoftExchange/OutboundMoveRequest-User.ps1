#Using an Exchange server 2013
#CrossForest миграции почтового ящика 1 пользователя.Outbound миграция, когда скрипт заупскается на удаленном сервере, откуда нужно мигрировать почтовый ящик
$localCredentials = Get-Credential

$RemoteCredentials = Get-Credential

$trdb = "Mailbox1"
$rexch = "ex-001.remote.corp"
$trdomain = "remote.ru"

cd "C:\Program Files\Microsoft\Exchange Server\V15\Scripts"

#Запуск с исходного сервера. Outbound Миграция
New-MoveRequest -Identity test@remote.ru -Outbound -RemoteTargetDatabase $trdb -Remotehostname $rexch -RemoteCredential $RemoteCredentials `
-TargetDeliverydomain $trdomain -BadItemLimit 200 -AcceptLargeDataLoss