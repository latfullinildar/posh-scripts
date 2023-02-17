#Скрипт для парсера логов по событию 4624, Тип логона 10
#Добавить за сутки -after (Get-date -hour 0 -minute 0 -second 0)
$serv = "dc002"

foreach ($srv in $serv) {
Get-EventLog -ComputerName $srv -Logname security -After (Get-Date).AddDays(-1)| ?{$_.EventID -eq 4624 -and $_.Message -match 'Тип входа:\s+(10)\s'}| %{
    (new-object -Type PSObject -Property @{
        TimeGenerated = $_.TimeGenerated
        ClientIP = $_.Message -replace '(?smi).*Сетевой адрес источника:\s+([^\s]+)\s+.*','$1'
        UserName = $_.Message -replace '(?smi).*Имя учетной записи:\s+([^\s]+)\s+.*','$1'
        UserDomain = $_.Message -replace '(?smi).*Домен учетной записи:\s+([^\s]+)\s+.*','$1'
        LogonType = $_.Message -replace '(?smi).*Тип входа:\s+([^\s]+)\s+.*','$1'
        UserSid = $_.Message -replace '(?smi).*ИД безопасности:\s+([^\s]+)\s+.*','$1'
        })
} |Export-CSV -Path $PSScriptRoot\rds-logs.csv -Delimiter ";" -Encoding UTF8 -NoTypeInformation -Append
}#foreach