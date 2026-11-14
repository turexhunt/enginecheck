<#
EngineCheck v6.1 - Fixed PowerShell 5.1 compatibility
#>

$Config = @{
    TelegramBotToken = "ТВОЙ_ТОКЕН_БОТА"
    TelegramChatId   = "ТВОЙ_CHAT_ID"
    MaxJarSizeMB     = 100
}

$Script:WhitelistPaths = @(
    '\\libraries\\','\\assets\\','\\natives\\','\\cache\\','\\logs\\','\\log\\',
    '\\org\\eclipse\\','\\org\\bouncycastle\\','\\org\\apache\\','\\com\\google\\',
    '\\io\\netty\\','\\com\\mojang\\','\\io\\papermc\\','\\org\\spigotmc\\',
    '\\org\\slf4j\\','\\org\\jetbrains\\','\\org\\json\\','\\com\\fasterxml\\',
    '\\net\\minecraft\\','\\org\\lwjgl\\','\\net\\fabricmc\\','\\org\\quiltmc\\',
    '\\net\\neoforged\\','\\net\\minecraftforge\\','\\com\\github\\',
    '\\\.gradle\\','\\\.m2\\','\\\.ivy2\\','\\runtime\\','\\jre\\','\\jdk\\'
)
$Script:WhitelistNames = @(
    'grim','shard','vulcan','matrix','spartan','aac','ncp','negativity','polar',
    'intave','themis','karhu','verus','eris','medusa','sentinel','buzz','reflex',
    'anticheat','nightfall','antlr','icu4j','guava','netty','log4j','gson',
    'snakeyaml','bcprov','bcpkix','bouncycastle','maven','paper-api','spigot-api',
    'bukkit','sat4j','fabric-loader','quilt-loader','forge','neoforge','slf4j',
    'listenablefuture','sisu','asm','ow2','objectweb','commons-','jsr','jakarta',
    'kotlin-','scala-','groovy','junit','testng','mockito','hamcrest','assertj',
    'lombok','sodium','iris','optifine','rubidium','embeddium','modmenu',
    'fabric-api','cloth-config','yacl','lithium','phosphor','ferritecore',
    'krypton','starlight','indium','continuity','lazydfu','c2me','noisium',
    'memoryleakfix','dynamic-fps','fps-reducer','smooth-boot','modernfix',
    'fastload','fast-ip-ping','carpet','litematica','minihud','tweakeroo',
    'item-scroller','shulkerboxtooltip','appleskin','roughly-enough-items',
    'jei','rei','emi','wthit','jade','hwyla','mod-menu','malilib','sodium-extra',
    'lunar','badlion','labymod','tlauncher','technic','prism','multimc',
    'atlauncher','gdlauncher','polymc','java-runtime'
)
$Script:CheatNames = @(
    'impact','wurst','aristois','huzuni','skillclient','nodus','inertia','ares',
    'sigma','meteor','liquidbounce','expensive','neverhook','wexside','future',
    'dreampool','vape','konas','zeusclient','richclient','ghostclient','rusherhack',
    'thunderhack','moonhack','nova','exire','jex','hakari','hush','hach','haruka',
    'wissend','fluger','vortex','newcode','luminex','nuclear','bleachhack',
    'novoline','remix','astolfo','moonlight','cuckoo','pandora','azura','akrien',
    'minced','deadcode','dauntiblyat','takker','faker','xameleon','fuzeclient',
    'wisefolder','feather','eclipse-client','venus','catlavan','win4','dorito',
    'hero','spooky','winter','seppuku','koks','kov','stealth','valor','fluger',
    'horizon','nuclear-v2','eagle','sakura','kami','oldver','polar-client',
    'raphael','drag-client','incognito','trident','waveclient','zucc','insomnia',
    'ether','zamorozka','nurik','nursultan','celestial','celka','arbuz','britva',
    'bariton','rogalik','sperma','astra','doomsday','nightware','extazyy','troxill'
)
$Script:DefinitiveFuncs = @(
    'killaura','kill_aura','aimbot','aim_bot','aimassist','aim_assist',
    'hitbox_expand','hitboxexpand','reach_hack','reachhack','autototem',
    'auto_totem','autocrystal','auto_crystal','autotrap','auto_trap','autolog',
    'auto_log','autopot','auto_pot','criticals','anti_knockback','antiknockback',
    'velocity_mod','velocitymod','backtrack','fake_lag','fakelag','pingspoof',
    'ping_spoof','timerhack','timer_hack','keep_sprint','keepsprint','noslow',
    'no_slow','scaffold_walk','scaffoldwalk','scaffold','flyhack','fly_hack',
    'speedhack','speed_hack','longjump','long_jump','step_hack','stephack',
    'nofall','no_fall','jesus','dolphin','bhop','bunnyhop','bunny_hop',
    'antivelocity','anti_velocity','xray','x_ray','fullbright','tracers',
    'nametags','name_tags','wallhack','wall_hack','esp','chams','outline_esp',
    'outlineesp','nuker','nukeraura','fastbreak','fast_break','fastplace',
    'fast_place','instabreak','insta_break','scaffoldtower','tower','ghosthand',
    'ghost_hand','auto_build','autobuild','autofarm','auto_farm','chest_stealer',
    'cheststealer','inventory_move','invmove','phase','noclip','no_clip',
    'teleport','tp_hack'
)
$Script:SignatureFuncs = @(
    'aim','hit','reach','velocity','fly','speed','jump','totem','crystal',
    'aura','block','place','break','tower','scaffold','farm','sell','buy',
    'tracers','esp','xray','bright','walk','run','sprint','crouch','sneak'
)
$Script:PackageIndicators = @(
    'functions/combat/','functions/movement/','functions/render/','functions/player/',
    'functions/world/','functions/misc/','functions/exploit/',
    'module/combat/','module/movement/','module/render/','module/player/',
    'modules/combat/','modules/movement/','modules/render/','modules/player/',
    'hack/combat/','hack/movement/','hack/render/','hack/player/',
    'cheat/combat/','cheat/movement/','cheat/render/','cheat/player/'
)
$Script:ScoreThreshold = 5

