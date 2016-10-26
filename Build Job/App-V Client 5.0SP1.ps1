# Start Application Virtualization 5.0 Client with Service Pack 1 Build ###########################
Write-Output 'Installing Application Virtualization 5.0 Client with Service Pack 1.'
VMR_RunModule -Module Framework\Module_Software-App-V-Client5.0SP1.ps1

Write-Output 'Installing Application Virtualization Client Custom Configuration.'
VMR_RunModule -Module Framework\Module_Software-App-V-ClientConfiguration.ps1
#<<< End of Application Virtualization 5.0 Client with Service Pack 1 Build >>>
