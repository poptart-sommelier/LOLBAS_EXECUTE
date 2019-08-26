<# 
    .Synopsis


    .Description

    
#>

function Start-Skeleton {
    $binpaths = @('')
    $binparams = ''

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
Export-ModuleMember -Function Start-Skeleton