$Script:Report = New-Object System.Collections.Generic.List[string]
$Script:Threats = 0
$Script:StartTime = $null

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
    Write-Host "  ENGINE CHECK v6.1 - Fixed PS 5.1" -ForegroundColor Cyan
}

function Show-Menu {
    Write-Host ""
    Write-Host "  [1] ПОЛНЫЙ СКАН" -ForegroundColor White
    Write-Host "  [2] JAR скан — mods/" -ForegroundColor White
    Write-Host "  [3] JAR скан — ВСЕ .jar на ПК" -ForegroundColor White
    Write-Host "  [4] Процессы + Память (javaw)" -ForegroundColor White
    Write-Host "  [5] Everything" -ForegroundColor White
    Write-Host "  [6] Строки (explorer/javaw)" -ForegroundColor White
    Write-Host "  [7] Артефакты (BAM/Prefetch/Amcache)" -ForegroundColor White
    Write-Host "  [8] Сеть" -ForegroundColor White
    Write-Host "  [9] Отправить в Telegram" -ForegroundColor White
    Write-Host "  [0] Выход" -ForegroundColor White
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

# JAR SCANNER (self-contained, без передачи helper)
function Invoke-JarScanSingle {
    param($JarPath, $Def, $Sig, $Pkg, $Thr)

    function Get-CpStringsLocal {
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

    $result = [PSCustomObject]@{ Path = $JarPath; Score = 0; Reasons = @(); Error = $null }
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)
        $seen = @{}
        foreach ($entry in $zip.Entries) {
            if ($entry.FullName -notmatch '\.class$') { continue }
            $entryLower = $entry.FullName.ToLower()
            foreach ($pkg in $Pkg) {
                if ($entryLower -match [regex]::Escape($pkg) -and -not $seen.ContainsKey($pkg)) {
                    $seen[$pkg] = $true; $result.Score += 5
                    $result.Reasons += "Структура: $pkg ($($entry.FullName))"
                }
            }
            try {
                $s = $entry.Open(); $ms = New-Object System.IO.MemoryStream
                $s.CopyTo($ms); $bytes = $ms.ToArray(); $s.Close(); $ms.Close()
                $cp = Get-CpStringsLocal -b $bytes
                foreach ($str in $cp) {
                    $sl = $str.ToLower()
                    foreach ($d in $Def) {
                        if ($sl -match $d -and -not $seen.ContainsKey($d)) {
                            $seen[$d] = $true; $result.Score += 10
                            $result.Reasons += "Функция '$d' в $($entry.FullName)"
                        }
                    }
                    foreach ($sg in $Sig) {
                        if ($sl -match $sg -and -not $seen.ContainsKey($sg)) {
                            $seen[$sg] = $true; $result.Score += 3
                            $result.Reasons += "Сигнатура '$sg' в $($entry.FullName)"
                        }
                    }
                }
            } catch { }
        }
        $zip.Dispose()
    } catch { $result.Error = $_.Exception.Message }
    if ($result.Score -lt $Thr) { $result.Reasons = @() }
    return $result
}

