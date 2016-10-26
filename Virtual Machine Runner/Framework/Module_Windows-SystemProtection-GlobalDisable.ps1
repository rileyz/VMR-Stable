# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,Unproven,Unproven
# Windows 8.1,Yes,Yes
# Windows 8,Yes,Yes
# Windows 7,Yes,Yes
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
$ArrayScriptExitResult = @()

&vssadmin Delete Shadows /All /Quiet
If ($LASTEXITCODE -eq '1' -or ($LASTEXITCODE -eq '0'))
        {$LASTEXITCODE = '0'}
$ArrayScriptExitResult += $LASTEXITCODE
Write-Host "Removing Shadow Copies exit code $LASTEXITCODE"

&vssadmin Resize ShadowStorage /For=C: /On=C: /MaxSize=1%
$ArrayScriptExitResult += $LASTEXITCODE
Write-Host "Resizing Shadow Volume size exit code $LASTEXITCODE"

Disable-ComputerRestore -Drive "C:\"
Write-Host "Disabling System Restore exit code $LASTEXITCODE"
$ArrayScriptExitResult += $LASTEXITCODE

$PreviousVersionsFilesKey = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SPP\Clients\'
$RegCheck = $PreviousVersionsFilesKey.GetValue("{3E7F07C9-6BC3-11DC-A033-0019B92BB8B1}")

If ($RegCheck -eq $null)
        {Write-Host 'Registry key for System Restore was not found, nothng to do here.'}
    Else{Remove-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SPP\Clients' -name '{3E7F07C9-6BC3-11DC-A033-0019B92BB8B1}'
         $ArrayScriptExitResult += $LASTEXITCODE
         Write-Host 'Registry key for System Restore was removed.'}

$ExitResultSuccessCodes = @('0') #List success codes here.
$NonSuccessCodes = $ArrayScriptExitResult | Where-Object {$ExitResultSuccessCodes -notcontains $_}

If ($NonSuccessCodes -eq $null)
        {$ScriptExitResult = '0'}
    Else{$ScriptExitResult = 'Error'
         $NonSuccessCodes >> "$VMRScriptLocation\..\Logs\$VMRScriptFile.log"}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}   #System Protection disabled ok.
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}      #Error in applying features.
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
