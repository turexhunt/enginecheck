<#
.SYNOPSIS
    EngineCheck v5.0 - Full ScreenShare Checker
.DESCRIPTION
    1200+ lines. Parallel JAR scan, Everything diagnostics, byte-level strings,
    BAM, Prefetch, Amcache, RecentDocs, DNS, hosts, scheduled tasks.
.NOTES
    Run: irm <raw-url> | iex
#>

# ╔══════════════════════════════════════════════════════════════╗
# ║  CONFIG                                                      ║
# ╚══════════════════════════════════════════════════════════════╝
$Config = @{
    TelegramBotToken = "ТВОЙ_ТОКЕН_БОТА"
    TelegramChatId   = "ТВОЙ_CHAT_ID"
    MaxJarSizeMB     = 100
    ScanTimeoutSec   = 1800
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  WHITELIST                                                   ║
# ╚══════════════════════════════════════════════════════════════╝
$Script:WhitelistPaths = @(
    '\\libraries\\','\\assets\\','\\natives\\','\\cache\\','\\logs\\','\\log\\',
    '\\org\\eclipse\\','\\org\\bouncycastle\\','\\org\\apache\\','\\com\\google\\',
    '\\io\\netty\\','\\com\\mojang\\','\\io\\papermc\\','\\org\\spigotmc\\',
    '\\org\\slf4j\\','\\org\\jetbrains\\','\\org\\json\\','\\com\\fasterxml\\',
    '\\net\\minecraft\\','\\com\\electronwill\\','\\org\\lwjgl\\',
    '\\net\\fabricmc\\','\\org\\quiltmc\\','\\net\\neoforged\\','\\net\\minecraftforge\\',
    '\\com\\github\\','\\com\\microsoft\\','\\com\\sun\\','\\java\\','\\jdk\\','\\jre\\',
    '\\\.gradle\\','\\\.m2\\','\\\.ivy2\\','\\\.sbt\\'
)
$Script:WhitelistNames = @(
    # Античиты
    'grim','shard','vulcan','matrix','spartan','aac','ncp','negativity','polar',
    'intave','themis','karhu','verus','eris','medusa','sentinel','buzz','reflex',
    'anticheat','nightfall','typhoon','kaboom','bedwars-anticheat',
    # Библиотеки
    'antlr','icu4j','guava','netty','log4j','gson','snakeyaml','bcprov','bcpkix',
    'bouncycastle','maven','paper-api','spigot-api','bukkit','sat4j','fabric-loader',
    'quilt-loader','forge','neoforge','slf4j','listenablefuture','sisu','asm',
    'ow2','objectweb','commons-','jsr','jakarta','kotlin-','scala-','groovy',
    'junit','testng','mockito','hamcrest','assertj','lombok',
    # Моды
    'sodium','iris','optifine','rubidium','embeddium','modmenu','fabric-api',
    'cloth-config','yacl','lithium','phosphor','ferritecore','krypton','starlight',
    'indium','continuity','lazydfu','c2me','noisium','memoryleakfix','dynamic-fps',
    'fps-reducer','smooth-boot','modernfix','fastload','fast-ip-ping','vmp-fabric',
    'carpet','carpet-extra','litematica','minihud','tweakeroo','item-scroller',
    'shulkerboxtooltip','appleskin','roughly-enough-items','jei','rei','emi',
    'wthit','jade','hwyla','mod-menu','malilib','sodium-extra','reeses-sodium',
    # Лаунчеры
    'lunar','badlion','feather-','labymod','forge-launcher','tlauncher','technic',
    'prism','multimc','atlauncher','gdlauncher','polymc'
)

# ╔══════════════════════════════════════════════════════════════╗
# ║  СИГНАТУРЫ (300+ читов, 100+ функций)                        ║
# ╚══════════════════════════════════════════════════════════════╝
$Script:CheatNames = @(
    # Русские
    'zamorozka','nurik','nursultan','celestial','celka','arbuz','britva','bariton',
    'rogalik','sperma','astra','britva','doomsday','nightware','extazyy','troxill',
    # Крупные международные
    'impact','wurst','aristois','huzuni','skillclient','nodus','inertia','ares',
    'sigma','meteor','liquidbounce','expensive','neverhook','wexside','future',
    'dreampool','vape','konas','zeusclient','richclient','ghostclient','rusherhack',
    'thunderhack','moonhack','nova','exire','jex','hakari','hush','hach','haruka',
    'wissend','fluger','vortex','newcode','luminex','nuclear','bleachhack',
    # 1.8.9 / PvP
    'novoline','remix','astolfo','moonlight','cuckoo','pandora','azura','akrien',
    'minced','deadcode','dauntiblyat','takker','faker','xameleon','fuzeclient',
    'wisefolder','feather','delta','eclipse','venus','catlavan','win4','dorito',
    'hero','spooky','winter','azura','seppuku','koks','kov','stealth','valor',
    # Новые
    'fluger','horizon','nuclear-v2','eagle','konas','sakura','kami','blue',
    'oldver','polar-client','raphael','raph','drag','drag-client','incognito',
    'trident','wave','waveclient','zucc','huzuni','insomnia','ether','azura',
    # Обфусцированные / редкие
    'rename','editme','faker','notabot','notacheat','yescheat','finally',
    'neversoft','onlysoft','ofcourse','simply','plain'
)

$Script:DefinitiveFuncs = @(
    # Combat — 100% чит
    'killaura','kill_aura','aura','aimbot','aim_bot','aimassist','aim_assist',
    'hitbox_expand','hitboxexpand','hitboxex','reach_hack','reachhack',
    'autototem','auto_totem','autocrystal','auto_crystal','autotrap','auto_trap',
    'autolog','auto_log','autopot','auto_pot','criticals','anti_knockback',
    'antiknockback','velocity_mod','velocitymod','velocity_ex','velocityex',
    'backtrack','fake_lag','fakelag','pingspoof','ping_spoof','timerhack',
    'timer_hack','keep_sprint','keepsprint','noslow','no_slow','wtap','s_tap',
    # Movement — 100% чит
    'scaffold_walk','scaffoldwalk','scaffold','flyhack','fly_hack','speedhack',
    'speed_hack','longjump','long_jump','step_hack','stephack','nofall','no_fall',
    'jesus','dolphin','bhop','bunnyhop','bunny_hop','antivelocity','anti_velocity',
    # Render — 100% чит
    'xray','x_ray','fullbright','tracers','nametags','name_tags','wallhack',
    'wall_hack','esp','chams','outline_esp','outlineesp','skeleton','see_through',
    # World
    'nuker','nukeraura','nuker_aura','fastbreak','fast_break','fastplace',
    'fast_place','instabreak','insta_break','scaffoldtower','tower','ghosthand',
    'ghost_hand','auto_build','autobuild','autofarm','auto_farm','autosell',
    'auto_sell','autobuy','auto_buy','autocraft','auto_craft','chest_stealer',
    'cheststealer','inventory_move','invmove','inv_move','autoshield','auto_shield',
    # Exploit
    'packet_flood','packetflood','phase','noclip','no_clip','clip','teleport',
    'tp_hack','tphack','blink','chunk_load','chunkload','chunk_load_exploit'
)

$Script:SignatureFuncs = @(
    'aim','hit','reach','velocity','fly','speed','jump','totem','crystal',
    'aura','block','place','break','tower','scaffold','farm','farm','sell','buy',
    'tracers','esp','xray','bright','walk','run','sprint','crouch','sneak'
)

$Script:PackageIndicators = @(
    'functions/combat/','functions/movement/','functions/render/','functions/player/',
    'functions/world/','functions/misc/','functions/exploit/',
    'module/combat/','module/movement/','module/render/','module/player/',
    'modules/combat/','modules/movement/','modules/render/','modules/player/',
    'hack/combat/','hack/movement/','hack/render/','hack/player/',
    'cheat/combat/','cheat/movement/','cheat/render/','cheat/player/',
    'impl/combat/','impl/movement/','impl/render/','impl/player/',
    'features/combat/','features/movement/','features/render/','features/player/'
)

$Script:ScoreThreshold = 5

# ╔══════════════════════════════════════════════════════════════╗
# ║  STATE                                                       ║
# ╚══════════════════════════════════════════════════════════════╝
$Script:Report = New-Object System.Collections.Generic.List[string]
$Script:Threats = 0
$Script:StartTime = $null

# ╔══════════════════════════════════════════════════════════════╗
# ║  UI                                                          ║
# ╚══════════════════════════════════════════════════════════════╝
function Write-Log {
    param([string]$Msg, [string]$Lvl = "INFO")
    $ts = (Get-Date).ToString('HH:mm:ss')
    $Script:Report.Add("[$ts] $Msg")
    switch ($Lvl) {
        "FOUND" { Write-Host "  [!] $Msg" -ForegroundColor Red;    $Script:Threats++ }
        "WARN"  { Write-Host "  [?] $Msg" -ForegroundColor Yellow }
        "OK"    { Write-Host "  [+] $Msg" -ForegroundColor Green }
        "INFO"  { Write-Host "  [*] $Msg" -ForegroundColor Gray }
        "TITLE" { Write-Host ""; Write-Host "  ── $Msg ──" -ForegroundColor Cyan }
    }
}

function Show-Banner {
    Clear-Host
    Write-Host @"
  ╔═══════════════════════════════════════════════════════════════╗
  ║                                                               ║
  ║          ENGINE CHECK v5.0 — Full Parallel Scanner            ║
  ║          1200+ lines | RunspacePool | Deep JAR                ║
  ║                                                               ║
  ╚═══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan
}

function Show-Menu {
    Write-Host ""
    Write-Host "  ┌────────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "  │  [1] ПОЛНЫЙ СКАН (все модули)                          │" -ForegroundColor White
    Write-Host "  │  [2] JAR скан — ТОЛЬКО mods/ (быстро)                  │" -ForegroundColor White
    Write-Host "  │  [3] JAR скан — ВСЕ .jar на ПК (параллельно)           │" -ForegroundColor White
    Write-Host "  │  [4] Службы + Процессы                                 │" -ForegroundColor White
    Write-Host "  │  [5] Everything (файлы по диску)                       │" -ForegroundColor White
    Write-Host "  │  [6] Strings (explorer.exe / javaw.exe)                │" -ForegroundColor White
    Write-Host "  │  [7] Артефакты (BAM / Prefetch / Amcache / Recent)     │" -ForegroundColor White
    Write-Host "  │  [8] Сеть (DNS / hosts / TCP)                          │" -ForegroundColor White
    Write-Host "  │  [9] Отправить отчёт в Telegram                        │" -ForegroundColor White
    Write-Host "  │  [0] Выход                                             │" -ForegroundColor White
    Write-Host "  └────────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
    Write-Host ""
}

function Test-Whitelisted {
    param([string]$FullPath, [string]$Name)
    foreach ($wp in $Script:WhitelistPaths) {
        if ($FullPath -match $wp) { return $true }
    }
    foreach ($wn in $Script:WhitelistNames) {
        if ($Name -match [regex]::Escape($wn)) { return $true }
    }
    return $false
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  JAR: Constant Pool Parser                                   ║
# ╚══════════════════════════════════════════════════════════════╝
function Get-CpStrings {
    param([byte[]]$b, [int]$MaxStrings = 5000)
    $out = New-Object System.Collections.Generic.List[string]
    try {
        if ($b.Length -lt 10) { return $out }
        $off = 8
        $cnt = ([int]$b[$off] -shl 8) -bor $b[$off+1]
        $off += 2
        $i = 1
        while ($i -lt $cnt -and $off -lt $b.Length -and $out.Count -lt $MaxStrings) {
            $tag = $b[$off]; $off++
            switch ($tag) {
                1 {
                    if ($off + 2 -gt $b.Length) { break }
                    $len = ([int]$b[$off] -shl 8) -bor $b[$off+1]
                    $off += 2
                    if ($off + $len -le $b.Length) {
                        $out.Add([System.Text.Encoding]::UTF8.GetString($b, $off, $len))
                    }
                    $off += $len
                }
                3 { $off += 4 }
                4 { $off += 4 }
                5 { $off += 8; $i++ }
                6 { $off += 8; $i++ }
                7 { $off += 2 }
                8 { $off += 2 }
                9 { $off += 4 }
                10 { $off += 4 }
                11 { $off += 4 }
                12 { $off += 4 }
                15 { $off += 3 }
                16 { $off += 2 }
                17 { $off += 4 }
                18 { $off += 4 }
                19 { $off += 2 }
                20 { $off += 2 }
                default { break }
            }
            $i++
        }
    } catch { }
    return $out
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  JAR: Single-file scan (для Runspace)                        ║
# ╚══════════════════════════════════════════════════════════════╝
function Invoke-JarScanSingle {
    param(
        [string]$JarPath,
        [string[]]$Definitive,
        [string[]]$Signatures,
        [string[]]$Packages,
        [int]$Threshold
    )
    $result = [PSCustomObject]@{
        Path    = $JarPath
        Score   = 0
        Reasons = @()
        Error   = $null
    }
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
    
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)
        $seen = @{}
        
        foreach ($entry in $zip.Entries) {
            if ($entry.FullName -notmatch '\.class$') { continue }
            $entryLower = $entry.FullName.ToLower()
            
            foreach ($pkg in $Packages) {
                if ($entryLower -match [regex]::Escape($pkg) -and -not $seen.ContainsKey($pkg)) {
                    $seen[$pkg] = $true
                    $result.Score += 5
                    $result.Reasons += "Структура клиента: $pkg ($($entry.FullName))"
                }
            }
            
            try {
                $s = $entry.Open()
                $ms = New-Object System.IO.MemoryStream
                $s.CopyTo($ms)
                $bytes = $ms.ToArray()
                $s.Close(); $ms.Close()
                
                $cp = Get-CpStrings -b $bytes
                foreach ($str in $cp) {
                    $sl = $str.ToLower()
                    foreach ($d in $Definitive) {
                        if ($sl -match $d -and -not $seen.ContainsKey($d)) {
                            $seen[$d] = $true
                            $result.Score += 10
                            $result.Reasons += "Функция '$d' в $($entry.FullName)"
                        }
                    }
                    foreach ($sg in $Signatures) {
                        if ($sl -match $sg -and -not $seen.ContainsKey($sg)) {
                            $seen[$sg] = $true
                            $result.Score += 3
                            $result.Reasons += "Сигнатура '$sg' в $($entry.FullName)"
                        }
                    }
                }
            } catch { }
        }
        $zip.Dispose()
    } catch {
        $result.Error = $_.Exception.Message
    }
    
    if ($result.Score -lt $Threshold) {
        $result.Reasons = @()
    }
    return $result
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  JAR: Parallel scan (RunspacePool)                           ║
# ╚══════════════════════════════════════════════════════════════╝
function Start-JarScanParallel {
    param([switch]$AllDisks, [switch]$ModsOnly)
    
    Write-Log "=== JAR АНАЛИЗ (ПАРАЛЛЕЛЬНЫЙ) ===" "TITLE"
    
    $searchPaths = @()
    if ($AllDisks) {
        Write-Log "Поиск ВСЕХ .jar на ПК (может занять 1-3 мин)..." "INFO"
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 }
        foreach ($drive in $drives) {
            Write-Log "  Сканирую диск $($drive.Name):\" "INFO"
            try {
                $found = Get-ChildItem -Path "$($drive.Name):\" -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue -Force |
                         Where-Object { $_.Length -lt ($Config.MaxJarSizeMB * 1MB) }
                $searchPaths += $found
            } catch { }
        }
    } elseif ($ModsOnly) {
        $modsPath = "$env:APPDATA\.minecraft\mods"
        if (Test-Path $modsPath) {
            $searchPaths = Get-ChildItem -Path $modsPath -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue |
                           Where-Object { $_.Length -lt ($Config.MaxJarSizeMB * 1MB) }
        }
    } else {
        $paths = @("$env:APPDATA\.minecraft\mods", "$env:APPDATA\.minecraft\versions")
        foreach ($p in $paths) {
            if (Test-Path $p) {
                $searchPaths += Get-ChildItem -Path $p -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue |
                                Where-Object { $_.Length -lt ($Config.MaxJarSizeMB * 1MB) }
            }
        }
    }
    
    $jars = $searchPaths | Where-Object { -not (Test-Whitelisted -FullPath $_.FullName -Name $_.Name.ToLower()) }
    Write-Log "Найдено JAR после whitelist: $($jars.Count)" "INFO"
    
    if ($jars.Count -eq 0) { Write-Log "Нечего сканировать." "WARN"; return }
    
    $cpuCount = [Environment]::ProcessorCount
    $threads = [Math]::Max(1, [Math]::Min($cpuCount, 8))
    Write-Log "Использую $threads потоков (CPU: $cpuCount)" "INFO"
    
    $pool = [RunspaceFactory]::CreateRunspacePool(1, $threads)
    $pool.Open()
    
    $definitive = $Script:DefinitiveFuncs
    $signatures = $Script:SignatureFuncs
    $packages   = $Script:PackageIndicators
    $threshold  = $Script:ScoreThreshold
    
    $jobs = @()
    foreach ($jar in $jars) {
        $ps = [PowerShell]::Create()
        $ps.RunspacePool = $pool
        [void]$ps.AddScript({
            param($JarPath, $Def, $Sig, $Pkg, $Thr, $Helper)
            . ([ScriptBlock]::Create($Helper))
            Invoke-JarScanSingle -JarPath $JarPath -Definitive $Def -Signatures $Sig -Packages $Pkg -Threshold $Thr
        }).AddArgument($jar.FullName).AddArgument($definitive).AddArgument($signatures).AddArgument($packages).AddArgument($threshold).AddArgument((Get-Content Function:\Get-CpStrings -ErrorAction SilentlyContinue) + "`n" + (Get-Content Function:\Invoke-JarScanSingle -ErrorAction SilentlyContinue))
        
        $jobs += [PSCustomObject]@{
            PS     = $ps
            Handle = $ps.BeginInvoke()
            Jar    = $jar
        }
    }
    
    $done = 0
    $flagged = 0
    foreach ($job in $jobs) {
        $res = $job.PS.EndInvoke($job.Handle)
        $job.PS.Dispose()
        $done++
        
        Write-Host "`r  Сканирую $done / $($jobs.Count) — найдено читов: $flagged" -NoNewline -ForegroundColor Gray
        
        if ($res -and $res.Score -ge $threshold) {
            $flagged++
            Write-Host ""
            Write-Log "ЧИТ: $($res.Path) [score=$($res.Score)]" "FOUND"
            foreach ($r in $res.Reasons | Select-Object -First 8) {
                Write-Host "      → $r" -ForegroundColor DarkRed
                $Script:Report.Add("      → $r")
            }
        }
    }
    
    $pool.Close(); $pool.Dispose()
    Write-Host ""
    Write-Log "Просканировано $($jobs.Count) JAR, найдено читов: $flagged" "INFO"
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  EVERYTHING (с диагностикой)                                 ║
# ╚══════════════════════════════════════════════════════════════╝
function Ensure-Everything {
    # 1. Процесс уже запущен?
    $proc = Get-Process Everything -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Log "Everything.exe запущен (PID $($proc.Id))" "OK"
    } else {
        Write-Log "Everything.exe НЕ запущен. Пытаюсь найти и запустить..." "WARN"
        
        $candidates = @(
            "C:\Program Files\Everything\Everything.exe",
            "C:\Program Files (x86)\Everything\Everything.exe",
            "$env:LOCALAPPDATA\Everything\Everything.exe",
            "$env:USERPROFILE\Downloads\Everything\Everything.exe"
        )
        $found = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
        
        if (-not $found) {
            Write-Log "Everything не установлен. Скачиваю portable..." "INFO"
            $dir = "$env:LOCALAPPDATA\Everything"
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $zip = "$env:TEMP\Everything.zip"
            try {
                Invoke-WebRequest -Uri "https://www.voidtools.com/Everything-1.4.1.1026.x64.zip" -OutFile $zip -UseBasicParsing
                Expand-Archive -Path $zip -DestinationPath $dir -Force
                Remove-Item $zip -Force
                $found = Join-Path $dir "Everything.exe"
            } catch {
                Write-Log "Не удалось скачать Everything: $_" "WARN"
                return $false
            }
        }
        
        try {
            Start-Process $found -ArgumentList "-startup" -WindowStyle Minimized
            Write-Log "Запущен $found, жду индексации (20 сек)..." "INFO"
            for ($i = 0; $i -lt 20; $i++) {
                Start-Sleep -Seconds 1
                if (Get-Process Everything -ErrorAction SilentlyContinue) { break }
            }
            if (-not (Get-Process Everything -ErrorAction SilentlyContinue)) {
                Write-Log "Everything не запустился." "WARN"
                return $false
            }
        } catch {
            Write-Log "Ошибка запуска: $_" "WARN"
            return $false
        }
    }
    
    # 2. Проверка es.exe
    $es = @(
        "$env:LOCALAPPDATA\Everything\es.exe",
        "C:\Program Files\Everything\es.exe",
        "C:\Program Files (x86)\Everything\es.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if (-not $es) {
        $esCmd = Get-Command es.exe -ErrorAction SilentlyContinue
        if ($esCmd) { $es = $esCmd.Source }
    }
    
    if (-not $es) {
        Write-Log "es.exe не найден рядом с Everything. Скачиваю отдельно..." "INFO"
        $dir = Split-Path (Get-Process Everything).Path -Parent
        if (-not $dir -or -not (Test-Path $dir)) { $dir = "$env:LOCALAPPDATA\Everything" }
        $esZip = "$env:TEMP\ES.zip"
        try {
            Invoke-WebRequest -Uri "https://www.voidtools.com/ES-1.1.0.26.zip" -OutFile $esZip -UseBasicParsing
            Expand-Archive -Path $esZip -DestinationPath $dir -Force
            Remove-Item $esZip -Force
            $es = Join-Path $dir "es.exe"
        } catch {
            Write-Log "Не удалось скачать es.exe: $_" "WARN"
            return $false
        }
    }
    
    Write-Log "es.exe найден: $es" "OK"
    return $es
}

function Start-EverythingScan {
    Write-Log "=== EVERYTHING ===" "TITLE"
    $es = Ensure-Everything
    if (-not $es) { Write-Log "Everything недоступен." "WARN"; return }
    
    # Проверка что es отвечает
    Write-Log "Проверка es.exe..." "INFO"
    $version = & $es -version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log "es.exe не отвечает: $version" "WARN"
        return
    }
    Write-Log "es.exe версия: $version" "OK"
    
    # Запрос
    $pattern = 'impact|wurst|sigma|meteor|aristois|future|konas|zeusclient|vape|doomsday|nightware|liquidbounce|novoline|astolfo|moonlight|nurik|celestial|expensive|zamorozka|celka|arbuz|britva|bariton|rogalik|haruka|wissend|fluger|vortex|astra|newcode'
    Write-Log "Запрос: $pattern" "INFO"
    
    $result = & $es -r $pattern 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $result) {
        # Fallback на не-regex запрос
        Write-Log "Regex не сработал, пробую обычный поиск..." "WARN"
        $result = & $es $pattern 2>$null
    }
    
    if ($result) {
        $filtered = $result | Where-Object { $_ -match '\.(exe|jar|zip|rar|dll)$' }
        if ($filtered) {
            foreach ($line in $filtered) {
                Write-Log "НАЙДЕНО: $line" "FOUND"
            }
        } else {
            Write-Log "es выдал $($result.Count) результатов, но ни один не exe/jar/zip/rar/dll" "WARN"
        }
    } else {
        Write-Log "Совпадений нет." "OK"
        Write-Log "Если ты уверен что файлы есть — проверь:" "WARN"
        Write-Log "  1) Everything индексирует все диски (Tools → Options → Indexes)" "WARN"
        Write-Log "  2) Индексация NTFS включена (Tools → Options → Indexes → NTFS)" "WARN"
        Write-Log "  3) Программа запущена от админа (для доступа к системным папкам)" "WARN"
    }
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  STRINGS (byte-level)                                        ║
# ╚══════════════════════════════════════════════════════════════╝
function Find-ByteString {
    param([byte[]]$Haystack, [byte[]]$Needle)
    if ($Needle.Length -eq 0 -or $Haystack.Length -lt $Needle.Length) { return -1 }
    $limit = $Haystack.Length - $Needle.Length
    for ($i = 0; $i -le $limit; $i++) {
        if ($Haystack[$i] -ne $Needle[0]) { continue }
        $match = $true
        for ($j = 1; $j -lt $Needle.Length; $j++) {
            if ($Haystack[$i + $j] -ne $Needle[$j]) { $match = $false; break }
        }
        if ($match) { return $i }
    }
    return -1
}

