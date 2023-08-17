if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
  $arguments = "& '" +$myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}


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
$checkRequirement = (Get-ComputerInfo -property "HyperV*").HyperVRequirementVirtualizationFirmwareEnabled
# Check if Hyper-V is enabled
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V is enabled. Continue ..."
} else {
    Write-Host "Hyper-V is not enabled. Install HyperV and after reboot your machine re-lunch this script"
    #vérification de la configuration dans le BIOS
    if($checkRequirement){
    try
        {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -ErrorAction Stop
        }
    catch
        {
            # check version Windows and Patch if possible
            $editionWin = (Get-WindowsEdition -Online).edition
            if(($editionWin -eq "core")-or($editionWin -eq "home")){
                Write-Host "You have Windows $editionWin, this edition needed patch for install Hyper-V"
                Start-Process "C:\cla-cg\Hyper-V-Enabler.bat"

}  
        }
    }else{
    #Vérification si $checkRequirement est vide, alors on vérifie que HYPER-V est activé d'une autre maniere
      if($checkRequirement -eq $empty ){
        Write-Host "Hyper-V already seems to be active in a second test, so let's try creating a VM."
        Start-Sleep -Seconds 5
      }else{
        Write-Host "Virtualization options must be enabled in the BIOS"
        Write-Host "Your GPU is not Support for the moment, sorry. Autoclose in 15sec."
        Start-Sleep -Seconds 15
        exit
      }
    }
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
    if (($vmName  -eq "")-or($vmName  -eq  $empty)){$vmName = Read-Host "Veuillez choisir un nom pour la VM"}else {
    $i++ } 
}



$totalPhysicalRam = ((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb) - 4

Do { $vmRAM = Read-host "Select quantity Ram for VM. Recommend 4GB minimal, if your system as 8GB ( to 4GB as " + $totalPhysicalRam + "GB ) "} 
while ((4..$totalPhysicalRam) -notcontains $vmRAM)




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
        $getDiskFreeSpace = (Get-PSDrive $getDiskLetterByUser).Free
        $getDiskFreeSpaceinGB = [math]::Floor($getDiskFreeSpace /1GB)
       
        Do { $vmSpaceDisk = Read-host "Choix de la quantité du HDD en GB ( de 25 à " + $getDiskFreeSpaceinGB + "GB) "} 
        while ((25..$getDiskFreeSpaceinGB) -notcontains $vmSpaceDisk)



      }
    }


$vmSpaceDisk1 = [int64]$vmSpaceDisk * 1GB
$vmRAMRH = [int64]$vmRAM * 1GB
$fullPath = $getDiskLetterByUser + ":\VMs"

## Création de la VM
cls
New-VM -Name "$vmName" -Path "$fullPath" -MemoryStartupBytes "$vmRAMRH" -NewVHDPath "$fullPath\$vmName\$vmName.vhdx" -NewVHDSizeBytes "$vmSpaceDisk1" -Generation 2 -Switch "External"
Set-VM -Name "$vmName" -ProcessorCount $vmProc -CheckpointType Disabled
Add-VMDvdDrive -VMName "$vmName"

function GpuPreprar(){
        $folderNameUID = Get-ChildItem -Path "C:\Windows\System32\DriverStore\FileRepository\" -Filter nv_dispi* | ForEach-Object -Process {[System.IO.Path]::GetFileName($_)}
        Copy-Item -Path "C:\Windows\System32\DriverStore\FileRepository\$folderNameUID\" -Destination "C:\cla-cg\$gpuCardBrand\System32\HostDriverStore\FileRepository\$folderNameUID" -Recurse
        Copy-Item -Path "C:\Windows\System32\nv*.*" -Destination "C:\cla-cg\$gpuCardBrand\System32\"
        Copy-Item -Path "C:\cla-cg\installgpu.ps1" -Destination "C:\cla-cg\$gpuCardBrand\"
        New-ISOFile -source "C:\cla-cg\$gpuCardBrand" -destinationIso "C:\cla-cg\latest_$gpuCardBrand.iso"  -Force
        Set-VMDvdDrive -VMName "$vmName" -Path "C:\cla-cg\latest_$gpuCardBrand.iso"
        

}

    if (Test-Path "C:\cla-cg\$gpuCardBrand"){
        GpuPreprar
    }else{
        New-Item "C:\cla-cg\$gpuCardBrand\System32" -itemType Directory
        gpuPreprar
    }


Add-VMGpuPartitionAdapter -VMName $vmName
Set-VMGpuPartitionAdapter -VMName $vmName -MinPartitionVRAM 80000000 -MaxPartitionVRAM 100000000 -OptimalPartitionVRAM 100000000 -MinPartitionEncode 80000000 -MaxPartitionEncode 100000000 -OptimalPartitionEncode 100000000 -MinPartitionDecode 80000000 -MaxPartitionDecode 100000000 -OptimalPartitionDecode 100000000 -MinPartitionCompute 80000000 -MaxPartitionCompute 100000000 -OptimalPartitionCompute 100000000

Set-VM -GuestControlledCacheTypes $true -VMName $vmName
Set-VM -LowMemoryMappedIoSpace 1Gb -VMName $vmName
Set-VM –HighMemoryMappedIoSpace 32GB –VMName $vmName

vmconnect localhost $vmName