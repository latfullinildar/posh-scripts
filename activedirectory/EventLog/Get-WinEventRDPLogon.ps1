Get-WinEvent -FilterHashtable @{Logname='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational';ID=22}| %{
    ([PSCustomObject]@{
        UserName = $_.Message -replace '(?smi).*User:\s+([^\s]+)\s+.*','$1';
        Network = $_.Message -replace '(?smi).*Source Network Address:\s+([^\s]+)\s+.*','$1'
        })
} |Export-CSV -Path $PSSCriptroot\rds-logs-DC.csv -Delimiter ";" -Encoding UTF8 -NoTypeInformation -Append