<#
.SYNOPSIS
    EngineCheck v4.0 - Focused ScreenShare Checker
    Run via: irm <raw-url> | iex
#>

$Config = @{
    TelegramBotToken = "ТВОЙ_ТОКЕН_БОТА"
    TelegramChatId   = "ТВОЙ_CHAT_ID"
}

# ============================================================
# WHITELIST (пропускаем эти пути и файлы полностью)
# ============================================================
$Script:WhitelistPaths = @(
    '\\libraries\\', '\\assets\\', '\\natives\\', '\\cache\\', '\\logs\\',
    '\\org\\eclipse\\', '\\org\\bouncycastle\\', '\\org\\apache\\', '\\com\\google\\',
    '\\io\\netty\\', '\\com\\mojang\\', '\\io\\papermc\\', '\\org\\spigotmc\\'
)

$Script:WhitelistNames = @(
    # Anticheats (содержат cheat-строки как часть своей БД детектов)
    'grim', 'shard', 'vulcan', 'matrix', 'spartan', 'aac', 'ncp', 'negativity',
    'polar', 'intave', 'themis', 'karhu', 'verus', 'eris', 'medusa', 'sentinel',
    'buzz', 'reflex', 'abc', 'anticheat', 'nightfall',
    # Легитимные библиотеки
    'antlr', 'icu4j', 'guava', 'netty', 'log4j', 'gson', 'snakeyaml',
    'bcprov', 'bcpkix', 'bouncycastle', 'maven', 'paper-api', 'spigot-api',
    'bukkit', 'sat4j', 'fabric-loader', 'quilt-loader', 'forge-', 'neoforge',
    'slf4j', 'listenablefuture', 'sisu',
    # Легитимные моды
    'sodium', 'iris', 'optifine', 'rubidium', 'embeddium', 'modmenu',
    'fabric-api', 'cloth-config', 'yacl', 'lithium', 'phosphor',
    'ferritecore', 'krypton', 'starlight', 'indium', 'continuity', 'lazydfu'
)

# ============================================================
# SIGNATURES — только специфичные читерские функции
# ============================================================
# Вес 10 = мгновенный флаг (только для этой строки достаточно)
$Script:DefinitiveFuncs = @(
    'killaura','kill_aura','aimbot','aim_bot','hitbox_expand','hitboxexpand',
    'autototem','auto_totem','autocrystal','auto_crystal','scaffold_walk',
    'antiknockback','anti_knockback','velocity_mod','velocitymod'
)
# Вес 3 = нужно набрать ещё пару
$Script:SignatureFuncs = @(
    'aimassist','aim_assist','fastplace','fast_place','fastbreak','fast_break',
    'pingspoof','ping_spoof','tracers','nuker','xray','x_ray'
)
# Вес 5 = структура vape-like клиента
$Script:PackageIndicators = @(
    'functions/combat/','functions/movement/','functions/render/','functions/player/',
    'module/combat/','module/movement/','module/render/','modules/combat/',
    'hack/combat/','cheat/combat/'
)
$Script:ScoreThreshold = 5

# ============================================================
# UI
# ============================================================
$Script:Report = New-Object System.Collections.Generic.List[string]
$Script:Threats = 0
$Script:StartTime = $null

function Write-Log {
    param([string]$Msg, [string]$Lvl = "INFO")
    $Script:Report.Add("[$((Get-Date).ToString('HH:mm:ss'))] $Msg")
    switch ($Lvl) {
        "FOUND" { Write-Host "  [!] $Msg" -ForegroundColor Red; $Script:Threats++ }
        "WARN"  { Write-Host "  [?] $Msg" -ForegroundColor Yellow }
        "OK"    { Write-Host "  [+] $Msg" -ForegroundColor Green }
        "INFO"  { Write-Host "  [*] $Msg" -ForegroundColor Gray }
    }
}

function Show-Banner {
    Clear-Host
    Write-Host @"
  ╔═══════════════════════════════════════════════════════════════╗
  ║                                                               ║
  ║          ENGINE CHECK v4.0 — Focused Detection                ║
  ║          Low FP | Deep JAR | Everything | UTF-16 Strings      ║
  ║                                                               ║
  ╚═══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan
}

