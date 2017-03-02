<#
.SYNOPSIS
    Configures Task Scheduler globally.
 
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
# Asset: BaseConfiguration_Windows7.csv
# Asset: BaseConfiguration_Windows8.csv
# Asset: BaseConfiguration_Windows10.csv
# Asset: BaseConfiguration_WindowsServer2008R2.csv
# Asset: BaseConfiguration_WindowsServer2012.csv
# Asset: BaseConfiguration_WindowsServer2016.csv
#<<< End of Script Assets >>>



# Setting up housekeeping #########################################################################
Param([String]$TaskSchedulesCSV)
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

$DataCSV = "$VMRCollateral" + "\$TaskSchedulesCSV" 

If ((Test-Path "$DataCSV") -eq $true)
        {Write-Debug 'The CSV path is valid, starting adjustment of Task Schedules.'
         $ConfigureTaskSchedules = (Import-Csv $DataCSV -Header TaskSchedule,Status)[1..($DataCSV.length - 1)]
         $Counter = 1

         ForEach ($_ in $ConfigureTaskSchedules) 
             {$TaskSchedule = ($_.TaskSchedule)
              $NewStatus = '/' + ($_.Status)
              $Counter ++
              
              &schtasks /Query /tn "$TaskSchedule"
              If ($LASTEXITCODE -ne '0')
                      {"Warning processing line $Counter in $TaskSchedulesCSV. Task does not exist, skipping." >> $VMRScriptLog}
                  Else{&schtasks /Change /tn "$TaskSchedule" $NewStatus
                       If ($LASTEXITCODE -ne '0')
                               {$ArrayScriptExitResult += $LASTEXITCODE
                                "Error returned processing line $Counter in $TaskSchedulesCSV." >> $VMRScriptLog}}}}    

    Else{Write-Debug 'The CSV path is not valid.'
         $ArrayScriptExitResult += 'Error'
         Exit}

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
