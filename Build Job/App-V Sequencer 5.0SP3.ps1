# Start Application Virtualization 5.0 Sequencer with Service Pack 3 Build ########################
Write-Output 'Installing Application Virtualization 5.0 Sequencer with Service Pack 3.'
VMR_RunModule -Module Framework\Module_Software-App-V-Sequencer5.0SP3.ps1

Write-Output 'Installing Application Virtualization Sequencer Custom Configuration.'
VMR_RunModule -Module Framework\Module_Software-App-V-SequencerConfiguration.ps1
#<<< End of Application Virtualization 5.0 Sequencer with Service Pack 3 Build >>>
