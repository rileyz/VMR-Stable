<#
.SYNOPSIS
    Creates a shortcut for Sequencer enabled PVAD.
 
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

If (Test-Path 'C:\Program Files\Microsoft Application Virtualization\Sequencer\Sequencer.exe')
        {$Target = 'C:\Program Files\Microsoft Application Virtualization\Sequencer\Sequencer.exe'
         $Shortcut = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Application Virtualization Sequencer\Squencer with PVAD Enabled.lnk'

         $WshShell = New-Object -comObject WScript.Shell
         $Shortcut = $WshShell.CreateShortcut("$Shortcut")
         $Shortcut.Arguments = '-EnablePVADControl'
         $Shortcut.IconLocation = "$Target, 2"
         $Shortcut.TargetPath = "$Target"
         $Shortcut.Save()
         
         If (Test-Path $Shortcut) {$ArrayScriptExitResult += 0}}

If (Test-Path 'C:\Program Files\Windows Kits\10\Microsoft Application Virtualization\Sequencer\Sequencer.exe')
        {$Target = 'C:\Program Files\Windows Kits\10\Microsoft Application Virtualization\Sequencer\Sequencer.exe'
         $Shortcut = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Windows Kits\Windows ADK\Squencer with PVAD Enabled.lnk'

         $WshShell = New-Object -comObject WScript.Shell
         $Shortcut = $WshShell.CreateShortcut("$Shortcut")
         $Shortcut.Arguments = '-EnablePVADControl'
         $Shortcut.IconLocation = "$Target, 2"
         $Shortcut.TargetPath = "$Target"
         $Shortcut.Save()
         
         If (Test-Path $Shortcut) {$ArrayScriptExitResult += 0}}

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
