# Build Asset Inventorying ########################################################################
Param([String]$VMRBaseDirectory,
      [Boolean]$RunVerbose)
$ScriptPath = $VMRBaseDirectory 

If ($RunVerbose -eq $true) {$VerbosePreference = 'Continue'}

#Uncomment below if testing as standalone script. Switches current directory to correct location.
#$DebugPreference = 'SilentlyContinue' #SilentlyContinue|Continue
#$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
#$ScriptPath = "$ScriptPath\..\"

Set-Location $ScriptPath

Write-Verbose 'Starting asset checks.' *>&1
Write-Verbose 'Discovering Build Jobs.' *>&1
$BuildRunnerContent = Get-Content '.\Build Job\Build Runner.ps1' | Out-String
Write-Debug 'Variable details for $BuildRunnerContent.'
Write-Debug "Variable type is $($BuildRunnerContent.GetType()) and contains $($BuildRunnerContent.Length) lines."
Write-Debug 'Looking for all Build Jobs via RegEx.'
$RegEx = [RegEx]'Build Job.*?.ps1'
$UnfilteredBuildJobArray = Select-String -Pattern $RegEx -InputObject $BuildRunnerContent -AllMatches | foreach {$_.matches}

Write-Debug 'Cleaning each string in $UnfilteredBuildJobArray.'
$BuildJobArray = @()
Foreach ($Item in $UnfilteredBuildJobArray)
        {$Item = $Item.Value -creplace 'Build Job\\',''
         $BuildJobArray += $Item
         Write-Debug "    $Item"}

$BuildJobArray = $BuildJobArray | select -Unique
Write-Debug "    `$UnfilteredBuildJobArray count is: $($UnfilteredBuildJobArray.Count)"
Write-Debug "    `$BuildJobArray is $($BuildJobArray.Count)"

Write-Verbose 'Discovering Modules.' *>&1
Write-Debug 'Processing $BuildJobArray to discover each Module required in Build Job.' 
$DynamicBuildJobAssets = @()
Foreach ($Item_BJA in $BuildJobArray)
        {$BuildJob =  "$ScriptPath\Build Job\$Item_BJA"
         Write-Debug "Build Job: $Item_BJA"

         $BuildJobContents = Get-Content $BuildJob
         $BuildModuleArray = @($BuildJobContents | where { $_ -like 'VMR_RunModule -Module*'})

         Foreach ($Item_BMA in $BuildModuleArray)
                 {$Module = $Item_BMA
                  $Module = $Module -creplace 'VMR_RunModule -Module ',''
                  $Module = $Module -creplace '\.ps1*.*','.ps1'
                  $ModuleName = $Module -creplace '.*\\',''
                  $Module = "$ScriptPath\Virtual Machine Runner\$Module"

                  $TestPath = Test-Path $Module
                  Write-Debug "   Module: $ModuleName $($TestPath)"
                  
                  $CustomObject = New-Object System.Object
                  $CustomObject | Add-Member -type NoteProperty -name 'Build Job' -value $Item_BJA
                  $CustomObject | Add-Member -type NoteProperty -name 'Associated Asset' -value $ModuleName
                  $CustomObject | Add-Member -type NoteProperty -name 'Exists' -value $TestPath
                  $DynamicBuildJobAssets += $CustomObject}}
#To show RAW information for Build Job assets, uncomment below. This is a trusted source, the 
#Build Jobs are discovered from source folder, the Modules are discovered from the Build Jobs.
#$DynamicBuildJobAssets | Format-Table



#To pass unfiltered data to the next process switch the commenting below. Keep in mind this will
#cause reported errors in downstream workflow. 
#$ModuleArray = $DynamicBuildJobAssets | Select-Object 'Associated Asset', Exists -Unique | Sort-Object -Property 'Associated Asset'
$ModuleArray = $DynamicBuildJobAssets | Select-Object 'Associated Asset', Exists -Unique | where Exists -EQ $true | Sort-Object -Property 'Associated Asset'

