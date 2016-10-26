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
    0.01 - Initial Synchronisation - 26/10/2016
 
Copyright & Intellectual Property
    Feel to copy, modify and redistribute, but please pay credit where it is due.
    Feed back is welcome, please contact me on LinkedIn. 
 

.LINK
Author:.......http://www.linkedin.com/in/rileylim
 Source Code:..https://github.com/rileyz
#>



# Setting up housekeeping for variables ###########################################################
Clear-Host
Write-Output '** Start Virtual Machine Runner Build **'
Write-Output "Virtual Machine Runner script started at $(Get-Date)" `r
Write-Output 'Starting housekeeping actions, preparing variables.'
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

. "$ScriptPath\Virtual Machine Runner\Framework\Core_CommonFunctions.ps1"

$VMRCollateral = VMR_ScriptInformation -CollateralFolder
$VMRScriptLocation = VMR_ScriptInformation -ScriptFolder
$VMRScriptFile = VMR_ScriptInformation -ScriptName

$Source = "$VMRScriptLocation\Virtual Machine Runner"
$VM_VMRTarget = 'C:\VirtualMachineRunner'
$VM_PowerShell = 'C:\Windows\System32\WindowsPowershell\v1.0\PowerShell.exe'
$VMs = (Get-FileName -initialDirectory "C:\Users\$env:username\Documents\Virtual Machines\")

#User modifiable debugging variables.
$VerbosePreference        = 'Continue' #SilentlyContinue|Continue
$DebugPreference          = 'Continue' #SilentlyContinue|Continue
$BuildErrorPreference     = 'RetryThenSkip'    #Pause|RetryThenSkip|RetryThenStop|Stop
$BuildErrorRetryAttempts  = '7'                #0 for unlimited attempts
$ForceRunUnprovenScripts  = $false

#User modifiable Virtual Machine Runner variables.
$GuestUserName            = 'Administrator'
$GuestPassword            = 'PasswordChangeHere'
$VM_DisableScreenScaling  = $true              #Disables VMware Display Scaling to virtual machine.
$VM_EmptyDVDDrive         = $true              #Ejects media from virtual machine DVD drive.
$VM_OptimiseIOPerformance = $true

$PostBootWaitInterval = 30

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
$AppVClient5SP3HF2  = $true
$AppVClient5SP3HF3  = $true

$AppVSeq51          = $true
$AppVClient51       = $true
$AppVClient51HF1    = $true
$AppVClient51HF2    = $true
$AppVClient51HF4    = $true

Write-Verbose 'Variables prepared.'
#<<< End of Setting up housekeeping for variables >>>



# Start of build work ############################################################################
. "$ScriptPath\Build Job\Build Runner.ps1"

Write-Output ''
Write-Output '** THE END **'
Write-Output "Virtual Machine Runner script ended at $(Get-Date)"
#<<< End of build work >>>
