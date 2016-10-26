# Start Application Virtualization 5.0 Prerequisites ################################################
Write-Output 'Installing .Net 4 Framework.'
VMR_RunModule -Module Framework\Module_Windows-Component-.Net4.0.0Framework.ps1

Write-Output 'Installing Windows Critical Update KB2533623.'
VMR_RunModule -Module Framework\Module_Windows-WindowsUpdate-KB2533623.ps1

Write-Output 'Installing PowerShell 3.'
VMR_RunModule -Module Framework\Module_Windows-Component-PowerShell3.ps1
#<<< End of Application Virtualization 5.0 Prerequisites >>>
