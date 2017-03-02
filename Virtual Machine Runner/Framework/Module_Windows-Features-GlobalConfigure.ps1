<#
.SYNOPSIS
	Configures Windows operating system Features globally.
 
.LINK
Author:.......http://www.linkedin.com/in/rileylim
#>



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

# Script Assets ###################################################################################
# Asset: BaseConfiguration_Windows7.csv
# Asset: BaseConfiguration_Windows10.csv
# Asset: SxS Windows OS Version 10.0 32-Bit\microsoft-windows-netfx3-ondemand-package.cab
# Asset: SxS Windows OS Version 10.0 64-Bit\microsoft-windows-netfx3-ondemand-package.cab
#<<< End of Script Assets >>>



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
$ArrayScriptExitResult = @()

$DataCSV = "$VMRCollateral\$WindowsFeaturesCSV" 

If ((Test-Path "$DataCSV") -eq $true)
        {Write-Debug 'The CSV path is valid, starting adjustment of Windows Features.'
         $ConfigureFeatures = (Import-Csv $DataCSV -Header WindowsFeature,State)[1..($DataCSV.length - 1)]
         $OperatingSystem = [Environment]::GetEnvironmentVariable("VMRWindowsOperatingSystem","Machine")
         $OperatingSystemArchitecture= [Environment]::GetEnvironmentVariable("VMRWindowsArchitecture","Machine")

         Write-Debug 'Processing start time is' (Get-Date)

         Switch -Wildcard ($OperatingSystem)
             {'*Windows 10*'       {If ($OperatingSystemArchitecture -eq '32-Bit')
                                           {$DismSource = "$VMRCollateral\SxS Windows OS Version 10.0 32-Bit"
                                            ForEach ($_ in $ConfigureFeatures) 
                                                {Start-Sleep -Seconds 1
                                                 Write-Debug 'Checking Feature' $_.WindowsFeature 'is' $_.State
                                                 $WinFeat = $_.WindowsFeature
                                                 $DismCheck = &Dism /online /Get-FeatureInfo /FeatureName:$WinFeat
                                                 $IsThisFeatEnabled = $DismCheck -contains "State : Enabled"

                                                 If ($IsThisFeatEnabled -eq $true)
                                                        {$IsThisFeatEnabled = 'Enabled'}
                                                    Else{$IsThisFeatEnabled = 'Disabled'}

                                                 Write-Debug ' Currently this feature is' $IsThisFeatEnabled

                                                 $Check = ($IsThisFeatEnabled -eq $_.State)
                                                 Write-Debug ' Does this match our desired state?' $Check

                                                 If ($Check -eq $false) 
                                                        {If ($IsThisFeatEnabled -eq 'Enabled') 
                                                                {Write-Debug ' Disabling Feature.'
                                                                 &Dism /online /Disable-Feature /FeatureName:$WinFeat /norestart
                                                                 Write-Debug " Exit code is $LASTEXITCODE"
                                                                 $WinFeat >> $VMRScriptLog
                                                                 $LASTEXITCODE >> $VMRScriptLog
                                                                 If ($LASTEXITCODE -ne 0)
                                                                         {$ArrayScriptExitResult += $LASTEXITCODE}}

                                                         If ($IsThisFeatEnabled -eq 'Disabled') 
                                                                {Write-Debug ' Enabling Feature.'
                                                                 &Dism /online /Enable-Feature /FeatureName:$WinFeat /norestart /Source:"$DismSource" /LimitAccess
                                                                 Write-Debug " Exit code is $LASTEXITCODE"
                                                                 $WinFeat >> $VMRScriptLog
                                                                 $LASTEXITCODE >> $VMRScriptLog
                                                                 If ($LASTEXITCODE -ne 0)
                                                                       {$ArrayScriptExitResult += $LASTEXITCODE}}}}}
                                       Else{$DismSource = "$VMRCollateral\SxS Windows OS Version 10.0 64-Bit"
                                            ForEach ($_ in $ConfigureFeatures) 
                                                {Start-Sleep -Seconds 1
                                                 Write-Debug 'Checking Feature' $_.WindowsFeature 'is' $_.State
                                                 $WinFeat = $_.WindowsFeature
                                                 $DismCheck = &Dism /online /Get-FeatureInfo /FeatureName:$WinFeat
                                                 $IsThisFeatEnabled = $DismCheck -contains "State : Enabled"

                                                 If ($IsThisFeatEnabled -eq $true)
                                                        {$IsThisFeatEnabled = 'Enabled'}
                                                    Else{$IsThisFeatEnabled = 'Disabled'}

                                                 Write-Debug ' Currently this feature is' $IsThisFeatEnabled

                                                 $Check = ($IsThisFeatEnabled -eq $_.State)
                                                 Write-Debug ' Does this match our desired state?' $Check

                                                 If ($Check -eq $false) 
                                                        {If ($IsThisFeatEnabled -eq 'Enabled') 
                                                                {Write-Debug ' Disabling Feature.'
                                                                 &Dism /online /Disable-Feature /FeatureName:$WinFeat /norestart
                                                                 Write-Debug " Exit code is $LASTEXITCODE"
                                                                 $WinFeat >> $VMRScriptLog
                                                                 $LASTEXITCODE >> $VMRScriptLog
                                                                 If ($LASTEXITCODE -ne 0)
                                                                         {$ArrayScriptExitResult += $LASTEXITCODE}}

                                                         If ($IsThisFeatEnabled -eq 'Disabled') 
                                                                {Write-Debug ' Enabling Feature.'
                                                                 &Dism /online /Enable-Feature /FeatureName:$WinFeat /norestart /Source:"$DismSource" /LimitAccess
                                                                 Write-Debug " Exit code is $LASTEXITCODE"
                                                                 $WinFeat >> $VMRScriptLog
                                                                 $LASTEXITCODE >> $VMRScriptLog
                                                                 If ($LASTEXITCODE -ne 0)
                                                                       {$ArrayScriptExitResult += $LASTEXITCODE}}}}}}
              '*Windows 8.1*'      {Write-Output ''}
              '*Windows 8*'        {Write-Output ''}
              '*Windows 7*'        {ForEach ($_ in $ConfigureFeatures) 
                                        {Start-Sleep -Seconds 1
                                         Write-Debug 'Checking Feature' $_.WindowsFeature 'is' $_.State
                                         $WinFeat = $_.WindowsFeature
                                         $DismCheck = &Dism /online /Get-FeatureInfo /FeatureName:$WinFeat
                                         $IsThisFeatEnabled = $DismCheck -contains "State : Enabled"

                                         If ($IsThisFeatEnabled -eq $true)
                                                {$IsThisFeatEnabled = 'Enabled'}
                                            Else{$IsThisFeatEnabled = 'Disabled'}

                                         Write-Debug ' Currently this feature is' $IsThisFeatEnabled

                                         $Check = ($IsThisFeatEnabled -eq $_.State)
                                         Write-Debug ' Does this match our desired state?' $Check

                                         If ($Check -eq $false) 
                                                {If ($IsThisFeatEnabled -eq 'Enabled') 
                                                        {Write-Debug ' Disabling Feature.'
                                                         &Dism /online /Disable-Feature /FeatureName:$WinFeat /norestart
                                                         Write-Debug " Exit code is $LASTEXITCODE"
                                                         $WinFeat >> $VMRScriptLog
                                                         $LASTEXITCODE >> $VMRScriptLog
                                                         If ($LASTEXITCODE -ne 0)
                                                                 {$ArrayScriptExitResult += $LASTEXITCODE}}

                                                 If ($IsThisFeatEnabled -eq 'Disabled') 
                                                        {Write-Debug ' Enabling Feature.'
                                                         &Dism /online /Enable-Feature /FeatureName:$WinFeat /norestart
                                                         Write-Debug " Exit code is $LASTEXITCODE"
                                                         $WinFeat >> $VMRScriptLog
                                                         $LASTEXITCODE >> $VMRScriptLog
                                                         If ($LASTEXITCODE -ne 0)
                                                               {$ArrayScriptExitResult += $LASTEXITCODE}}}}}
              '*Server 2016*'      {Write-Output ''}
              '*Server 2012 R2*'   {Write-Output ''}
              '*Server 2012*'      {Write-Output ''}
              '*Server 2008 R2*'   {Write-Output ''}
              Default              {Write-Warning 'Unknown Operating System'}}

         Write-Debug 'End time is' (Get-Date)}
    Else{Write-Debug 'The CSV path is not valid.'
         $ArrayScriptExitResult += 'Error'
         Exit}

$SuccessCodes = @('Example','0','3010','True')                                                    #List all success codes, including reboots here.
$SuccessButNeedsRebootCodes = @('Example','3010')                                                 #List success but needs reboot code here.
$ScriptError = $ArrayScriptExitResult | Where-Object {$SuccessCodes -notcontains $_}              #Store errors found in this variable
$ScriptReboot = $ArrayScriptExitResult | Where-Object {$SuccessButNeedsRebootCodes -contains $_}  #Store success but needs reboot in this variable

If ($ScriptError -eq $null)                       #If ScriptError is empty, then everything processed ok.
        {If ($ScriptReboot -ne $null)             #If ScriptReboot is not empty, then everything processed ok, but just needs a reboot.
                {$ScriptExitResult = 'Reboot'}
            Else{$ScriptExitResult = '0'}}
    Else{$ScriptExitResult = 'Error'
         $ScriptError >> $VMRScriptLog}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}
     'Reboot'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'}
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>



<#
Virtual Machine Runner  -  Copyright (C) 2016-2017  -  Riley Lim

This program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the 
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, 
see <http://www.gnu.org/licenses/>.
#>
