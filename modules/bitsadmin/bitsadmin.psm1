<# 
    .Synopsis
    BITSAdmin abuse techniques

    .Description
    https://lolbas-project.github.io/lolbas/Binaries/Bitsadmin/
#>

function Start-Bits {

    # Logging
    $logname = 'bitsadmin.log'
    $logfile = $PSScriptRoot + "\logs\$logname"
    $logged_content = ""

    # Create temp folder
    $tempdir = $PSScriptRoot + "\temp"
    if (-not (Test-Path $tempdir)) {
        New-Item -Path $tempdir -ItemType Directory
    }

    # Target binaries
    $binpaths = @('C:\Windows\System32\bitsadmin.exe', 'C:\Windows\SysWOW64\bitsadmin.exe')

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
    # file staging - used invoke-cimmethod because nothing else worked... something to do with the colon
    $command = "cmd /c type c:\windows\system32\cmd.exe > $tempdir\1.txt:cmd.exe"
    Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine = $command}
    # actual technique
    $logged_content += & $binpath /create t1 2>&1
    $logged_content += & $binpath /addfile t1 c:\windows\system32\cmd.exe $tempdir\cmd.exe 2>&1
    $logged_content += & $binpath /SetNotifyCmdLine t1 $tempdir\1.txt:cmd.exe NULL 2>&1
    $logged_content += & $binpath /RESUME t1 2>&1
    $logged_content += & $binpath /complete t1 2>&1
    # clean up - this should be a seperate function
    Remove-Item -Path $tempdir\*

    $logged_content += "Technique 2 - Download"
    $logged_content += & $binpath /create t2 2>&1
    $logged_content += & $binpath /addfile t2 https://live.sysinternals.com/autoruns.exe $tempdir\autoruns.exe 2>&1
    $logged_content += & $binpath /resume t2 2>&1
    $logged_content += & $binpath /complete t2 2>&1
    # clean up - this should be a seperate function
    Remove-Item -Path $tempdir\*

    $logged_content += "Technique 3 - Copy"
    $logged_content += & $binpath /create t3 2>&1
    $logged_content += & $binpath /addfile t3 c:\windows\system32\cmd.exe $tempdir\cmd.exe 2>&1
    $logged_content += & $binpath /RESUME t3 2>&1
    $logged_content += & $binpath /Complete t3 2>&1
    $logged_content += & $binpath /reset 2>&1
    # clean up - this should be a seperate function
    Remove-Item -Path $tempdir\*

    $logged_content += "Technique 4 - Execute"
    $logged_content += & $binpath bitsadmin /create t4 
    $logged_content += & $binpath /addfile t4 c:\windows\system32\cmd.exe $tempdir\cmd.exe 
    $logged_content += & $binpath /SetNotifyCmdLine t4 $tempdir\cmd.exe NULL 
    $logged_content += & $binpath /RESUME t4 
    $logged_content += & $binpath /Reset
    # clean up - this should be a seperate function
    Remove-Item -Path $tempdir\*


    $logged_content = ""
    # Write out log
    Out-File -InputObject $logged_content -FilePath $logfile

    # Clean up
    Remove-Item -Path $tempdir -Recurse
}
Export-ModuleMember -Function Start-Bits