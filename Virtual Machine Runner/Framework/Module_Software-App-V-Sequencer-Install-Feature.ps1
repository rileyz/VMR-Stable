<#
.SYNOPSIS
    Installs the Application Virtualization (App-V) sequencer from the Windows Assessment and 
    Deployment Kit.
 
.LINK
Author:.......http://www.linkedin.com/in/rileylim
#>



# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,Yes,Yes
# Windows 8.1,No,No
# Windows 8,No,No
# Windows 7,No,No
# Server 2016,NA,Yes
# Server 2012 R2,NA,No
# Server 2012,NA,No
# Server 2008 R2,NA,No
#<<< End of Script Support >>>

# Script Assets ###################################################################################
# Asset: 32-bit\Appman Sequencer on x86-x86_en-us.msi
# Asset: 64-bit\Appman Sequencer on amd64-x64_en-us.msi
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

$Bitness = $([Environment]::GetEnvironmentVariable("VMRWindowsArchitecture","Machine"))

Switch ($Bitness) 
    {'32-bit'    {$Installer = "$VMRCollateral\$Bitness\Appman Sequencer on x86-x86_en-us.msi"
                  $ArrayScriptExitResult += (Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$Installer`" AcceptEULA=1 CEIPOPTIN=0 MUOPTIN=0 REBOOT=ReallySuppress /qn" -Wait -Passthru).ExitCode}
     '64-bit'    {$Installer = "$VMRCollateral\$Bitness\Appman Sequencer on amd64-x64_en-us.msi"
                  $ArrayScriptExitResult += (Start-Process -FilePath msiexec.exe -ArgumentList "/i `"$Installer`" AcceptEULA=1 CEIPOPTIN=0 MUOPTIN=0 REBOOT=ReallySuppress /qn" -Wait -Passthru).ExitCode}
     Default     {$ArrayScriptExitResult += 'Error'
                  Write-Debug 'No match found!'}}

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
