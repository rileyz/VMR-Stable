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
$DataCVS = "$VMRCollateral\UserAccountsAdd.csv" 
$UserAccountsArray = (Import-Csv $DataCVS -Header UserNames)[1..($DataCVS.length - 1)]

ForEach ($_ in $UserAccountsArray)
        {$CSVUser = $_.UserNames

         "Adding user `'$CSVUser`'" >> $VMRScriptLog                       
         &net User "$CSVUser" /Add PASSWORDCHG:NO
         $Results += $LASTEXITCODE
         $LASTEXITCODE >> $VMRScriptLog #if last exit code = 2 then account exits         
         
         'Setting the password to never expire.' >> $VMRScriptLog
         &WMIC USERACCOUNT WHERE "Name=`"$CSVUser`"" SET PasswordExpires=FALSE
         $Results += $LASTEXITCODE

         'Setting the password to blank/no password required.' >> $VMRScriptLog
         Start-Process -FilePath cmd.exe -ArgumentList "/C net User $CSVUser `"`"" -Wait
         $Results += $LASTEXITCODE

         $LASTEXITCODE >> $VMRScriptLog}

If ($Results -ne 0)
        {$ScriptExitResult = 'Error'}
    Else{$ScriptExitResult = '0'}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}         #Error in setting up user accounts.
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
