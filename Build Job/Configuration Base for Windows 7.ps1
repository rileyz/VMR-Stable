# Start Windows 7 Build ###########################################################################
Write-Output 'Adjusting Power Plan to High Preformace.'
VMR_RunModule -Module Framework\Module_Windows-PowerModeHighPreformace-GlobalEnable.ps1

Write-Output 'Disabling System Restore'
VMR_RunModule -Module Framework\Module_Windows-SystemProtection-GlobalDisable.ps1

Write-Output 'Installing Windows 7 Service Pack 1 on the virtual machine.'
VMR_RunModule -Module Framework\Module_Windows-WindowsUpdate-KB976932.ps1

Write-Output 'Installing April 2015 Servicing Stack update for Windows 7 Service Pack 1 on the virtual machine.'
VMR_RunModule -Module Framework\Module_Windows-WindowsUpdate-KB3020369.ps1

Write-Output 'Installing Convenience Rollup update for Windows 7 Service Pack 1 on the virtual machine.'
VMR_RunModule -Module Framework\Module_Windows-WindowsUpdate-KB3125574.ps1

Write-Output 'Installing Windows 7 updates via WSUSOffline.'
VMR_RunModule -RerunUntilComplete -WaitForWindowsUpdateWorkerProcess -Module Framework\Module_Windows-WindowsUpdate-WSUSOffline.ps1

Write-Output 'Adjusting Windows 7 Features.'
VMR_RunModule -Module Framework\Module_Windows-Features-GlobalConfigure.ps1 -Arguments '-WindowsFeaturesCSV BaseConfiguration_Windows7.csv'

Write-Output 'Configure Windows Services: BaseConfiguration_Windows7.csv.'
VMR_RunModule -Module Framework\Module_Windows-Services-GlobalConfigure.ps1 -Arguments '-WindowsServicesCSV BaseConfiguration_Windows7.csv'

Write-Output 'Configure Windows Task Schedules: SequencerConfiguration_Windows7.'
VMR_RunModule -Module Framework\Module_Windows-TaskScheduler-GlobalConfigure.ps1 -Arguments '-TaskSchedulesCSV BaseConfiguration_Windows7.csv'

Write-Output 'Disable Prefetch and Superfetch.'
VMR_RunModule -Module Framework\Module_Windows-PrefetchSuperfetch-GlobalDisable.ps1

Write-Output 'Importing Security Policy: RelaxPasswordPolicy.inf.'
VMR_RunModule -Module Framework\Module_Windows-SecurityPolicy-GlobalConfigure.ps1 -Arguments '-ImportPolicy RelaxPasswordPolicy.inf'

Write-Output 'Disable computer account password change.'
VMR_RunModule -Module Framework\Module_Windows-ComputerAccountPasswordChange-GlobalDisable.ps1

Write-Output 'Enable Remote Desktop Connection.'
VMR_RunModule -Module Framework\Module_DesktopExperience-EnableRemoteDesktopConnection.ps1

Write-Output 'Deleting User Accounts not needed as part of deployment.'
VMR_RunModule -Module Framework\Module_Windows-UserAccounts-Remove.ps1

Write-Output 'Creating Test User Accounts.'
VMR_RunModule -Module Framework\Module_Windows-UserAccounts-Add.ps1

Write-Output 'Enabling auto logon.'
VMR_RunModule -Module Framework\Module_Windows-UserAccounts-AutoLogon.ps1 -Arguments '-AutoLogonUserName Cached'

Write-Output 'Enabling auto logon.'
VMR_RunModule -Module Framework\Module_Windows-UserAccounts-AutoLogon.ps1 -Arguments "-AutoLogonUserName $GuestUserName -AutoLogonPassword $GuestPassword"

Write-Output 'Show hidden file types and extensions.'
VMR_RunModule -Module Framework\Module_DesktopExperience-ShowFileExtsAndHiddenFiles.ps1

Write-Output 'Enabling show all icons and notifications.'
VMR_RunModule -Module Framework\Module_DesktopExperience-ShowAllIconsAndNotifications.ps1

Write-Output 'Set Windows Update to Notify Before Download.'
VMR_RunModule -Module Framework\Module_Windows-WindowsUpdate-GlobalNotifyBeforeDownload.ps1

Write-Output 'Visual Effects to custom settings.'
VMR_RunModule -Module Framework\Module_DesktopExperience-VisualEffectsCustom.ps1

Write-Output 'Disable Internet Explorer first run wizard.'
VMR_RunModule -Module Framework\Module_Windows-InternetExplorerCustomiseOnFirstRun-GlobalDisable.ps1

Write-Output 'Set Internet Explorer to about:blank.'
VMR_RunModule -Module Framework\Module_DesktopExperience-ConfigureInternetExplorerHomePage.ps1

Write-Output 'Adding Repackaging Tools.'
VMR_RunModule -Module Custom\Module_Custom-PackagingTools.ps1

Write-Output 'Creating Binaries folder and shortcut.'
VMR_RunModule -Module Custom\Module_Custom-CreateMyBinariesFolder.ps1

Write-Output 'Installing Office Professional Plus 2013.'
VMR_RunModule -Module Framework\Module_Software-OfficeProfessionalPlus2013.ps1 -Arguments '-Offce32bit'

Write-Output 'Installing Windows 7 and Office updates via WSUSOffline.'
VMR_RunModule -RerunUntilComplete -Module Framework\Module_Windows-WindowsUpdate-WSUSOffline.ps1
#<<< End of Windows 7 Build >>>
