param([switch]$NonInteractive)
Push-Location $PSScriptRoot
$def = Get-Content ../ut-server/System/default-InstaGibPlus.ini
$flag = $false
$def = @($def | % {
    if ($_ -match "\[WeaponSettings") { $flag = $true }
    if ($flag) {
        $_
    }
})
$act = Get-Content ../ut-server/System/InstaGibPlus.example.ini
$flag = $false
$act = @($act | % {
    if ($_ -match "\[WeaponSettings") { $flag = $true }
    if ($flag) {
        $_
    }
})
$act | % {
    if ($_ -match "^(\w*)=(.*)") {
        $setting = $Matches[1]
        $value = $Matches[2]
        $def | ? {$_ -match "^$($setting)="} | % {
            $default = ""
            if ($_ -match ".*=(.*)") {
                $default = $Matches[1]
            }
            if ($default.Length) {
                if ($value -eq $default) {
                    Write-Host "$($setting)=$($value)" -ForegroundColor DarkGreen
                } else {
                    Write-Host "$($setting)=$($value) [Default = $($default)]" -ForegroundColor Yellow
                }
            }
        }
    } elseif ($_ -match "^;") {
        Write-Host $_ -ForegroundColor DarkGray
    } else {
        Write-Host $_
    }
}
if (!$NonInteractive -and !$psISE) {
    pause
}
Pop-Location