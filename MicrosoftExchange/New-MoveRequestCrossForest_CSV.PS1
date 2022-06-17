#миграция почтовых ящиков
#авторизация в локальном AD
$localCredentials = Get-Credential

#авторизация в удаленном AD
$RemoteCredentials = Get-Credential

#путь к файлу csv
$csv_users = (Import-CSV "C:\migration\migration_csv\users_AHO.csv") 

#удаленный хост Exchange
$remote_host = "ex-01.remote.corp"

#локальная база exchange
$db_exch = "MailboxF1"

#локальный домен smtp
$destinat_domain = "example.ru"

# каталог логов
$logFolder = "C:\migration\migration_csv\logs"

# имя лог файла
$logFilename = "$logFolder\$((Get-Date).ToString('dd-MM-yyyy')).log"

function Write-Log
{
    [CmdletBinding()]
    param (
        [string]$Text
    )
    #$lines = @($Text)
    #$Encoding = New-Object System.Text.ASCIIEncoding #$False
    #[System.IO.File]::AppendAllLines([string]$logFilename, [string[]]$lines, $Encoding)
    $Text | Out-File $logFilename -Append -NoClobber -Encoding utf8
}

# подключаем модуль для работы c Exchange 2013
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
# подключаем модуль для работы c Exchange 2010
#Add-PSsnapin Microsoft.Exchange.Management.PowerShell.E2010

#переходим в папку с скриптами Exchange
cd "C:\Program Files\Microsoft\Exchange Server\V15\Scripts"


$csv_users | % {
    try
    {
        New-MoveRequest `
            -TargetDatabase = $db_exch `
            –Remote `
            –Remotehostname = $remote_host `
			-RemoteCredential = $RemoteCredentials `
			–TargetDeliverydomain = $destinat_domain
    }
    catch
    {
        Write-Log -Text "[$(Get-Date)] Error: $($_.Exception.Message)"
    }
}