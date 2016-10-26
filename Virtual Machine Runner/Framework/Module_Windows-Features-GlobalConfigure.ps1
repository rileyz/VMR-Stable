# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,Yes,Yes
# Windows 8.1,Unproven,Unproven
# Windows 8,Unproven,Unproven
# Windows 7,Yes,Yes
# Server 2016,NA,Unproven
# Server 2012 R2,NA,Unproven
# Server 2012,NA,Unproven
# Server 2008 R2,NA,Yes
#<<< End of Script Support >>>



# Setting up housekeeping #########################################################################
Param([string]$WindowsFeaturesCSV)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$ScriptPath\..\Framework\Core_CommonFunctions.ps1"
$VMRCollateral = VMR_ScriptInformation -CollateralFolder
$VMRScriptLocation = VMR_ScriptInformation -ScriptFolder
$VMRScriptFile = VMR_ScriptInformation -ScriptName
$VMRScriptLog = VMR_ScriptInformation -ScriptLogLocation
VMR_ReadyMessagingEnvironment
#<<< End of Setting up housekeeping >>>



# Start of script work ############################################################################
$DataCSV = "$VMRCollateral\$WindowsFeaturesCSV" 
$ArrayScriptExitResult = @()

If ((Test-Path "$DataCSV") -eq $true)
        {Write-Host 'The CSV path is valid, starting adjustment of Windows Features.'
         $ConfigureFeatures = (Import-Csv $DataCSV -Header WindowsFeature,State)[1..($DataCSV.length - 1)]
         $OperatingSystem = [Environment]::GetEnvironmentVariable("VMRWindowsOperatingSystem","Machine")
         $OperatingSystemArchitecture= [Environment]::GetEnvironmentVariable("VMRWindowsArchitecture","Machine")

         Write-Host 'Processing start time is' (Get-Date)

         Switch -Wildcard ($OperatingSystem)
             {'*Windows 10*'       {If ($OperatingSystemArchitecture -eq '32-Bit')
                                           {$DismSource = "$VMRCollateral\SxS Windows OS Version 10.0 32-Bit"
                                            ForEach ($_ in $ConfigureFeatures) 
                                                {Start-Sleep -Seconds 1
                                                 Write-Host 'Checking Feature' $_.WindowsFeature 'is' $_.State
                                                 $WinFeat = $_.WindowsFeature
                                                 $DismCheck = &Dism /online /Get-FeatureInfo /FeatureName:$WinFeat
                                                 $IsThisFeatEnabled = $DismCheck -contains "State : Enabled"

                                                 If ($IsThisFeatEnabled -eq $true)
                                                        {$IsThisFeatEnabled = 'Enabled'}
                                                    Else{$IsThisFeatEnabled = 'Disabled'}

                                                 Write-Host ' Currently this feature is' $IsThisFeatEnabled

                                                 $Check = ($IsThisFeatEnabled -eq $_.State)
                                                 Write-Host ' Does this match our desired state?' $Check

                                                 If ($Check -eq $false) 
                                                        {If ($IsThisFeatEnabled -eq 'Enabled') 
                                                                {Write-Host ' Disabling Feature.'
                                                                 &Dism /online /Disable-Feature /FeatureName:$WinFeat /norestart
                                                                 Write-Host " Exit code is $LASTEXITCODE"
                                                                 $WinFeat >> $VMRScriptLog
                                                                 $LASTEXITCODE >> $VMRScriptLog
                                                                 If ($LASTEXITCODE -ne 0)
                                                                         {$ArrayScriptExitResult += $LASTEXITCODE}}

                                                         If ($IsThisFeatEnabled -eq 'Disabled') 
                                                                {Write-Host ' Enabling Feature.'
                                                                 &Dism /online /Enable-Feature /FeatureName:$WinFeat /norestart /Source:"$DismSource" /LimitAccess
                                                                 Write-Host " Exit code is $LASTEXITCODE"
                                                                 $WinFeat >> $VMRScriptLog
                                                                 $LASTEXITCODE >> $VMRScriptLog
                                                                 If ($LASTEXITCODE -ne 0)
                                                                       {$ArrayScriptExitResult += $LASTEXITCODE}}}}}
                                       Else{$DismSource = "$VMRCollateral\SxS Windows OS Version 10.0 64-Bit"
                                            ForEach ($_ in $ConfigureFeatures) 
                                                {Start-Sleep -Seconds 1
                                                 Write-Host 'Checking Feature' $_.WindowsFeature 'is' $_.State
                                                 $WinFeat = $_.WindowsFeature
                                                 $DismCheck = &Dism /online /Get-FeatureInfo /FeatureName:$WinFeat
                                                 $IsThisFeatEnabled = $DismCheck -contains "State : Enabled"

                                                 If ($IsThisFeatEnabled -eq $true)
                                                        {$IsThisFeatEnabled = 'Enabled'}
                                                    Else{$IsThisFeatEnabled = 'Disabled'}

                                                 Write-Host ' Currently this feature is' $IsThisFeatEnabled

                                                 $Check = ($IsThisFeatEnabled -eq $_.State)
                                                 Write-Host ' Does this match our desired state?' $Check

                                                 If ($Check -eq $false) 
                                                        {If ($IsThisFeatEnabled -eq 'Enabled') 
                                                                {Write-Host ' Disabling Feature.'
                                                                 &Dism /online /Disable-Feature /FeatureName:$WinFeat /norestart
                                                                 Write-Host " Exit code is $LASTEXITCODE"
                                                                 $WinFeat >> $VMRScriptLog
                                                                 $LASTEXITCODE >> $VMRScriptLog
                                                                 If ($LASTEXITCODE -ne 0)
                                                                         {$ArrayScriptExitResult += $LASTEXITCODE}}

                                                         If ($IsThisFeatEnabled -eq 'Disabled') 
                                                                {Write-Host ' Enabling Feature.'
                                                                 &Dism /online /Enable-Feature /FeatureName:$WinFeat /norestart /Source:"$DismSource" /LimitAccess
                                                                 Write-Host " Exit code is $LASTEXITCODE"
                                                                 $WinFeat >> $VMRScriptLog
                                                                 $LASTEXITCODE >> $VMRScriptLog
                                                                 If ($LASTEXITCODE -ne 0)
                                                                       {$ArrayScriptExitResult += $LASTEXITCODE}}}}}}
              '*Windows 8.1*'      {Write-Output ''}
              '*Windows 8*'        {Write-Output ''}
              '*Windows 7*'        {ForEach ($_ in $ConfigureFeatures) 
                                        {Start-Sleep -Seconds 1
                                         Write-Host 'Checking Feature' $_.WindowsFeature 'is' $_.State
                                         $WinFeat = $_.WindowsFeature
                                         $DismCheck = &Dism /online /Get-FeatureInfo /FeatureName:$WinFeat
                                         $IsThisFeatEnabled = $DismCheck -contains "State : Enabled"

                                         If ($IsThisFeatEnabled -eq $true)
                                                {$IsThisFeatEnabled = 'Enabled'}
                                            Else{$IsThisFeatEnabled = 'Disabled'}

                                         Write-Host ' Currently this feature is' $IsThisFeatEnabled

                                         $Check = ($IsThisFeatEnabled -eq $_.State)
                                         Write-Host ' Does this match our desired state?' $Check

                                         If ($Check -eq $false) 
                                                {If ($IsThisFeatEnabled -eq 'Enabled') 
                                                        {Write-Host ' Disabling Feature.'
                                                         &Dism /online /Disable-Feature /FeatureName:$WinFeat /norestart
                                                         Write-Host " Exit code is $LASTEXITCODE"
                                                         $WinFeat >> $VMRScriptLog
                                                         $LASTEXITCODE >> $VMRScriptLog
                                                         If ($LASTEXITCODE -ne 0)
                                                                 {$ArrayScriptExitResult += $LASTEXITCODE}}

                                                 If ($IsThisFeatEnabled -eq 'Disabled') 
                                                        {Write-Host ' Enabling Feature.'
                                                         &Dism /online /Enable-Feature /FeatureName:$WinFeat /norestart
                                                         Write-Host " Exit code is $LASTEXITCODE"
                                                         $WinFeat >> $VMRScriptLog
                                                         $LASTEXITCODE >> $VMRScriptLog
                                                         If ($LASTEXITCODE -ne 0)
                                                               {$ArrayScriptExitResult += $LASTEXITCODE}}}}}
              '*Server 2016*'      {Write-Output ''}
              '*Server 2012 R2*'   {Write-Output ''}
              '*Server 2012*'      {Write-Output ''}
              '*Server 2008 R2*'   {Write-Output ''}
              Default              {Write-Warning 'Unknown Operating System'}}

         Write-Host 'End time is' (Get-Date)}
    Else{Write-Host 'The CSV path is not valid.'
         $ScriptExitResult = 'Error'
         Exit}

$ExitResultSuccessCodes = @('3010') #List non zero success codes here.
$NonSuccessCodes = $ArrayScriptExitResult | Where-Object {$ExitResultSuccessCodes -notcontains $_}
$SuccessButNeedsReboot = $ArrayScriptExitResult | Where-Object {$ExitResultSuccessCodes -contains $_}

If ($NonSuccessCodes -eq $null)
        {If ($SuccessButNeedsReboot -ne $null)
                {$ScriptExitResult = 'Reboot'}
            Else{$ScriptExitResult = '0'}}
    Else{$ScriptExitResult = 'Error'
         $NonSuccessCodes >> $VMRScriptLog}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}      #Features applied ok.
     'Reboot'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'} #Features applied, pending reboot.
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}         #Error in applying features.
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>