function Start-JarScanParallel {
    param([switch]$AllDisks, [switch]$ModsOnly)
    Write-Log "=== JAR АНАЛИЗ ===" "TITLE"
    $searchPaths = @()
    if ($AllDisks) {
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 }
        foreach ($drive in $drives) {
            try {
                $searchPaths += Get-ChildItem -Path "$($drive.Name):\" -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue -Force |
                                Where-Object { $_.Length -lt ($Config.MaxJarSizeMB * 1MB) }
            } catch { }
        }
    } elseif ($ModsOnly) {
        $modsPath = "$env:APPDATA\.minecraft\mods"
        if (Test-Path $modsPath) {
            $searchPaths = Get-ChildItem -Path $modsPath -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue |
                           Where-Object { $_.Length -lt ($Config.MaxJarSizeMB * 1MB) }
        }
    } else {
        foreach ($p in @("$env:APPDATA\.minecraft\mods", "$env:APPDATA\.minecraft\versions")) {
            if (Test-Path $p) {
                $searchPaths += Get-ChildItem -Path $p -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue |
                                Where-Object { $_.Length -lt ($Config.MaxJarSizeMB * 1MB) }
            }
        }
    }
    $jars = $searchPaths | Where-Object { -not (Test-Whitelisted -FullPath $_.FullName -Name $_.Name.ToLower()) }
    Write-Log "Найдено JAR: $($jars.Count)" "INFO"
    if ($jars.Count -eq 0) { Write-Log "Нечего сканировать." "WARN"; return }

    $cpu = [Environment]::ProcessorCount
    $threads = [Math]::Max(1, [Math]::Min($cpu, 8))
    Write-Log "Потоков: $threads (CPU: $cpu)" "INFO"

    $pool = [RunspaceFactory]::CreateRunspacePool(1, $threads)
    $pool.Open()

    # Передаём тело функции через Definition (работает в PS 5.1)
    $funcDef = (Get-Item function:Invoke-JarScanSingle).Definition

    $jobs = @()
    foreach ($jar in $jars) {
        $ps = [PowerShell]::Create()
        $ps.RunspacePool = $pool
        [void]$ps.AddScript({
            param($JarPath, $Def, $Sig, $Pkg, $Thr, $FuncDef)
            . ([ScriptBlock]::Create($FuncDef))
            Invoke-JarScanSingle -JarPath $JarPath -Def $Def -Sig $Sig -Pkg $Pkg -Thr $Thr
        }).AddArgument($jar.FullName).AddArgument($Script:DefinitiveFuncs).AddArgument($Script:SignatureFuncs).AddArgument($Script:PackageIndicators).AddArgument($Script:ScoreThreshold).AddArgument($funcDef)
        $jobs += [PSCustomObject]@{ PS = $ps; Handle = $ps.BeginInvoke(); Jar = $jar }
    }
    $done = 0; $flagged = 0
    foreach ($job in $jobs) {
        $res = $job.PS.EndInvoke($job.Handle)
        $job.PS.Dispose()
        $done++
        Write-Host "`r  Сканирую $done / $($jobs.Count) — читов: $flagged" -NoNewline -ForegroundColor Gray
        if ($res -and $res.Score -ge $Script:ScoreThreshold) {
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
    Write-Log "Просканировано $($jobs.Count), найдено: $flagged" "INFO"
}

# PROCESS MEMORY SCANNER
function Test-ProcessMemory {
    Write-Log "=== ПАМЯТЬ javaw.exe ===" "TITLE"
    $javaws = Get-Process javaw -ErrorAction SilentlyContinue
    if (-not $javaws) { Write-Log "javaw.exe не запущен." "WARN"; return }

    if (-not ("MemReader" -as [type])) {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class MemReader {
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern IntPtr OpenProcess(int access, bool inherit, int pid);
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool ReadProcessMemory(IntPtr h, IntPtr addr, byte[] buf, int size, out IntPtr read);
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern bool CloseHandle(IntPtr h);
    [DllImport("kernel32.dll", SetLastError=true)]
    public static extern int VirtualQueryEx(IntPtr h, IntPtr addr, out MEMORY_BASIC_INFORMATION mbi, int len);
}
[StructLayout(LayoutKind.Sequential)]
public struct MEMORY_BASIC_INFORMATION {
    public IntPtr BaseAddress;
    public IntPtr AllocationBase;
    public uint AllocationProtect;
    public IntPtr RegionSize;
    public uint State;
    public uint Protect;
    public uint Type;
}
"@
    }

    $patterns = @('l.png','killaura','aimbot','vape','sigma','meteor','hitbox_expand')
    $PROCESS_QUERY_INFORMATION = 0x0400
    $PROCESS_VM_READ = 0x0010
    $MEM_COMMIT = 0x1000
    $PAGE_READABLE = 0x02, 0x04, 0x20, 0x40

    foreach ($proc in $javaws) {
        Write-Log "Сканирую PID $($proc.Id)..." "INFO"
        $h = [MemReader]::OpenProcess($PROCESS_QUERY_INFORMATION -bor $PROCESS_VM_READ, $false, $proc.Id)
        if ($h -eq [IntPtr]::Zero) { Write-Log "OpenProcess failed (админ?)." "WARN"; continue }

        $addr = [IntPtr]::Zero
        $mbiSize = [System.Runtime.InteropServices.Marshal]::SizeOf([type][MEMORY_BASIC_INFORMATION])
        $regions = 0; $bytesReadTotal = 0

        while ($true) {
            $mbi = New-Object MEMORY_BASIC_INFORMATION
            $ret = [MemReader]::VirtualQueryEx($h, $addr, [ref]$mbi, $mbiSize)
            if ($ret -eq 0) { break }
            if ($mbi.State -eq $MEM_COMMIT -and ($PAGE_READABLE -contains [int]$mbi.Protect)) {
                $size = [int]$mbi.RegionSize
                if ($size -gt 0 -and $size -lt 50MB) {
                    $buf = New-Object byte[] $size
                    $read = [IntPtr]::Zero
                    if ([MemReader]::ReadProcessMemory($h, $mbi.BaseAddress, $buf, $size, [ref]$read)) {
                        $regions++
                        $bytesReadTotal += [int]$read
                        $text = [System.Text.Encoding]::ASCII.GetString($buf, 0, [int]$read)
                        foreach ($pattern in $patterns) {
                            if ($text -match [regex]::Escape($pattern)) {
                                Write-Log "ПАМЯТЬ: '$pattern' в PID $($proc.Id) @ $($mbi.BaseAddress)" "FOUND"
                            }
                        }
                    }
                }
            }
            $addr = [IntPtr]([long]$mbi.BaseAddress + [long]$mbi.RegionSize)
        }
        [MemReader]::CloseHandle($h) | Out-Null
        Write-Log "PID $($proc.Id): $regions регионов, $([math]::Round($bytesReadTotal/1MB,1)) MB" "INFO"
    }
}

# EVERYTHING
function Ensure-Everything {
    $proc = Get-Process Everything -ErrorAction SilentlyContinue
    if (-not $proc) {
        $candidates = @(
            "C:\Program Files\Everything\Everything.exe",
            "C:\Program Files (x86)\Everything\Everything.exe",
            "$env:LOCALAPPDATA\Everything\Everything.exe"
        )
        $found = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
        if ($found) {
            Start-Process $found -ArgumentList "-startup" -WindowStyle Minimized
            Start-Sleep -Seconds 10
        } else { Write-Log "Everything не установлен." "WARN"; return $null }
    }
    $es = @(
        "$env:LOCALAPPDATA\Everything\es.exe",
        "C:\Program Files\Everything\es.exe",
        "C:\Program Files (x86)\Everything\es.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $es) {
        $cmd = Get-Command es.exe -ErrorAction SilentlyContinue
        if ($cmd) { $es = $cmd.Source }
    }
    return $es
}

function Start-EverythingScan {
    Write-Log "=== EVERYTHING ===" "TITLE"
    $es = Ensure-Everything
    if (-not $es) { Write-Log "es.exe не найден." "WARN"; return }
    $ver = & $es -version 2>&1
    Write-Log "es.exe: $ver" "OK"
    $pattern = 'impact|wurst|sigma|meteor|aristois|future|konas|zeusclient|vape|doomsday|nightware|liquidbounce|novoline|astolfo|moonlight|nurik|celestial|expensive'
    Write-Log "Запрос: $pattern" "INFO"
    $result = & $es -r $pattern 2>$null
    if (-not $result) { Write-Log "Совпадений нет. Проверь индексацию Everything (Tools > Options > Indexes > NTFS)." "WARN"; return }
    $filtered = $result | Where-Object { $_ -match '\.(exe|jar|zip|rar|dll)$' }
    if ($filtered) { foreach ($line in $filtered) { Write-Log "НАЙДЕНО: $line" "FOUND" } }
    else { Write-Log "es вернул $($result.Count) результатов, но не exe/jar/zip/rar/dll" "WARN" }
}

# STRINGS
function Test-Strings {
    Write-Log "=== СТРОКИ ===" "TITLE"
    $targets = @(
        @{ Path = "$env:WINDIR\explorer.exe"; Patterns = @("deltadlc","nursultam","celestial") }
    )
    $candidates = @(
        "C:\Program Files\Java","C:\Program Files\Eclipse Adoptium",
        "$env:APPDATA\.minecraft\runtime","$env:USERPROFILE\.jdks"
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) {
            $jp = (Get-ChildItem -Path $c -Filter "javaw.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 3).FullName
            foreach ($p in $jp) { $targets += @{ Path = $p; Patterns = @("l.png") } }
        }
    }
    foreach ($t in $targets) {
        if (-not (Test-Path $t.Path)) { continue }
        $size = (Get-Item $t.Path).Length / 1MB
        if ($size -gt 100) { continue }
        Write-Log "Читаю $($t.Path)..." "INFO"
        try { $bytes = [System.IO.File]::ReadAllBytes($t.Path) } catch { Write-Log "Ошибка: $_" "WARN"; continue }
        $found = $false
        foreach ($pattern in $t.Patterns) {
            $a = [System.Text.Encoding]::ASCII.GetBytes($pattern)
            $u = [System.Text.Encoding]::Unicode.GetBytes($pattern)
            if ((Find-ByteString -Haystack $bytes -Needle $a) -ge 0) { Write-Log "ASCII '$pattern' в $([System.IO.Path]::GetFileName($t.Path))" "FOUND"; $found = $true }
            if ((Find-ByteString -Haystack $bytes -Needle $u) -ge 0) { Write-Log "UTF-16 '$pattern' в $([System.IO.Path]::GetFileName($t.Path))" "FOUND"; $found = $true }
        }
        if (-not $found) { Write-Log "$([System.IO.Path]::GetFileName($t.Path)): чисто" "OK" }
    }
}

# SERVICES + PROCESSES
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
    if ($found) { foreach ($p in $found) { Write-Log "ПРОЦЕСС: $($p.ProcessName) (PID $($p.Id))" "FOUND" } }
    else { Write-Log "Подозрительных процессов нет." "OK" }
}

