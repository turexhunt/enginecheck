<#
.SYNOPSIS
    EngineCheck v3.0 - Interactive ScreenShare Checker
.DESCRIPTION
    Menu-driven checker with precise signatures to avoid false positives.
    Run via: irm <raw-url> | iex
#>

# ============================================================
# CONFIGURATION
# ============================================================
$Config = @{
    TelegramBotToken = "ТВОЙ_ТОКЕН_БОТА"
    TelegramChatId   = "ТВОЙ_CHAT_ID"
    MaxJarSizeMB     = 100
}

# ============================================================
# PRECISE SIGNATURE DATABASE (Только читерские функции)
# ============================================================
$Script:CheatNames = @(
    "impact","wurst","bleachhack","aristois","huzuni","skillclient","nodus","inertia",
    "ares","sigma","meteor","atomic","zamorozka","liquidbounce","nurik","celestial",
    "expensive","neverhook","wexside","future","dreampool","vape","konas","zeusclient",
    "richclient","ghostclient","rusherhack","thunderhack","moonhack","exire","doomsday",
    "nightware","extazyy","arbuz","xameleon","feather","delta","eclipse","venus","jex",
    "hakari","hush","rogalik","catlavan","haruka","wissend","fluger","vortex","astra",
    "britva","bariton","luminex","nuclear"
)

# Только специфичные строки, которые вряд ли встретятся в легитимных модах
$Script:CheatStrings = @(
    "killaura", "kill_aura", "aimbot", "aim_assist", "aimassist",
    "hitbox_expand", "hitboxexpand", "reach_hack", "reachhack",
    "autototem", "auto_totem", "autocrystal", "auto_crystal",
    "antiknockback", "anti_knockback", "velocity_mod",
    "nuker", "scaffold_walk", "scaffoldwalk",
    "xray", "x_ray", "tracers", "backtrack", "nofall", "no_fall",
    "fastplace", "fast_place", "fastbreak", "fast_break",
    "pingspoof", "ping_spoof", "critical_hit", "criticalhit"
)

$Script:RequiredServices = @("Sysmain","Diagtrack","PcaSvc","DPS","Eventlog","AppInfo")

# ============================================================
# UI HELPERS
# ============================================================
$Script:Report = New-Object System.Collections.Generic.List[string]
$Script:ThreatsFound = 0

function Write-Banner {
    Clear-Host
    $banner = @"
╔══════════════════════════════════════════════════════════════════════╗
║                                                                      ║
║   ███████╗███╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗                   ║
║   ██╔════╝████╗  ██║██╔════╝ ██║████╗  ██║██╔════╝                   ║
║   █████╗  ██╔██╗ ██║██║  ███╗██║██╔██╗ ██║█████╗                     ║
║   ██╔══╝  ██║╚██╗██║██║   ██║██║██║╚██╗██║██╔══╝                     ║
║   ███████╗██║ ╚████║╚██████╔╝██║██║ ╚████║███████╗                   ║
║   ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝                   ║
║                                                                      ║
║              ENGINE CHECK v3.0 - INTERACTIVE                         ║
║              Precise Detection | No False Positives                  ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
"@
    Write-Host $banner -ForegroundColor Cyan
    Write-Host ""
}

function Write-Result {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $line = "[$timestamp] $Message"
    $Script:Report.Add($line)
    
    switch ($Level) {
        "FOUND" { 
            Write-Host "  [!] $Message" -ForegroundColor Red
            $Script:ThreatsFound++
        }
        "WARN"  { Write-Host "  [?] $Message" -ForegroundColor Yellow }
        "OK"    { Write-Host "  [+] $Message" -ForegroundColor Green }
        "INFO"  { Write-Host "  [*] $Message" -ForegroundColor Gray }
    }
}

