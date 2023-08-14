# Déclaration des variables
$cardName = ""
$vnName = ""
$vmRAM = 0
$vmProc = 0
$vmSpaceDisk = 0


# Import the file module needed
. "C:\cla-cg\New-IsoFile.ps1"


## Get Graphic card

$gpuCardBrand = (Get-WmiObject Win32_VideoController).AdapterCompatibility
if ($gpuCardBrand -eq "NVIDIA"){
Write-Host "Your GPU is supported, let's go to start installation"
}
if ($gpuCardBrand -eq "AMD"){
Write-Host "Your GPU is not Support for the moment, sorry. Autoclose in 15sec."
Start-Sleep -Seconds 15 
exit
}



# Check and install if necessary Hyper-v
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
# Check if Hyper-V is enabled
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V is enabled. Continue ..."
} else {
    Write-Host "Hyper-V is not enabled. Install HyperV and after reboot your machine re-lunch this script"
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
New-VM -Name "$vmName" -Path "$getDiskLetterByUser:\VM" -MemoryStartupBytes "$vmRAM" -NewVHDPath "$getDiskLetterByUser:\VM\$vmName\$vmName.vhdx" -NewVHDSizeBytes "$vmSpaceDisk"GB -Generation 2 -Switch "External"
Set-VM -Name "$vmName" -ProcessorCount $vmProc -CheckpointType Disabled

function GpuPreprar(){
        $folderNameUID = Get-ChildItem -Path "C:\Windows\System32\DriverStore\FileRepository\" -Filter nv_dispi* | ForEach-Object -Process {[System.IO.Path]::GetFileName($_)}
        Copy-Item -Path "C:\Windows\System32\DriverStore\FileRepository\$folderNameUID\" -Destination "C:\cla-cg\$gpuCardBrand\System32\HostDriverStore\FileRepository\$folderNameUID" -Recurse
        Copy-Item -Path "C:\Windows\System32\nv*.*" -Destination "C:\cla-cg\$gpuCardBrand\System32\"
        Copy-Item -Path "C:\cla-cg\installgpu.ps1" -Destination "C:\cla-cg\$gpuCardBrand\"
        New-ISOFile -source C:\cla-cg\$gpuCardBrand -destinationIso C:\cla-cg\latest_$gpuCardBrand.iso
        Set-VMDvdDrive -VMName "$vmName" -Path "C:\cla-cg\latest_$gpuCardBrand.iso"
        Start-VM -Name "$vmName"

}

    if (Test-Path "C:\cla-cg\$gpuCardBrand"){
        GpuPreprar
    }else{
        New-Item "C:\cla-cg\$gpuCardBrand\System32" -itemType Directory
        gpuPreprar
    }
