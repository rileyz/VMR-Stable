# Shared Sequencer Configuration Windows 8 Build ##################################################
#Setting Wallpaper for Administrator.
Write-Output 'Setting Wallpaper for Administrator.'
VMR_RunModule -Module Framework\Module_DesktopExperience-SetWallPaper.ps1 -Arguments "-Wallpaper 'Sequencer.jpg' -PicturePosition 'Center' -DesktopColour '229 115 0'"

#Configure Windows Services.
Write-Output 'Configure Windows Services: SequencerConfiguration_Windows8.csv'
VMR_RunModule -Module Framework\Module_Windows-Services-GlobalConfigure.ps1 -Arguments '-WindowsServicesCSV SequencerConfiguration_Windows8.csv'

#Disable Action Centre Notifications.
Write-Output 'Disable Action Centre Notifications.'
VMR_RunModule -Module Framework\Module_Windows-HelpTips-GlobalDisable.ps1

#Disable Windows Defender.
Write-Output 'Disable Windows Defender.'
VMR_RunModule -Module Framework\Module_Windows-WindowsDefender-GlobalDisable.ps1

#Removing Modern Apps from Administrator.
Write-Output 'Removing Modern Apps from  Administrator.'
VMR_RunModule -Module Framework\Module_DesktopExperience-RemoveAppXPackages.ps1
#<<< End of Shared Sequencer Configuration Windows 8 Build >>>



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
