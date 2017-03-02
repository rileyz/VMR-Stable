<#
.SYNOPSIS
     Configures a logon script triggered by Active Setup to mapped simulated network drives.
 
.LINK
Author:.......http://www.linkedin.com/in/rileylim
#>



# Script Support ##################################################################################
# Operating System, 32-bit Support, 64-bit Support
# Windows 10,Yes,Yes
# Windows 8.1,Yes,Yes
# Windows 8,Yes,Yes
# Windows 7,Yes,Yes
# Server 2016,NA,Yes
# Server 2012 R2,NA,Yes
# Server 2012,NA,Yes
# Server 2008 R2,NA,Yes
#<<< End of Script Support >>>

# Script Assets ###################################################################################
# Asset: VMR Map Simulated Mapped Drives.ps1
#<<< End of Script Assets >>>



# Setting up housekeeping #########################################################################
Param([Parameter(Mandatory=$true)][String]$HomeDrives,
      [Parameter(Mandatory=$true)][String]$CommonDrives)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$ScriptPath\..\Framework\Core_CommonFunctions.ps1"
$VMRCollateral = VMR_ScriptInformation -CollateralFolder
$VMRScriptLocation = VMR_ScriptInformation -ScriptFolder
$VMRScriptFile = VMR_ScriptInformation -ScriptName
$VMRScriptLog = VMR_ScriptInformation -ScriptLogLocation
VMR_ReadyMessagingEnvironment
#<<< End of Setting up housekeeping >>>



