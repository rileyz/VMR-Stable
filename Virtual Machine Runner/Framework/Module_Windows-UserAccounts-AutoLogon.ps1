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
Param([string]$AutoLogonUserName,
      [string]$AutoLogonPassword)
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
$AutoAdminLogon = '1'
$DefaultUserName = $AutoLogonUserName
$DefaultPassword = $AutoLogonPassword

If ((Test-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Value 'AutoAdminLogon') -eq $true)
        {$RegCheckAutoLogon = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoAdminLogon}
If ((Test-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Value 'DefaultUserName') -eq $true)
        {$RegCheckUserName = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultUserName}
If ((Test-RegistryValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Value 'DefaultPassword') -eq $true)
        {$RegCheckPassword = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name DefaultPassword}

If ($RegCheckAutoLogon.AutoAdminLogon -eq $AutoAdminLogon -And $RegCheckUserName.DefaultUserName -eq $DefaultUserName -And $RegCheckPassword.DefaultPassword -eq $DefaultPassword)
        {Write-Host "Auto Logon has already been set for `'$DefaultUserName`', with a password of `'$DefaultPassword`'."
         $ArrayScriptExitResult += '0'}
    Else{$ArrayScriptExitResult += (Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -RegistryValueName 'AutoAdminLogon' -RegistryValueData "$AutoAdminLogon" -RegistryValueType 'String')
         $ArrayScriptExitResult += (Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -RegistryValueName 'DefaultUserName' -RegistryValueData "$DefaultUserName" -RegistryValueType 'String')
         $ArrayScriptExitResult += (Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -RegistryValueName 'DefaultPassword' -RegistryValueData "$DefaultPassword" -RegistryValueType 'String')}     

$NonSuccessCodes = $ArrayScriptExitResult | Where-Object {0 -notcontains $_}

If ($NonSuccessCodes -eq $null)
        {Write-Host "Auto Logon has been set for `'$DefaultUserName`', with a password of `'$DefaultPassword`'."
         $ScriptExitResult = 'Reboot'}
    Else{$ScriptExitResult = 'Error'
         $NonSuccessCodes >> $VMRScriptLog}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     'Reboot'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'} 
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}         #Error in setting up user accounts.
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
