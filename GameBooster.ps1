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

    # Ambil semua proses sekali, lebih efisien daripada loop query per-proses
    $allProcesses = Get-Process -ErrorAction SilentlyContinue | Group-Object -Property Name -AsHashTable -AsString

    foreach ($proc in $processesToKill) {
        if ($allProcesses[$proc]) {
            try {
                $running = $allProcesses[$proc]
                $ramMB = [math]::Round(($running | Measure-Object WorkingSet -Sum).Sum / 1MB, 1)
                Stop-Process -Name $proc -Force -ErrorAction Stop
                Write-OK "Killed: $proc  (RAM freed: ~$ramMB MB)"
                $killed++
            } catch {
                Write-Warn "Gagal kill: $proc - $_"
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

    # Batch retrieve semua services sekaligus
    $allServices = Get-Service -ErrorAction SilentlyContinue
    $serviceMap = @{}
    $allServices | ForEach-Object { $serviceMap[$_.Name] = $_ }

    foreach ($svc in $servicesToDisable) {
        $service = $serviceMap[$svc.Name]
        if ($service) {
            try {
                if ($service.Status -eq "Running") {
                    Stop-Service -Name $svc.Name -Force -ErrorAction Stop
                }
                Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop
                Write-OK "Disabled: $($svc.DisplayName)"
            } catch {
                Write-Warn "Gagal disable $($svc.DisplayName): $_"
            }
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
            try {
                # Ambil ukuran sebelum
                $sizeBefore = 0
                Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | 
                    ForEach-Object { $sizeBefore += $_.Length }
                
                # Hapus dengan parallel processing untuk folder besar
                Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | 
                    Remove-Item -Force -ErrorAction SilentlyContinue
                
                $totalFreed += $sizeBefore
                Write-OK "Cleaned: $path"
            } catch {
                Write-Warn "Error cleaning $path : $_"
            }
        }
    }

    # Flush DNS untuk latency yang lebih baik
    try {
        ipconfig /flushdns | Out-Null
        Write-OK "DNS Cache di-flush (bantu latency online game)"
    } catch {
        Write-Skip "Gagal flush DNS"
    }

    $freed = [math]::Round($totalFreed / 1MB, 1)
    Write-Host "  Total dibersihkan: ~$freed MB" -ForegroundColor Cyan
}

# ══════════════════════════════════════════════════════════════
#  FUNGSI: OPTIMASI REGISTRY GAMING
# ══════════════════════════════════════════════════════════════
function Set-GameOptimizations {
    Write-Section "OPTIMASI REGISTRY UNTUK GAMING"

    # Helper function untuk mengurangi redundansi registry operations
    $regOps = @(
        @{ Path = "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"; Name = "AppCaptureEnabled"; Value = 0; Type = "REG_DWORD"; Msg = "Xbox Game Bar DVR dinonaktifkan" },
        @{ Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_Enabled"; Value = 0; Type = "REG_DWORD"; Msg = "" },
        @{ Path = "HKCU\SOFTWARE\Microsoft\GameBar"; Name = "AllowAutoGameMode"; Value = 1; Type = "REG_DWORD"; Msg = "Windows Game Mode diaktifkan" },
        @{ Path = "HKCU\SOFTWARE\Microsoft\GameBar"; Name = "AutoGameModeEnabled"; Value = 1; Type = "REG_DWORD"; Msg = "" },
        @{ Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_FSEBehaviorMode"; Value = 2; Type = "REG_DWORD"; Msg = "" },
        @{ Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_HonorUserFSEBehaviorMode"; Value = 1; Type = "REG_DWORD"; Msg = "" },
        @{ Path = "HKCU\System\GameConfigStore"; Name = "GameDVR_DXGIHonorFSEWindowsCompatible"; Value = 1; Type = "REG_DWORD"; Msg = "Fullscreen Optimization dioptimasi" },
        @{ Path = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "GPU Priority"; Value = 8; Type = "REG_DWORD"; Msg = "" },
        @{ Path = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "Priority"; Value = 6; Type = "REG_DWORD"; Msg = "" },
        @{ Path = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"; Name = "Scheduling Category"; Value = "High"; Type = "REG_SZ"; Msg = "GPU dan CPU Priority untuk Games dinaikkan" },
        @{ Path = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; Name = "NetworkThrottlingIndex"; Value = "0xffffffff"; Type = "REG_DWORD"; Msg = "" },
        @{ Path = "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"; Name = "SystemResponsiveness"; Value = 0; Type = "REG_DWORD"; Msg = "Network Throttling dinonaktifkan" },
        @{ Path = "HKCU\Control Panel\Mouse"; Name = "MouseSpeed"; Value = "0"; Type = "REG_SZ"; Msg = "" },
        @{ Path = "HKCU\Control Panel\Mouse"; Name = "MouseThreshold1"; Value = "0"; Type = "REG_SZ"; Msg = "" },
        @{ Path = "HKCU\Control Panel\Mouse"; Name = "MouseThreshold2"; Value = "0"; Type = "REG_SZ"; Msg = "Mouse Acceleration dinonaktifkan (aim lebih konsisten di Valorant!)" },
        @{ Path = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"; Name = "VisualFXSetting"; Value = 2; Type = "REG_DWORD"; Msg = "Visual Effects Windows dikurangi" }
    )

    foreach ($op in $regOps) {
        try {
            reg add $op.Path /v $op.Name /t $op.Type /d $op.Value /f | Out-Null
            if ($op.Msg) { Write-OK $op.Msg }
        } catch {
            Write-Warn "Gagal set registry $($op.Name): $_"
        }
    }
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

    # Batch retrieve services untuk efisiensi
    $allServices = Get-Service -ErrorAction SilentlyContinue
    $serviceMap = @{}
    $allServices | ForEach-Object { $serviceMap[$_.Name] = $_ }

    foreach ($svc in $servicesToDisable) {
        if ($serviceMap[$svc.Name]) {
            try {
                Set-Service -Name $svc.Name -StartupType Automatic -ErrorAction Stop
                Start-Service -Name $svc.Name -ErrorAction Stop
                Write-OK "Restored: $($svc.DisplayName)"
            } catch {
                Write-Warn "Gagal restore $($svc.DisplayName): $_"
            }
        }
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

    # Restore mouse settings
    $mouseSettings = @(
        @{ Name = "MouseSpeed"; Value = "1" },
        @{ Name = "MouseThreshold1"; Value = "6" },
        @{ Name = "MouseThreshold2"; Value = "10" }
    )

    foreach ($setting in $mouseSettings) {
        try {
            reg add "HKCU\Control Panel\Mouse" /v $setting.Name /t REG_SZ /d $setting.Value /f | Out-Null
        } catch {
            Write-Warn "Gagal restore mouse setting $($setting.Name)"
        }
    }
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
