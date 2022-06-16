#Using an Exchange server 2013
#CrossForest миграции почтового ящика 1 пользователя.Outbound миграция, когда скрипт заупскается на удаленном сервере, откуда нужно мигрировать почтовый ящик
$localCredentials = Get-Credential

$RemoteCredentials = Get-Credential

cd "C:\Program Files\Microsoft\Exchange Server\V15\Scripts"

#Запуск с исходного сервера. Outbound Миграция
New-MoveRequest -Identity test@remote.ru -Outbound -RemoteTargetDatabase "Mailbox2" -Remotehostname ex-003.target.corp -RemoteCredential $RemoteCredentials `
-TargetDeliverydomain remote.ru -BadItemLimit 200 -AcceptLargeDataLoss