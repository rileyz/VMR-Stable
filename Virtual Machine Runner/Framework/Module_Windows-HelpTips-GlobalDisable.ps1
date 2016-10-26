# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,Unproven,Unproven
# Windows 8.1,Yes,Yes
# Windows 8,No,No
# Windows 7,No,No
# Server 2016,NA,No
# Server 2012 R2,NA,No
# Server 2012,NA,No
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
$ScriptExitResult = Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI' -RegistryValueName 'DisableHelpSticker' -RegistryValueData '1' -RegistryValueType 'DWord'

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     'Reboot'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'}
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
