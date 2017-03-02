<#
.SYNOPSIS
    Removes the build environment variables and source folder.
 
.LINK
Author:.......http://www.linkedin.com/in/rileylim
#>



# Start of script work ############################################################################
$SymbolicLinkTarget = [Environment]::GetEnvironmentVariable("VMRSymbolicLinkTarget","Machine")

[Environment]::SetEnvironmentVariable("VMRStatus", "", "Machine")
[Environment]::SetEnvironmentVariable("VMRSymbolicLinkTarget", "", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsOperatingSystem", "", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsArchitecture", "", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsVersion", "", "Machine")

$RemoveJunction = Get-Item "$SymbolicLinkTarget"
$RemoveJunction.Delete()

If ((Test-Path $SymbolicLinkTargett) -eq $false)
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