# Start of script work ############################################################################
Function New-Share 
{ 
    [CmdletBinding()] 
    [OutputType([bool])] 
    Param 
    (         
        [Parameter(Position=0, 
                   Mandatory=$True, 
                   ValueFromPipelineByPropertyName=$True,  
                   HelpMessage="No share name specified")] 
        [ValidateLength(1,80)] 
        [string] 
        $Name, 
 
        [Parameter(Position=1,  
                   Mandatory=$True, 
                   ValueFromPipelineByPropertyName=$True,  
                   HelpMessage="No folder path specified")] 
 
        [string] 
        $Path, 
   
        [Parameter(HelpMessage="No description specified")] 
        [ValidateLength(0,256)] 
        [string] 
        $Description, 
    
        [ValidateSet('Allow','Deny')] 
        [String] 
        $AccessType = "Allow", 
 
        [Parameter(Mandatory=$True, 
                   HelpMessage="Specify user or group name in the following format DOMAIN\User")] 
        [String[]] 
        $Users, 
 
        [ValidateSet('None','Read','Modify','Full')] 
        [String] 
        $Access = "Read", 
 
        $MaxConnections = $null, 
 
        [Parameter(Position=0, 
                   Mandatory=$False, 
                   ValueFromPipeline=$True, 
                   HelpMessage='An array of computer names. The default is the local computer.')] 
 
        [string[]] 
        $ComputerName = $env:COMPUTERNAME 
 
    ) 
 
    Begin 
    { 
 
        # Set the AccessMask 
        [UInt32]$AccessMask = Switch($Access) { 
 
            'None'   {'1'} 
            'Read'   {'1179817'} 
            'Modify' {'1245631'} 
            'Full'   {'2032127'} 
 
        } 
 
        # Set the AceType 
        [UInt32]$AceTypeAccess = Switch($AccessType) { 
 
            'Allow' {'0'} 
            'Deny'  {'1'} 
            #'Audit' {'2'} possibly for future use 
 
        } 
 
        $MaxConnections = if($MaxConnections){[UInt32]$MaxConnections} 
 
        # Define the Ace Flag values 
        [UInt32]$ACEFLAG_OBJECT_INHERIT_ACE = 1 
        [UInt32]$ACEFLAG_CONTAINER_INHERIT_ACE = 2 
        [UInt32]$ACEFLAG_NO_PROPAGATE_INHERIT_ACE = 4 
        [UInt32]$ACEFLAG_INHERIT_ONLY_ACE = 8 
        [UInt32]$ACEFLAG_INHERITED_ACE = 16 
        [UInt32]$ACEFLAG_VALID_INHERIT_FLAGS = 31 
        [UInt32]$ACEFLAG_SUCCESSFUL_ACCESS_ACE_FLAG = 64 
        [UInt32]$ACEFLAG_FAILED_ACCESS_ACE_FLAG = 128 
 
        # Should almost always be 3. Really. don't change it. 
        [UInt32]$AceFlag = $ACEFLAG_OBJECT_INHERIT_ACE + $ACEFLAG_CONTAINER_INHERIT_ACE 
 
        # Set the ShareType 
        [String]$Type = 'Disk Drive' 
 
        # I simply listed all the share type to give me the flexibility to expand the function easily in the future. 
        [UInt32]$ShareType = switch($Type){ 
 
            'Disk Drive' {'0'} 
            'Print Queue' {'1'} 
            'Device' {'2'} 
            'IPC' {'3'} 
            'Disk Drive Admin' {'2147483648'} 
            'Print Queue Admin' {'2147483649'} 
            'Device Admin' {'2147483650'} 
            'IPC Admin' {'2147483651'} 
 
        } 
 
        # Array to store domain info 
        $DomainList = @() 
         
        # Check if pc is part of a domain 
        # If it is get the info for all domains in the forest  
        if((Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain){ 
 
            try{ 
 
                # Determine Configuration naming context from RootDSE object.  
                $RootDSE = [System.DirectoryServices.DirectoryEntry]([ADSI]"LDAP://RootDSE")  
                $ConfigNC = $RootDSE.Get("configurationNamingContext")  
 
                # Get details on the current Forest 
                $Forest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest() 
 
                # Get a list of the FQDN's in the forest 
                $Domains = $Forest | Select -ExpandProperty  Domains 
  
                # Use ADSI Searcher object to determine NetBIOS names of domains.  
                $Searcher = New-Object System.DirectoryServices.DirectorySearcher 
                $Searcher.SearchRoot = "LDAP://cn=Partitions,$ConfigNC" 
                $Searcher.SearchScope = "subtree"  
                $Searcher.PropertiesToLoad.Add("nETBIOSName") |Out-Null   
 
                    
 
                foreach($Domain in $Domains){ 
 
                    $DN = $Domain.GetDirectoryEntry() | Select -ExpandProperty distinguishedName 
                    $Searcher.Filter = "(nCName=$DN)" 
 
                    # Properties to load into PSObject. FQDN, DN, NetBiosName, Domain controller name 
                    $objProperties = (@{'FQDN'="$($Domain.Name)"; 
                                        'NetBIOSName'= "$(($Searcher.FindOne()).Properties.Item("nETBIOSName"))"; 
                                        'DN'="$DN"; 
                                        'DC'="$($Domain.FindDomainController() | Select -ExpandProperty Name)"}) 
     
                    $DomainList += New-Object -TypeName psobject –Prop $objProperties 
 
 
                } 
                $Searcher.Dispose() 
            } 
 
            Catch { 
 
                Write-Error "An error occurred while attempting to retrieve the domain information." 
 
            } 
 
 
        } 
 
         
         
    } 
    Process 
    { 
        # Loop through each Computer name specified 
        foreach($Computer in $ComputerName){ 
             
            Write-Debug "Current computer : $Computer" 
 
            try{ 
 
                # Create the ACE on the specified computer 
                $Ace = ([WMIClass] "\\$Computer\root\cimv2:Win32_ACE").CreateInstance()  
                $Ace.AccessMask = $AccessMask 
                $Ace.AceFlags = $AceFlag 
                $Ace.AceType = $AceTypeAccess 
 
                # Create the Security Descriptor on the specified computer 
                $SD = ([WMIClass] "\\$Computer\root\cimv2:Win32_SecurityDescriptor").CreateInstance() 
                $SD.DACL = @() 
         
                # Loop through each user 
                ForEach($User in $Users){ 
 
                    Write-Debug "Current User/Group object : $User" 
 
                    # Create the Trustee on the specified computer 
                    $Trustee = ([WMIClass] "\\$Computer\root\cimv2:Win32_Trustee").CreateInstance() 
 
                    # Check for special groups such as Everyone and Authenticated users 
                    Switch ($User){ 
                        'EVERYONE' { 
                             
                            Write-Debug "Setting Trustee properties for EVERYONE group."                             
                            $Trustee.Domain = $Null 
                            $Trustee.Name = “EVERYONE” 
                            $Trustee.SID = @(1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0) 
                        } 
                        'AUTHENTICATED USERS' { 
 
                            Write-Debug "Setting Trustee properties for AUTHENTICATED USERS group." 
                            $Trustee.Domain = 'NT AUTHORITY' 
                            $Trustee.Name = “Authenticated Users” 
                            $Trustee.SID = @(1, 1, 0, 0, 0, 0, 0, 5, 11, 0, 0, 0) 
 
                        } 
                        Default{ 
 
                            # If username is specified in Domain\username format split it 
                            if($User.Contains("\")){ 
                         
                                $Domain = ($User -split "\\")[0] 
                                $Username = ($User -split "\\")[1] 
 
                                Write-Debug "Domain : $Domain" 
                                Write-Debug "Username : $Username" 
 
                                # Get the Domain and username details 
                                $DomainInfo = $DomainList | Where {$_.NetBIOSName -eq "$Domain"} 
                                Write-Debug "Domain details : $DomainInfo" 
 
                                # Check if the domain specified before the \ is a valid domain 
                                if($DomainInfo){ 
 
                                    # Query AD for the specified object 
                                    $objSearch = New-Object System.DirectoryServices.DirectorySearcher 
                                    $objSearch.SearchRoot = "LDAP://$($DomainInfo.DN)" 
                                    $objSearch.SearchScope = "Subtree" 
                                    $objSearch.Filter = "(samaccountname=$Username)" 
                                    $searchResult = $objSearch.FindOne() 
 
                                    # Get the objectclass and use it to check if the object is a user or group 
                                    $objectClass = $searchResult.Properties.Item("objectclass") 
 
                                    Write-Debug "Object Class details : $objectClass" 
 
                                    if ($objectClass.Contains('user')) { 
                                        Write-Debug "$Domain\$Username is a user" 
                                        $account = [WMI] "\\$Computer\root\cimv2:Win32_Account.Name='$Username',Domain='$Domain'" 
                                    } 
                                    elseif ($objectClass.Contains('group')) { 
                                        Write-Debug "$Domain\$Username is a group" 
                                        $account = [WMI] "\\$Computer\root\cimv2:Win32_Group.Name='$Username',Domain='$Domain'" 
                                    } 
                                    else { 
                                        Throw "The specified object is neither a domain user or a group" 
                                    } 
 
                                    $objSearch.Dispose() 
 
 
                                } 
                                # Check if the domain specified before the \ is the same as the computer name of the remote computer 
                                elseif($Domain -eq $Computer) { 
 
                                    # Query the specified computer to see if the a user or group exists with the specified nam 
                                    $localGroupResult = Get-WMIObject -ComputerName $Computer -Class Win32_Group -filter "LocalAccount='$true' AND Name='$Username'" 
                                    $localUserResult = Get-WMIObject -ComputerName $Computer -Class Win32_UserAccount -filter "LocalAccount='$true' AND Name='$Username'" 
 
                                    If($localGroupResult){ 
 
                                        $account = [WMI] "\\$Computer\root\cimv2:Win32_Group.Name='$Username',Domain='$Domain'" 
 
                                    } Elseif ($localUserResult) { 
 
                                        $account = [WMI] "\\$Computer\root\cimv2:Win32_Account.Name='$Username',Domain='$Domain'" 
 
                                    } Else { 
                                         
                                        Throw "The specified user or group name is invalid" 
                                    } 
 
                                } else { 
                                    Throw "Invalid Domain specified" 
                                } 
 
                                 
                            } else { 
 
                                $Domain = $Computer 
                                $Username = $User 
 
                                Write-Host "Domain : $Domain" 
                                Write-Host "Username : $Username" 
 
                               # Query the specified computer to see if the a user or group exists with the specified nam 
                                $localGroupResult = Get-WMIObject -ComputerName $Computer -Class Win32_Group -filter "LocalAccount='$true' AND Name='$Username'" 
                                $localUserResult = Get-WMIObject -ComputerName $Computer -Class Win32_UserAccount -filter "LocalAccount='$true' AND Name='$Username'" 
 
                                If($localGroupResult){ 
 
                                    $account = [WMI] "\\$Computer\root\cimv2:Win32_Group.Name='$Username',Domain='$Domain'" 
 
                                } Elseif ($localUserResult) { 
 
                                    $account = [WMI] "\\$Computer\root\cimv2:Win32_Account.Name='$Username',Domain='$Domain'" 
 
                                } Else { 
                                         
                                    Throw "The specified user or group name is invalid" 
                                } 
                                 
                            } 
 
                            Write-Debug "Getting Account SID" 
                            # Get the SID for the found account. 
                            $accountSID = [WMI] "\\$Computer\root\cimv2:Win32_SID.SID='$($account.sid)'" 
                             
                            Write-Debug "Setting Trustee properties" 
                            # Setup Trustee object 
                            $Trustee.Domain = $Domain 
                            $Trustee.Name = $Username 
                            $Trustee.SID = $accountSID.BinaryRepresentation 
                         
                        } 
                         
                         
                    } 
                     
                    $Ace.Trustee = $Trustee 
                    $SD.DACL += $Ace.psObject.baseobject 
                } 
 
                # Check if the share exists on the specified computer 
                if (!(Get-WmiObject -Class Win32_Share -ComputerName $Computer -Filter "Name='$Name'")) 
                {    
 
                    # Check if the directory exist at the specified path. 
                    # If not create it     
                    [String]$UncPath = "\\$Computer\$($Path.Replace(':','$'))" 
                    if(!(Test-Path -Path "$UncPath")){ 
                        New-Item -Path $UncPath -ItemType Directory | Out-Null 
                    } 
 
                    # Create the Share 
                    $Share = [WmiClass]"\\$Computer\root\cimv2:Win32_share" 
                    $InParams = $Share.psbase.GetMethodParameters("Create") 
                    $InParams.Access = $SD 
                    $InParams.Description = $Description 
                    $InParams.MaximumAllowed = $MaxConnections 
                    $InParams.Name = $Name 
                    $InParams.Password = $null 
                    $InParams.Path = $Path 
                    $InParams.Type = $ShareType 
 
                    $Result = $Share.PSBase.InvokeMethod("Create", $InParams, $Null) 
 
                    # Check if it was successfull 
                    $rvalue = Switch ($Result.ReturnValue) { 
                        0 {"Success"} 
                        2 {"Access Denied"}      
                        8 {"Unknown Failure"}      
                        9 {"Invalid Name"}      
                        10 {"Invalid Level"}      
                        21 {"Invalid Parameter"}      
                        22 {"Duplicate Share"}      
                        23 {"Redirected Path"}      
                        24 {"Unknown Device or Directory"} 
                        25 {"Net Name Not Found"} 
                        Default {"Unknown Error"} 
                    } 
          
                    if ($Result.ReturnValue -ne 0)  
                    { 
                        Write-Error ("Failed to create share {0} for {1} on {2}. Error: {3}" -f $Name,$Path,$Computer,$rvalue)  
                        Return $False 
                    } 
                    else  
                    { 
                        Write-Host "Successfully shared folder [$Path] on [$Computer] as [$Name] ." 
                        Return $True 
                    } 
 
                } else { 
 
                    Write-Error "The share [$Name] already exists on [$Computer]." 
                    Return $False 
                } 
 
            } 
            Catch 
            { 
                Write-Error "Error creating share [$Name] on [$Computer] ." 
                Write-Error $_ 
                Return $False 
            } 
 
        } 
         
    } 
    End 
    { 
    } 
} #https://gallery.technet.microsoft.com/scriptcenter/Create-Shared-Folder-with-79fce495

$ArrayScriptExitResult = @()

#Create folder and share for all users: full permission
$SimulatedNetworkFolder = 'C:\Windows\debug\SimulatedNetworkDrives'
New-Share -Path "$SimulatedNetworkFolder" -Name 'SimulatedNetworkDrives$' -Description 'Simulated Network Drives' -AccessType Allow -Access Full -Users 'Users'
& icacls $SimulatedNetworkFolder /Inheritance:R /Grant:R Users:`(OI`)`(CI`)F /T
$ArrayScriptExitResult += $LASTEXITCODE

