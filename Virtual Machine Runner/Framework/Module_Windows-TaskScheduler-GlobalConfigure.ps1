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
Param([string]$TaskSchedulesCSV)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$ScriptPath\..\Framework\Core_CommonFunctions.ps1"
$VMRCollateral = VMR_ScriptInformation -CollateralFolder
$VMRScriptLocation = VMR_ScriptInformation -ScriptFolder
$VMRScriptFile = VMR_ScriptInformation -ScriptName
$VMRScriptLog = VMR_ScriptInformation -ScriptLogLocation
VMR_ReadyMessagingEnvironment
#<<< End of Setting up housekeeping >>>



# Start of script work ############################################################################
$DataCSV = "$VMRCollateral" + "\$TaskSchedulesCSV" 
$ArrayScriptExitResult = @()

If ((Test-Path "$DataCSV") -eq $true)
        {Write-Host 'The CSV path is valid, starting adjustment of Task Schedules.'
         $ConfigureTaskSchedules = (Import-Csv $DataCSV -Header TaskSchedule,Status)[1..($DataCSV.length - 1)]
         $Counter = 1

         ForEach ($_ in $ConfigureTaskSchedules) 
             {$TaskSchedule = ($_.TaskSchedule)
              $NewStatus = '/' + ($_.Status)
              $Counter ++
              
              &schtasks /Query /tn "$TaskSchedule"
              If ($LASTEXITCODE -ne '0')
                      {"Warning processing line $Counter in $TaskSchedulesCSV. Task does not exist, skipping." >> $VMRScriptLog}
                  Else{&schtasks /Change /tn "$TaskSchedule" $NewStatus
                       If ($LASTEXITCODE -ne '0')
                               {$ArrayScriptExitResult += $LASTEXITCODE
                                "Error returned processing line $Counter in $TaskSchedulesCSV." >> $VMRScriptLog}}}}    

    Else{Write-Host 'The CSV path is not valid.'
         $ScriptExitResult = 'Error'
         Exit}

$NonSuccessCodes = $ArrayScriptExitResult | Where-Object {0 -notcontains $_}

If ($NonSuccessCodes -eq $null)
        {$ScriptExitResult = '0'}
    Else{$ScriptExitResult = 'Error'}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}         #Error in setting up user accounts.
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
