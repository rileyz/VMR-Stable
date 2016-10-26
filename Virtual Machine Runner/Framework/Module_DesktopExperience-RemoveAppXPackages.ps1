<#
.SYNOPSIS
    Remove mordern applications via a predefined CSV for the invoker of the script.
 
.LINK
Author:.......http://www.linkedin.com/in/rileylim
#>



# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,Unproven,Unproven
# Windows 8.1,yes,yes
# Windows 8,yes,yes
# Windows 7,Unproven,Unproven
# Server 2016,NA,Unproven
# Server 2012 R2,NA,Unproven
# Server 2012,NA,Unproven
# Server 2008 R2,NA,Unproven
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
$DataCVS = "$VMRCollateral\DefaultMordernApps.csv"

$MordernAppsArray = (Import-Csv $DataCVS -Header MordernApp,AppXName)[1..($DataCVS.length - 1)]

ForEach ($_ in $MordernAppsArray)
        {Write-Host "Processing" $_.MordernApp
         $App = Get-AppxPackage -Name $_.AppXName

         If ($App -ne $null)
                 {Remove-AppxPackage -Package (Get-AppxPackage -Name $_.AppXName).PackageFullName
                  Write-Host ' AppX package removed!'}
             Else{Write-Host ' Appx package was not found on this machine.'}}

$ScriptExitResult = 0 #how do we error check this?

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     'Reboot'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'}
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