# ============================================================
# MENU SYSTEM
# ============================================================
function Show-MainMenu {
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "  │                    ВЫБЕРИТЕ ДЕЙСТВИЕ                    │" -ForegroundColor DarkCyan
    Write-Host "  ├─────────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan
    Write-Host "  │  [1] Полный скан (все проверки по очереди)              │" -ForegroundColor White
    Write-Host "  │  [2] Только JAR анализ (поиск читов в .jar)             │" -ForegroundColor White
    Write-Host "  │  [3] Только службы (Services)                           │" -ForegroundColor White
    Write-Host "  │  [4] Только процессы (Processes)                        │" -ForegroundColor White
    Write-Host "  │  [5] Только Everything (поиск файлов по диску)          │" -ForegroundColor White
    Write-Host "  │  [6] Только строки (explorer.exe / javaw.exe)           │" -ForegroundColor White
    Write-Host "  │  [7] Отправить отчёт в Telegram                         │" -ForegroundColor White
    Write-Host "  │  [0] Выход                                              │" -ForegroundColor White
    Write-Host "  └─────────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    Write-Host ""
}

# ============================================================
# EVERYTHING AUTO-INSTALL & SCAN
# ============================================================
function Install-EverythingCLI {
    Write-Result "Everything CLI не найден. Скачиваю..." "INFO"
    
    $installDir = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }
    
    $esPath = Join-Path $installDir "es.exe"
    
    # Прямая ссылка на x64 версию ES с GitHub
    $downloadUrl = "https://github.com/voidtools/ES/releases/download/1.1.0.37/ES-1.1.0.37.x64.zip"
    $zipPath = "$env:TEMP\ES.zip"
    
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force
        $extractedEs = Get-ChildItem -Path $env:TEMP -Filter "es.exe" -Recurse | Select-Object -First 1
        
        if ($extractedEs) {
            Copy-Item -Path $extractedEs.FullName -Destination $esPath -Force
            Write-Result "Everything CLI установлен в $esPath" "OK"
            return $esPath
        } else {
            Write-Result "Не удалось найти es.exe в архиве." "WARN"
            return $null
        }
    } catch {
        Write-Result "Ошибка скачивания Everything CLI: $_" "WARN"
        return $null
    } finally {
        Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
    }
}

function Get-EsPath {
    $esPath = Get-Command "es.exe" -ErrorAction SilentlyContinue
    if ($esPath) { return $esPath.Source }
    
    $localEs = "$env:LOCALAPPDATA\Microsoft\WindowsApps\es.exe"
    if (Test-Path $localEs) { return $localEs }
    
    return (Install-EverythingCLI)
}

function Start-EverythingScan {
    Write-Result "=== EVERYTHING SCAN ===" "INFO"
    $esPath = Get-EsPath
    if (-not $esPath) {
        Write-Result "Everything CLI недоступен. Пропускаю." "WARN"
        return
    }
    
    $regex = ($Script:CheatNames -join "|")
    $query = "ext:exe;jar;zip;rar regex:$regex"
    
    try {
        Write-Result "Запуск поиска Everything..." "INFO"
        $result = & $esPath -regex $query 2>$null
        
        if ($result) {
            foreach ($line in $result) {
                Write-Result "EVERYTHING: $line" "FOUND"
            }
        } else {
            Write-Result "Everything: совпадений не найдено." "OK"
        }
    } catch {
        Write-Result "Ошибка Everything: $_" "WARN"
    }
}

# ============================================================
# SERVICES CHECK
# ============================================================
function Test-Services {
    Write-Result "=== ПРОВЕРКА СЛУЖБ ===" "INFO"
    $i = 0
    foreach ($svc in $Script:RequiredServices) {
        $i++
        Write-Host "`r  Проверка $svc ($i/$($Script:RequiredServices.Count))..." -NoNewline -ForegroundColor Gray
        try {
            $service = Get-Service -Name $svc -ErrorAction Stop
            if ($service.Status -eq 'Running') {
                Write-Result "Служба $svc : RUNNING" "OK"
            } else {
                Write-Result "Служба $svc : $($service.Status) (ПОДОЗРИТЕЛЬНО)" "FOUND"
            }
        } catch {
            Write-Result "Служба $svc : НЕ НАЙДЕНА (ПОДОЗРИТЕЛЬНО)" "FOUND"
        }
    }
    Write-Host ""
}

# ============================================================
# PROCESS SCAN
# ============================================================
function Test-Processes {
    Write-Result "=== ПРОВЕРКА ПРОЦЕССОВ ===" "INFO"
    $pattern = ($Script:CheatNames -join "|")
    $processes = Get-Process | Where-Object { $_.ProcessName -match $pattern }
    
    if ($processes) {
        foreach ($proc in $processes) {
            Write-Result "НАЙДЕН ПРОЦЕСС: $($proc.ProcessName) (PID: $($proc.Id))" "FOUND"
        }
    } else {
        Write-Result "Подозрительных процессов не найдено." "OK"
    }
    Write-Host ""
}

