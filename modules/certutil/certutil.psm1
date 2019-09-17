<# 
    .Synopsis
    Certutil abuse techniques

    .Description
    https://lolbas-project.github.io/lolbas/Binaries/Certutil/
    
#>

function Start-Certutil {

    # Logging
    $logname = 'certutil.log'
    $logfile = $PSScriptRoot + "\logs\$logname"
    $logged_content = ""

    # Create temp folder
    $tempdir = $PSScriptRoot + "\temp"
    if (-not (Test-Path $tempdir)) {
        New-Item -Path $tempdir -ItemType Directory
    }

    # Target binaries
    $binpaths = @('c:\windows\system32\certutil.exe', 'c:\windows\syswow64\certutil.exe')

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

    $logged_content += "Technique 1 - Download"
    $logged_content += & $binpath -urlcache -split -f http://7-zip.org/a/7z1604-x64.exe $tempdir\7zip.exe
    # clean up - this should be a seperate function
    Remove-Item -Path $tempdir\*

    $logged_content += "Technique 2 - Download"
    $logged_content += & $binpath -verifyctl -f -split http://7-zip.org/a/7z1604-x64.exe $tempdir\7zip.exe
    # Clean up
    Remove-Item -Path $tempdir\*

    $logged_content += "Technique 3 - Alternate Data Stream"
    # Staging temp file
    Set-Content $tempdir\1.txt -Value "Hello World"
    # Using invoke-cimmethod because nothing else worked for alternate data stream... something to do with the colon
    $command = "$binpath -urlcache -split -f https://live.sysinternals.com/autoruns.exe $tempdir\1.txt:adsfile"
    Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine = $command}
    # Clean up
    Remove-Item -Path $tempdir\*

    $logged_content += "Technique 4 - Encode"
    $logged_content += & $binpath -encode c:\windows\system32\cmd.exe $tempdir\encoded_file
    $logged_content += "Technique 5 - Decode"
    $logged_content += & $binpath -decode $tempdir\encoded_file $tempdir\cmd.exe
    # Clean up
    Remove-Item -Path $tempdir\*

    # Write out log
    Out-File -InputObject $logged_content -FilePath $logfile

    # Clean up
    Remove-Item -Path $tempdir -Recurse
}
Export-ModuleMember -Function Start-Certutil