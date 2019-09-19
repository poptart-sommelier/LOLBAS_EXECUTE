<# 
    .Synopsis
    Bash.exe abuse to launch malicious process

    .Description
    https://lolbas-project.github.io/lolbas/Binaries/Bash/
#>

function Write-Log {
    Param(
    [Parameter(Mandatory=$True)]
    [string] $Message
    )

    # Log file location
    $logfile = $PSScriptRoot + "\logs\bash.log"

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Message"
    Add-Content $logfile -Value $Line
}

function Start-TechniqueOne {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $lolbinpath
    )

    $lolbinparams = '-c calc.exe'

    # Store command output
    $logged_content = ""

    Write-Log("Starting Technique One")
    $logged_content += & $lolbinpath $lolbinparams
    Write-Log($logged_content)
}

function Start-Bash {
    if (Test-Path 'C:\Windows\System32\bash.exe') {
        $lolbinpath = 'C:\Windows\System32\bash.exe'
    }
    else {
        return
    }

    Start-TechniqueOne($lolbinpath)
}
Export-ModuleMember -Function Start-Bash