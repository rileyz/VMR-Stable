<#
.SYNOPSIS
    Applies wallpaper, wallpaper position and desktop colour for script invoker.
 
.LINK
Author:.......http://www.linkedin.com/in/rileylim
#>



# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,Yes,Yes
# Windows 8.1,Yes,Yes
# Windows 8,Yes,Yes
# Windows 7,Yes,Yes
# Server 2016,NA,Yes
# Server 2012 R2,NA,Yes
# Server 2012,NA,Yes
# Server 2008 R2,NA,Yes
#<<< End of Script Support >>>



# Setting up housekeeping #########################################################################
Param([string]$Wallpaper,
      [string][ValidateSet('Center','Stretch','Tile')]$PicturePosition,
      [string]$DesktopColour)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$ScriptPath\..\Framework\Core_CommonFunctions.ps1"
$VMRCollateral = VMR_ScriptInformation -CollateralFolder
$VMRScriptLocation = VMR_ScriptInformation -ScriptFolder
$VMRScriptFile = VMR_ScriptInformation -ScriptName
$VMRScriptLog = VMR_ScriptInformation -ScriptLogLocation
VMR_ReadyMessagingEnvironment
#<<< End of Setting up housekeeping >>>



# Start of script work ############################################################################
$ArrayScriptExitResult = @()
$Wallpaper = "$VMRCollateral" + "\$Wallpaper"
$WallpaperDestination = "$env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper.jpg"

Copy-Item -Path $Wallpaper -Destination $WallpaperDestination

Remove-Item $env:APPDATA\Microsoft\Windows\Themes\CachedFiles\* -Recurse

If ((Test-Path $env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper) -eq $true)
        {Remove-Item $env:APPDATA\Microsoft\Windows\Themes\TranscodedWallpaper -ErrorAction SilentlyContinue}

$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Desktop' -RegistryValueName 'Wallpaper' -RegistryValueData "$WallpaperDestination" -RegistryValueType 'String'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Colors' -RegistryValueName 'Background' -RegistryValueData "$DesktopColour" -RegistryValueType 'String'

Switch ($PicturePosition)
        {Center    {$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Desktop' -RegistryValueName 'WallpaperStyle' -RegistryValueData '0' -RegistryValueType 'String'
                    $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Desktop' -RegistryValueName 'TileWallpaper' -RegistryValueData '0' -RegistryValueType 'String'}
         Stretch   {$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Desktop' -RegistryValueName 'WallpaperStyle' -RegistryValueData '2' -RegistryValueType 'String'
                    $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Desktop' -RegistryValueName 'TileWallpaper' -RegistryValueData '0' -RegistryValueType 'String'}
         Tile      {$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Desktop' -RegistryValueName 'WallpaperStyle' -RegistryValueData '1' -RegistryValueType 'String'
                    $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Desktop' -RegistryValueName 'TileWallpaper' -RegistryValueData '1' -RegistryValueType 'String'}
         Default   {Write-Host 'Did not capture wallpaper picture position' >> $VMRScriptLog
                    $ArrayScriptExitResult += '1'}}

$SuccessCodes = @('Example','0','3010')                                                           #List all success codes, inculding reboots here.
$SuccessButNeedsRebootCodes = @('Example','3010')                                                 #List success but needs reboot code here.
$ScriptError = $ArrayScriptExitResult | Where-Object {$SuccessCodes -notcontains $_}              #Store errors found in this variable
$ScriptReboot = $ArrayScriptExitResult | Where-Object {$SuccessButNeedsRebootCodes -contains $_}  #Store success but needs reboot in this varible

If ($ScriptError -eq $null)                       #If ScriptError is empty, then everything processed ok.
        {If ($ScriptReboot -ne $null)             #If ScriptReboot is not empty, then everything processed ok, but just needs a reboot.
                {$ScriptExitResult = 'Reboot'}
            Else{$ScriptExitResult = '0'}}
    Else{$ScriptExitResult = 'Error'
         $ScriptError >> $VMRScriptLog}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     'Reboot'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'}
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
