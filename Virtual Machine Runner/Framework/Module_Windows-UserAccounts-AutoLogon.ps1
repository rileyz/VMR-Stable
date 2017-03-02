<#
.SYNOPSIS
    Sets Auto Logon.
 
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
Param([String]$AutoLogonUserName,
      [String]$AutoLogonPassword)
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

$AutoAdminLogon = '1'
$DefaultUserName = $AutoLogonUserName
$DefaultPassword = $AutoLogonPassword

If ((Test-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Value 'AutoAdminLogon') -eq $true)
        {$RegCheckAutoLogon = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon}
If ((Test-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Value 'DefaultUserName') -eq $true)
        {$RegCheckUserName = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName}
If ((Test-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Value 'DefaultPassword') -eq $true)
        {$RegCheckPassword = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword}

If ($RegCheckAutoLogon.AutoAdminLogon -eq $AutoAdminLogon -And $RegCheckUserName.DefaultUserName -eq $DefaultUserName -And $RegCheckPassword.DefaultPassword -eq $DefaultPassword)
        {Write-Debug "Auto Logon has already been set for `'$DefaultUserName`', with a password of `'$DefaultPassword`'."
         $ArrayScriptExitResult += '0'}
    Else{$ArrayScriptExitResult += (Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -RegistryValueName 'AutoAdminLogon' -RegistryValueData "$AutoAdminLogon" -RegistryValueType 'String')
         $ArrayScriptExitResult += (Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -RegistryValueName 'DefaultUserName' -RegistryValueData "$DefaultUserName" -RegistryValueType 'String')
         $ArrayScriptExitResult += (Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -RegistryValueName 'DefaultPassword' -RegistryValueData "$DefaultPassword" -RegistryValueType 'String')}     

$ArrayScriptExitResult += 'Reboot'

$SuccessCodes = @('Example','0','Reboot','True')                                                  #List all success codes, including reboots here.
$SuccessButNeedsRebootCodes = @('Example','Reboot')                                               #List success but needs reboot code here.
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
