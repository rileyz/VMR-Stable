# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,No,No
# Windows 8.1,Yes,Yes
# Windows 8,Yes,Yes
# Windows 7,No,No
# Server 2016,NA,Unproven
# Server 2012 R2,NA,Yes
# Server 2012,NA,Yes
# Server 2008 R2,NA,No
#<<< End of Script Support >>>



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

&takeown /A /F "$env:WinDir\System32\Tasks\Microsoft\Windows\TaskScheduler\Maintenance Configurator"
$ArrayScriptExitResult += $LASTEXITCODE

&icacls "$env:WinDir\System32\Tasks\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /Grant Administrators:F
$ArrayScriptExitResult += $LASTEXITCODE

Disable-ScheduledTask -TaskName "\Microsoft\Windows\TaskScheduler\Idle Maintenance"
$ArrayScriptExitResult += $?

Disable-ScheduledTask -TaskName "\Microsoft\Windows\TaskScheduler\Maintenance Configurator"
$ArrayScriptExitResult += $?

Disable-ScheduledTask -TaskName "\Microsoft\Windows\TaskScheduler\Manual Maintenance"
$ArrayScriptExitResult += $?

Disable-ScheduledTask -TaskName "\Microsoft\Windows\TaskScheduler\Regular Maintenance"
$ArrayScriptExitResult += $?

#https://github.com/clymb3r/PowerShell/blob/master/Invoke-TokenManipulation/Invoke-TokenManipulation.ps1
#http://deploymentresearch.com/Research/Post/401/Automatic-Maintenance-in-Windows-Server-2012-R2-is-EVIL

$SuccessCodes = @('Example','0','3010','True')                                                    #List all success codes, inculding reboots here.
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
