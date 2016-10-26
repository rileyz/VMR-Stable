<#
.SYNOPSIS
    Installs Office 2013, used for office document processing.
 
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
Param([Switch]$Offce32bit,
      [Switch]$Offce64bit)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$ScriptPath\..\Framework\Core_CommonFunctions.ps1"
$VMRCollateral = VMR_ScriptInformation -CollateralFolder
$VMRScriptLocation = VMR_ScriptInformation -ScriptFolder
$VMRScriptFile = VMR_ScriptInformation -ScriptName
$VMRScriptLog = VMR_ScriptInformation -ScriptLogLocation
VMR_ReadyMessagingEnvironment
#<<< End of Setting up housekeeping >>>



# Start of script work ############################################################################
If ($Offce32bit -eq $true)
        {Start-Process -FilePath $VMRCollateral\x86\setup.exe -ArgumentList "/Config $VMRCollateral\VMROfficeProPlus2013Configuration.xml" -Wait}

If ($Offce64bit -eq $true)
        {Start-Process -FilePath $VMRCollateral\x64\setup.exe -ArgumentList "/Config $VMRCollateral\VMROfficeProPlus2013Configuration.xml" -Wait}

$OfficeLog = Get-Content -Path "$env:WinDir\Temp\OfficeProfessionalPlus2013.log" | Out-String

If (($OfficeLog.Contains('Successfully installed package: ProPlusrWW path:C:\MSOCache\All Users\{91150000-0011-0000-0000-0000000FF1CE}-C\ProPlusrWW.msi')) -eq $true)
        {$ScriptExitResult = '0'}
    Else{$ScriptExitResult = 'Error'} 

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     'Reboot'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'}
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
