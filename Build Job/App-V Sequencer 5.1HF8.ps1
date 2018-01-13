# Start Application Virtualization 5.1 Sequencer with Hotfix 8 Build ############################################
Write-Output 'Installing Application Virtualization 5.1 Sequencer with Hotfix 8.'
VMR_RunModule -Module Framework\Module_Software-App-V-Sequencer5.1HF8.ps1

Write-Output 'Creating Application Virtualization Sequencer shortcut with PVAD switch.'
VMR_RunModule -Module Framework\Module_Software-App-V-SequencerPVADShortcut.ps1

Write-Output 'Installing Application Virtualization Sequencer Custom Configuration.'
VMR_RunModule -Module Framework\Module_Software-App-V-SequencerConfiguration.ps1
#<<< End of Application Virtualization 5.1 Sequencer Build >>>



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
