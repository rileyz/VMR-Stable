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
$Result32 = (Start-Process -FilePath "C:\Windows\Microsoft.NET\Framework\v4.0.30319\ngen.exe" -ArgumentList "executeQueuedItems" -Wait -PassThru).ExitCode

If (([Environment]::GetEnvironmentVariable("VMRWindowsArchitecture","Machine")) -eq '64-bit')
        {$Result64 = (Start-Process -FilePath "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\ngen.exe" -ArgumentList "executeQueuedItems" -Wait -PassThru).ExitCode} 
    Else{$Result64 = '0'}

If ($Result32 -eq '0' -and ($Result64 -eq '0'))
        {$Result = '0'}
    Else{$Result = 'Error'}

($ScriptExitResult = $Result) >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     'Reboot'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'}
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