# BAM / PREFETCH / AMCACHE
function Test-BAM {
    Write-Log "=== BAM ===" "TITLE"
    $paths = @("HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings","HKLM:\SYSTEM\CurrentControlSet\Services\bam\UserSettings")
    $found = $false
    foreach ($bamPath in $paths) {
        if (-not (Test-Path $bamPath)) { continue }
        foreach ($sid in (Get-ChildItem $bamPath -ErrorAction SilentlyContinue)) {
            $vals = Get-ItemProperty -Path $sid.PSPath -ErrorAction SilentlyContinue
            foreach ($p in $vals.PSObject.Properties) {
                if ($p.Name -match '\\') {
                    foreach ($cheat in $Script:CheatNames) {
                        if ($p.Name -match [regex]::Escape($cheat)) { Write-Log "BAM: $($p.Name)" "FOUND"; $found = $true }
                    }
                }
            }
        }
    }
    if (-not $found) { Write-Log "BAM: чисто" "OK" }
}

function Test-Prefetch {
    Write-Log "=== PREFETCH ===" "TITLE"
    $pfDir = "$env:WINDIR\Prefetch"
    if (-not (Test-Path $pfDir)) { Write-Log "Prefetch недоступен." "WARN"; return }
    $files = Get-ChildItem $pfDir -Filter "*.pf" -ErrorAction SilentlyContinue
    $found = $false
    foreach ($f in $files) {
        $name = $f.Name.ToLower()
        foreach ($cheat in $Script:CheatNames) {
            if ($name -match [regex]::Escape($cheat)) { Write-Log "PREFETCH: $($f.Name)" "FOUND"; $found = $true }
        }
    }
    if (-not $found) { Write-Log "Prefetch: чисто" "OK" }
}

