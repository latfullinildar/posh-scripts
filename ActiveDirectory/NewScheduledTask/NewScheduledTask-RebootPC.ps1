#Скрипт для создания задания на перезагрузку хоста по планировщику, разовый
#New-ScheduledTaskTrigger -At 23:45 -Once
#New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 03.00
#функция для записи в лог

#каталог для логов
$logFolder = "$PSScriptRoot\logs"
# имя лог файла,ежедневный
$logFilename = "$logFolder\$((Get-Date).ToString('yyyyMMdd')).log"
#функция записи логов
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
Write-Log -Level INFO -Message "Script New-ScheduledTask started"
#("dc001","dc002","dc003",)
#задаем имя (имена) серверов
$PCs = @("dc001","dc002","dc003")
$time = '22:00'
#$TaskName = "Restart computer 03.00 AM"
#$Trigger= New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 03:00
$TaskName = "Restart computer once"
$Trigger= New-ScheduledTaskTrigger -At $time -Once
$User= "NT AUTHORITY\SYSTEM"
$Action= New-ScheduledTaskAction `
    -Execute "PowerShell.exe" `
    -Argument '-ep Bypass -NoProfile -WindowStyle Hidden -command "& {Restart-Computer -Force}"'
#Register-ScheduledTask -TaskName "StartupScript_PS" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force
foreach ($PC in $PCs) {
    Register-ScheduledTask -CimSession $PC -TaskName $TaskName -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force
    Write-Log -Level INFO -Message "New ScheduledTask $TaskName created for $PC in $time"
    }

