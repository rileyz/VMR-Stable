# Start of script work ############################################################################
$SymbolicLinkTarget = [Environment]::GetEnvironmentVariable("VMRSymbolicLinkTarget","Machine")

[Environment]::SetEnvironmentVariable("VMRStatus", "", "Machine")
[Environment]::SetEnvironmentVariable("VMRSymbolicLinkTarget", "", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsOperatingSystem", "", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsArchitecture", "", "Machine")
[Environment]::SetEnvironmentVariable("VMRWindowsVersion", "", "Machine")

$RemoveJunction = Get-Item "$SymbolicLinkTarget"
$RemoveJunction.Delete()

If ((Test-Path $SymbolicLinkTargett) -eq $false)
        {Exit 0}
    Else{Exit 1}
#<<< End of script work >>>
