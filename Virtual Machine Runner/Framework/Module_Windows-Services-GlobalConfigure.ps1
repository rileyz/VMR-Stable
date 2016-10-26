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
Param([string]$WindowsServicesCSV)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$ScriptPath\..\Framework\Core_CommonFunctions.ps1"
$VMRCollateral = VMR_ScriptInformation -CollateralFolder
$VMRScriptLocation = VMR_ScriptInformation -ScriptFolder
$VMRScriptFile = VMR_ScriptInformation -ScriptName
$VMRScriptLog = VMR_ScriptInformation -ScriptLogLocation
VMR_ReadyMessagingEnvironment
#<<< End of Setting up housekeeping >>>



# Start of script work ############################################################################
$DataCSV = "$VMRCollateral\$WindowsServicesCSV" 

If ((Test-Path "$DataCSV") -eq $true)
        {Write-Host 'The CSV path is valid, starting adjustment of Windows Features.'
         $ConfigureService = (Import-Csv $DataCSV -Header ServiceName,StartupType)[1..($DataCSV.length - 1)]

         ForEach ($_ in $ConfigureService) 
             {If ($_.StartupType -eq 'Disabled')
                     {Stop-Service -Name $_.ServiceName
                      Set-Service -Name $_.ServiceName -StartupType $_.StartupType}
                 Else{$_.ServiceName
                      $_.StartupType
                      Set-Service -Name $_.ServiceName -StartupType $_.StartupType
                      Start-Service -Name $_.ServiceName}
              
              $ServiceName = $_.ServiceName
              $QueryString = "Select StartMode From Win32_Service Where Name='" + $ServiceName + "'"
              $Service = Get-WmiObject -Query $QueryString
 
              If ($_.StartupType -eq 'Disabled')
                     {If ($Service.StartMode -eq 'Disabled')
                             {Write-Host "$_.ServiceName has been stopped and disabled."
                              $ScriptExitResult = '0'}
                         Else{Write-Host '$_.ServiceName failed to be stopped or disabled.'
                              $ScriptExitResult = 'Error'}}
                 Else{If ($Service.StartMode -eq 'Auto')
                             {Write-Host "$_.ServiceName has been started and enabled."
                              $ScriptExitResult = '0'}
                         Else{Write-Host '$_.ServiceName failed to be started or enabled.'
                              $ScriptExitResult = 'Error'}}
                
                If ($ScriptExitResult -eq 'Error')
                      {Break}}}

    Else{Write-Host 'The CSV path is not valid.'
         $ScriptExitResult = 'Error'
         Exit}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Completed ok.
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
