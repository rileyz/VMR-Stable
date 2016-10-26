# Start Application Virtualization 5.0 Client with Hotfix 1 Build #################################
Write-Output 'Installing Application Virtualization 5.0 Client.'
VMR_RunModule -Module Framework\Module_Software-App-V-Client5.0.ps1

Write-Output 'Installing Application Virtualization 5.0, Hotfx 1.'
VMR_RunModule -Module Framework\Module_Software-App-V-Client5.0HF1.ps1

Write-Output 'Installing Application Virtualization Client Custom Configuration.'
VMR_RunModule -Module Framework\Module_Software-App-V-ClientConfiguration.ps1
#<<< End of Application Virtualization 5.0 Client with Hotfix 1 Build >>>
