# ============================================================
#  GAME BOOSTER - Laptop Optimizer for Gaming
#  Dibuat untuk: Optimasi Valorant & Gaming Performa
#  Cara pakai: Klik kanan -> Run with PowerShell (As Admin)
# ============================================================

param(
    [switch]$Restore,
    [switch]$Silent
)

# ── HELPER FUNCTIONS ─────────────────────────────────────────
function Write-Header {
    Clear-Host
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "       GAME BOOSTER - Laptop Optimizer for Gaming       " -ForegroundColor Cyan
    Write-Host "              by GitHub Copilot for MUSA                " -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step($msg) { Write-Host "  >> $msg" -ForegroundColor Yellow }
function Write-OK($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Skip($msg) { Write-Host "  [--] $msg" -ForegroundColor DarkGray }
function Write-Warn($msg) { Write-Host "  [!!] $msg" -ForegroundColor Red }
function Write-Section($title) {
    Write-Host ""
    Write-Host "  --------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host "  [ $title ]" -ForegroundColor White
    Write-Host "  --------------------------------------------------" -ForegroundColor DarkCyan
}

# ── CEK ADMIN ────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Script ini butuh hak Administrator!"
    Write-Host "Silakan klik kanan file ini -> 'Run with PowerShell' sebagai Admin" -ForegroundColor Yellow
    pause
    exit
}

Write-Header

# ══════════════════════════════════════════════════════════════
#  DAFTAR PROSES AMAN UNTUK DIMATIKAN SAAT GAMING
# ══════════════════════════════════════════════════════════════
$processesToKill = @(
    "MicrosoftEdgeUpdate",
    "edgeupdate",
    "edgeupdatem",
    "GoogleUpdate",
    "GoogleCrashHandler",
    "GoogleCrashHandler64",
    "OneDrive",
    "OneDriveStandaloneUpdater",
    "Teams",
    "ms-teams",
    "OUTLOOK",
    "WINWORD",
    "EXCEL",
    "SkypeApp",
    "Skype",
    "Spotify",
    "iTunesHelper",
    "AppleMobileDeviceService",
    "AdobeUpdateService",
    "AdobeIPCBroker",
    "AGSService",
    "CCXProcess",
    "McAfeeClassic",
    "mcapexe",
    "mfevtps",
    "MCUICNT",
    "Norton",
    "NortonSecurity",
    "mbam",
    "Zoom",
    "ZoomOutlookIMPlugin",
    "CptHost",
    "nvsphelper64",
    "AdobeCollabSync",
    "acrotray",
    "sidebar",
    "wlanext",
    "yourphone",
    "YourPhone",
    "PhoneExperienceHost",
    "DropboxUpdate",
    "Dropbox",
    "iCloudDrive",
    "iCloudServices",
    "ApplePhotoStreams"
)

# ══════════════════════════════════════════════════════════════
#  SERVICES YANG AMAN DI-DISABLE SAAT GAMING
# ══════════════════════════════════════════════════════════════
$servicesToDisable = @(
    @{ Name = "SysMain";            DisplayName = "SysMain (Superfetch)" },
    @{ Name = "DiagTrack";          DisplayName = "Connected User Experiences and Telemetry" },
    @{ Name = "dmwappushservice";   DisplayName = "WAP Push Message Routing" },
    @{ Name = "WSearch";            DisplayName = "Windows Search Indexer" },
    @{ Name = "TabletInputService"; DisplayName = "Touch Keyboard and Handwriting" },
    @{ Name = "Fax";                DisplayName = "Fax Service" },
    @{ Name = "RetailDemo";         DisplayName = "Retail Demo Service" },
    @{ Name = "MapsBroker";         DisplayName = "Downloaded Maps Manager" },
    @{ Name = "lfsvc";              DisplayName = "Geolocation Service" },
    @{ Name = "RemoteRegistry";     DisplayName = "Remote Registry" },
    @{ Name = "XblAuthManager";     DisplayName = "Xbox Live Auth Manager" },
    @{ Name = "XblGameSave";        DisplayName = "Xbox Live Game Save" },
    @{ Name = "XboxNetApiSvc";      DisplayName = "Xbox Live Networking Service" },
    @{ Name = "XboxGipSvc";         DisplayName = "Xbox Accessory Management" }
)

# ══════════════════════════════════════════════════════════════
#  FUNGSI: KILL PROSES TIDAK PENTING
# ══════════════════════════════════════════════════════════════
function Kill-UnnecessaryProcesses {
    Write-Section "MATIKAN PROSES TIDAK PENTING"
    $killed  = 0
    $skipped = 0

    foreach ($proc in $processesToKill) {
        $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
        if ($running) {
            try {
                $ramMB = [math]::Round(($running | Measure-Object WorkingSet -Sum).Sum / 1MB, 1)
                Stop-Process -Name $proc -Force -ErrorAction Stop
                Write-OK "Killed: $proc  (RAM freed: ~$ramMB MB)"
                $killed++
            } catch {
                Write-Warn "Gagal kill: $proc"
            }
        } else {
            $skipped++
        }
    }

    Write-Host ""
    Write-Host "  Hasil: $killed proses dimatikan, $skipped tidak berjalan" -ForegroundColor Cyan
}

# ══════════════════════════════════════════════════════════════
#  FUNGSI: SET HIGH PERFORMANCE POWER PLAN
# ══════════════════════════════════════════════════════════════
function Set-HighPerformancePower {
    Write-Section "SET POWER PLAN KE HIGH PERFORMANCE"

    $ultimate = powercfg /list | Select-String "Ultimate Performance"
    $highPerf  = powercfg /list | Select-String "High performance"

    if ($ultimate) {
        $guid = ($ultimate -split "\s+")[3]
        powercfg /setactive $guid
        Write-OK "Power Plan: Ultimate Performance diaktifkan"
    } elseif ($highPerf) {
        $guid = ($highPerf -split "\s+")[3]
        powercfg /setactive $guid
        Write-OK "Power Plan: High Performance diaktifkan"
    } else {
        Write-Step "Membuat Ultimate Performance power plan..."
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
        $newUlt = powercfg /list | Select-String "Ultimate Performance"
        if ($newUlt) {
            $guid = ($newUlt -split "\s+")[3]
            powercfg /setactive $guid
            Write-OK "Ultimate Performance berhasil dibuat dan diaktifkan"
        }
    }

    powercfg /change standby-timeout-ac 0
    powercfg /change hibernate-timeout-ac 0
    Write-OK "Sleep/Hibernate dinonaktifkan (saat charging)"
}

# ══════════════════════════════════════════════════════════════
#  FUNGSI: DISABLE SERVICES
# ══════════════════════════════════════════════════════════════
function Disable-TelemetryServices {
    Write-Section "NONAKTIFKAN SERVICES TIDAK PENTING"

    foreach ($svc in $servicesToDisable) {
        $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($service) {
            if ($service.Status -eq "Running") {
                Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
            }
            Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
            Write-OK "Disabled: $($svc.DisplayName)"
        } else {
            Write-Skip "Tidak ada: $($svc.DisplayName)"
        }
    }
}

# ══════════════════════════════════════════════════════════════
#  FUNGSI: BERSIHKAN FILE SAMPAH
# ══════════════════════════════════════════════════════════════
function Clean-TempFiles {
    Write-Section "BERSIHKAN FILE SAMPAH"

    $paths = @(
        "$env:TEMP",
        "$env:LOCALAPPDATA\Temp",
        "C:\Windows\Temp",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
    )

    $totalFreed = 0
    foreach ($path in $paths) {
        if (Test-Path $path) {
            $sizeBefore = (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            $totalFreed += $sizeBefore
            Write-OK "Cleaned: $path"
        }
    }

    $freed = [math]::Round($totalFreed / 1MB, 1)
    Write-Host "  Total dibersihkan: ~$freed MB" -ForegroundColor Cyan

    ipconfig /flushdns | Out-Null
    Write-OK "DNS Cache di-flush (bantu latency online game)"
}

# ══════════════════════════════════════════════════════════════
#  FUNGSI: OPTIMASI REGISTRY GAMING
# ══════════════════════════════════════════════════════════════
function Set-GameOptimizations {
    Write-Section "OPTIMASI REGISTRY UNTUK GAMING"

    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
    Write-OK "Xbox Game Bar DVR dinonaktifkan"

    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f | Out-Null
    Write-OK "Windows Game Mode diaktifkan"

    reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f | Out-Null
    reg add "HKCU\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKCU\System\GameConfigStore" /v GameDVR_DXGIHonorFSEWindowsCompatible /t REG_DWORD /d 1 /f | Out-Null
    Write-OK "Fullscreen Optimization dioptimasi"

    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f | Out-Null
    Write-OK "GPU dan CPU Priority untuk Games dinaikkan"

    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f | Out-Null
    Write-OK "Network Throttling dinonaktifkan"

    reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d "0" /f | Out-Null
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d "0" /f | Out-Null
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d "0" /f | Out-Null
    Write-OK "Mouse Acceleration dinonaktifkan (aim lebih konsisten di Valorant!)"

    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f | Out-Null
    Write-OK "Visual Effects Windows dikurangi"
}

# ══════════════════════════════════════════════════════════════
#  FUNGSI: TAMPILKAN GPU INFO + TIPS
# ══════════════════════════════════════════════════════════════
function Show-GPUTips {
    Write-Section "INFO GPU DAN TIPS OPTIMASI"

    $gpus = Get-WmiObject Win32_VideoController | Where-Object { $_.Name -match "NVIDIA|AMD|Intel" }
    foreach ($g in $gpus) {
        Write-Host "  GPU Terdeteksi: $($g.Name)" -ForegroundColor Magenta
    }

    Write-Host ""
    Write-Host "  Tips NVIDIA Control Panel (lakukan manual):" -ForegroundColor Yellow
    Write-Host "    1. Buka NVIDIA Control Panel" -ForegroundColor White
    Write-Host "    2. Manage 3D Settings -> Power Management -> Prefer Maximum Performance" -ForegroundColor White
    Write-Host "    3. Low Latency Mode -> Ultra" -ForegroundColor White
    Write-Host "    4. Vertical Sync -> Off" -ForegroundColor White
    Write-Host "    5. Texture Filtering Quality -> High Performance" -ForegroundColor White
    Write-Host ""
    Write-Host "  Tips In-Game Valorant:" -ForegroundColor Yellow
    Write-Host "    - Material/Texture/Detail/UI Quality -> Low" -ForegroundColor White
    Write-Host "    - VSync -> Off" -ForegroundColor White
    Write-Host "    - Anti-Aliasing -> None" -ForegroundColor White
    Write-Host "    - Bloom, Distortion, Cast Shadows -> Off" -ForegroundColor White
    Write-Host "    - Display Mode -> Fullscreen (bukan Windowed!)" -ForegroundColor White
}

# ══════════════════════════════════════════════════════════════
#  FUNGSI: TAMPILKAN STATUS RESOURCE
# ══════════════════════════════════════════════════════════════
function Show-ResourceStats {
    Write-Section "STATUS RESOURCE SAAT INI"

    $os       = Get-WmiObject Win32_OperatingSystem
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $freeRAM  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $usedRAM  = [math]::Round($totalRAM - $freeRAM, 1)
    $ramPct   = [math]::Round(($usedRAM / $totalRAM) * 100, 0)

    Write-Host "  RAM Total : $totalRAM GB" -ForegroundColor White
    $ramColor = if ($ramPct -gt 80) { "Red" } elseif ($ramPct -gt 60) { "Yellow" } else { "Green" }
    Write-Host "  RAM Pakai : $usedRAM GB ($ramPct%)" -ForegroundColor $ramColor
    Write-Host "  RAM Bebas : $freeRAM GB" -ForegroundColor Green

    $cpu = (Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    $cpuColor = if ($cpu -gt 80) { "Red" } elseif ($cpu -gt 50) { "Yellow" } else { "Green" }
    Write-Host "  CPU Usage : $cpu%" -ForegroundColor $cpuColor

    Write-Host ""
    Write-Host "  Top 10 Proses RAM Terbesar:" -ForegroundColor Cyan
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 | ForEach-Object {
        $ramMB = [math]::Round($_.WorkingSet / 1MB, 1)
        $color = if ($ramMB -gt 500) { "Red" } elseif ($ramMB -gt 200) { "Yellow" } else { "White" }
        Write-Host ("    {0,-30} {1,7} MB" -f $_.ProcessName, $ramMB) -ForegroundColor $color
    }
}

# ══════════════════════════════════════════════════════════════
#  FUNGSI: RESTORE KE NORMAL
# ══════════════════════════════════════════════════════════════
function Restore-NormalSettings {
    Write-Section "RESTORE KE PENGATURAN NORMAL"

    foreach ($svc in $servicesToDisable) {
        Set-Service -Name $svc.Name -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name $svc.Name -ErrorAction SilentlyContinue
        Write-OK "Restored: $($svc.DisplayName)"
    }

    $balanced = powercfg /list | Select-String "Balanced"
    if ($balanced) {
        $guid = ($balanced -split "\s+")[3]
        powercfg /setactive $guid
        Write-OK "Power Plan dikembalikan ke Balanced"
    }

    powercfg /change standby-timeout-ac 15
    powercfg /change hibernate-timeout-ac 30
    Write-OK "Sleep/Hibernate dikembalikan"

    reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d "1" /f | Out-Null
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d "6" /f | Out-Null
    reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d "10" /f | Out-Null
    Write-OK "Mouse Acceleration dikembalikan ke default"

    Write-Host ""
    Write-OK "Semua setting berhasil dikembalikan ke normal!"
}

# ══════════════════════════════════════════════════════════════
#  MAIN EXECUTION
# ══════════════════════════════════════════════════════════════

if ($Restore) {
    Restore-NormalSettings
    Write-Host ""
    Write-Host "  Selesai! Semua setting kembali normal." -ForegroundColor Green
    if (-not $Silent) { pause }
    exit
}

Show-ResourceStats

Write-Host ""
Write-Host "  Siap mengoptimalkan laptop untuk gaming..." -ForegroundColor Cyan

if (-not $Silent) {
    Write-Host "  Tekan ENTER untuk mulai, atau CTRL+C untuk batal..." -ForegroundColor Yellow
    Read-Host
}

Kill-UnnecessaryProcesses
Set-HighPerformancePower
Disable-TelemetryServices
Clean-TempFiles
Set-GameOptimizations
Show-GPUTips

Show-ResourceStats

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "         OPTIMASI SELESAI! LAPTOP SIAP GAMING          " -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Setelah selesai gaming, jalankan:" -ForegroundColor Yellow
Write-Host "    .\GameBooster.ps1 -Restore" -ForegroundColor White
Write-Host "  untuk mengembalikan semua setting ke normal." -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Tips Tambahan:" -ForegroundColor Yellow
Write-Host "    - Pastikan laptop colok charger saat gaming" -ForegroundColor White
Write-Host "    - Gunakan cooling pad jika ada" -ForegroundColor White
Write-Host "    - Bersihkan fan laptop dari debu (tiap 6 bulan)" -ForegroundColor White
Write-Host "    - Update driver GPU ke versi terbaru" -ForegroundColor White
Write-Host "    - Tutup browser sebelum buka game" -ForegroundColor White
Write-Host ""

if (-not $Silent) { pause }
