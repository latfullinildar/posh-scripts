#Скрипт для массовой подготовки к перемещению почтовых ящиков между лесами ActiveDirectory
#авторизация в локальном AD
$localCredentials = Get-Credential

#авторизация в удаленном AD
$RemoteCredentials = Get-Credential

$TargetOU = "OU=Container for test,DC=local,DC=corp"
#путь к файлу csv
$csv_users = (Import-CSV "C:\migration\users_1.csv") 

#удаленный хост Exchange
$remote_host = "ex-001.remote.corp"
#удаленный контролер
$remote_dc = "dc-001.remote.corp"
#локальный контролер
$local_dc = "dc-002.local.corp"

#локальная база exchange
$db_exch = "Mailbox1"

#локальный домен smtp
$destinat_domain = "example.ru"

# каталог логов
$logFolder = "C:\migration\logs"

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
        .\Prepare-MoveRequest.Ps1 `
			-RemoteForestDomainController = $remote_dc `
			-RemoteForestCredential = $RemoteCredentials `
			-LocalForestDomainController =  $local_dc `
			-LocalForestCredential = $LocalCredentials `
			-TargetMailUserOU = $TargetOU `
			–UseLocalObject -Verbose
    }
    catch
    {
        Write-Log -Text "[$(Get-Date)] Error: $($_.Exception.Message)"
    }
}