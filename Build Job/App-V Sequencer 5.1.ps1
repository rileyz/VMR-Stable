# Start Application Virtualization 5.1 Sequencer Build ############################################
Write-Output 'Installing Application Virtualization 5.1 Sequencer.'
VMR_RunModule -Module Framework\Module_Software-App-V-Sequencer5.1.ps1

Write-Output 'Installing Application Virtualization Sequencer Custom Configuration.'
VMR_RunModule -Module Framework\Module_Software-App-V-SequencerConfiguration.ps1
#<<< End of Application Virtualization 5.0 Sequencer Build >>>
