# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,No,No
# Windows 8.1,No,No
# Windows 8,No,No
# Windows 7,Yes,Yes
# Server 2016,NA,No
# Server 2012 R2,NA,No
# Server 2012,NA,No
# Server 2008 R2,NA,Yes
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
#Need to add detection for SP1
If (([Environment]::GetEnvironmentVariable("VMRWindowsArchitecture","Machine")) -eq '32-bit')
        {$PowerShell3ForThisArchitecture = "$VMRCollateral\Windows6.1-KB2506143-x86.msu"}
   Else {$PowerShell3ForThisArchitecture = "$VMRCollateral\Windows6.1-KB2506143-x64.msu"}
                          
Write-Host $PowerShell3ForThisArchitecture
$Process = Start-Process -FilePath $PowerShell3ForThisArchitecture -ArgumentList '/quiet /norestart' -Wait -PassThru

($ScriptExitResult = $Process.ExitCode) >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'2359302'  {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     '3010'     {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'}
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
