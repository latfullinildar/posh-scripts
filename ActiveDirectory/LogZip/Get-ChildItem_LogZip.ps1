#Читай README
#каталог с логами
$logFolder = "C:\Logs\*"
$include=@("*.zip")
#ищем логи, с датой старше 1 дня и больше 30 мб
$logs = Get-ChildItem -Path $logFolder -Recurse -Include *.log | Where-Object -FilterScript {($_.LastWriteTime -lt (Get-Date).adddays(-1)) -and ($_.Length -ge 30mb)}
#сжимаем найденные логи и удаляем файл с расширением .log
foreach ($log in $logs) {
    #$logfullname = $log.FullName
    #$logname = $log.Name
    #$log.FullName
    try {
            $lfname = $log.FullName
            $lname = $log.Name
            $compress = @{
            LiteralPath = "$lfname"
            CompressionLevel = "Fastest"
            DestinationPath = "C:\Logs\$lname.zip"
            }
        Compress-Archive @compress
        Remove-Item $lfname
    }
    catch{
        Write-error $($_.Exception.message)
    }
}
# удаляем старые логи, больше дней указанных в переменной, и имя не содержит слово "archive"
$cutoffDays = 30
Get-ChildItem -Path $logFolder -Include $include | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(0 - $cutoffDays) -and $_.Name -notmatch "archive" } | Remove-Item -WhatIf