#Debug parameters, the share must exist before debugging
#$CommonDrives = 'I:IT Dept,S:Shared'
#$HomeDrives >> $VMRScriptLog
#$CommonDrives >> $VMRScriptLog

#Text to be added to the simulated network drive
$SimulatedNetworkFolderReadMe += "This is a simulated network drive that can be found in this location `"C:\Windows\debug\SimulatedNetworkDrives`". `r`n"
$SimulatedNetworkFolderReadMe += 'This is an exclusion area for App-V Sequencer, thus no file will be captured.'

$CommonDrivesArray = $CommonDrives.Split(',')
$CommonDrivesArray | ForEach-Object {Write-Debug "Working on object $_"
                                     $DriveToMap = $_.Split(':')
                                     $CreateUNCFolder = 'Common ' + $DriveToMap[0] + ' ' + $DriveToMap[1]
                                     If (!(Test-Path "\\LocalHost\SimulatedNetworkDrives$\$CreateUNCFolder"))
                                             {New-Item -ItemType Directory -Path "\\LocalHost\SimulatedNetworkDrives$\$CreateUNCFolder"
                                              $ArrayScriptExitResult += $?
                                              $SimulatedNetworkFolderReadMe | Out-File "\\LocalHost\SimulatedNetworkDrives$\$CreateUNCFolder\This is a simulated network drive.txt"
                                              $ArrayScriptExitResult += $?}}
 
#Setting up Active Setup to run the drive mappings
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\VMR Map Simulated Network Drives' -RegistryValueName '(Default)' -RegistryValueData 'Mapping Simulated Network Drives' -RegistryValueType 'String' 
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\VMR Map Simulated Network Drives' -RegistryValueName 'StubPath' -RegistryValueData "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File `"C:\Windows\debug\SimulatedNetworkDrives\VMR Map Simulated Mapped Drives.ps1`"" -RegistryValueType 'String'                                   
$ArrayScriptExitResult += Write-Registry -RegistryKey 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\VMR Map Simulated Network Drives' -RegistryValueName 'Version' -RegistryValueData '1' -RegistryValueType 'String' 

