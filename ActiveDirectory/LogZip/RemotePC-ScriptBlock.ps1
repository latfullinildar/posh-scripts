#remote servers
$Dcs = Import-CSV "$PSScriptRoot\dc.txt"

ForEach ($dc in $Dcs) {
     
    try {
        #Invoke-Command -ComputerName $dc.Name -ScriptBlock {Get-UICulture}
        Invoke-Command -ComputerName $dc.Name -FilePath "$PSScriptRoot\Get-ChildItem_LogZip.ps1"
    }
    catch{
    Write-error $($_.Exception.message)
    }
}