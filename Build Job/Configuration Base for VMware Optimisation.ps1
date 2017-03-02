# Start Configuration Base for VMware Optimisation ################################################
Function UpdateVMX{
    Param ([System.Collections.ArrayList]$VMX,
           [String] $ConfigurationItem,
           [String] $Value)

    If (($Element = (0..($VMX.Count-1)) | where {$VMX[$_] -like "*$ConfigurationItem*"}) -ne $null)
            {$VMX[$Element] = "$ConfigurationItem = `"$Value`""}
        Else{$VMX += "$ConfigurationItem = `"$Value`""}
    Return $VMX
 } #End Function VMwareUpdateVMX

Write-Output 'Applying VMware optimisations.'
Write-Verbose '  Loading VMware virtual machine configuration file into memory.'
[System.Collections.ArrayList]$VMXFileInMemory = Get-Content "$VM"

If ($VM_DisableScreenScaling -eq $true)
        {Write-Output '  Disabling screen scaling via .vmx configuration file.'
         Write-Output '   This disables VMware from applying host screen scaling to the virtual machine.'
         [System.Collections.ArrayList]$VMXFileInMemory = UpdateVMX -VMX $VMXFileInMemory -ConfigurationItem 'gui.applyHostDisplayScalingToGuest' -Value 'FALSE'}

If ($VM_OptimiseIOPerformance -eq $true)
        {Write-Output '  Optimising disk I/O performance via .vmx configuration file.'
         Write-Output '   This requires the host to have a lot of RAM, please insure you meet the requirements.'
         Write-Output '   https://www.vmware.com/support/ws55/doc/ws_performance_diskio.html'
         Write-Output '   http://kb.vmware.com/kb/1008885'
         [System.Collections.ArrayList]$VMXFileInMemory = UpdateVMX -VMX $VMXFileInMemory -ConfigurationItem 'MemTrimRate' -Value '0'
         [System.Collections.ArrayList]$VMXFileInMemory = UpdateVMX -VMX $VMXFileInMemory -ConfigurationItem 'mainMem.useNamedFile' -Value 'FALSE'
         [System.Collections.ArrayList]$VMXFileInMemory = UpdateVMX -VMX $VMXFileInMemory -ConfigurationItem 'sched.mem.pshare.enable' -Value 'FALSE'
         [System.Collections.ArrayList]$VMXFileInMemory = UpdateVMX -VMX $VMXFileInMemory -ConfigurationItem 'prefvmx.useRecommendedLockedMemSize' -Value 'TRUE'
         Write-Verbose 'Disk I/O performance optimisations have been applied.'}

If ($VM_EmptyDVDDrive -eq $true)
        {Write-Output '  Ensuring first available virtual DVD drive is empty.'
         Write-Output '   If more than one DVD drive is available, it will not be checked.'
         [System.Collections.ArrayList]$VMXFileInMemory = UpdateVMX -VMX $VMXFileInMemory -ConfigurationItem 'sata0:1.deviceType' -Value 'cdrom-raw'
         [System.Collections.ArrayList]$VMXFileInMemory = UpdateVMX -VMX $VMXFileInMemory -ConfigurationItem 'sata0:1.fileName' -Value 'auto detect'
         [System.Collections.ArrayList]$VMXFileInMemory = UpdateVMX -VMX $VMXFileInMemory -ConfigurationItem 'sata0:1.startConnected' -Value 'FALSE'}

Start-Sleep -Seconds 1

Write-Verbose 'Writing VMware virtual machine configuration file into to file.'
$VMXFileInMemory | Set-Content $VM

Write-Verbose 'VMware optimisations applied.'
#<<< End of Configuration Base for VMware Optimisation >>>



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
