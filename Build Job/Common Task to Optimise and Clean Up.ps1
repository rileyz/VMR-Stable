# Start Optimise and Clean Up Build ###############################################################
Write-Output 'Running .Net 4.x Assemblies Optimisations.'
VMR_RunModule -Module Framework\Module_Windows-.Net4xFrameworkAssembliesOptimisations.ps1

Write-Output 'Removing temporary files to recover disk space.'
VMR_RunModule -Module Framework\Module_Windows-RecoverDiskSpace.ps1
#<<< End of Optimise and Clean Up Build >>>
