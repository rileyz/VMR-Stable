<#
.SYNOPSIS
    Sets the IE homepage for the invoker of the script.
 
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
Param([string]$URL)
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

If ($URL -eq "")
        {$URL = 'about:blank'}

$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main' -RegistryValueName 'Default_Page_URL' -RegistryValueData "$URL" -RegistryValueType 'String'
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main' -RegistryValueName 'Start Page' -RegistryValueData "$URL" -RegistryValueType 'String'

If ((Test-RegistryValue -Path 'HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main' -Value 'First Home Page') -eq $true)
        {Remove-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main' -Name 'First Home Page'
         $ArrayScriptExitResult += $?}

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
