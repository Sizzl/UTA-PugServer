<# 
.SYNOPSIS 
 Script to check the provided Pug Maps listing and confirm maps exist, with all dependencies present
 
.DESCRIPTION 
 Requires UT 469 for the packagedump commandlet
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ ORIGIN STORY                                                                                │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 2020
│   AUTHOR      : sizzl@utassault.net
│   DESCRIPTION : Dependency checker
└─────────────────────────────────────────────────────────────────────────────────────────────┘ 
 
.PARAMETER Path
 Root path to check (must contain "Maps" directory)

.PARAMTER UTPath
 Path to UnrealTournament root if different from -Path

.PARAMTER Source
 Path to Source files; if file is missing from Path but is present in Source, it will copy it in

.PARAMETER PugMaps
 Copy of Pug Maps !listmaps output
 
.EXAMPLE 
 
Check-PugDepends.ps1 -Path 'C:\Servers\UnrealTournament' -PugMaps 'AS-Bridge AS-Frigate AS-Submarinebase]['
 
#> 

param(
    $Path="C:\UnrealTournament",
    $UTPath="",
    $Source="",
    $PugMaps="1) AS-AsthenosphereSE:small_orange_diamond:2) AS-AutoRip:small_orange_diamond:3) AS-Ballistic:small_orange_diamond:4) AS-Bridge:small_orange_diamond:5) AS-Desertstorm:small_orange_diamond:6) AS-Desolate][:small_orange_diamond:7) AS-Frigate:small_orange_diamond:8) AS-GolgothaAL:small_orange_diamond:9) AS-Golgotha][AL:small_orange_diamond:10) AS-Mazon:small_orange_diamond:11) AS-RiverbedSE:small_orange_diamond:12) AS-Riverbed]l[AL:small_orange_diamond:13) AS-Rook:small_orange_diamond:14) AS-Siege][:small_orange_diamond:15) AS-Submarinebase][:small_orange_diamond:16) AS-SaqqaraPE_preview3:small_orange_diamond:17) AS-SnowDunes][AL_beta:small_orange_diamond:18) AS-LostTempleBetaV2:small_orange_diamond:19) AS-TheDungeon]l[AL:small_orange_diamond:20) AS-DustbowlALRev04:small_orange_diamond:21) AS-NavaroneAL:small_orange_diamond:22) AS-TheScarabSE:small_orange_diamond:23) AS-Vampire:small_orange_diamond:24) AS-ColderSteelSE_beta3:small_orange_diamond:25) AS-HiSpeed:small_orange_diamond:26) AS-LavaFort][PV:small_orange_diamond:27) AS-BioassaultSE_preview2:small_orange_diamond:28) AS-Razon_preview3:small_orange_diamond:29) AS-Resurrection:small_orange_diamond:30) AS-WorseThings_preview:small_orange_diamond:31) AS-GekokujouAL][:small_orange_diamond:32) AS-AsthenosphereTE_beta:small_orange_diamond:33) AS-BridgePV_beta:small_orange_diamond:34) AS-WaterFort_beta4:small_orange_diamond:35) AS-BioassaultSME:small_orange_diamond:36) AS-Subbase][SE_preview:small_orange_diamond:37) AS-Overlord"
)

# UT File types
$Types = @{"System"="u";"Textures"="utx";"Sounds"="uax";"Music"="umx";"Maps"="unr"}    

