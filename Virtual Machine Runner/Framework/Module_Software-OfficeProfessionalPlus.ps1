<#
.SYNOPSIS
    Installs Office Professional Plus 2013/2016 with generic volume licence keys.
 
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
# Asset: SW_DVD5_Office_Professional_Plus_2013_64Bit_English_MLF_X18-55297.ISO\setup.exe
# Asset: SW_DVD5_Office_Professional_Plus_2013_W32_English_MLF_X18-55138.ISO\setup.exe
# Asset: SW_DVD5_Office_Professional_Plus_2016_64Bit_English_MLF_X20-42432.ISO\setup.exe
# Asset: SW_DVD5_Office_Professional_Plus_2016_W32_English_MLF_X20-41353.ISO\setup.exe
#<<< End of Script Assets >>>



# Setting up housekeeping #########################################################################
Param([String]$Version)
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

If ($Version -eq 'DoNotInstall')
        {Write-Output 'Not installing Office.'
         $ArrayScriptExitResult += '0'}
    Else{Switch ($Version)
             {'Office2013_32'    {Start-Process -FilePath $VMRCollateral\SW_DVD5_Office_Professional_Plus_2013_W32_English_MLF_X18-55138.ISO\setup.exe -ArgumentList "/Config $VMRCollateral\OfficeProPlusConfiguration.xml" -Wait}
              'Office2013_64'    {Start-Process -FilePath $VMRCollateral\SW_DVD5_Office_Professional_Plus_2013_64Bit_English_MLF_X18-55297.ISO\setup.exe -ArgumentList "/Config $VMRCollateral\OfficeProPlusConfiguration.xml" -Wait}
              'Office2016_32'    {Start-Process -FilePath $VMRCollateral\SW_DVD5_Office_Professional_Plus_2016_W32_English_MLF_X20-41353.ISO\setup.exe -ArgumentList "/Config $VMRCollateral\OfficeProPlusConfiguration.xml" -Wait}
              'Office2016_64'    {Start-Process -FilePath $VMRCollateral\SW_DVD5_Office_Professional_Plus_2016_64Bit_English_MLF_X20-42432.ISO\setup.exe -ArgumentList "/Config $VMRCollateral\OfficeProPlusConfiguration.xml" -Wait}
               Default           {"Switch statement was unable to determine selection: $Version" >> $VMRScriptLog
                                  $ArrayScriptExitResult += 'Error'}}

         $OfficeLog = Get-Content -Path "$env:WinDir\Temp\OfficeProfessionalPlus.log"

         If ($OfficeLog -match 'Successfully installed package: ProPlus.*?-C\\ProPlus.?WW.msi')
                 {$ArrayScriptExitResult += '0'}
             Else{$ArrayScriptExitResult += 'Error'}}

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
