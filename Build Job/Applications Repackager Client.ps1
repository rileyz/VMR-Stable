# Start Windows Installer Repackager Build ########################################################
Write-Output 'Setting Wallpaper for Administrator.'
VMR_RunModule -Module Framework\Module_DesktopExperience-SetWallPaper.ps1 -Arguments "-Wallpaper 'Repackager.jpg' -PicturePosition 'Center' -DesktopColour '10 59 118'"

Write-Output 'Installing AppDeploy Repackager.'
VMR_RunModule -Module Framework\Module_Software-AppDeployRepackager.ps1

Write-Output 'Installing InstEd.'
VMR_RunModule -Module Framework\Module_Software-InstEd.ps1

Write-Output 'Installing Installshield Repackager.'
VMR_RunModule -Module Framework\Module_Software-InstallshieldRepackager.ps1
#<<< End of Windows Installer Repackager Build >>>



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
