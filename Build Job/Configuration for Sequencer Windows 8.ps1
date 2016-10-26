# Start Windows Installer Repackager Build ########################################################
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

#Removing Mordern Apps from Administrator.
Write-Output 'Removing Mordern Apps from Administrator.'
VMR_RunModule -Module Framework\Module_DesktopExperience-RemoveAppXPackages.ps1
#<<< End of Windows Installer Repackager Build >>>
