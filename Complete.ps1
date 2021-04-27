#Remove OneDrive Icon from Explorer
Write-Host "Removing OneDrive icon. NB: This won't uninstall OneDrive, just removes it from your Windows Explorer"
New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
Set-ItemProperty -Path 'HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Name System.IsPinnedToNameSpaceTree -Value 0

if ([System.Environment]::Is64BitOperatingSystem -eq 'True') {
    Set-ItemProperty -Path 'HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Name System.IsPinnedToNameSpaceTree -Value 0   
}

#Set Explorer to Launch to This PC instsead of Quick Access
Write-Host "Making some improvements to Windows Explorer"
$WEPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
New-ItemProperty -Path $WEPath -Name LaunchTo -Value 1
Set-ItemProperty -Path $WEPath -Name HideFileExt Value 0
Set-ItemProperty -Path $WEPath -Name Hidden Value 1
Set-ItemProperty -Path $WEPath -Name ShowSuperHidden 1
New-ItemProperty -Path $WEPath -Name SharingWizardOn 0

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