# ============================================================
# DEEP JAR ANALYZER
# ============================================================
function Get-ConstantPoolStrings {
    param([byte[]]$ClassBytes)
    $strings = New-Object System.Collections.Generic.List[string]
    try {
        if ($ClassBytes.Length -lt 10) { return $strings }
        $offset = 8
        $cpCount = [int]($ClassBytes[$offset] -shl 8) -bor $ClassBytes[$offset + 1]
        $offset += 2
        $i = 1
        while ($i -lt $cpCount) {
            if ($offset -ge $ClassBytes.Length) { break }
            $tag = $ClassBytes[$offset]; $offset++
            switch ($tag) {
                1 { 
                    if ($offset + 2 -gt $ClassBytes.Length) { break }
                    $len = [int]($ClassBytes[$offset] -shl 8) -bor $ClassBytes[$offset + 1]
                    $offset += 2
                    if ($offset + $len -le $ClassBytes.Length) {
                        $strings.Add([System.Text.Encoding]::UTF8.GetString($ClassBytes, $offset, $len))
                    }
                    $offset += $len
                }
                3 { $offset += 4 }; 4 { $offset += 4 }
                5 { $offset += 8; $i++ }; 6 { $offset += 8; $i++ }
                7 { $offset += 2 }; 8 { $offset += 2 }
                9 { $offset += 4 }; 10 { $offset += 4 }; 11 { $offset += 4 }; 12 { $offset += 4 }
                15 { $offset += 3 }; 16 { $offset += 2 }; 18 { $offset += 4 }
                default { break }
            }
            $i++
        }
    } catch { }
    return $strings
}

function Start-JarScan {
    Write-Result "=== JAR АНАЛИЗ ===" "INFO"
    
    $searchPaths = @(
        "$env:APPDATA\.minecraft",
        "$env:APPDATA\.minecraft\mods",
        "$env:APPDATA\.minecraft\versions",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Desktop"
    ) | Where-Object { Test-Path $_ }
    
    if ($searchPaths.Count -eq 0) {
        Write-Result "Папки Minecraft/загрузок не найдены." "WARN"
        return
    }
    
    $jars = @()
    foreach ($path in $searchPaths) {
        $found = Get-ChildItem -Path $path -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue |
                 Where-Object { $_.Length -lt ($Config.MaxJarSizeMB * 1MB) }
        $jars += $found
    }
    
    Write-Result "Найдено JAR файлов: $($jars.Count)" "INFO"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    $suspiciousCount = 0
    $i = 0
    foreach ($jar in $jars) {
        $i++
        Write-Host "`r  Сканирую $i из $($jars.Count): $($jar.Name)" -NoNewline -ForegroundColor Gray
        
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
            $jarName = $jar.Name.ToLower()
            $reasons = @()
            
            foreach ($cheat in $Script:CheatNames) {
                if ($jarName -match [regex]::Escape($cheat)) {
                    $reasons += "Имя JAR содержит: $cheat"
                }
            }
            
            foreach ($entry in $zip.Entries) {
                if ($entry.FullName -match "\.class$") {
                    try {
                        $stream = $entry.Open()
                        $ms = New-Object System.IO.MemoryStream
                        $stream.CopyTo($ms)
                        $classBytes = $ms.ToArray()
                        $stream.Close(); $ms.Close()
                        
                        $cpStrings = Get-ConstantPoolStrings -ClassBytes $classBytes
                        foreach ($str in $cpStrings) {
                            foreach ($sig in $Script:CheatStrings) {
                                if ($str -match [regex]::Escape($sig)) {
                                    $reasons += "Класс $($entry.FullName) содержит строку: '$str'"
                                    break
                                }
                            }
                        }
                    } catch { }
                }
            }
            
            $zip.Dispose()
            
            if ($reasons.Count -gt 0) {
                $suspiciousCount++
                Write-Host ""
                Write-Result "ПОДОЗРИТЕЛЬНЫЙ JAR: $($jar.FullName)" "FOUND"
                foreach ($r in $reasons | Select-Object -First 5) {
                    Write-Host "      -> $r" -ForegroundColor DarkRed
                }
            }
        } catch { }
    }
    
    Write-Host ""
    if ($suspiciousCount -eq 0) {
        Write-Result "Подозрительных JAR не найдено (проверено $($jars.Count))." "OK"
    } else {
        Write-Result "ВСЕГО ПОДОЗРИТЕЛЬНЫХ JAR: $suspiciousCount" "FOUND"
    }
}

