# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,No,No
# Windows 8.1,No,No
# Windows 8,No,No
# Windows 7,Yes,Yes
# Server 2016,NA,No
# Server 2012 R2,No,No
# Server 2012,No,No
# Server 2008 R2,No,Yes
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
If (([Environment]::GetEnvironmentVariable("VMRWindowsArchitecture","Machine")) -eq '32-bit')
        {$KB3125574ForThisArchitecture = "$VMRCollateral\windows6.1-kb3125574-v4-x86_ba1ff5537312561795cc04db0b02fbb0a74b2cbd.msu"}
   Else {$KB3125574ForThisArchitecture = "$VMRCollateral\windows6.1-kb3125574-v4-x64_2dafb1d203c8964239af3048b5dd4b1264cd93b9.msu"}
                          
Write-Host $KB3125574ForThisArchitecture
$Process = Start-Process -FilePath $KB3125574ForThisArchitecture -ArgumentList '/quiet /norestart' -Wait -PassThru

($ScriptExitResult = $Process.ExitCode) >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'           {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     '2359302'     {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Already installed.
     '-2145124329' {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Update not required, WSUSOffline would of patched it, but if skipping WSUSOffline job, this is required.
     '3010'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'}
     'Error'       {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default       {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
