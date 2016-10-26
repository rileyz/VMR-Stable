# Function List ###################################################################################
Function Get-FileName($InitialDirectory) {   
    Write-Verbose 'Initiating file selection.'
    $null = [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "VMware configuration files (*.vmx)|*.vmx|All files|*.*"
    $null = $OpenFileDialog.ShowDialog()
    Write-Debug 'File input string is:'
    Write-Debug $OpenFileDialog.filename

    Write-Verbose "Checking file selction variable is not null."
    If ([String]::IsNullOrEmpty($OpenFileDialog.filename) -eq $true)
            {Write-Warning 'No virtual machine was selected.' ; Break}

    $ExtCheck = $null
    $CheckCSVPaths = [ordered]@{}

    If ($OpenFileDialog.filename -match '.vmx$')
            {$ExtCheck = 'VMX'
             Write-Debug 'File input is a VMX file.'}

    If ($OpenFileDialog.filename -match '.csv$')
            {$ExtCheck = 'CSV'
             Write-Debug 'File input is a CSV file.'}

    Write-Verbose 'Starting stringent checks with the file.'
    Switch -Wildcard ($ExtCheck)
        {'VMX'    {If (Test-Path $OpenFileDialog.filename)
                           {$VerifyVMX = Get-Content $OpenFileDialog.filename -ErrorAction SilentlyContinue
                            If ($VerifyVMX -match '.vmdk' -and ($VerifyVMX -match 'displayName') -and ($VerifyVMX -match 'nvram'))
                                    {Write-Verbose 'Virtual machine path is valid.'}}
                       Else{Write-Warning 'Virtual machine path is not valid.' ; Break}
                   Write-Debug 'Returning VMX file path from function.'
                   $OpenFileDialog.filename} 
         'CSV'    {Get-Content $OpenFileDialog.filename| Where {$_.trim() -ne ""} | ForEach-Object {Write-Debug 'Stripping quotes, carriage returns, line feeds and showing result:'
                                                                                                    $_ = $_ -replace '"|`n|`r'

                                                                                                    Write-Debug (Test-Path $_)
                                                                                                    If (Test-Path $_) {$VerifyVMX = Get-Content $_ -ErrorAction SilentlyContinue
                                                                                                                                      If ($VerifyVMX -match '.vmdk' -and ($VerifyVMX -match 'displayName') -and ($VerifyVMX -match 'nvram'))
                                                                                                                                              {$TestResult = 'Valid'}
                                                                                                                                          Else{$TestResult = 'Invalid VMX...'}}
                                                                                                                                 Else{$TestResult = 'Invalid Path..'}
                                                                                                    $CheckCSVPaths.Add("$_", "$TestResult")}

                   If ($CheckCSVPaths.Values -contains 'Invalid Path..' -or ($CheckCSVPaths.Values -contains 'Invalid VMX...') -eq $true)
                           {$CheckCSVPaths.GetEnumerator() | ForEach-Object {If ($_.value -ne 'Valid')
                                                                                     {$CheckCSVPaths_Key = $_.Key 
                                                                                      $CheckCSVPaths_Value = $_.value
                                                                                      Write-Warning "$CheckCSVPaths_Value $CheckCSVPaths_Key"}}
                                                                                      Write-Warning 'Stopping build, please resolve the CSV issues.'}
                                                                                 Else{Write-Verbose 'Virtual machine list is valid.'
                                                                                      Write-Debug 'Returning array of paths from the function, without values from hash table.'
                                                                                      $CheckCSVPaths.Keys}}
         Default  {Write-Warning 'Function Get-FileName critical error on Switch statement.'
                   Write-Warning 'Please insure the file selected is correct.' ; Break}}
 
    #http://blogs.technet.com/b/heyscriptingguy/archive/2009/09/01/hey-scripting-guy-september-1.aspx

 } #End Function Get-FileName

Function VMR_CreateJunctionPoint{
    Write-Output 'Setting up Virtual Machine Runner folder.'
    $FileCheck = "$VM_VMRTarget\Framework\Core_CommonFunctions.ps1"
    $FileCheck = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword fileExistsInGuest $VM "$FileCheck"
    If ($FileCheck -eq 'The file exists.')
            {Write-Verbose 'The Virtual Machine Runner folder has already been mounted.'}
        Else{Write-Verbose 'Setting execution policy to bypass on the virtual machine to allow execution from UNC path.'
             $Arguments = 'Set-ExecutionPolicy -ExecutionPolicy Bypass -Force'
             &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword runProgramInGuest $VM $VM_PowerShell $Arguments
             VMwareVMRunResult
             
             Write-Verbose 'Enabling shared folders.'
             &.\vmrun enableSharedFolders $VM
             VMwareVMRunResult
             
             Write-Verbose 'Adding shared folder.'
             &.\vmrun addSharedFolder $VM 'Virtual Machine Runner' "$Source"
             VMwareVMRunResult
             
             Write-Verbose 'Prepare temporary "Core_PrepareBuildEnviroment" variable.'
             &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword writeVariable $VM guestEnv VMRSymbolicLinkTarget "$VM_VMRTarget"
             VMwareVMRunResult

             Write-Verbose 'Prepare build enviroment with "Core_PrepareBuildEnviroment" script.'
             $Arguments = "& '\\vmware-host\Shared Folders\Virtual Machine Runner\Framework\Core_PrepareBuildEnviroment.ps1'"
             &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword runProgramInGuest $VM $VM_PowerShell "$Arguments"
             VMwareVMRunResult
             If ($LASTEXITCODE -ne 0)
                     {Write-Warning 'Something went wrong with the Virtual Machine Runner junction point.'
                      Throw}

             Write-Verbose 'Setting execution policy to unrestricted on the virtual machine.'
             $Arguments = 'Set-ExecutionPolicy -ExecutionPolicy Bypass -Force'
             &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword runProgramInGuest $VM $VM_PowerShell $Arguments
             VMwareVMRunResult}

    Write-Verbose 'Ready for build work.'

 } #End Function VMR_CreateJunctionPoint

Function VMR_ProcessingModuleComplete{
    Param ([Parameter(Mandatory=$true)][String]$ModuleExitStatus)

    [Environment]::SetEnvironmentVariable("VMRStatus", "$ModuleExitStatus", "Machine")
 
 } #End Function VMR_ProcessingModuleComplete

Function VMR_ReadyMessagingEnvironment{
    [Environment]::SetEnvironmentVariable("VMRStatus", "Module Started", "Machine")
 
 } #End Function VMR_ReadyMessagingEnvironment

Function VMR_RemoveJunctionPoint{
    Write-Output 'Removing Virtual Machine Runner folder.'
    $FileCheck = "$VM_VMRTarget\Framework\Core_CommonFunctions.ps1"
    $FileCheck = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword fileExistsInGuest $VM "C:\VirtualMachineRunner\Framework\Core_CommonFunctions.ps1"
    If ($FileCheck -eq 'The file does not exist.')
            {Write-Verbose 'The Virtual Machine Runner folder has already been unmounted.'}
        Else{Write-Verbose 'Prepare snapshot enviroment with "Core_PrepareSnapshotEnviroment" script.'             
             $Arguments = "& '\\vmware-host\Shared Folders\Virtual Machine Runner\Framework\Core_PrepareSnapshotEnviroment.ps1'"
             &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword runProgramInGuest $VM $VM_PowerShell "$Arguments"
             VMwareVMRunResult
             If ($LASTEXITCODE -ne 0)
                     {Write-Warning 'Something went wrong with the Virtual Machine Runner junction point removal.'
                      Throw}}
        
             Write-Verbose 'Disabling shared folder.'
             &.\vmrun removeSharedFolder $VM 'Virtual Machine Runner'
             VMwareVMRunResult
        
             Write-Verbose 'Removing shared folders.'
             &.\vmrun disableSharedFolders $VM
             VMwareVMRunResult

     Write-Verbose 'Ready for snapshots.'

 } #End Function VMR_RemoveJunctionPoint

Function VMR_RunModule{
    Param ([Parameter(Mandatory=$true)][String]$Module,
                                       [String]$Arguments,
                                       [Switch]$RerunUntilComplete,
                                       [Switch]$WaitForWindowsUpdateWorkerProcess)

    $ScriptModule = $Source + '\' + $Module
    $Counter = 0
    $RetryAttemptsCounter = 0

    If ((Test-Path $ScriptModule -ErrorAction SilentlyContinue) -eq $false)
            {Write-Warning 'Script can not be found.'
             Write-Warning "Please check build job for $Module."
             Return}

    $LineStart = Select-String -Pattern '# Script Support #' -Path "$ScriptModule" | Select-Object LineNumber
    $LineEnd = Select-String -Pattern '#<<< End of Script Support >>>' -Path "$ScriptModule" | Select-Object LineNumber
    $Array = Get-Content -Path "$ScriptModule" | Select-Object -Index (($LineStart.LineNumber)..($LineEnd.LineNumber -2))
    $ScriptSupport = $null
    $ScriptSupport = @()

    Foreach ($_ in $Array)
        {$LineRecord = $_.split(",")
         $ScriptSupport +=, @($LineRecord[0],$LineRecord[1],$LineRecord[2])}

    Do {$ArrayRecord = $ScriptSupport[$Counter][0] | Out-String
        $ArrayRecord = "*$ArrayRecord*" -replace "`n|`r|# "
         
        If (($VM_OperatingSystem -replace "`n|`r") -like $ArrayRecord)
                {Write-Debug "Array match to $VM_OperatingSystem, use `$Counter value for array referance."
                 $Match = $true ; Break}
         
        $Counter ++}
        Until ($Counter -eq $ScriptSupport.Length)

    If ($Match -eq $true)
            {$QuerySupportOS = $ScriptSupport[$Counter][0]
             If ($VM_Architecture -eq '32-bit')
                     {$Supported = $ScriptSupport[$Counter][1]}
                 Else{$Supported = $ScriptSupport[$Counter][2]}
              
             Switch ($Supported)
                 {'Yes'        {Write-Verbose 'Module indicated it is supported on this operating system.'
                                $SkipModule = $false}
                  'No'         {Write-Verbose 'Module indicated it is not supported on this operating system.'
                                $SkipModule = $true}
                  'Unproven'   {If ($ForceRunUnprovenScripts -eq $true)
                                        {Write-Warning 'Force run unproven script is true, running script.'
                                         $SkipModule = $false}
                                    Else{Do    {Write-Warning 'Module is unproven on this operating system.'
                                                $RunUnproven = Read-Host '  Do you want to run the module and see what happens?'}
                                         Until ($RunUnproven -eq 'Y' -or ($RunUnproven -eq 'N'))           

                                         If ($RunUnproven -eq 'Y')
                                                 {Write-Output '  Running unproven script.'
                                                  $SkipModule = $false}
                                             Else{$SkipModule = $true}}}}}
        Else{Write-Warning 'No match made on operating system support, please check the script module to ensure this is complete.'
             $SkipModule = $true}
 
    If ($SkipModule -eq $true)
            {Write-Verbose 'Skipping module.'}
        Else{Do {If ($WaitForWindowsUpdateWorkerProcess -eq $true)
                        {Write-Verbose 'Checking for Windows Update worker processes and waiting if running.'
                         Do {$CheckProcessArray = @()
                             $VM_RunningProcesses = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword listProcessesInGuest $VM
                             If ((@($VM_RunningProcesses -like '*TrustedInstaller*').count -gt 0) -eq $true)
                                     {$CheckProcessArray += 1}
                             If ((@($VM_RunningProcesses -like '*TiWorker*').count -gt 0) -eq $true)
                                     {$CheckProcessArray += 1}
                             Start-Sleep -Seconds 2}
                             While($CheckProcessArray.count -gt 0)}                 
                 
                 If ($RebootPendingDetection -eq $true)
                         {Write-Verbose 'Reboot has now taken place.'
                          If ($RerunUntilComplete -eq $true)
                                  {Write-Verbose 'Triggering the script module on the virtual machine again, RerunUntilComplete was dectected.'
                                   &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword runProgramInGuest $VM $VM_PowerShell "$VM_VMRTarget\$Module $Arguments"
                                   VMwareVMRunResult

                                   $VMModuleExitStatus = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword readVariable $VM guestEnv VMRStatus
                                   Write-Debug "`$VMModuleExitStatus value is $VMModuleExitStatus."}
                              Else{$VMModuleExitStatus = 'Complete'
                                   $RebootPendingDetection = $null}}
                     Else{Write-Verbose 'Triggering the script module on the virtual machine.'
                          $VMRunExitStatus = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword runProgramInGuest $VM $VM_PowerShell "$VM_VMRTarget\$Module $Arguments"
                          VMwareVMRunResult

                          $VMModuleExitStatus = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword readVariable $VM guestEnv VMRStatus
                          If ($VMModuleExitStatus -eq 'Module Started' -and $VMRunExitStatus -eq 'Error: VMware Tools are not running in the guest')
                                  {Write-Warning 'Lost connection with virtual machine, but $VMModuleExitStatus indicated it started.'
                                   Write-Verbose 'Waiting for $VMModuleExitStatus to change from Module Started.'
                                   Do {Start-Sleep 2
                                       $VMModuleExitStatus = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword readVariable $VM guestEnv VMRStatus}
                                       Until ($VMModuleExitStatus -ne 'Module Started')}

                          Write-Debug "`$VMModuleExitStatus value is $VMModuleExitStatus."}

                 Switch ($BuildErrorPreference)
                      {RetryThenSkip       {If ($BuildErrorRetryAttempts -eq '0') 
                                                    {$RetryAttemptsCounter = '-1'}
                                            If ($RetryAttemptsCounter -le $BuildErrorRetryAttempts)
                                                    {$RetryAttemptsCounter ++
                                                     Write-Debug "`$RetryAttemptsCounter has increased to $RetryAttemptsCounter."}
                                                Else{Write-Warning 'Maximum retry attempts reached, skipping script module.'
                                                     $VMModuleExitStatus = 'Complete'}}
                       RetryThenStop       {If ($BuildErrorRetryAttempts -eq '0') {$RetryAttemptsCounter = '-1'}
                                            If ($RetryAttemptsCounter -le $BuildErrorRetryAttempts)
                                                    {$RetryAttemptsCounter ++
                                                     Write-Debug "`$RetryAttemptsCounter has increased to $RetryAttemptsCounter."}
                                                Else{Write-Warning 'Maximum retry attempts reached, stopping Virtual Machine Runner.'
                                                     Throw}}
                       Default             {Write-Warning "`$BuildErrorPreference value is not set correctly."
                                            Throw}}

                 Switch ($VMModuleExitStatus)
                      {Complete            {Write-Verbose 'Module exit status has indicated it is complete.'}
                       RebootPending       {Write-Verbose 'Module exit status has indicated a reboot is pending.'
                                            VMWarePowerControl -SoftRestart
                                            VMwareVMRunResult
                                            $RebootPendingDetection = $true}
                       Error               {Write-Warning 'Module exit status has indicated an error which was trapped, please check the logs and script for more details.'
                                            Write-Warning 'Trying the script module again.'
                                            #Pause
                                            }
                       Default             {Write-Warning 'Module exit status has indicated unknown value which was not trapped, please check logs and run payload manually in virtual machine to view error.'
                                            Write-Warning 'Trying the script module again. '
                                            #Pause
                                            }}
 
                  Switch ($BuildErrorPreference)
                      {Pause               {$PauseCounter = 0
                                            If ($VMModuleExitStatus -ne 'Complete')
                                                    {$PauseCounter ++}
                                            If ($VMModuleExitStatus -ne 'RebootPending')
                                                    {$PauseCounter ++}
                                            If ($PauseCounter -ne 1)
                                                    {Pause}}
                       Stop                {$PauseCounter = 0
                                            If ($VMModuleExitStatus -ne 'Complete')
                                                    {$PauseCounter ++}
                                            If ($VMModuleExitStatus -ne 'RebootPending')
                                                    {$PauseCounter ++}
                                            If ($PauseCounter -ne 1)
                                                    {Throw}}}}
             Until ($VMModuleExitStatus -eq 'Complete')}
 
 } #End Function VMR_RunModule

Function VMR_ScriptInformation{
    Param ([Switch] $CollateralFolder,
           [Switch] $ScriptFolder,
           [Switch] $ScriptLogLocation,
           [Switch] $ScriptName)

    Function ScriptSolver{
            $Invocation = (Get-Variable MyInvocation -Scope 2).Value
            $Invocation.MyCommand}

    If ($CollateralFolder -eq $true)
            {$Script = ScriptSolver
             $FileObject = Get-ChildItem -Path ($Script.Path)
             $ScriptDir = Split-Path $Script:MyInvocation.MyCommand.Path
             $ScriptDir + '\' + $FileObject.BaseName}
            
    If ($ScriptFolder -eq $true)
            {$ScriptDir = Split-Path $Script:MyInvocation.MyCommand.Path
             $ScriptDir}

    If ($ScriptLogLocation -eq $true)
            {$Script = ScriptSolver
             $FileObject = Get-ChildItem -Path ($Script.Path)
             $ScriptDir = Split-Path $Script:MyInvocation.MyCommand.Path
             $ScriptDir + '\..\Logs\' + $FileObject.BaseName + '.log'}

    If ($ScriptName -eq $true)
            {$Script = ScriptSolver
             $Script.Name}
 
 } #End Function VMR_ScriptInformation

Function Test-RegistryValue {
    Param ([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]$Path,
           [Parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$Value)

    Try   {$null = Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop
	   Return $true}
    catch {Return $false}
    #http://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html
 
 } #End Function Test-RegistryValue

 Function VMWarePowerControl{
    Param ([Switch] $SoftRestart,
           [Switch] $SoftStop,
           [Switch] $Start)

    If ($SoftRestart -eq $true)
            {Write-Output ' ·Restarting the virtual machine.'
             &.\vmrun -T ws reset $VM soft
             VMwareVMRunResult
             Write-Verbose 'Waiting for the virtual machine to be ready before proceeding.'
             $null = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword listProcessesInGuest $VM
             If ($LASTEXITCODE -eq '-1')
                     {Write-Warning 'Trying to contact the virtual machine again.'
                      $null = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword listProcessesInGuest $VM
                      VMwareVMRunResult}
             Start-Sleep -Seconds $PostBootWaitInterval}

    If ($SoftStop -eq $true)
            {Write-Output ' ·Stopping the virtual machine.'
             &.\vmrun -T ws stop $VM soft
             VMwareVMRunResult}

    If ($Start -eq $true)
            {Write-Output ' ·Starting the virtual machine.'
             &.\vmrun -T ws start $VM
             VMwareVMRunResult
             Write-Verbose 'Waiting for the virtual machine to be ready before proceeding.'
             $null = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword listProcessesInGuest $VM
             If ($LASTEXITCODE -eq '-1')
                     {Write-Warning 'Trying to contact the virtual machine again.'
                      $null = &.\vmrun -T ws -gu $GuestUserName -gp $GuestPassword listProcessesInGuest $VM
                      VMwareVMRunResult}
             Start-Sleep -Seconds $PostBootWaitInterval}

 } #End Function VMWarePowerControl

 Function VMWareSnapshotControl{
    Param ([Switch] $TakeSnapshot,
           [Switch] $RevertSnapshot,
           [String] $SnapshotName)

    If ($TakeSnapshot -eq $true)
            {Write-Output " »Snapshot control, taking snapshot `'$SnapshotName`'."
             &.\vmrun -T ws snapshot $VM $SnapshotName
             If ($LASTEXITCODE -eq 0)
                     {VMwareVMRunResult}
                 Else{Break}}

    If ($RevertSnapshot -eq $true)
            {Write-Output " »Snapshot control, reverting to snapshot `'$SnapshotName`'."
             &.\vmrun -T ws revertToSnapshot $VM $SnapshotName
             VMwareVMRunResult}

 } #End Function VMWareSnapshotControl

 Function VMwareVMRunResult{
    If ($LASTEXITCODE -ne 0)
            {Write-Warning " VMRun Error: $LASTEXITCODE"}

 } #End Function VMwareVMRunResult

Function Write-Registry {
    Param ([Parameter(Mandatory=$true)][String]$RegistryKey,
           [Parameter(Mandatory=$true)][String]$RegistryValueName,
                                       [String]$RegistryValueData,
           [Parameter(Mandatory=$true)][String]$RegistryValueType,
                                       [Switch]$EnableReflectiontoWOW3264Node)
    #Need to add logic to write to WOW3264Node if in 64bit system via switch.
    
    Try   {Switch ((Get-ItemProperty -Path $RegistryKey -Name $RegistryValueName -ErrorAction SilentlyContinue).$RegistryValueName.gettype().name)
                   {'String'    {$RegistryValueTypeCheck = 'String'}
                    'Int32'     {$RegistryValueTypeCheck = 'DWord'}
                    'Int64'     {$RegistryValueTypeCheck = 'QWord'}
                    'String[]'  {$RegistryValueTypeCheck = 'MultiString'}
                    'Byte[]'    {$RegistryValueTypeCheck = 'Binary'}
                    Default     {Return 'Unable to discover registry type for overwrite check'}}}
    Catch {$RegistryValueTypeCheck = $null}

    If ($RegistryValueTypeCheck -ne $null)
            {If ($RegistryValueTypeCheck -ne $RegistryValueType)
                    {Return 'Registry type mismatch'}}
    
    #Force create the registry path.
    If (((Test-Path $RegistryKey) -replace "`n|`r") -eq 'False')
            {$null = New-Item -Path $RegistryKey -Force}

    Switch ($RegistryValueTypeCheck)
        {MultiString   {#Writing registry MultiString value.
                        $MultiStringArray = Get-ItemProperty -Path $RegistryKey | Select-Object -ExpandProperty $RegistryValueName
                        $MultiStringArray = @($MultiStringArray | where {$_ -ne $RegistryValueData})
             
                        If ($MultiStringArray -notcontains $RegistryValueData) 
                                {$MultiStringArray += $RegistryValueData}
                                 
                        #Not in use yet, needs coded into params.
                        If ($Remove -eq $true)
                                {$MultiStringArray = @($MultiStringArray | where { $_ -ne $RegistryValueData })}

                        Set-ItemProperty -Path $RegistryKey -type $RegistryValueTypeCheck -Name $RegistryValueName -Value $MultiStringArray
                                 
                        Try   {$RegistryWriteCheck = Get-ItemProperty -Path $RegistryKey | Select-Object -ExpandProperty $RegistryValueName
                               If ($RegistryWriteCheck -contains $RegistryValueData)
                                       {$RegistryWriteCheck = $null
                                        Return '0'}
                                   Else{Return 'Unexpected value on validation'}}
                        Catch {Return 'Error'}}

         Default       {#Writing registry String, Dword, Qword, value.
                        $null = New-ItemProperty -Path $RegistryKey -Name $RegistryValueName -Value $RegistryValueData -PropertyType $RegistryValueType -Force

                        Try   {$RegistryWriteCheck = (Get-ItemProperty -Path $RegistryKey | Select-Object -ExpandProperty $RegistryValueName)
                               If ($RegistryWriteCheck -eq $RegistryValueData)
                                       {$RegistryWriteCheck = $null
                                        Return '0'}
                                   Else{Return 'Unexpected value on validation'}}
                        Catch {Return 'Error'}}}

    #https://social.technet.microsoft.com/Forums/windowsserver/en-US/6ccf94ee-9a15-49fc-9abf-0050b66b0643/registry-how-to-test-the-type-of-a-value    
    #http://blogs.technet.com/b/heyscriptingguy/archive/2015/04/02/update-or-add-registry-key-value-with-powershell.aspx
    #http://stackoverflow.com/questions/27238523/editing-a-multistring-array-for-a-registry-value-in-powershell
    #http://www.jonathanmedd.net/2014/02/testing-for-the-presence-of-a-registry-key-and-value.html
    #https://msdn.microsoft.com/en-us/library/microsoft.win32.registryvaluekind(v=vs.110).aspx

 } #End Function Write-Registry

#<<< End Of Function List >>>