function Test-Amcache {
    Write-Log "=== AMCACHE ===" "TITLE"
    $path = "C:\Windows\AppCompat\Programs\Amcache.hve"
    if (-not (Test-Path $path)) { Write-Log "Amcache.hve не найден." "WARN"; return }
    try {
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $found = $false
        foreach ($cheat in $Script:CheatNames) {
            $unicode = [System.Text.Encoding]::Unicode.GetBytes($cheat)
            if ((Find-ByteString -Haystack $bytes -Needle $unicode) -ge 0) {
                Write-Log "AMCACHE: '$cheat'" "FOUND"; $found = $true
            }
        }
        if (-not $found) { Write-Log "Amcache: чисто" "OK" }
    } catch { Write-Log "Ошибка Amcache: $_" "WARN" }
}

# NETWORK
function Test-Network {
    Write-Log "=== СЕТЬ ===" "TITLE"
    $hosts = "$env:WINDIR\System32\drivers\etc\hosts"
    if (Test-Path $hosts) {
        $content = Get-Content $hosts -ErrorAction SilentlyContinue | Where-Object { $_ -notmatch '^\s*#' -and $_.Trim() -ne '' }
        if ($content) { Write-Log "hosts:" "WARN"; foreach ($l in $content) { Write-Log "  $l" "WARN" } }
        else { Write-Log "hosts пуст." "OK" }
    }
    $susp = 'vape|impact|wurst|sigma|meteor|aristois|konas|zeus|doomsday|liquidbounce|novoline|astolfo|moonlight'
    try {
        $dns = Get-DnsClientCache -ErrorAction SilentlyContinue | Where-Object { $_.Entry -match $susp }
        if ($dns) { foreach ($d in $dns) { Write-Log "DNS: $($d.Entry)" "FOUND" } }
        else { Write-Log "DNS: чисто." "OK" }
    } catch { }
}

# TELEGRAM
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

# MAIN
Write-Host "  >>> ENGINE CHECK v6.1 LOADED <<<" -ForegroundColor Magenta
$Script:Report.Add("=== ENGINE CHECK v6.1 ===")
$Script:Report.Add("Дата: $(Get-Date)")
$Script:Report.Add("ПК: $env:COMPUTERNAME")
$Script:Report.Add("")

$exit = $false
while (-not $exit) {
    Show-Menu
    $c = Read-Host "  Выбор"
    $Script:StartTime = Get-Date
    switch ($c) {
        "1" { Test-Services; Test-Processes; Start-JarScanParallel; Test-ProcessMemory; Start-EverythingScan; Test-Strings; Test-BAM; Test-Prefetch; Test-Amcache; Test-Network }
        "2" { Start-JarScanParallel -ModsOnly }
        "3" { Start-JarScanParallel -AllDisks }
        "4" { Test-Processes; Test-ProcessMemory }
        "5" { Start-EverythingScan }
        "6" { Test-Strings }
        "7" { Test-BAM; Test-Prefetch; Test-Amcache }
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