#To show RAW information for unique modules, uncomment below. This is a trusted source, the Modules
#are derived from the above $DynamicBuildJobAssets.
#$ModuleArray | Format-Table



Write-Verbose 'Discovering Module assets.' *>&1
Write-Debug 'Processing $ModuleArray to discover each asset required in Module.'
$DynamicModuleAssets = @()
Foreach ($Item_MA in $ModuleArray)
        {If ($Item_MA.'Associated Asset' -like 'Module_Custom*')
                 {$Module = "$ScriptPath\Virtual Machine Runner\Custom\$($Item_MA.'Associated Asset')"}
             Else{$Module = "$ScriptPath\Virtual Machine Runner\Framework\$($Item_MA.'Associated Asset')"}
         
         Write-Debug "Module: $($Item_MA.'Associated Asset')"         
         $ModuleName = $Item_MA.'Associated Asset' -creplace '.ps1*.*'
         $BuildModuleContents = Get-Content $Module -ErrorAction SilentlyContinue
         $BuildAssetArray = @($BuildModuleContents | where { $_ -like '# Asset: *'})

         If ($BuildAssetArray.Count -gt 0)
                 {Write-Debug "   `$BuildAssetArray.Count was $($BuildAssetArray.Count)"
                  Foreach ($Item_BMAA in $BuildAssetArray)
                           {$ModuleAsset = $Item_BMAA
                            $ModuleAsset = $ModuleAsset -creplace '# Asset: ',''

                            $TestPath = Test-path "$ScriptPath\Virtual Machine Runner\Framework\$ModuleName\$ModuleAsset"
                            Write-Debug "   Asset: $ModuleAsset $($TestPath)"

                            $CustomObject = New-Object System.Object
                            $CustomObject | Add-Member -type NoteProperty -name 'Module' -value $Item_MA.'Associated Asset'
                            $CustomObject | Add-Member -type NoteProperty -name 'Associated Asset' -value $ModuleAsset
                            $CustomObject | Add-Member -type NoteProperty -name 'Exists' -value $TestPath
                            $DynamicModuleAssets += $CustomObject}}
              Else{Write-Debug '   $BuildAssetArray.Count was 0'
                   $BuildAssetArray = @($BuildModuleContents | where { $_ -like '# None'})
                   If ($BuildAssetArray.Count -eq 1) 
                           {Write-Debug '   No assets required for this script.'
                            $AssociatedAssetValue = 'None'
                            $ExistsValue = $null}
                       Else{Write-Debug '   WARNING: Asset information not defined!'
                            $AssociatedAssetValue = 'WARNING: Asset information not defined!'
                            $ExistsValue = 'Error'}

                   $CustomObject = New-Object System.Object
                   $CustomObject | Add-Member -type NoteProperty -name 'Module' -value $Item_MA.'Associated Asset'
                   $CustomObject | Add-Member -type NoteProperty -name 'Associated Asset' -value $AssociatedAssetValue
                   $CustomObject | Add-Member -type NoteProperty -name 'Exists' -value $ExistsValue
                   $DynamicModuleAssets += $CustomObject}}
#To show RAW information for Module assets, uncomment below. This is a trusted source, the assets
#are discovered from the Modules asset section.
#$DynamicModuleAssets | Format-Table



