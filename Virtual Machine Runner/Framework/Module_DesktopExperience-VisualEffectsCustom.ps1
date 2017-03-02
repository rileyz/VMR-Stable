<#
.SYNOPSIS
    Sets visual effects settings for better virtual machine Performance globally.
 
.LINK
Author:.......http://www.linkedin.com/in/rileylim
#>



# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,Yes,Yes
# Windows 8.1,Yes,Yes
# Windows 8,Yes,Yes
# Windows 7,Yes,Yes
# Server 2016,NA,Unproven
# Server 2012 R2,NA,Unproven
# Server 2012,NA,Unproven
# Server 2008 R2,NA,Unproven
#<<< End of Script Support >>>

# Script Assets ###################################################################################
# None
#<<< End of Script Assets >>>



# Setting up housekeeping #########################################################################
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

#Set local machine defaults for future profiles.
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ComboBoxAnimation' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ControlAnimations' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\CursorShadow' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DragFullWindows' -RegistryValueName 'DefaultValue' -RegistryValueData '1' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMAeroPeekEnabled' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMSaveThumbnailEnabled' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing' -RegistryValueName 'DefaultValue' -RegistryValueData '1' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListBoxSmoothScrolling' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect' -RegistryValueName 'DefaultValue' -RegistryValueData '1' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TaskbarAnimations' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ThumbnailsOrIcon' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation' -RegistryValueName 'DefaultValue' -RegistryValueData '0' -RegistryValueType 'DWord'

#Set for script invoker (Administrator) account.
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name UserPreferencesMask -Value ([Byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Desktop' -RegistryValueName 'DragFullWindows' -RegistryValueData '1' -RegistryValueType 'String'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Desktop' -RegistryValueName 'FontSmoothing' -RegistryValueData '2' -RegistryValueType 'String'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Control Panel\Desktop\WindowMetrics' -RegistryValueName 'MinAnimate' -RegistryValueData '0' -RegistryValueType 'String'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -RegistryValueName 'IconsOnly' -RegistryValueData '1' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -RegistryValueName 'ListviewAlphaSelect' -RegistryValueData '1' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -RegistryValueName 'ListviewShadow' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -RegistryValueName 'TaskbarAnimations' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -RegistryValueName 'VisualFXSetting' -RegistryValueData '3' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Software\Microsoft\Windows\DWM' -RegistryValueName 'AlwaysHibernateThumbnails' -RegistryValueData '0' -RegistryValueType 'DWord'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\Software\Microsoft\Windows\DWM' -RegistryValueName 'EnableAeroPeek' -RegistryValueData '0' -RegistryValueType 'DWord' #Windows 8 and above.

$SuccessCodes = @('Example','0','3010','True')                                                    #List all success codes, including reboots here.
$SuccessButNeedsRebootCodes = @('Example','3010')                                                 #List success but needs reboot code here.
$ScriptError = $ArrayScriptExitResult | Where-Object {$SuccessCodes -notcontains $_}              #Store errors found in this variable
$ScriptReboot = $ArrayScriptExitResult | Where-Object {$SuccessButNeedsRebootCodes -contains $_}  #Store success but needs reboot in this variable

If ($ScriptError -eq $null)                       #If ScriptError is empty, then everything processed ok.
        {If ($ScriptReboot -ne $null)             #If ScriptReboot is not empty, then everything processed ok, but just needs a reboot.
                {$ScriptExitResult = 'Reboot'}
            Else{$ScriptExitResult = '0'}}
    Else{$ScriptExitResult = 'Error'
         $ScriptError >> $VMRScriptLog}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}
     'Reboot'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'}
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>



<#
Virtual Machine Runner  -  Copyright (C) 2016-2017  -  Riley Lim

This program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the 
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, 
see <http://www.gnu.org/licenses/>.
#>
