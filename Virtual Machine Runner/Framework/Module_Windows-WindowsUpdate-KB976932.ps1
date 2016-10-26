# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,No,No
# Windows 8.1,No,No
# Windows 8,No,No
# Windows 7,Yes,Yes
# Server 2012 R2,No,No
# Server 2012,No,No
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
If (([Environment]::GetEnvironmentVariable("VMRWindowsArchitecture","Machine")) -eq '32-bit')
        {$ServicePackForThisArchitecture = "$VMRCollateral\windows6.1-KB976932-x86.exe"}
   Else {$ServicePackForThisArchitecture = "$VMRCollateral\windows6.1-KB976932-X64.exe"}
                          
Write-Host $ServicePackForThisArchitecture
$Process = Start-Process -FilePath $ServicePackForThisArchitecture -ArgumentList '/quiet /nodialog /noreboot' -Wait -PassThru

$ScriptExitResult = $Process.ExitCode | Out-String
($ScriptExitResult = $ScriptExitResult -replace "`n|`r") >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     '985603'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #SP1 already installed.
     '3010'     {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'} #SP1 installed pending reboot.
     '3017'     {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'} #Reboot preventing SP1 install.
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
