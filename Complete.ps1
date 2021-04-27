#Remove OneDrive Icon from Explorer
Write-Host "Removing OneDrive icon. NB: This won't uninstall OneDrive, just removes it from your Windows Explorer"
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
Set-ItemProperty -Path 'HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Name System.IsPinnedToNameSpaceTree -Value 0

if ([System.Environment]::Is64BitOperatingSystem -eq 'True') {
    Set-ItemProperty -Path 'HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Name System.IsPinnedToNameSpaceTree -Value 0   
}

#Remove Windows Telemetry
Write-Host "Preventing Billy G spying on you via Telemetry"
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

#Remove Location Tracking
Write-Host "Preventing Billy G tracking your location"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0

#Stopping Windows Updates from restarting your computer
Write-Host "Nerfing Windows Updates"
Set-ItemProperty -Path "HKLM:\Software\Microsoft\WindowsUpdate\UX\Settings" -Name "UxOption" -Type DWord -Value 1

#Clear up your apps
Write-Host "Taking out the trash"
Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage
Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage


# cd "C:\Program Files (x86)\Microsoft\Edge\Application\**\Installer\"
# .\setup.exe --uninstall --force-uninstall --system-level
# ^ That will remove Edge, but for some reason leave an icon. I didn't try restarting but that might remove icon if you want to try it
# v This will remove Edge but it's a little round-the-houses
$edge  = Get-AppxPackage *edge*
$edge = $edge | Out-String -Stream | Select-String "PackageFullName" | Select-String -NotMatch "DevToolsClient"
$edge = $edge -split ": " | Select-String -NotMatch "PackageFullName"
$edge = -split $edge
Remove-AppxPackage $edge

#Set Explorer to Launch to This PC instsead of Quick Access
Write-Host "Making some improvements to Windows Explorer"
$WEPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $WEPath -Name LaunchTo -Value 1
Set-ItemProperty -Path $WEPath -Name HideFileExt Value 0
Set-ItemProperty -Path $WEPath -Name Hidden Value 1
Set-ItemProperty -Path $WEPath -Name ShowSuperHidden 1
Set-ItemProperty -Path $WEPath -Name SharingWizardOn 0

#Start Improvements
Write-Host "Upgrading your Start Menu"
$SMPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
If(!(Test-Path $SMPath)) {
    New-Item -Path $SMPath
    New-ItemProperty -Path $SMPath -Name NoSearchInternetInStartMenu -Value 1
    New-ItemProperty -Path $SMPath -Name NoSearchCommInStartMenu -Value 1
    New-ItemProperty -Path $SMPath -Name NoSimpleStartMenu -Value 0 
} else {
    $RKey = (Get-ItemProperty $SMPath)
    $RKey.PSObject.Properties | ForEach-Object {
        If($_.Name -like 'NoSearchInternetInStartMenu') {
            Set-ItemProperty -Path $SMPath -Name NoSearchInternetInStartMenu -Value 1
        } else {
            New-ItemProperty -Path $SMPath -Name NoSearchInternetInStartMenu -Value 1
        }}
        $RKey.PSObject.Properties | ForEach-Object {
            If($_.Name -like "NoSearchCommInStartMenu") {
                Set-ItemProperty -Path $SMPath -Name NoSearchCommInStartMenu -Value 1
            } else {
                New-ItemProperty -Path $SMPath -Name NoSearchCommInStartMenu -Value 1
            }}
        $RKey.PSObject.Properties | ForEach-Object {
        If($_.Name -like 'NoSimpleStartMenu') {
            Set-ItemProperty -Path $SMPath -Name NoSimpleStartMenu -Value 0
        } else {
            New-ItemProperty -Path $SMPath -Name NoSimpleStartMenu -Value 0
        }}
    }


dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
if ([System.Environment]::OSVersion.Version.Build -lt 19041) {
    Write-Host "Build 19041 or greater required to upgrade to WSL2"
    Exit
} else {
    Write-Host "Enabling Window Subsystem for Linux"
    New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense Value 1
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    wsl --set-default-version 2
}

