<# 
    .Synopsis
    Bash.exe abuse to launch malicious process

    .Description
    https://lolbas-project.github.io/lolbas/Binaries/Bash/
#>

function Start-Bash {
    $binpaths = @('C:\Windows\System32\bash.exe','C:\Windows\SysWOW64\bash.exe')
    $binparams = '-c calc.exe'

    ForEach ($bp in $binpaths) {
        if (Test-Path $bp) {
            $binpath = $bp
            break
        }
    }

    #Handle this better
    if ($binpath = $null) {
        return
    }

    Start-Process -FilePath $binpath -ArgumentList $binparams
}
Export-ModuleMember -Function Start-Bash