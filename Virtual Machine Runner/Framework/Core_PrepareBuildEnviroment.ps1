<#
.SYNOPSIS
    Prepares the build environment variables and source folder.
 
.LINK
Author:.......http://www.linkedin.com/in/rileylim
#>



# Start of script work ############################################################################
$SymbolicLinkTarget = [Environment]::GetEnvironmentVariable("VMRSymbolicLinkTarget","User")
$OperatingSystem = ((Get-WmiObject win32_operatingsystem).Caption).TrimEnd()
$OperatingSystemArchitecture = (Get-WmiObject win32_operatingsystem).OSArchitecture
$OperatingSystemVersion = (Get-WmiObject -class Win32_OperatingSystem).Version

[Environment]::SetEnvironmentVariable("VMRSymbolicLinkTarget", "", "User")

[Environment]::SetEnvironmentVariable("VMRStatus", "Null", "Machine")
[Environment]::SetEnvironmentVariable("VMRSymbolicLinkTarget", "$SymbolicLinkTarget", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsOperatingSystem", "$OperatingSystem", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsArchitecture", "$OperatingSystemArchitecture", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsVersion", "$OperatingSystemVersion", "Machine")

$Arguments = '/C mklink /D ' + '"' + $SymbolicLinkTarget + '"' + ' "\\vmware-host\Shared Folders\Virtual Machine Runner"'
Start-Process -FilePath cmd.exe -ArgumentList "$Arguments" -Wait

#Removing artifact created by common function VMR_CreateJunctionPoint.
[Environment]::SetEnvironmentVariable("VMRTarget", "", "User")

If ((Test-Path $SymbolicLinkTarget) -eq $true)
        {Exit 0}
    Else{Exit 1}
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
