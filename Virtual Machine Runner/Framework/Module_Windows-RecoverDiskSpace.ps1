<#
.SYNOPSIS
    Clears all Event logs and removes all temporary files to recover space.
 
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

$OperatingSystem = [Environment]::GetEnvironmentVariable("VMRWindowsOperatingSystem","Machine")
If ($OperatingSystem -notlike '*Server*')
        {Write-Debug 'Setting up Disk Cleanup'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameNewsFiles' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameStatisticsFiles' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameUpdateFiles' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Sync Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'
         $ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files' -RegistryValueName 'StateFlags0000' -RegistryValueData '2' -RegistryValueType 'DWord'

         Write-Debug 'Starting Disk Cleanup.'
         Start-Process -FilePath cleanmgr.exe -ArgumentList '/sagerun:0' -Wait
         $ArrayScriptExitResult += $?}

Write-Debug 'Clearing user and system temp folders'
Remove-Item C:\Users\$env:username\AppData\Local\Temp\* -Recurse
Remove-Item C:\Logs -Recurse -Force
Remove-Item C:\PerfLogs -Recurse -Force
Remove-Item C:\Windows\Prefetch\* -Recurse
Remove-Item C:\Windows\Temp\* -Recurse

&wevtutil el | Foreach-Object {wevtutil cl "$_"} #http://jpwaldin.com/blog/?p=166
$ArrayScriptExitResult += $?

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
