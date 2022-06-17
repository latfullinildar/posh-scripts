<# Скрипт наверно мало кому пригодится, специфичные условия.
Назначение: создание почтовых ящиков по разным базам данных Exchange в зависимости от OrganizationUnit в AD
с условием вхождения в определенную группу для автоматического создания почтового ящика, для исключение создание почтовых ящиков всех учетных записей
Используются значение пара $enableMailboxOUs: OU  - бд Exchange
Используется LDAP фильтр $FilterOUs: OU  - AD group
#>
$enableMailboxOUs = @{
	"OU=Department1,DC=example,DC=corp" = "MailboxF1"
	"OU=Department2,DC=example,DC=corp" = "MailboxF2"
	"OU=Department3,DC=example,DC=corp" = "MailboxF3"
}

$FilterOUs = @{
    "OU=Department1,DC=example,DC=corp" = "memberOf:1.2.840.113556.1.4.1941:=CN=AutoEnableExchangeMailboxF1,DC=example,DC=corp"
	"OU=Department2,DC=example,DC=corp" = "memberOf:1.2.840.113556.1.4.1941:=CN=AutoEnableExchangeMailboxF2,DC=example,DC=corp"
	"OU=Department3,DC=example,DC=corp" = "memberOf:1.2.840.113556.1.4.1941:=CN=AutoEnableExchangeMailboxF3,DC=example,DC=corp"
}


# шаблоны логинов пользователей, которые будут игнорироваться при включении почтового ящика
$ignoreUserPatterns = @{
    'SamAccountName' = @(
        "^_",
        "test",
        "taxnet",
        "ReaderOIK",
		"^unit",
		"^iBank$",
		".*[-,_].*"
    )
	'Description' = @('for Address book')
}

# каталог логов
$logFolder = "$PSScriptRoot\logs"

# длительность хранения логов
$log_history_days = 60

# имя лог файла
$logFilename = "$logFolder\$((Get-Date).ToString('yyyyMMdd')).log"


# функция для игнорирования пользователей
function Get-IgnoreFlag {
    [CmdletBinding()]
    param (
        [Microsoft.ActiveDirectory.Management.ADUser]$user
    )
    $flag = $false
    # для каждого шаблона проверяем соответствие
    foreach($key in $ignoreUserPatterns.Keys){
        foreach($pattern in $ignoreUserPatterns.Item($key)){
            # если соответствует хотя бы одному шалону, то возвращаем $true
            if($User[$key] -match $pattern){
                $flag = $true
                break
            }
        }
    }
    $flag
}

# функция для записи в лог
function Write-Log {
    [CmdletBinding()]
    param (
        [string]$Message,
        [Parameter()]
        [ValidateSet('INFO','WARNING','ERROR')]
        [string]$Level
    )
    $LogLine = "$((Get-date).ToString('yyyy-MM-ddTHH:mm:ss')) [$Level] $Message"
    $LogLine | Out-File $logFilename -Append -NoClobber -Encoding utf8
}

# Если папка для логов не существует, создаем её
if(!(Test-Path $logFolder -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $logFolder
}

Write-Log -Level INFO -Message "Script started"


# подключаем модуль для работы c Exchange
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn    # Exchange 2013
#Add-PSsnapin Microsoft.Exchange.Management.PowerShell.E2010    # Exchange 2010


Write-Log -Level INFO -Message "Start enabling mailboxes"
# подключаем почтовый ящик включенным пользователям
$enableMailboxOUs.Keys | ForEach-Object {
    try {
		$ou = $_
        $db_name = $enableMailboxOUs[$ou]
        $F = $FilterOUs[$ou]
        # находим в контейнере активных пользователей
        Get-ADUser -Properties Mail,Description `
			-LDAPFilter "(&(!mail=*)(!userAccountControl:1.2.840.113556.1.4.803:=2)($F))" `
            -SearchScope Subtree | Sort-Object SamAccountName | ForEach-Object {
                $adUser = $_
                # проверяем, нужно ли игнорировать пользователя
                $ignore = Get-IgnoreFlag -User $adUser
                if(!$ignore)
                {
                    #"enable: $($adUser.UserPrincipalName)"
					
                    Write-Log -Level INFO -Message "Enabling mailbox for user '$($adUser.SamAccountName)'"
                    Enable-Mailbox $adUser.UserPrincipalName -Database $db_name -Confirm:$false
                }
		        else
		        {
		            Write-Log -Level INFO -Message "Ignoring user '$($adUser.SamAccountName)'"    
		        }
            }
    }
    catch {
        Write-Log -Level ERROR -Message "$($_.Exception.Message)"
    }
}
Write-Log -Level INFO -Message "Script finished"

# удаление старых логов

Get-ChildItem "$logFolder\*.log" | Where-Object { $_.LastWriteTime.AddDays($log_history_days) -lt (Get-Date) } | Remove-Item
