# Check and install if necessary Hyper-v
$hyperv = Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online
# Check if Hyper-V is enabled
if($hyperv.State -eq "Enabled") {
    Write-Host "Hyper-V is enabled."
} else {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
}

# After install hyper-v, download pre-request
## Windows 10 super-light
### Package FR
### Steam cla
### Suchine Host Gaming + Custom config ( Port + Game - Desktop access )

