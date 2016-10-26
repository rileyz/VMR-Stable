# Start of script work ############################################################################
$SymbolicLinkTarget = [Environment]::GetEnvironmentVariable("VMRSymbolicLinkTarget","User")
$OperatingSystem = ((Get-WmiObject win32_operatingsystem).Caption).TrimEnd()
$OperatingSystemArchitecture = (Get-WmiObject win32_operatingsystem).OSArchitecture
$OperatingSystemVersion = (Get-WmiObject -class Win32_OperatingSystem).Version

[Environment]::SetEnvironmentVariable("VMRSymbolicLinkTarget", "", "User")

[Environment]::SetEnvironmentVariable("VMRStatus", "Null", "Machine")
[Environment]::SetEnvironmentVariable("VMRSymbolicLinkTarget", "$SymbolicLinkTarget", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsOperatingSystem", "$OperatingSystem", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsArchitecture", "$OperatingSystemArchitecture", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsVersion", "$OperatingSystemVersion", "Machine")

$Arguments = '/C mklink /D ' + '"' + $SymbolicLinkTarget + '"' + ' "\\vmware-host\Shared Folders\Virtual Machine Runner"'
Start-Process -FilePath cmd.exe -ArgumentList "$Arguments" -Wait

#Removing artifact created by common function VMR_CreateJunctionPoint.
[Environment]::SetEnvironmentVariable("VMRTarget", "", "User")

If ((Test-Path $SymbolicLinkTarget) -eq $true)
        {Exit 0}
    Else{Exit 1}
#<<< End of script work >>>
