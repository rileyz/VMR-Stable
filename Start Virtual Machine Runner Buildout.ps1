<#
.SYNOPSIS
    Automated building of virtual machines with snapshots for recapturing, App-V sequencing and
    App-V package testing.


.DESCRIPTION
Intended Use
    This build tool was produced save me time, because we all want to be lazy and not build a 
    sequencer everytime we change contracts or move to different client sites.

Quick Guide
    Setup your virtual machines as mentioned in the documentation. Update the user modifiable
    variables for desired build outcome, hit play when you're ready to build. 

Release Version
    0.02 - Andorra - 01/03/2017
 
Copyright & Intellectual Property
    Feel to copy, modify and redistribute, but please pay credit where it is due.
    Feed back is welcome, please contact me on LinkedIn. 
 

.LINK
Author:.......http://www.linkedin.com/in/rileylim
 Source Code:..https://github.com/rileyz
#>



# Setting up housekeeping for variables ###########################################################
Clear-Host
Write-Output '** Start Virtual Machine Runner Build **' `r
Write-Output 'Starting housekeeping actions, preparing variables.'
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

. "$ScriptPath\Virtual Machine Runner\Framework\Core_CommonFunctions.ps1"

$VMRCollateral = VMR_ScriptInformation -CollateralFolder
$VMRScriptLocation = VMR_ScriptInformation -ScriptFolder
$VMRScriptFile = VMR_ScriptInformation -ScriptName

$Source = "$VMRScriptLocation\Virtual Machine Runner"
$VMwareVIX = 'C:\Program Files (x86)\VMware\VMware VIX'
$VM_VMRTarget = 'C:\VirtualMachineRunner'
$VM_PowerShell = 'C:\Windows\System32\WindowsPowershell\v1.0\PowerShell.exe'
$VMs = (Get-FileName "C:\Users\$env:username\Documents\Virtual Machines\")
$GuestUserName  = 'Administrator'
$GuestPassword  = Get-Password                 #Note: Function and variable are not secure.

#User modifiable debugging variables.
$VerbosePreference        = 'SilentlyContinue' #SilentlyContinue|Continue
$DebugPreference          = 'SilentlyContinue' #SilentlyContinue|Continue
$BuildErrorPreference     = 'RetryThenSkip'    #Pause|RetryThenSkip|RetryThenStop|Stop
$BuildErrorRetryAttempts  = '7'                #Note: 0 for unlimited attempts
$PostBootWaitInterval     = '30'
$ForceRunUnprovenScripts  = $false

#User modifiable Virtual Machine Runner variables.
$VM_CleanUpDisks          = $true              #Note: Will preform VMware Workstation Clean up Disks.
$VM_DisableScreenScaling  = $true              #Note: Disables VMware Display Scaling to virtual machine.
$VM_EmptyDVDDrive         = $true              #Note: Ejects media from virtual machine DVD drive.
$VM_OptimiseIOPerformance = $true


$MimicHomeDrives    = 'H:Home'                 #None|H:Home
$MimicCommonDrives  = 'I:IT Dept,S:Shared'     #None|F:Finance Dept|I:IT Dept,S:Shared

$OfficeVersion      = 'Office2016_32'          #DoNotInstall|Office2013_32|Office2013_64|Office2016_32|Office2016_64

$Repackager         = $true

$AppVSeq5           = $true
$AppVClient5        = $true
$AppVClient5HF1     = $true

$AppVSeq5SP1        = $true
$AppVClient5SP1     = $true
$AppVClient5SP1HF3  = $true

$AppVSeq5SP2        = $true
$AppVClient5SP2     = $true
$AppVClient5SP2HF2  = $true

$AppVSeq5SP2HF4     = $true
$AppVClient5SP2HF4  = $true
$AppVClient5SP2HF5  = $true

$AppVSeq5SP3        = $true
$AppVClient5SP3     = $true
$AppVClient5SP3HF1  = $true
$AppVClient5SP3HF2  = $true
$AppVClient5SP3HF3  = $true

$AppVSeq51          = $true
$AppVClient51       = $true
$AppVClient51HF1    = $true
$AppVClient51HF2    = $true
$AppVClient51HF3    = $true
$AppVClient51HF4    = $true
$AppVClient51HF5    = $true
$AppVClient51HF6    = $true
$AppVClient51HF7    = $true

$AppVInBoxClient    = $true                    #Note: App-V Client is now part of the operating system.
$AppVADKSequencer   = $true                    #Note: Sequencer via the Windows Assessment and Deployment Kit.

Write-Verbose 'Variables prepared.'
#<<< End of Setting up housekeeping for variables >>>



# Start of build work ############################################################################
. "$ScriptPath\Build Job\Build Runner.ps1"

Write-Output ''
Write-Output '** THE END **'
#<<< End of build work >>>



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
