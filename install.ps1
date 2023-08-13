# Check and install if necessary Hyper-v
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
# Check if Hyper-V is enabled
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V is enabled."
} else {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
}

# After install hyper-v, download pre-request
## Création d'une vm
### Création d'un adapateur reseau externe 
#### Vérification de l'existance du nom
$tt = (Get-NetAdapter -physical | where status -eq 'up').name
foreach ($name in $tt) { if ($name -eq "Ethernet") { New-VMSwitch -Name "External"  -NetAdapterName "Ethernet" }else{
Write-Host "non $name"
(Get-NetAdapter -physical | where status -eq 'up').name


    }
}





New-VM -Name "VM-TEST" -Path "C:\VM" -MemoryStartupBytes 10GB -NewVHDPath "C:\VM\VM-TEST\VM-TEST-C.vhdx" -NewVHDSizeBytes 120GB -Generation 2 -Switch "LAB_RDR" -BootDevice NetworkAdapter
Set-VM -Name "VM-TEST" -ProcessorCount 2 -CheckpointType Disabled

### Windows 10 super-light
#### Package FR
#### Steam cla
#### Suchine Host Gaming + Custom config ( Port + Game - Desktop access )