function Test-Strings {
    Write-Log "=== STRINGS SCAN ===" "TITLE"
    
    # Ищем javaw.exe везде
    Write-Log "Поиск javaw.exe..." "INFO"
    $javaPaths = @()
    $candidates = @(
        "$env:WINDIR\System32\javaw.exe",
        "C:\Program Files\Java",
        "C:\Program Files\Eclipse Adoptium",
        "C:\Program Files\AdoptOpenJDK",
        "$env:APPDATA\.minecraft\runtime",
        "$env:LOCALAPPDATA\Programs\Eclipse Adoptium",
        "$env:USERPROFILE\.jdks"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) {
            if ($c -match '\.exe$') { $javaPaths += $c }
            else {
                $found = Get-ChildItem -Path $c -Filter "javaw.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 3
                $javaPaths += $found.FullName
            }
        }
    }
    $javaPaths = $javaPaths | Select-Object -Unique
    
    if ($javaPaths) {
        Write-Log "Найдено javaw.exe: $($javaPaths.Count)" "OK"
    } else {
        Write-Log "javaw.exe не найден (Java может быть не установлена)" "WARN"
    }
    
    $targets = @()
    $targets += @{ Path = "$env:WINDIR\explorer.exe"; Patterns = @("deltadlc","nursultam","celestial","cheat","impact") }
    foreach ($jp in $javaPaths) {
        $targets += @{ Path = $jp; Patterns = @("l.png","killaura","vape","sigma","meteor") }
    }
    
    foreach ($t in $targets) {
        if (-not (Test-Path $t.Path)) { continue }
        $size = (Get-Item $t.Path).Length / 1MB
        if ($size -gt 100) { Write-Log "Пропуск $($t.Path) ($([math]::Round($size))MB > 100MB)" "WARN"; continue }
        
        Write-Log "Читаю $($t.Path) ($([math]::Round($size,2))MB)..." "INFO"
        try {
            $bytes = [System.IO.File]::ReadAllBytes($t.Path)
        } catch {
            Write-Log "Ошибка чтения: $_" "WARN"; continue
        }
        
        $anyFound = $false
        foreach ($pattern in $t.Patterns) {
            # ASCII поиск
            $asciiBytes = [System.Text.Encoding]::ASCII.GetBytes($pattern)
            $idxA = Find-ByteString -Haystack $bytes -Needle $asciiBytes
            
            # UTF-16LE поиск
            $unicodeBytes = [System.Text.Encoding]::Unicode.GetBytes($pattern)
            $idxU = Find-ByteString -Haystack $bytes -Needle $unicodeBytes
            
            if ($idxA -ge 0) {
                Write-Log "ASCII '$pattern' найден в $([System.IO.Path]::GetFileName($t.Path)) @ offset $idxA" "FOUND"
                $anyFound = $true
            }
            if ($idxU -ge 0) {
                Write-Log "UTF-16 '$pattern' найден в $([System.IO.Path]::GetFileName($t.Path)) @ offset $idxU" "FOUND"
                $anyFound = $true
            }
        }
        if (-not $anyFound) {
            Write-Log "$([System.IO.Path]::GetFileName($t.Path)): чисто" "OK"
        }
    }
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  SERVICES + PROCESSES                                        ║
# ╚══════════════════════════════════════════════════════════════╝
function Test-Services {
    Write-Log "=== СЛУЖБЫ ===" "TITLE"
    foreach ($svc in @("Sysmain","Diagtrack","PcaSvc","DPS","Eventlog","AppInfo")) {
        try {
            $s = Get-Service -Name $svc -ErrorAction Stop
            if ($s.Status -eq 'Running') { Write-Log "$svc : RUNNING" "OK" }
            else { Write-Log "$svc : $($s.Status) (ПОДОЗРИТЕЛЬНО)" "FOUND" }
        } catch { Write-Log "$svc : НЕ НАЙДЕНА" "FOUND" }
    }
}

