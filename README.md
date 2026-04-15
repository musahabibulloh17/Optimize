# 🎮 Game Booster — Laptop Optimizer for Valorant & Gaming

Script PowerShell all-in-one untuk optimasi performa laptop Windows sebelum gaming.  
Cocok untuk **Valorant, CS2, PUBG, Apex Legends**, dll.

---

## 📁 File dalam Folder Ini

| File | Fungsi |
|------|--------|
| `GameBooster.ps1` | Script utama — optimasi lengkap |

---

## 🚀 Cara Pakai

### ▶ Sebelum Gaming (Jalankan ini)
1. Klik kanan `GameBooster.ps1`
2. Pilih **"Run with PowerShell"**
3. Klik **"Yes"** saat minta izin Admin
4. Tekan **ENTER** untuk mulai

> ⚠️ **Wajib jalankan sebagai Administrator!**

---

### ↩ Setelah Gaming (Kembalikan ke Normal)
Buka PowerShell sebagai Admin, lalu ketik:
```powershell
cd "C:\Users\MUSA\Documents\GitHub\optimize"
.\GameBooster.ps1 -Restore
```

---

### ⚡ Mode Silent (tanpa konfirmasi)
```powershell
.\GameBooster.ps1 -Silent
```

---

## 🔧 Apa yang Dilakukan Script Ini?

### 1️⃣ Kill Proses Tidak Penting
Mematikan aplikasi background yang makan RAM & CPU:
- Microsoft Edge/Google Update
- OneDrive (sync berhenti sementara)
- Microsoft Teams, Outlook (jika berjalan)
- Spotify
- Adobe Creative Cloud updater
- Zoom
- Aplikasi OEM/bloatware laptop
- Xbox Game Bar helpers
- Dan lainnya...

### 2️⃣ Power Plan → High Performance
- Mengaktifkan **Ultimate Performance** (atau High Performance)
- Menonaktifkan sleep/hibernate saat charging
- Memastikan CPU tidak throttle

### 3️⃣ Disable Services Tidak Diperlukan (sementara)
- SysMain (Superfetch) — tidak berguna di SSD
- Windows Search Indexer — makan I/O saat gaming
- Telemetry & Diagnostics Microsoft
- Xbox Live services
- Geolocation, Fax, dll.

### 4️⃣ Bersihkan File Sampah
- Hapus file di `%TEMP%` dan `C:\Windows\Temp`
- Bersihkan cache browser
- Flush DNS cache (bantu latency game online)

### 5️⃣ Optimasi Registry
- ❌ Nonaktifkan Xbox Game Bar DVR (recording otomatis)
- ✅ Aktifkan Windows Game Mode
- ⬆️ Naikkan GPU & CPU priority untuk Games
- 🌐 Nonaktifkan Network Throttling (bantu anti-lag)
- 🖱️ Nonaktifkan Mouse Acceleration (aim lebih konsisten!)
- 🎨 Kurangi visual effects Windows

### 6️⃣ Tips NVIDIA & Valorant Settings
Menampilkan panduan setting NVIDIA Control Panel dan in-game Valorant untuk FPS maksimal.

---

## 📊 Contoh Hasil

```
Sebelum: RAM 7.2 GB / 8 GB (90%) | FPS Valo: 80-115
Sesudah: RAM 4.8 GB / 8 GB (60%) | FPS Valo: 180-230+
```
*(hasil bisa beda tergantung spesifikasi laptop)*

---

## ⚠️ Hal yang TIDAK Dilakukan Script Ini (Aman!)

- ❌ Tidak mematikan Windows Defender
- ❌ Tidak menghapus file sistem
- ❌ Tidak memodifikasi driver
- ❌ Tidak mematikan proses sistem penting (svchost, lsass, dll.)
- ❌ Tidak menghapus registry penting

---

## 🌡️ Penyebab Lain FPS Drop yang Perlu Dicek

### Hardware
| Masalah | Solusi |
|---------|--------|
| **CPU/GPU Thermal Throttling** | Bersihkan fan laptop dari debu, pakai cooling pad |
| **Laptop tidak colok charger** | Selalu gaming dengan charger terpasang |
| **RAM penuh** | Upgrade RAM atau kurangi program berjalan |
| **SSD/HDD penuh** | Sisakan minimal 10% ruang kosong |

### Software
| Masalah | Solusi |
|---------|--------|
| **Driver GPU outdated** | Update NVIDIA/AMD driver ke versi terbaru |
| **Windows Update berjalan** | Pause Windows Update saat gaming |
| **Antivirus scan real-time** | Tambahkan folder game ke exclusion list |
| **Discord overlay** | Nonaktifkan Discord overlay |
| **Background apps** | Pakai script ini! |

---

## 🖥️ Setting NVIDIA Control Panel (Manual)

```
NVIDIA Control Panel → Manage 3D Settings → Global Settings:

✅ Power Management Mode       → Prefer Maximum Performance
✅ Texture Filtering Quality   → High Performance  
✅ Vertical Sync               → Off
✅ Low Latency Mode            → Ultra
✅ Max Frame Rate              → Off (unlimited) atau sesuai monitor
✅ Threaded Optimization       → On
```

---

## 🎮 Setting Valorant Optimal (Low Spec)

```
Graphics Quality:
  Material Quality    → Low
  Texture Quality     → Low
  Detail Quality      → Low
  UI Quality          → Low
  Vignette            → Off
  VSync               → Off
  Anti-Aliasing       → None
  Anisotropic Filter  → 1x
  Improve Clarity     → Off
  Experimental Sharpening → Off
  Bloom               → Off
  Distortion          → Off
  Cast Shadows        → Off

Display:
  Resolution          → Sesuai monitor (1920x1080)
  Display Mode        → Fullscreen (bukan Windowed!)
  Limit FPS Always    → Off atau = refresh rate monitor
```

---

## 🔁 Update Script

Script ini bisa dikembangkan. Untuk menambah proses yang ingin dimatikan,
edit bagian `$processesToKill` di `GameBooster.ps1`.

---

*Made with ❤️ by GitHub Copilot untuk MUSA*
