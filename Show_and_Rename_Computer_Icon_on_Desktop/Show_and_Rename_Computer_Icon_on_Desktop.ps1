# Enable the "Computer" icon on the desktop, and change its name to the system's hostname
# 
# This is helpful for when you're remotely accessing multiple systems and want to know where you are when you look at the desktop
#
# Andrew Shugg <andrew.shugg@uwa.edu.au>
# 2022-10-10: Initial version
# 2022-10-11: Only run on Windows platforms, figured out how to test for the registry keys and create them if missing
# 
# 
# With thanks to
# https://devblogs.microsoft.com/scripting/weekend-scripter-use-powershell-to-change-computer-icon-caption-to-computer-name/
# and
# https://gist.github.com/Santaro255/16dc20f7b800c07ab13683eebe38641c
# 
# 
# The registry key we manipulate to show or hide the "Computer" icon on the current user's desktop:
# HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel\ {20D04FE0-3AEA-1069-A2D8-08002B30309D} = 0/show , 1/hide
#
# So far:
# 
# * works on Windows 10
# * works on Windows Server 2022
# * tested in Windows PowerShell 5.1
# * tested in PowerShell Core 7.2
# 

# Sanity checking - only run if we're on Windows!
If (-Not ([System.Environment]::OSVersion.Platform -eq "Win32NT"))
{
    Write-Error "System does not appear to be running Windows!"
    exit 1
}

# Settings
$ErrorActionPreference="SilentlyContinue"
$basekey="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
$nextkey="HideDesktopIcons"
$lastkey="NewStartPanel"
$name="{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
$My_Computer = 17

# Confirm that HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer exists, because if 
# it doesn't then we've got problems
$path = $basekey
If (-Not (Test-Path -Path $path))
{
    Write-Error "Registry key base $basepath was not found!"
    Exit 1
}
Else
{
    # Create HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons if
    # it doesn't already exist (usually not present on Windows Server)
    $path = "$basekey\$nextkey"
    If (-Not (Test-Path -Path "$path"))
    {
        $foo = New-Item -Path "$path"
    }
    # Create HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel if
    # it doesn't already exist (usually not present on Windows Server)
    $path = "$basekey\$nextkey\$lastkey"
    If (-Not (Test-Path -Path "$path"))
    {
        $foo = New-Item -Path "$path"
    }
    # Set key value "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" to zero (show on desktop), creating key value if it doesn't exist
    If (-Not (Get-ItemProperty -Path $path -Name $name))
    {
        $foo = New-ItemProperty -Path $path -Name $name -Value 0
    }
    Else
    {
        $foo = Set-ItemProperty -Path $path -Name $name -Value 0
    }
    # Rename the "Computer" icon to the current COMPUTERNAME setting
    $Shell = new-object -comobject shell.application
    $NSComputer = $Shell.Namespace($My_Computer)
    $NSComputer.self.name = $env:COMPUTERNAME
}
