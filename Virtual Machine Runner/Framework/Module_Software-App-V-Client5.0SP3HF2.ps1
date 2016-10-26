<#
.SYNOPSIS
    Installs the Application Virtualization (App-V) service pack or hotfix.
 
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
$Process = Start-Process -FilePath $VMRCollateral\AppV5.0SP3_Client_KB3060458.exe -ArgumentList '/q /AcceptEULA /CEIPOPTIN=0 /MUOPTIN=0 /NoRestart' -Wait -PassThru

($ScriptExitResult = $Process.ExitCode) >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     '3010'     {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'} #Windows Installer: A restart is required to complete the install. 
     '1603'     {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}         #Windows Installer: Fatal error during installation.
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