# Built-in files to ignore
$Ignore="^Activates$|noxxsnd|^VRikers$|AmbAncient|AmbCity|^Addon1$|^rain$|^LadderSounds$|AmbModern|AmbOutside|DoorsAnc|^Extro$|^Pan1$|DoorsAnc|DoorsMod|^DDay$|\dVoice$|^Botpck10$|^Cannon$|^Foregone$|^Nether$|^Mission$|^Mech8$|^Strider$|^Wheels$|^Engine$|^Botpack$|^UWindow$|^Editor$|^Core$|^city$|Crypt_FX|DDayFX|^Detail$|^Egypt$|EgyptPan|^eol$|FireEng|FractalFx|GreatFire|Indus\d|ISVFX|^LavaFX$|^Liquids$|Metalmys|Old_FX$|RainFX$|ShaneChurch|TCrystal|^UT$|UTbase1|UTcrypt|UTtech\d|XbpFX|^XFX$"
$IgnoreGroup="^Wall$|^Base$|^Floor$|^Light$|^Ceiling$|^Trim$|^Pillar$|^Deco$|^Glass$|^Door$|^Ammocount$|^Mask$|^Girder$|^LensFlar$|^Signs$|^General$|^Looping$|^Panel$|^Misc$|^Icons$|^OneShot$|^Skins$|^GenericThumps$|^2nd$|^Cloth$|^Blob$|^Effects$|^\(All\)$|^Translocator$|^Pickups$|^ground$|^Rock$|^Water$|^sky$|^Woods$|^Animated2$|^Animated$|^Beeps$|^Galleon$|^ClicksBig$|^Dispersion$|^metal$|^Stoonestuff$|^Stills$|^ShieldBelt$|^Walls$|^lava$|^Eightball$|^flak$|^ASMD$|^Krall$|^WarExplosionS2$|^Other$|^Switch$|^ClicksSmall$|^Requests$|^Redeemer$|^Male$|^Grass$|^Testing$|^Harbour$|^ShaneFx$|^Wood$|^Lights$|^Castle$|^Sky1$|^Stone$|^Doors$|^Arch$|^Masked$|^Ut_Explosions$|^Effect25$|^FlameEffect$|^Generic$|^Crystals$|^Minigun$|^xtreme$|^Roof$|^walls$|^floors$|^Other$|^Stonestuff$|^Miscellaneous$"
if ($(Resolve-Path $Path -ErrorAction SilentlyContinue).Path.Length) {
    $Path = $(Resolve-Path $Path -ErrorAction SilentlyContinue).Path

    if ($UTPath.Length -eq 0) {
        $UTPath = $Path
    } else {
        $UTPath = $(Resolve-Path $UTPath -ErrorAction SilentlyContinue).Path
    }
    if ($([System.Environment]::OSVersion.Platform) -notmatch "^Win") {
        $UCCPath = "$($UTPath)/System/ucc-bin"
    }
    else
    {
        $UCCPath = "$($UTPath)\System\ucc.exe"
    }
    if (Test-Path $UCCPath) {
        $tmpPath = Get-Location
        Set-Location $UTPath
        if ($([System.Environment]::OSVersion.Platform) -notmatch "^Win") {
            $CheckPD = System/ucc-bin packagedump
        } else {
            $CheckPD = System\ucc.exe packagedump
        }
        if ($CheckPD -match "Package\sname") {
            $PugMaps -replace ":small_orange_diamond:" -replace "\d{1,2}\)" -split "\s" | ? {$_.Length} | % {
                $map = $_

                if (Test-Path -LiteralPath "$($Path)\Maps\$($map).unr") {
                    Write-Host "Dumping contents of $($map)"
                    if (Test-Path -LiteralPath "$($Path)\Maps\pkgd-$($map).txt") {
                        Get-ChildItem -LiteralPath "$($Path)\Maps\pkgd-$($map).txt" | % {
                            if ($_.Length -lt 4096) {
                                if ($([System.Environment]::OSVersion.Platform) -notmatch "^Win") {
                                    System/ucc-bin packagedump "$($Path)\Maps\$($map).unr" | Out-File -LiteralPath "$($Path)\Maps\pkgd-$($map).txt" -Force
                                } else {
                                    System\ucc.exe packagedump "$($Path)\Maps\$($map).unr" | Out-File -LiteralPath "$($Path)\Maps\pkgd-$($map).txt" -Force
                                }
                            }
                        }
                    } else {
                        if ($([System.Environment]::OSVersion.Platform) -notmatch "^Win") {
                            System/ucc-bin packagedump "$($Path)\Maps\$($map).unr" | Out-File -LiteralPath "$($Path)\Maps\pkgd-$($map).txt" -Force
                        } else {
                            System\ucc.exe packagedump "$($Path)\Maps\$($map).unr" | Out-File -LiteralPath "$($Path)\Maps\pkgd-$($map).txt" -Force
                        }
                    }
                } else {
                    Write-Host "Not found: $($map).unr" -ForegroundColor Red
                }
            }
            $Imports = @(Get-ChildItem "Maps" -Filter "pkgd-*.txt") | % {
                Write-Host "Checking $($_.BaseName)..."
                $MC = $_ | Get-Content
                $i = 0
                $Map = ""
                $MC | % {
                    if ($MC[$i] -match "Dumping\sPackage:\s(.*)") {
                        $Map = $Matches[1]
                    }
                    if ($_ -match "^Import\[\d{1,9}\]:") {
                        $Class=$Package=$Object=""
                        if ($MC[$($i+2)] -match "ClassName:\s(.*)$") {
                            if ($Matches[1] -ne "Class") {
                                $Class = $Matches[1]
                            }
                        }
                        if ($MC[$($i+3)] -match "Package\sCore\.(.*)\)$") {
                            $Package = $Matches[1]
                        }
                        if ($MC[$($i+4)] -match "ObjectName:\s(.*)$") {
                            $Object = $Matches[1]
                        }
                        "" | Select @{n="Map";e={$Map}},@{n="Package";e={$Package}},@{n="Class";e={$Class}},@{n="Object";e={$Object}}
                    }
                    if ($_ -match "^Export\sTable:") {
                        #break
                    }
                    $i++
                }
            }

            

            $Depends = $Imports | Group-Object Class | ? {$_.Name -eq "Package"} | % {
                $_.Group | Group-Object Map | % {
                    $Map = $_.Name
                    $Files = $_.Group | ? {$_.Package.Length -lt 1} | % { $_.Object | Select -Unique }
                    $Missing = $FullFiles = @()
                    @($Files | % {
                        $File = $_
                        $FoundFiles = @()
                        $Types.Keys | Sort-Object -Descending | % {
                            $FoundFiles += @(Get-ChildItem "$($Path)\$($_)" -Filter "$($File).$($Types.Get_Item($_))" | % { "$($_.Directory.Name)\$($_.Name)" })
                        }
                        if ($FoundFiles.Count -gt 0) {
                            $FullFiles += $FoundFiles
                        } else {
                            if ($File -notmatch $Ignore) {
                                Write-Host "NOT FOUND: $($File)" -foregroundcolor Red
                                $Missing += $File
                            } else {
                                Write-Host "IGNORING: $($File)" -foregroundcolor Gray
                            }
                        }
                    })
                    "" | Select @{n="Map";e={$Map}},@{n="Imports";e={$FullFiles}},@{n="Missing";e={$Missing | Select -Unique}}
                }
            }

            $Depends.Imports | Select-Object -Unique | % {
                if (!(Test-Path -LiteralPath "$($Path)\$($_)")) {
                    Write-Host "NOT PRESENT: $($_)" -foregroundcolor Red
                } else {
                    Write-Host "PRESENT: $($_)" -foregroundcolor DarkGreen
                }
            }
            if ($Source.Length) {
                $Source = $(Resolve-Path $Source -ErrorAction SilentlyContinue).Path
                if (@($Depends.Missing | Select -Unique).Count -and $(Test-Path $Source)) {
                    $Depends.Missing | Select -Unique | % {
                        $File = $_
                        $Types.Keys | Sort -Descending | % {
                            @(Get-ChildItem "$($Source)\$($_)" -Filter "$($File).$($Types.Get_Item($_))" | % {
                                Copy-Item -Path "$($_.Directory.FullName)\$($_.Name)" -Destination "$($Path)\$($_.Directory.BaseName)\" -Verbose
                                #"Copy-Item -Path `"$($_.Directory.FullName)\$($_.Name)`" -Destination `"$($Path)\$($_.Directory.BaseName)\`" -WhatIf"
                                $Depends.Missing = $Depends.Missing | ? {$_ -ne $File} # Remove from missing list
                            })
                        }
                    }
                }
            }
            if ($AllDepends.Missing.Count) {
                $AllDepends.Missing += $Depends.Missing
                $AllDepends.Missing = $AllDepends.Missing | Select-Object -Unique
            } else {
                $AllDepends = $Depends | Select-Object Missing
            }
        } else {
            Write-Host "No support for PACKAGEDUMP. Please upgrade UCC" -ForegroundColor Red
        }
        if ($AllDepends.Missing.Count) {
            Write-Host "Files still not accounted for:" -ForegroundColor Yellow
            $AllDepends.Missing | Select-Object -Unique | ? {$_.Trim() -notmatch $Ignore -and $_.Trim() -notmatch $IgnoreGroup} | % { Write-Host " - $($_)" -ForegroundColor Red } 
        }
        Set-Location $tmpPath
    } else {
        Write-Error "Invalid UT Path, please supply the correct -Path or -UTPath parameter"
    }
} else {
    Write-Error "Invalid Path, please supply the correct -Path parameter"
}
