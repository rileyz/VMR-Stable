# Start Application Virtualization 5.0 Prerequisites Build ########################################
Write-Output 'Installing .Net 4.5 Framework.'
VMR_RunModule -Module Framework\Module_Windows-Component-.Net4.5.2Framework.ps1

Write-Output 'Installing Windows Critical Update KB2533623.'
VMR_RunModule -Module Framework\Module_Windows-WindowsUpdate-KB2533623.ps1

Write-Output 'Installing PowerShell 3.'
VMR_RunModule -Module Framework\Module_Windows-Component-PowerShell3.ps1
#<<< End of Application Virtualization 5.0 Prerequisites Build >>>



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
