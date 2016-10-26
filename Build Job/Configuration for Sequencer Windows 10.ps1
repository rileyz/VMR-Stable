# Start Windows Installer Repackager Build ########################################################
#Setting Wallpaper for Administrator.
Write-Output 'Setting Wallpaper for Administrator.'
VMR_RunModule -Module Framework\Module_DesktopExperience-SetWallPaper.ps1 -Arguments "-Wallpaper 'Sequencer.jpg' -PicturePosition 'Center' -DesktopColour '229 115 0'"

#Configure Windows Services.
Write-Output 'Configure Windows Services: SequencerConfiguration_Windows10.csv'
VMR_RunModule -Module Framework\Module_Windows-Services-GlobalConfigure.ps1 -Arguments '-WindowsServicesCSV SequencerConfiguration_Windows10.csv'

#Disable Windows Defender.
Write-Output 'Disable Windows Defender.'
VMR_RunModule -Module Framework\Module_Windows-WindowsDefender-GlobalDisable.ps1

#Hide Windows 10 Search Box.
Write-Output 'Hide Windows 10 Search Box.'
VMR_RunModule -Module Framework\Module_DesktopExperience-ConfigureSearchBox.ps1
#<<< End of Windows Installer Repackager Build >>>
