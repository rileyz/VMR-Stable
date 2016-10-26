# Shared Sequencer Configuration Windows Server 2008 R2 Build #####################################
#Setting Wallpaper for Administrator.
Write-Output 'Setting Wallpaper for Sequencer.'
VMR_RunModule -Module Framework\Module_DesktopExperience-SetWallPaper.ps1 -Arguments "-Wallpaper 'Sequencer.jpg' -PicturePosition 'Center' -DesktopColour '229 115 0'"

#Configure Windows Services.
Write-Output 'Configure Windows Services: SequencerConfiguration_WindowsServer2008R2.csv'
VMR_RunModule -Module Framework\Module_Windows-Services-GlobalConfigure.ps1 -Arguments '-WindowsServicesCSV SequencerConfiguration_WindowsServer2008R2.csv'
#<<< End of Shared Sequencer Configuration Windows Server 2008 R2 Build >>>
