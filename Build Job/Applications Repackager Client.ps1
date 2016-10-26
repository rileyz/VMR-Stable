# Start Windows Installer Repackager Build ########################################################
Write-Output 'Setting Wallpaper for Administrator.'
VMR_RunModule -Module Framework\Module_DesktopExperience-SetWallPaper.ps1 -Arguments "-Wallpaper 'Repackager.jpg' -PicturePosition 'Center' -DesktopColour '10 59 118'"

Write-Output 'Installing AppDeploy Repackager.'
VMR_RunModule -Module Framework\Module_Software-AppDeployRepackager.ps1

Write-Output 'Installing InstEd.'
VMR_RunModule -Module Framework\Module_Software-InstEd.ps1

Write-Output 'Installing Installshield Repackager 11.5.'
VMR_RunModule -Module Custom\Module_Custom-InstallshieldRepackager11.5.ps1
#<<< End of Windows Installer Repackager Build >>>
