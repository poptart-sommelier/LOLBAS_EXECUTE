<# 
    .Synopsis
    Synopsis

    .Description
    https://lolbas-project.github.io/lolbas/Binaries/___NAME___/
#>

function Start-___NAME___ {

    # Logging
    $logname = '___NAME___.log'
    $logfile = $PSScriptRoot + "\logs\$logname"
    $logged_content = ""

    # Create temp folder
    $tempdir = $PSScriptRoot + "\temp"
    if (-not (Test-Path $tempdir)) {
        New-Item -Path $tempdir -ItemType Directory
    }

    # Target binaries
    $binpaths = @('___BIN_LOC___', '___BIN_LOC___')

    ForEach ($bp in $binpaths) {
        if (Test-Path $bp) {
            $binpath = $bp
            break
        }
    }

    #Handle this better
    if ($null -eq $binpath) {
        return $null
    }
    $logged_content += "Technique 1 - Alternate Data Stream"
    $logged_content += & $binpath /create t1 2>&1
    $logged_content += & $binpath /addfile t1 c:\windows\system32\cmd.exe $tempdir\cmd.exe 2>&1
    $logged_content += & $binpath /SetNotifyCmdLine t1 $tempdir\1.txt:cmd.exe NULL 2>&1
    $logged_content += & $binpath /RESUME t1 2>&1
    $logged_content += & $binpath /complete t1 2>&1
    # clean up - this should be a seperate function
    Remove-Item -Path $tempdir\*

    # Write out log
    Out-File -InputObject $logged_content -FilePath $logfile

    # Clean up
    Remove-Item -Path $tempdir -Recurse
}
Export-ModuleMember -Function Start-___NAME___