 
$vms = (Get-VM -Name test-sfb)
$hostName = "sr-gen9-01"
$storagePath = "D:\"
 
Foreach ($vm in $vms) {
$namevm = $vm.Name
$storagename = $storagePath + $namevm
New-Item -ItemType Directory -Force -Path $storagename
Move-VMStorage -ComputerName $hostName `
               -DestinationStoragePath $storagename `
               -VMName $namevm
}