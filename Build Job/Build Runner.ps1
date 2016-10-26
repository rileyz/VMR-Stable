# Setting up housekeeping for virtual machine #####################################################
Write-Output 'Starting housekeeping actions, preparing virtual machine.'
#Setup VIX PS drive.
Write-Output 'Setting up VIX PS drive.'
If ((Test-Path VIX:\) -eq $false)
        {$null = New-PSDrive -name VIX -psprovider FileSystem -root 'C:\Program Files (x86)\VMware\VMware VIX'
         Set-Location VIX:
         Write-Verbose 'VIX PS drive is ready.'}
    Else{Write-Verbose 'No actions needed, VIX PS drive already mounted.'}

Foreach ($VM in $VMs)
   {#Creating safety snapshot for manual rollback if build fails.
    Write-Output ''
    Write-Output ''
    Write-Output 'Creating Pre-flight Safety Snapshot.'
    $VM_Snapshots = .\vmrun.exe -T ws listSnapshots $VM
    If ($VM_Snapshots -like 'Pre-flight Safety Snapshot')
            {Write-Verbose 'Pre-flight Safety Snapshot found.'}
        Else{Write-Verbose 'Pre-flight Safety Snapshot not found, creating snapshot.'
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Pre-flight Safety Snapshot'}
    
    #Start the target VM.
    Write-Output ' ·Starting the virtual machine.'
    Write-Debug "Staring virtual machine: `"$VM`""
    &.\vmrun -T ws start $VM

    #Waiting for VM to be ready.
    Write-Verbose 'Waiting for the virtual machine to be ready and checking credentials before proceeding.'
    $null = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword listProcessesInGuest $VM
    If ($LASTEXITCODE -eq 0)
            {Write-Verbose 'Credentials were OK, start test mount and unmount.'
             VMR_CreateJunctionPoint
             $VM_OperatingSystem = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword readVariable $VM guestEnv VMRWindowsOperatingSystem
             $VM_Architecture = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword readVariable $VM guestEnv VMRWindowsArchitecture
             $VM_Version = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword readVariable $VM guestEnv VMRWindowsVersion
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
    }
        Else{Write-Warning 'VMRun indicated there was a issue running the command, this could be caused by a bad password or'
             Write-Warning 'the Administrator account not being enabled on the virtual machine.' ; Continue}

    Write-Verbose 'Virtual machine prepared.'
    Write-Output ''
    Write-Output "All Housekeeping actions completed, ready to build on $VM_OperatingSystem $VM_Architecture."
    Write-Output ''
    #<<< End of Setting up housekeeping for virtual machine >>>



    # Start of Build Runner Logic #####################################################################
    If ($Repackager -or $AppVSeq5 -or $AppVClient5 -or $AppVClient5HF1 -or $AppVSeq5SP1 -or $AppVClient5SP1 -or $AppVClient5SP1HF3 -or $AppVSeq5SP2 -or $AppVClient5SP2 -or $AppVClient5SP2HF2 -or $AppVSeq5SP2HF4 -or $AppVClient5SP2HF4 -or $AppVClient5SP2HF5 -eq $true)
            {$Base = $true}
        Else{$Base = $null}

    If ($AppVSeq5SP3 -or $AppVClient5SP3 -or $AppVClient5SP3HF2 -or $AppVClient5SP3HF3 -or $AppVSeq51 -or $AppVClient51 -or $AppVClient51HF1 -or $AppVClient51HF2 -or $AppVClient51HF4 -eq $true)
            {$Base5SP3 = $true}
        Else{$Base5SP3 = $null}

    If ($Base -eq $true)
            {. "$VMRScriptLocation\Build Job\Configuration Base for VMware Optimisation.ps1"
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint


             Switch -Wildcard ($VM_OperatingSystem)
                 {'*Windows 10*'       {Write-Output 'Running configuration base for Windows 10.'
                                        . "$VMRScriptLocation\Build Job\Configuration Base for Windows 10.ps1" ; Break}
                  '*Windows 8.1*'      {Write-Output 'Running configuration base for Windows 8.1, using 8 base.'
                                        . "$VMRScriptLocation\Build Job\Configuration Base for Windows 8.ps1" ; Break}
                  '*Windows 8*'        {Write-Output 'Running configuration base for Windows 8.'
                                        . "$VMRScriptLocation\Build Job\Configuration Base for Windows 8.ps1" ; Break}
                  '*Windows 7*'        {Write-Output 'Running configuration base for Windows 7.'
                                        . "$VMRScriptLocation\Build Job\Configuration Base for Windows 7.ps1" ; Break}
                  '*Server 2016*'      {Write-Output 'Running configuration base for Windows Server 2016.'
                                        . "$VMRScriptLocation\Build Job\Configuration Base for Windows Server 2016.ps1" ; Break}
                  '*Server 2012 R2*'   {Write-Output 'Running configuration base for Windows Server 2012.'
                                        . "$VMRScriptLocation\Build Job\Configuration Base for Windows Server 2012.ps1" ; Break}
                  '*Server 2012*'      {Write-Output 'Running configuration base for Windows Server 2012.'
                                        . "$VMRScriptLocation\Build Job\Configuration Base for Windows Server 2012.ps1" ; Break}
                  '*Server 2008 R2*'   {Write-Output 'Running configuration base for Windows Server 2008 R2.'
                                        . "$VMRScriptLocation\Build Job\Configuration Base for Windows Server 2008 R2.ps1" ; Break}
                  Default              {Write-Warning 'Unknown Operating System'}}
         
             . "$VMRScriptLocation\Build Job\App-V Prerequisites 5.0.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'App-V 5.0 Base'}
         Else{If ($Base5SP3 -eq $true) 
                      {. "$VMRScriptLocation\Build Job\Configuration Base for VMware Optimisation.ps1"
                       VMWarePowerControl -Start
                       VMR_CreateJunctionPoint

                       Switch -Wildcard ($VM_OperatingSystem)
                           {'*Windows 10*'       {Write-Output 'Running configuration base for Windows 10.'
                                                  . "$VMRScriptLocation\Build Job\Configuration Base for Windows 10.ps1" ; Break}
                            '*Windows 8.1*'      {Write-Output 'Running configuration base for Windows 8.1, using 8 base.'
                                                  . "$VMRScriptLocation\Build Job\Configuration Base for Windows 8.ps1" ; Break}
                            '*Windows 8*'        {Write-Output 'Running configuration base for Windows 8.'
                                                  . "$VMRScriptLocation\Build Job\Configuration Base for Windows 8.ps1" ; Break}
                            '*Windows 7*'        {Write-Output 'Running configuration base for Windows 7.'
                                                  . "$VMRScriptLocation\Build Job\Configuration Base for Windows 7.ps1" ; Break}
                            '*Server 2016*'      {Write-Output 'Running configuration base for Windows Server 2016.'
                                                  . "$VMRScriptLocation\Build Job\Configuration Base for Windows Server 2016.ps1" ; Break}
                            '*Server 2012 R2*'   {Write-Output 'Running configuration base for Windows Server 2012.'
                                                  . "$VMRScriptLocation\Build Job\Configuration Base for Windows Server 2012.ps1" ; Break}
                            '*Server 2012*'      {Write-Output 'Running configuration base for Windows Server 2012.'
                                                  . "$VMRScriptLocation\Build Job\Configuration Base for Windows Server 2012.ps1" ; Break}
                            '*Server 2008 R2*'   {Write-Output 'Running configuration base for Windows Server 2008 R2.'
                                                  . "$VMRScriptLocation\Build Job\Configuration Base for Windows Server 2008 R2.ps1" ; Break}
                            Default              {Write-Warning 'Unknown Operating System'}}
         
                       . "$VMRScriptLocation\Build Job\App-V Prerequisites 5.0.ps1"
                       . "$VMRScriptLocation\Build Job\App-V Prerequisites 5.0SP3.ps1"
                       . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
                       VMR_RemoveJunctionPoint
                       VMWarePowerControl -SoftStop
                       VMWareSnapshotControl -TakeSnapshot -SnapshotName 'App-V 5SP3 Base'}}

    If ($Repackager -eq $true)
            {VMWarePowerControl -Start
             VMR_CreateJunctionPoint

             Switch -Wildcard ($VM_OperatingSystem)
                 {'*Windows 10*'       {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 10.ps1" ; Break}
                  '*Windows 8.1*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 8*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 7*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 7.ps1" ; Break}
                  '*Server 2016*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2016.ps1" ; Break}
                  '*Server 2012 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2012*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2008 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2008 R2.ps1" ; Break}
                  Default              {Write-Warning 'Unknown Operating System'}}

             . "$VMRScriptLocation\Build Job\Applications Repackager Client.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Repackager'}

    If ($AppVSeq5 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint

             Switch -Wildcard ($VM_OperatingSystem)
                 {'*Windows 10*'       {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 10.ps1" ; Break}
                  '*Windows 8.1*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 8*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 7*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 7.ps1" ; Break}
                  '*Server 2016*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2016.ps1" ; Break}
                  '*Server 2012 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2012*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2008 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2008 R2.ps1" ; Break}
                  Default              {Write-Warning 'Unknown Operating System'}}

             . "$VMRScriptLocation\Build Job\App-V Sequencer 5.0.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Sequencer 5.0'}

    If ($AppVClient5 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0'}

    If ($AppVClient5HF1 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0HF1.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0HF1'}

    If ($AppVSeq5SP1 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint

             Switch -Wildcard ($VM_OperatingSystem)
                 {'*Windows 10*'       {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 10.ps1" ; Break}
                  '*Windows 8.1*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 8*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 7*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 7.ps1" ; Break}
                  '*Server 2016*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2016.ps1" ; Break}
                  '*Server 2012 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2012*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2008 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2008 R2.ps1" ; Break}
                  Default              {Write-Warning 'Unknown Operating System'}}

             . "$VMRScriptLocation\Build Job\App-V Sequencer 5.0SP1.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Sequencer 5.0SP1'}

    If ($AppVClient5SP1 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0SP1.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0SP1'}

    If ($AppVClient5SP1HF3 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0SP1HF3.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0SP1HF3'}

    If ($AppVSeq5SP2 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint

             Switch -Wildcard ($VM_OperatingSystem)
                 {'*Windows 10*'       {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 10.ps1" ; Break}
                  '*Windows 8.1*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 8*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 7*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 7.ps1" ; Break}
                  '*Server 2016*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2016.ps1" ; Break}
                  '*Server 2012 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2012*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2008 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2008 R2.ps1" ; Break}
                  Default              {Write-Warning 'Unknown Operating System'}}

             . "$VMRScriptLocation\Build Job\App-V Sequencer 5.0SP2.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Sequencer 5.0SP2'}

    If ($AppVClient5SP2 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0SP2.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0SP2'}

    If ($AppVClient5SP2HF2 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0SP2HF2.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0SP2HF2'}

    If ($AppVSeq5SP2HF4 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint

             Switch -Wildcard ($VM_OperatingSystem)
                 {'*Windows 10*'       {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 10.ps1" ; Break}
                  '*Windows 8.1*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 8*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 7*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 7.ps1" ; Break}
                  '*Server 2016*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2016.ps1" ; Break}
                  '*Server 2012 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2012*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2008 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2008 R2.ps1" ; Break}
                  Default              {Write-Warning 'Unknown Operating System'}}

             . "$VMRScriptLocation\Build Job\App-V Sequencer 5.0SP2HF4.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Sequencer 5.0SP2HF4'}

    If ($AppVClient5SP2HF4 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0SP2HF4.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0SP2HF4'}

    If ($AppVClient5SP2HF5 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0SP2HF5.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0SP2HF5'}

    If ($Base -and $Base5SP3 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5.0 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Prerequisites 5.0SP3.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'App-V 5SP3 Base'}

    If ($AppVSeq5SP3 -eq $true)
            {VMWarePowerControl -Start
             VMR_CreateJunctionPoint

             Switch -Wildcard ($VM_OperatingSystem)
                 {'*Windows 10*'       {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 10.ps1" ; Break}
                  '*Windows 8.1*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 8*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 7*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 7.ps1" ; Break}
                  '*Server 2016*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2016.ps1" ; Break}
                  '*Server 2012 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2012*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2008 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2008 R2.ps1" ; Break}
                  Default              {Write-Warning 'Unknown Operating System'}}

             . "$VMRScriptLocation\Build Job\App-V Sequencer 5.0SP3.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Sequencer 5.0SP3'}

    If ($AppVClient5SP3 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5SP3 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0SP3.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0SP3'}

    If ($AppVClient5SP3HF2 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5SP3 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0SP3HF2.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0SP3HF2'}

    If ($AppVClient5SP3HF3 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5SP3 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.0SP3HF3.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.0SP3HF3'}

    If ($AppVSeq51 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5SP3 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint

             Switch -Wildcard ($VM_OperatingSystem)
                 {'*Windows 10*'       {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 10.ps1" ; Break}
                  '*Windows 8.1*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 8*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 8.ps1" ; Break}
                  '*Windows 7*'        {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows 7.ps1" ; Break}
                  '*Server 2016*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2016.ps1" ; Break}
                  '*Server 2012 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2012*'      {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2012.ps1" ; Break}
                  '*Server 2008 R2*'   {. "$VMRScriptLocation\Build Job\Configuration for Sequencer Windows Server 2008 R2.ps1" ; Break}
                  Default              {Write-Warning 'Unknown Operating System'}}

             . "$VMRScriptLocation\Build Job\App-V Sequencer 5.1.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Sequencer 5.1'}

    If ($AppVClient51 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5SP3 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.1.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.1'}

    If ($AppVClient51HF1 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5SP3 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.1HF1.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.1HF1'}

    If ($AppVClient51HF2 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5SP3 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.1HF2.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.1HF2'}

    If ($AppVClient51HF4 -eq $true)
            {VMWareSnapshotControl -RevertSnapshot -SnapshotName 'App-V 5SP3 Base'
             VMWarePowerControl -Start
             VMR_CreateJunctionPoint
             . "$VMRScriptLocation\Build Job\App-V Client 5.1HF4.ps1"
             . "$VMRScriptLocation\Build Job\Common Task to Optimise and Clean Up.ps1"
             VMR_RemoveJunctionPoint
             VMWarePowerControl -SoftStop
             VMWareSnapshotControl -TakeSnapshot -SnapshotName 'Client 5.1HF4'}

    Invoke-Item $VM
}
    #<<< End of Build Runner Logic >>>