Write-Verbose 'Creating status report for Modules.' *>&1
Write-Debug 'Processing $DynamicModuleAssets to check each asset.'
$ModuleAssetStatus = @()
$LoopingView = $DynamicModuleAssets | Select-Object Module -Unique | Sort-Object -Property Module
Foreach ($Item in $LoopingView)
        {Write-Debug "Unique Module: $($Item.Module)"
         $CheckingView = $DynamicModuleAssets | select Module, 'Associated Asset', Exists | where Module -EQ $Item.Module | sort
         #$CheckingView | Format-Table

         If ($($CheckingView.'Exists').Count -eq 0)
                 {$Status = 'OK'
                  Write-Debug '   Module has no assets. Module OK.'}
             Else{If (($CheckingView.'Exists').Count -eq ($CheckingView.'Exists' | where {$_ -eq $true}).Count)
                          {$Status = 'OK'
                           Write-Debug '   Module OK.'}
                      Else{$Status = 'Errors Detected'
                           Write-Debug '   Errors dectected.'}}

         $CustomObject = New-Object System.Object
         $CustomObject | Add-Member -type NoteProperty -name 'Module' -value $Item.Module
         $CustomObject | Add-Member -type NoteProperty -name 'Status' -value $Status
         $ModuleAssetStatus += $CustomObject}
#To show RAW information for the status of module assets, uncomment below.
#$ModuleAssetStatus | Format-Table



Write-Verbose 'Creating status report for Build Jobs.' *>&1
Write-Debug 'Processing $DynamicBuildJobAssets to check each asset.'
$BuildJobStatus = @()
$LoopingView = $DynamicBuildJobAssets | Select-Object 'Build Job' -Unique | Sort-Object -Property 'Build Job'
Foreach ($Item in $LoopingView)
        {Write-Debug "Unique Build Job: $($Item.'Build Job')"
         $CheckingView = $DynamicBuildJobAssets | select 'Build Job', 'Associated Asset', Exists | where 'Build Job' -EQ $Item.'Build Job'
         #$CheckingView | Format-Table

         If (($CheckingView.'Build Job').Count -eq ($CheckingView.'Exists' -eq $true).Count -and ($CheckingView.'Build Job').Count -eq (($CheckingView.'Associated Asset' | ForEach-Object {$ModuleAssetStatus | select Module, Status | where Module -EQ $_}).Status -eq 'OK').Count)
                 {$Status = 'OK'
                  Write-Debug '   Build Job and its Associated Asset OK'}
             Else{$Status = 'Errors Detected'
                  Write-Debug '   Errors dectected.'}

         $CustomObject = New-Object System.Object
         $CustomObject | Add-Member -type NoteProperty -name 'Build Job' -value $Item.'Build Job'
         $CustomObject | Add-Member -type NoteProperty -name 'Status' -value $Status
         $BuildJobStatus += $CustomObject}
#To show RAW information for the status of Build Jobs, uncomment below.
#$BuildJobStatus | Format-Table



Write-Verbose 'Producing reports.' *>&1
$ErrorReport_DynamicBuildJobAssets = $DynamicBuildJobAssets | Select-Object 'Build Job', 'Associated Asset', Exists | where Exists -EQ $false | Sort-Object -Property 'Build Job' | Format-Table
$ErrorReport_DynamicModuleAssets = $DynamicModuleAssets     | Select-Object Module, 'Associated Asset', Exists | where Exists -EQ $false | Sort-Object -Property 'Module' | Format-Table

If ($ErrorReport_DynamicBuildJobAssets.Count -eq 0)
        {Write-Output ' No errors detected with Build Jobs.'}
    Else{Write-Warning 'Errors detected with Build Jobs.' *>&1} 

If ($ErrorReport_DynamicModuleAssets.Count -eq 0)
        {Write-Output ' No errors detected with Modules.'}
    Else{Write-Warning 'Errors detected with Modules.' *>&1} 

If ($RunVerbose -eq $true)
        {$BuildJobStatus | Format-Table
         $ModuleAssetStatus | Format-Table}

If (($ErrorReport_DynamicBuildJobAssets.Count) -gt 0) {$ErrorReport_DynamicBuildJobAssets | Format-Table} 
If (($ErrorReport_DynamicModuleAssets.Count) -gt 0) {$ErrorReport_DynamicModuleAssets | Format-Table}
#<<< End of Build Asset Inventorying >>>



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