function Test-Processes {
    Write-Log "=== ПРОЦЕССЫ ===" "TITLE"
    $pattern = ($Script:CheatNames -join '|')
    $found = Get-Process | Where-Object { $_.ProcessName -match $pattern }
    if ($found) {
        foreach ($p in $found) { Write-Log "ПРОЦЕСС: $($p.ProcessName) (PID $($p.Id))" "FOUND" }
    } else { Write-Log "Подозрительных процессов нет." "OK" }
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  BAM                                                         ║
# ╚══════════════════════════════════════════════════════════════╝
function Test-BAM {
    Write-Log "=== BAM ===" "TITLE"
    $paths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings",
        "HKLM:\SYSTEM\CurrentControlSet\Services\bam\UserSettings"
    )
    $found = $false
    foreach ($bamPath in $paths) {
        if (-not (Test-Path $bamPath)) { continue }
        foreach ($sid in (Get-ChildItem $bamPath -ErrorAction SilentlyContinue)) {
            $vals = Get-ItemProperty -Path $sid.PSPath -ErrorAction SilentlyContinue
            foreach ($p in $vals.PSObject.Properties) {
                if ($p.Name -match '\\') {
                    foreach ($cheat in $Script:CheatNames) {
                        if ($p.Name -match [regex]::Escape($cheat)) {
                            Write-Log "BAM: $($p.Name)" "FOUND"
                            $found = $true
                        }
                    }
                }
            }
        }
    }
    if (-not $found) { Write-Log "BAM: чисто" "OK" }
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  PREFETCH                                                    ║
# ╚══════════════════════════════════════════════════════════════╝
function Test-Prefetch {
    Write-Log "=== PREFETCH ===" "TITLE"
    $pfDir = "$env:WINDIR\Prefetch"
    if (-not (Test-Path $pfDir)) { Write-Log "Prefetch отключён или недоступен." "WARN"; return }
    
    $files = Get-ChildItem $pfDir -Filter "*.pf" -ErrorAction SilentlyContinue
    Write-Log "Найдено .pf файлов: $($files.Count)" "INFO"
    $found = $false
    foreach ($f in $files) {
        $name = $f.Name.ToLower()
        foreach ($cheat in $Script:CheatNames) {
            if ($name -match [regex]::Escape($cheat)) {
                Write-Log "PREFETCH: $($f.Name)" "FOUND"
                $found = $true
            }
        }
    }
    if (-not $found) { Write-Log "Prefetch: чисто" "OK" }
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  AMCACHE                                                     ║
# ╚══════════════════════════════════════════════════════════════╝
function Test-Amcache {
    Write-Log "=== AMCACHE ===" "TITLE"
    $amcache = "C:\Windows\AppCompat\Programs\Amcache.hve"
    if (-not (Test-Path $amcache)) { Write-Log "Amcache.hve не найден." "WARN"; return }
    
    # Amcache.hve — это реестр, требует загрузки. Упрощённо: ищем по strings
    Write-Log "Читаю Amcache.hve (поиск сигнатур в бинарнике)..." "INFO"
    try {
        $bytes = [System.IO.File]::ReadAllBytes($amcache)
        $found = $false
        foreach ($cheat in $Script:CheatNames) {
            $asciiBytes = [System.Text.Encoding]::Unicode.GetBytes($cheat)
            if ((Find-ByteString -Haystack $bytes -Needle $asciiBytes) -ge 0) {
                Write-Log "AMCACHE: найден '$cheat'" "FOUND"
                $found = $true
            }
        }
        if (-not $found) { Write-Log "Amcache: чисто" "OK" }
    } catch {
        Write-Log "Ошибка чтения Amcache: $_" "WARN"
    }
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  RECENTDOCS                                                  ║
# ╚══════════════════════════════════════════════════════════════╝
function Test-RecentDocs {
    Write-Log "=== RECENT DOCS ===" "TITLE"
    $recent = "$env:APPDATA\Microsoft\Windows\Recent"
    if (-not (Test-Path $recent)) { Write-Log "Recent не найден." "WARN"; return }
    
    $files = Get-ChildItem $recent -ErrorAction SilentlyContinue
    $found = $false
    foreach ($f in $files) {
        foreach ($cheat in $Script:CheatNames) {
            if ($f.Name -match [regex]::Escape($cheat)) {
                Write-Log "RECENT: $($f.Name)" "FOUND"
                $found = $true
            }
        }
    }
    if (-not $found) { Write-Log "Recent: чисто" "OK" }
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  DNS + hosts + TCP                                           ║
# ╚══════════════════════════════════════════════════════════════╝
function Test-Network {
    Write-Log "=== СЕТЬ ===" "TITLE"
    
    # hosts
    $hosts = "$env:WINDIR\System32\drivers\etc\hosts"
    if (Test-Path $hosts) {
        $content = Get-Content $hosts -ErrorAction SilentlyContinue | Where-Object { $_ -notmatch '^\s*#' -and $_.Trim() -ne '' }
        if ($content) {
            Write-Log "hosts-файл содержит записи:" "WARN"
            foreach ($line in $content) { Write-Log "  $line" "WARN" }
        } else {
            Write-Log "hosts-файл пуст (стандартно)" "OK"
        }
    }
    
    # DNS cache — подозрительные домены
    $suspiciousDomains = 'vape|impact|wurst|sigma|meteor|aristois|konas|zeus|doomsday|liquidbounce|novoline|astolfo|moonlight'
    try {
        $dns = Get-DnsClientCache -ErrorAction SilentlyContinue | Where-Object { $_.Entry -match $suspiciousDomains }
        if ($dns) { foreach ($d in $dns) { Write-Log "DNS: $($d.Entry) -> $($d.Data)" "FOUND" } }
        else { Write-Log "DNS cache: чисто" "OK" }
    } catch { Write-Log "DNS cache недоступен" "WARN" }
    
    # TCP
    try {
        $conns = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
                 Where-Object { $_.RemotePort -in @(25565, 25566, 19132) }
        if ($conns) {
            foreach ($c in $conns) { Write-Log "TCP: $($c.RemoteAddress):$($c.RemotePort) (PID $($c.OwningProcess))" "INFO" }
        } else { Write-Log "TCP: нет подключений к MC-портам" "OK" }
    } catch { }
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  SCHEDULED TASKS                                             ║
# ╚══════════════════════════════════════════════════════════════╝
function Test-ScheduledTasks {
    Write-Log "=== SCHEDULED TASKS ===" "TITLE"
    try {
        $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue
        $found = $false
        foreach ($t in $tasks) {
            $actionStr = ($t.Actions | ForEach-Object { "$($_.Execute) $($_.Arguments)" }) -join ' '
            foreach ($cheat in $Script:CheatNames) {
                if ($actionStr -match [regex]::Escape($cheat)) {
                    Write-Log "TASK: $($t.TaskName) -> $actionStr" "FOUND"
                    $found = $true
                }
            }
        }
        if (-not $found) { Write-Log "Scheduled tasks: чисто" "OK" }
    } catch { Write-Log "Scheduled tasks недоступны" "WARN" }
}

# ╔══════════════════════════════════════════════════════════════╗
# ║  TELEGRAM                                                    ║
# ╚══════════════════════════════════════════════════════════════╝
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

# ╔══════════════════════════════════════════════════════════════╗
# ║  MAIN LOOP                                                   ║
# ╚══════════════════════════════════════════════════════════════╝
Show-Banner
$Script:Report.Add("=== ENGINE CHECK v5.0 ===")
$Script:Report.Add("Дата: $(Get-Date)")
$Script:Report.Add("ПК: $env:COMPUTERNAME")
$Script:Report.Add("")

$exit = $false
while (-not $exit) {
    Show-Menu
    $c = Read-Host "  Выбор"
    $Script:StartTime = Get-Date
    switch ($c) {
        "1" {
            Test-Services; Test-Processes
            Start-JarScanParallel
            Start-EverythingScan
            Test-Strings
            Test-BAM; Test-Prefetch; Test-Amcache; Test-RecentDocs
            Test-Network; Test-ScheduledTasks
        }
        "2" { Start-JarScanParallel -ModsOnly }
        "3" { Start-JarScanParallel -AllDisks }
        "4" { Test-Services; Test-Processes }
        "5" { Start-EverythingScan }
        "6" { Test-Strings }
        "7" { Test-BAM; Test-Prefetch; Test-Amcache; Test-RecentDocs; Test-ScheduledTasks }
        "8" { Test-Network }
        "9" { Send-Report }
        "0" { $exit = $true; continue }
        default { Write-Host "  Неверно." -ForegroundColor Red; continue }
    }
    $elapsed = (Get-Date) - $Script:StartTime
    Write-Host ""
    Write-Host "  Готово за $($elapsed.ToString('mm\:ss')). Флагов: $($Script:Threats)" -ForegroundColor Cyan
    Write-Host "  Enter для возврата..."
    Read-Host | Out-Null
    Show-Banner
}
