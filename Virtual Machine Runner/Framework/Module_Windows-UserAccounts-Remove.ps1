# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,Yes,Yes
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
(gwmi win32_operatingsystem -ComputerName localhost).Win32Shutdown(4)

Do {$Explorer = Get-Process Explorer -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1}
    Until ($Explorer -eq $null)

Start-Sleep 30

$DataCVS = "$VMRCollateral\UserAccountExceptions.csv" 
$UserAccountExceptionsArray = (Import-Csv $DataCVS -Header UserNames)[1..($DataCVS.length - 1)]

$LocalUserAccountsArray = &"$VMRCollateral\GetLocalAccount\GetLocalAccount.ps1"

ForEach ($LocalAccount in $LocalUserAccountsArray) 
    {$DoNotDelete = $null
     $LocalAccountName = $LocalAccount.Name 
     $LocalAccountName >> $VMRScriptLog
     ForEach ($AccountException in $UserAccountExceptionsArray)
         {If (($LocalAccountName -replace "`n|`r")  -eq ($AccountException -replace "@{UserNames=|}|`n|`r"))
                {$DoNotDelete = $true}}
     
     If ($DoNotDelete -eq $true)
             {' Not to be deleted.' >> $VMRScriptLog}
         Else{' To be deleted.' >> $VMRScriptLog
              ' Removing profile.' >> $VMRScriptLog
              $User = Get-WmiObject Win32_UserProfile -filter "localpath='C:\\Users\\$LocalAccountName'"
              $User.Delete()

              ' Deleting user from system.'  >> $VMRScriptLog        
              &net User `"$LocalAccountName`" /Delete}}

$Results = 0 #need to check for sucess somehow

If ($Results -eq 0)
        {$ScriptExitResult = '0'}
    Else{$ScriptExitResult = 'Error'}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Local accounts removed ok.
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}         #Error.
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