# ============================================================
# STRINGS SCAN
# ============================================================
function Test-Strings {
    Write-Result "=== СТРОКИ (explorer/javaw) ===" "INFO"
    $targets = @(
        @{ Path = "$env:WINDIR\explorer.exe"; Patterns = @("deltadlc","nursultam","celestial") },
        @{ Path = "$env:WINDIR\System32\javaw.exe"; Patterns = @("l.png") }
    )
    foreach ($target in $targets) {
        if (-not (Test-Path $target.Path)) { continue }
        try {
            $bytes = [System.IO.File]::ReadAllBytes($target.Path)
            $text = [System.Text.Encoding]::ASCII.GetString($bytes)
            foreach ($pattern in $target.Patterns) {
                if ($text -match [regex]::Escape($pattern)) {
                    Write-Result "НАЙДЕНО в $([System.IO.Path]::GetFileName($target.Path)): '$pattern'" "FOUND"
                }
            }
        } catch { }
    }
    Write-Result "Проверка строк завершена." "OK"
}

# ============================================================
# TELEGRAM REPORT
# ============================================================
function Send-TelegramReport {
    if ($Config.TelegramBotToken -eq "ТВОЙ_ТОКЕН_БОТА") {
        Write-Result "Telegram не настроен." "WARN"
        return
    }
    
    $tempFile = "$env:TEMP\enginecheck_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $Script:Report -join "`r`n" | Out-File -FilePath $tempFile -Encoding UTF8
    
    try {
        $uri = "https://api.telegram.org/bot$($Config.TelegramBotToken)/sendDocument"
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            Invoke-RestMethod -Uri $uri -Method Post -Form @{ chat_id = $Config.TelegramChatId; document = Get-Item $tempFile }
        } else {
            $boundary = [System.Guid]::NewGuid().ToString()
            $fileBytes = [System.IO.File]::ReadAllBytes($tempFile)
            $enc = [System.Text.Encoding]::GetEncoding('ISO-8859-1')
            $LF = "`r`n"
            $body = ("--$boundary","Content-Disposition: form-data; name=`"chat_id`"$LF",$Config.TelegramChatId,"--$boundary","Content-Disposition: form-data; name=`"document`"; filename=`"report.txt`"","Content-Type: application/octet-stream$LF",$enc.GetString($fileBytes),"--$boundary--$LF") -join $LF
            Invoke-RestMethod -Uri $uri -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $body
        }
        Write-Result "Отчёт отправлен в Telegram." "OK"
    } catch {
        Write-Result "Ошибка отправки: $_" "WARN"
    } finally {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}

# ============================================================
# MAIN EXECUTION LOOP
# ============================================================
Write-Banner
$Script:Report.Add("=== ENGINE CHECK REPORT ===")
$Script:Report.Add("Дата: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$Script:Report.Add("")

$exit = $false
while (-not $exit) {
    Show-MainMenu
    $choice = Read-Host "  Введите номер"
    
    switch ($choice) {
        "1" { Test-Services; Test-Processes; Start-JarScan; Test-Strings; Start-EverythingScan }
        "2" { Start-JarScan }
        "3" { Test-Services }
        "4" { Test-Processes }
        "5" { Start-EverythingScan }
        "6" { Test-Strings }
        "7" { Send-TelegramReport }
        "0" { $exit = $true }
        default { Write-Host "  Неверный выбор." -ForegroundColor Red }
    }
    
    if (-not $exit) {
        Write-Host ""
        Write-Host "  Нажмите Enter, чтобы вернуться в меню..." -ForegroundColor Cyan
        Read-Host | Out-Null
        Write-Banner
    }
}

Write-Host "  Выход..." -ForegroundColor Cyan