function Show-Menu {
    Write-Host ""
    Write-Host "  ┌─────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "  │  [1] Быстрый скан (службы + процессы + mods/*.jar)  │" -ForegroundColor White
    Write-Host "  │  [2] JAR анализ (только папка mods/)                │" -ForegroundColor White
    Write-Host "  │  [3] JAR анализ (полный, с versions/)               │" -ForegroundColor White
    Write-Host "  │  [4] Службы                                         │" -ForegroundColor White
    Write-Host "  │  [5] Процессы                                       │" -ForegroundColor White
    Write-Host "  │  [6] Everything (поиск файлов по имени)             │" -ForegroundColor White
    Write-Host "  │  [7] Strings (explorer.exe / javaw.exe)             │" -ForegroundColor White
    Write-Host "  │  [8] Отправить отчёт в Telegram                     │" -ForegroundColor White
    Write-Host "  │  [0] Выход                                          │" -ForegroundColor White
    Write-Host "  └─────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    Write-Host ""
}

function Test-Whitelisted {
    param([string]$FullPath, [string]$Name)
    foreach ($wp in $Script:WhitelistPaths) {
        if ($FullPath -match $wp) { return $true }
    }
    foreach ($wn in $Script:WhitelistNames) {
        if ($Name -match $wn) { return $true }
    }
    return $false
}

# ============================================================
# SERVICES
# ============================================================
function Test-Services {
    Write-Log "=== СЛУЖБЫ ===" "INFO"
    foreach ($svc in @("Sysmain","Diagtrack","PcaSvc","DPS","Eventlog","AppInfo")) {
        try {
            $s = Get-Service -Name $svc -ErrorAction Stop
            if ($s.Status -eq 'Running') { Write-Log "$svc : RUNNING" "OK" }
            else { Write-Log "$svc : $($s.Status) (ПОДОЗРИТЕЛЬНО)" "FOUND" }
        } catch { Write-Log "$svc : НЕ НАЙДЕНА" "FOUND" }
    }
}

# ============================================================
# PROCESSES
# ============================================================
function Test-Processes {
    Write-Log "=== ПРОЦЕССЫ ===" "INFO"
    $cheats = 'impact|wurst|sigma|meteor|aristois|future|konas|zeusclient|vape|doomsday|nightware|liquidbounce|novoline|remix|astolfo|moonlight'
    $found = Get-Process | Where-Object { $_.ProcessName -match $cheats }
    if ($found) {
        foreach ($p in $found) { Write-Log "ПРОЦЕСС: $($p.ProcessName) (PID $($p.Id))" "FOUND" }
    } else { Write-Log "Подозрительных процессов нет." "OK" }
}

# ============================================================
# DEEP JAR SCAN (Constant Pool + Scoring)
# ============================================================
function Get-CpStrings {
    param([byte[]]$b)
    $out = New-Object System.Collections.Generic.List[string]
    try {
        if ($b.Length -lt 10) { return $out }
        $off = 8
        $cnt = ([int]$b[$off] -shl 8) -bor $b[$off+1]; $off += 2
        $i = 1
        while ($i -lt $cnt -and $off -lt $b.Length) {
            $tag = $b[$off]; $off++
            switch ($tag) {
                1 {
                    if ($off+2 -gt $b.Length) { break }
                    $len = ([int]$b[$off] -shl 8) -bor $b[$off+1]; $off += 2
                    if ($off+$len -le $b.Length) {
                        $out.Add([System.Text.Encoding]::UTF8.GetString($b, $off, $len))
                    }
                    $off += $len
                }
                3 { $off += 4 }; 4 { $off += 4 }
                5 { $off += 8; $i++ }; 6 { $off += 8; $i++ }
                7 { $off += 2 }; 8 { $off += 2 }
                9 { $off += 4 }; 10 { $off += 4 }; 11 { $off += 4 }; 12 { $off += 4 }
                15 { $off += 3 }; 16 { $off += 2 }; 18 { $off += 4 }
                default { break }
            }
            $i++
        }
    } catch { }
    return $out
}

function Start-JarScan {
    param([switch]$IncludeVersions)
    
    $paths = @("$env:APPDATA\.minecraft\mods")
    if ($IncludeVersions) {
        $paths += "$env:APPDATA\.minecraft\versions"
        $paths += "$env:APPDATA\.minecraft\custom_mods"
        $paths += "$env:USERPROFILE\Downloads"
    }
    $paths = $paths | Where-Object { Test-Path $_ }
    
    $jars = @()
    foreach ($p in $paths) {
        $jars += Get-ChildItem -Path $p -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue |
                 Where-Object { $_.Length -lt (100MB) }
    }
    Write-Log "Найдено JAR: $($jars.Count) (после whitelist будет меньше)" "INFO"
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $flagged = 0
    $scanned = 0
    
    foreach ($jar in $jars) {
        if (Test-Whitelisted -FullPath $jar.FullName -Name $jar.Name.ToLower()) { continue }
        $scanned++
        Write-Host "`r  Сканирую $scanned / $($jars.Count): $($jar.Name.PadRight(50).Substring(0,50))" -NoNewline -ForegroundColor Gray
        
        $score = 0
        $reasons = @()
        
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
            $seenPatterns = @{}
            
            foreach ($entry in $zip.Entries) {
                if ($entry.FullName -notmatch "\.class$") { continue }
                $entryLower = $entry.FullName.ToLower()
                
                # Package indicators (смотрим путь класса)
                foreach ($pkg in $Script:PackageIndicators) {
                    if ($entryLower -match [regex]::Escape($pkg) -and -not $seenPatterns.ContainsKey($pkg)) {
                        $seenPatterns[$pkg] = $true
                        $score += 5
                        $reasons += "Структура клиента: $pkg"
                    }
                }
                
                # Читаем constant pool
                try {
                    $s = $entry.Open(); $ms = New-Object System.IO.MemoryStream
                    $s.CopyTo($ms); $bytes = $ms.ToArray(); $s.Close(); $ms.Close()
                    $cp = Get-CpStrings -b $bytes
                    
                    foreach ($str in $cp) {
                        $strLower = $str.ToLower()
                        foreach ($d in $Script:DefinitiveFuncs) {
                            if ($strLower -match $d -and -not $seenPatterns.ContainsKey($d)) {
                                $seenPatterns[$d] = $true
                                $score += 10
                                $reasons += "Функция '$d' в $($entry.FullName)"
                            }
                        }
                        foreach ($s2 in $Script:SignatureFuncs) {
                            if ($strLower -match $s2 -and -not $seenPatterns.ContainsKey($s2)) {
                                $seenPatterns[$s2] = $true
                                $score += 3
                                $reasons += "Сигнатура '$s2' в $($entry.FullName)"
                            }
                        }
                    }
                } catch { }
            }
            $zip.Dispose()
            
            if ($score -ge $Script:ScoreThreshold) {
                $flagged++
                Write-Host ""
                Write-Log "ЧИТ: $($jar.FullName) [score=$score]" "FOUND"
                foreach ($r in $reasons | Select-Object -First 6) {
                    Write-Host "      → $r" -ForegroundColor DarkRed
                    $Script:Report.Add("      → $r")
                }
            }
        } catch {
            Write-Log "Ошибка чтения $($jar.Name): $_" "WARN"
        }
    }
    Write-Host ""
    Write-Log "Просканировано $scanned JAR, найдено читов: $flagged" "INFO"
}

# ============================================================
# EVERYTHING (полная установка + запуск + запрос)
# ============================================================
function Ensure-Everything {
    # 1. Уже запущен?
    if (Get-Process Everything -ErrorAction SilentlyContinue) { return $true }
    
    # 2. Уже установлен в системе?
    $known = @(
        "C:\Program Files\Everything\Everything.exe",
        "C:\Program Files (x86)\Everything\Everything.exe",
        "$env:LOCALAPPDATA\Everything\Everything.exe"
    )
    foreach ($p in $known) {
        if (Test-Path $p) {
            Start-Process $p -ArgumentList "-minimized" -WindowStyle Hidden
            Start-Sleep -Seconds 5
            return $true
        }
    }
    
    # 3. Скачиваем portable Everything (включает es.exe)
    Write-Log "Everything не найден, скачиваю portable..." "INFO"
    $dir = "$env:LOCALAPPDATA\Everything"
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $zip = "$env:TEMP\EverythingPortable.zip"
    
    try {
        Invoke-WebRequest -Uri "https://www.voidtools.com/Everything-1.4.1.1026.x64.zip" -OutFile $zip -UseBasicParsing
        Expand-Archive -Path $zip -DestinationPath $dir -Force
        Remove-Item $zip -Force
        
        $exe = Join-Path $dir "Everything.exe"
        if (Test-Path $exe) {
            Start-Process $exe -ArgumentList "-minimized" -WindowStyle Hidden
            Write-Log "Everything запущен, ждём индексации (15 сек)..." "INFO"
            Start-Sleep -Seconds 15
            return $true
        }
    } catch {
        Write-Log "Ошибка скачивания Everything: $_" "WARN"
    }
    return $false
}

function Start-EverythingScan {
    Write-Log "=== EVERYTHING ===" "INFO"
    if (-not (Ensure-Everything)) { Write-Log "Everything недоступен." "WARN"; return }
    
    # es.exe из local appdata или из PATH
    $es = "$env:LOCALAPPDATA\Everything\es.exe"
    if (-not (Test-Path $es)) { $es = (Get-Command es.exe -ErrorAction SilentlyContinue).Source }
    if (-not $es) { Write-Log "es.exe не найден." "WARN"; return }
    
    $pattern = 'impact|wurst|sigma|meteor|aristois|future|konas|zeusclient|vape|doomsday|nightware|liquidbounce|novoline|astolfo|moonlight|nurik|celestial|expensive'
    
    # Правильный синтаксис Everything CLI: сначала regex, потом фильтр по расширению
    Write-Log "Запрос: регекс по имени, фильтр по расширениям" "INFO"
    $result = & $es -r $pattern 2>$null | Where-Object { $_ -match '\.(exe|jar|zip|rar|dll)$' }
    
    if ($result) {
        foreach ($line in $result) { Write-Log "НАЙДЕНО: $line" "FOUND" }
    } else {
        Write-Log "Совпадений нет (или индекс Everything ещё не готов)." "OK"
    }
}

# ============================================================
# STRINGS (ASCII + UTF-16LE)
# ============================================================
function Get-BinaryStrings {
    param([string]$Path, [int]$MinLen = 4)
    $ascii = New-Object System.Collections.Generic.List[string]
    $unicode = New-Object System.Collections.Generic.List[string]
    try {
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        
        # ASCII
        $sb = New-Object System.Text.StringBuilder
        foreach ($b in $bytes) {
            if ($b -ge 32 -and $b -le 126) { [void]$sb.Append([char]$b) }
            else { if ($sb.Length -ge $MinLen) { $ascii.Add($sb.ToString()) }; [void]$sb.Clear() }
        }
        if ($sb.Length -ge $MinLen) { $ascii.Add($sb.ToString()) }
        
        # UTF-16LE (каждый второй байт = 0x00, типично для Windows)
        $sb2 = New-Object System.Text.StringBuilder
        for ($i = 0; $i -lt $bytes.Length - 1; $i += 2) {
            $c = [int]$bytes[$i] + ([int]$bytes[$i+1] -shl 8)
            if ($c -ge 32 -and $c -le 126) { [void]$sb2.Append([char]$c) }
            else { if ($sb2.Length -ge $MinLen) { $unicode.Add($sb2.ToString()) }; [void]$sb2.Clear() }
        }
        if ($sb2.Length -ge $MinLen) { $unicode.Add($sb2.ToString()) }
    } catch { }
    return @{ ASCII = $ascii; Unicode = $unicode }
}

function Test-Strings {
    Write-Log "=== STRINGS SCAN ===" "INFO"
    
    $targets = @(
        @{ Path = "$env:WINDIR\explorer.exe"; Patterns = @("deltadlc","nursultam","celestial") },
        @{ Path = "$env:WINDIR\System32\javaw.exe"; Patterns = @("l.png") }
    )
    
    foreach ($t in $targets) {
        if (-not (Test-Path $t.Path)) { Write-Log "$($t.Path) не найден." "WARN"; continue }
        
        $size = (Get-Item $t.Path).Length / 1MB
        if ($size -gt 100) { Write-Log "$($t.Path) слишком большой ($([math]::Round($size))MB), пропуск." "WARN"; continue }
        
        Write-Log "Читаю $([System.IO.Path]::GetFileName($t.Path)) ($([math]::Round($size,1))MB)..." "INFO"
        $strings = Get-BinaryStrings -Path $t.Path
        
        $found = $false
        foreach ($pattern in $t.Patterns) {
            $hitA = $strings.ASCII | Where-Object { $_ -match [regex]::Escape($pattern) } | Select-Object -First 2
            $hitU = $strings.Unicode | Where-Object { $_ -match [regex]::Escape($pattern) } | Select-Object -First 2
            
            if ($hitA) { foreach ($h in $hitA) { Write-Log "ASCII: '$h' в $([System.IO.Path]::GetFileName($t.Path))" "FOUND"; $found = $true } }
            if ($hitU) { foreach ($h in $hitU) { Write-Log "UTF-16: '$h' в $([System.IO.Path]::GetFileName($t.Path))" "FOUND"; $found = $true } }
        }
        if (-not $found) {
            Write-Log "Не найдено: $($t.Patterns -join ', ') в $([System.IO.Path]::GetFileName($t.Path))" "OK"
        }
    }
}

# ============================================================
# TELEGRAM
# ============================================================
function Send-Report {
    if ($Config.TelegramBotToken -eq "ТВОЙ_ТОКЕН_БОТА") { Write-Log "TG не настроен." "WARN"; return }
    $tmp = "$env:TEMP\ec_$(Get-Date -Format yyyyMMdd_HHmmss).txt"
    $Script:Report -join "`r`n" | Out-File $tmp -Encoding UTF8
    try {
        $uri = "https://api.telegram.org/bot$($Config.TelegramBotToken)/sendDocument"
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            Invoke-RestMethod -Uri $uri -Method Post -Form @{ chat_id = $Config.TelegramChatId; document = Get-Item $tmp } | Out-Null
        } else {
            $b = [System.Guid]::NewGuid().ToString()
            $bytes = [System.IO.File]::ReadAllBytes($tmp)
            $enc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($bytes)
            $LF = "`r`n"
            $body = ("--$b","Content-Disposition: form-data; name=`"chat_id`"$LF",$Config.TelegramChatId,"--$b","Content-Disposition: form-data; name=`"document`"; filename=`"r.txt`"","Content-Type: application/octet-stream$LF",$enc,"--$b--$LF") -join $LF
            Invoke-RestMethod -Uri $uri -Method Post -ContentType "multipart/form-data; boundary=$b" -Body $body | Out-Null
        }
        Write-Log "Отчёт отправлен." "OK"
    } catch { Write-Log "TG ошибка: $_" "WARN" }
    finally { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
}

# ============================================================
# MAIN LOOP
# ============================================================
Show-Banner
$Script:Report.Add("=== ENGINE CHECK v4.0 ===")
$Script:Report.Add("Дата: $(Get-Date)")
$Script:Report.Add("ПК: $env:COMPUTERNAME")
$Script:Report.Add("")

$exit = $false
while (-not $exit) {
    Show-Menu
    $c = Read-Host "  Выбор"
    $Script:StartTime = Get-Date
    switch ($c) {
        "1" { Test-Services; Test-Processes; Start-JarScan }
        "2" { Start-JarScan }
        "3" { Start-JarScan -IncludeVersions }
        "4" { Test-Services }
        "5" { Test-Processes }
        "6" { Start-EverythingScan }
        "7" { Test-Strings }
        "8" { Send-Report }
        "0" { $exit = $true; continue }
        default { Write-Host "  Неверно." -ForegroundColor Red; continue }
    }
    $elapsed = (Get-Date) - $Script:StartTime
    Write-Host ""
    Write-Host "  Готово за $($elapsed.ToString('mm\:ss')). Флагов: $($Script:Threats)" -ForegroundColor Cyan
    Write-Host "  Enter для возврата в меню..."
    Read-Host | Out-Null
    Show-Banner
}