$ScriptDestination = "C:\Windows\debug\SimulatedNetworkDrives\VMR Map Simulated Mapped Drives.ps1"
Copy-Item -Path "$VMRCollateral\VMR Map Simulated Mapped Drives.ps1" -Destination $ScriptDestination
$ArrayScriptExitResult += $?

#Updating the script with desired simulated network drive mappings
$EditingScript = Get-Content $ScriptDestination
$EditingScript = $EditingScript -replace '<<HomeDrivesMask>>',"$HomeDrives"
$EditingScript = $EditingScript -replace '<<CommonDrivesMask>>',"$CommonDrives"
$EditingScript | Out-File $ScriptDestination -Encoding utf8
$ArrayScriptExitResult += $?

$SuccessCodes = @('Example','0','3010','True')                                                    #List all success codes, including reboots here.
$SuccessButNeedsRebootCodes = @('Example','3010')                                                 #List success but needs reboot code here.
$ScriptError = $ArrayScriptExitResult | Where-Object {$SuccessCodes -notcontains $_}              #Store errors found in this variable
$ScriptReboot = $ArrayScriptExitResult | Where-Object {$SuccessButNeedsRebootCodes -contains $_}  #Store success but needs reboot in this variable

If ($ScriptError -eq $null)                       #If ScriptError is empty, then everything processed ok.
        {If ($ScriptReboot -ne $null)             #If ScriptReboot is not empty, then everything processed ok, but just needs a reboot.
                {$ScriptExitResult = 'Reboot'}
            Else{$ScriptExitResult = '0'}}
    Else{$ScriptExitResult = 'Error'
         $ScriptError >> $VMRScriptLog}

$ScriptExitResult >> $VMRScriptLog

Switch ($ScriptExitResult) 
    {'0'        {VMR_ProcessingModuleComplete -ModuleExitStatus 'Complete'}
     'Reboot'   {VMR_ProcessingModuleComplete -ModuleExitStatus 'RebootPending'}
     'Error'    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Error'}
     Default    {VMR_ProcessingModuleComplete -ModuleExitStatus 'Null'
                 Write-Host "The script module was unable to trap exit code for $VMRScriptFile."}}
#<<< End of script work >>>



<#
Virtual Machine Runner  -  Copyright (C) 2016-2017  -  Riley Lim

This program is free software: you can redistribute it and/or modify it under the terms of the GNU
General Public License as published by the Free Software Foundation, either version 3 of the 
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, 
see <http://www.gnu.org/licenses/>.
#>
