# Shared Sequencer Configuration Windows 7 ########################################################
#Setting Wallpaper for Administrator.
Write-Output 'Setting Wallpaper for Sequencer.'
VMR_RunModule -Module Framework\Module_DesktopExperience-SetWallPaper.ps1 -Arguments "-Wallpaper 'Sequencer.jpg' -PicturePosition 'Center' -DesktopColour '229 115 0'"

#Configure Windows Services.
Write-Output 'Configure Windows Services: SequencerConfiguration_Windows7.csv'
VMR_RunModule -Module Framework\Module_Windows-Services-GlobalConfigure.ps1 -Arguments '-WindowsServicesCSV SequencerConfiguration_Windows7.csv'

#Disable Action Centre Notifications.
Write-Output 'Disable Action Centre Notifications.'
VMR_RunModule -Module Framework\Module_Windows-HelpTips-GlobalDisable.ps1
#<<< End of Shared Sequencer Configuration Windows 7 >>>
