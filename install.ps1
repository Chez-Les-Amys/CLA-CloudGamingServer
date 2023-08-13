# Déclaration des variables
$cardName = ""
$vnName = ""
$vmRAM = 0
$vmProc = 0
$vmSpaceDisk = 0


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
cls
(Get-NetAdapter -physical | where status -eq 'up').name
$cardName = Read-Host "Veuillez inscrir le nom de votre carte reseau. Par defaut 'Ethernet' "
if ($cardName -eq ""){ $cardName = "Ethernet"}
$tt = (Get-NetAdapter -physical | where status -eq 'up').name
    foreach ($name in $tt) 
    { 
        if ($name -eq "$cardName") { 
    
            New-VMSwitch -Name "External"  -NetAdapterName "$cardName" }
        else {
    
            Write-Host "Le reseau '$cardName' n'existe pas, merci de verifié le nom ci-apres et recommencer la procédure."
            (Get-NetAdapter -physical | where status -eq 'up').name
        }
    }
cls
# Préparation de la création de la VM
## Demande de la quantité RAM
cls
for ($i=0 ;$i -le 0){
    if ($vmName  -eq ""){$vmName = Read-Host "Veuillez choisir un nom pour la VM"}else {
    $i++ } 
}
Do { $vmRAM = Read-host "Choix de la quantité de la RAM en GB ( de 4 à 32GB ) "} 
while ((4..32) -notcontains $vmRAM)

## Demande de la quantité CPU
cls
$vmProcget = (Get-WmiObject –class Win32_processor).NumberOfLogicalProcessors
$vmProcMax = $vmProcget-2
Do { $vmProc = Read-host "Choix de la quantité du processeur de 2 à $vmProcMax "} 
while ((4.."$vmProcMax") -notcontains $vmProc)

## Demande de la quantité HDD
cls
write-host "Mes lettre de mes disques " 
$driveLetter = (Get-PSDrive).Name -match '^[a-z]$'
$driveLetter
$getDiskLetterByUser = Read-host "Merci de choisir votre lecteur pour le disk de la VM" 

 foreach ($letter in $driveLetter) 
    { if ($getDiskLetterByUser -eq "$letter") { 
        $getDiskFreeSpace = (Get-PSDrive $getDiskLetter).Free
        $getDiskFreeSpaceinGB = [math]::Floor($getDiskFreeSpace /1GB)
       
        Do { $vmSpaceDisk = Read-host "Choix de la quantité du HDD en GB ( de 25 à ""$getDiskFreeSpaceinGB""GB) "} 
        while ((25..$getDiskFreeSpaceinGB) -notcontains $vmSpaceDisk)



      }
    }




## Création de la VM
cls
New-VM -Name "$vmName" -Path "$getDiskLetterByUser:\VM" -MemoryStartupBytes "$vmRAM" -NewVHDPath "$getDiskLetterByUser:\VM\$vmName\$vmName.vhdx" -NewVHDSizeBytes "$vmSpaceDisk"GB -Generation 2 -Switch "External" -BootDevice NetworkAdapter
Set-VM -Name "$vmName" -ProcessorCount $vmProc -CheckpointType Disabled

## Get Graphic card
$gpuCardBrand = (Get-WmiObject Win32_VideoController).AdapterCompatibility
if ($gpuCardBrand -eq "NVIDIA"){"download this file"}
if ($gpuCardBrand -eq "AMD"){"download this file"}
### Windows 10 super-light
#### Package FR
#### Steam cla
#### Suchine Host Gaming + Custom config ( Port + Game - Desktop access )

