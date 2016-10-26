# Start Application Virtualization 5.0 Client with Service Pack 2 Hotfix 2 Build ##################
Write-Output 'Installing Application Virtualization 5.0 Client with Service Pack 2.'
VMR_RunModule -Module Framework\Module_Software-App-V-Client5.0SP2.ps1

Write-Output 'Installing Application Virtualization 5.0 Client with Service Pack 2, Hotfix 2.'
VMR_RunModule -Module Framework\Module_Software-App-V-Client5.0SP2HF2.ps1

Write-Output 'Installing Application Virtualization 5.0 Client UI for SP2 and greater'
VMR_RunModule -Module Framework\Module_Software-App-V-ClientUIApplication.ps1

Write-Output 'Installing Application Virtualization Client Custom Configuration.'
VMR_RunModule -Module Framework\Module_Software-App-V-ClientConfiguration.ps1
#<<< End of Application Virtualization 5.0 Client with Service Pack 2 Hotfix 2 Build >>>
