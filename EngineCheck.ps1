<#
.SYNOPSIS
    EngineCheck v7.0 - Advanced ScreenShare Checker for Minecraft
.DESCRIPTION
    Full single-file checker:
      - Discovery + Metadata (manifest, mods.toml, fabric.mod.json, mcmod.info)
      - Deep JAR scan (constant pool, bytecode signatures, obfuscation)
      - Network strings (URL/IP/webhooks), Native libs, Nested JARs, Dangerous patterns
      - Process memory scan (javaw.exe heap)
      - Everything diagnostic + multi-fallback search
      - BAM / Prefetch / Amcache / RecentDocs
      - Services / Processes / Network / Scheduled Tasks
      - Telegram report
.NOTES
    Run: Set-ExecutionPolicy -Scope Process Bypass -Force; irm <raw-url> | iex
#>

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  CONFIG                                                              ║
# ╚══════════════════════════════════════════════════════════════════════╝
$Config = @{
    TelegramBotToken = "ТВОЙ_ТОКЕН_БОТА"
    TelegramChatId   = "ТВОЙ_CHAT_ID"
    MaxJarSizeMB     = 100
    MaxDeepScanClass = 3000
    RunspaceThreads  = 8
}

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  WHITELIST                                                           ║
# ╚══════════════════════════════════════════════════════════════════════╝
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

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  SIGNATURE DATABASES                                                 ║
# ╚══════════════════════════════════════════════════════════════════════╝
$Script:CheatNames = @(
    'impact','wurst','aristois','huzuni','skillclient','nodus','inertia','ares',
    'sigma','meteor','liquidbounce','expensive','neverhook','wexside','future',
    'dreampool','vape','konas','zeusclient','richclient','ghostclient','rusherhack',
    'thunderhack','moonhack','nova','exire','jex','hakari','hush','hach','haruka',
    'wissend','fluger','vortex','newcode','luminex','nuclear','bleachhack',
    'novoline','remix','astolfo','moonlight','cuckoo','pandora','azura','akrien',
    'minced','deadcode','dauntiblyat','takker','faker','xameleon','fuzeclient',
    'wisefolder','feather','eclipse-client','venus','catlavan','win4','dorito',
    'hero','spooky','winter','seppuku','koks','kov','stealth','valor',
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
$Script:SignatureWeights = @{
    Definitive = 10
    Signature  = 3
    Package    = 5
    ClassName  = 8
    MethodName = 6
    FieldName  = 4
    Agent      = 15
    HashMatch  = 100
    Obfuscated = 4
}
$Script:ScoreThreshold = 5

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  STATE                                                               ║
# ╚══════════════════════════════════════════════════════════════════════╝
$Script:Report = New-Object System.Collections.Generic.List[string]
$Script:Threats = 0
$Script:StartTime = $null
$Script:LastJarMetas = @()
$Script:LastDeepResults = @()
$Script:LastAuxResults = @()
$Script:EverythingState = $null

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  UI HELPERS                                                          ║
# ╚══════════════════════════════════════════════════════════════════════╝
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
    Write-Host "  ENGINE CHECK v7.0 - Full Scanner" -ForegroundColor Cyan
    Write-Host "  JAR Deep + Network + Native + Everything + Memory" -ForegroundColor DarkCyan
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

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  JAR DISCOVERY PATHS                                                 ║
# ╚══════════════════════════════════════════════════════════════════════╝
$Script:MinecraftPaths = @(
    @{ Path = "$env:APPDATA\.minecraft";                     Name = "Vanilla";       Type = "mods" }
    @{ Path = "$env:APPDATA\.minecraft\mods";                Name = "Vanilla";       Type = "mods" }
    @{ Path = "$env:APPDATA\.minecraft\versions";            Name = "Vanilla";       Type = "versions" }
    @{ Path = "$env:APPDATA\.tlauncher\legacy\Minecraft";    Name = "TLauncher";     Type = "root" }
    @{ Path = "$env:APPDATA\.tlauncher\legacy\Minecraft\mods";Name = "TLauncher";    Type = "mods" }
    @{ Path = "$env:APPDATA\.tlauncher\legacy\Minecraft\versions";Name = "TLauncher";Type = "versions" }
    @{ Path = "$env:USERPROFILE\.lunarclient";               Name = "Lunar";         Type = "root" }
    @{ Path = "$env:USERPROFILE\.lunarclient\offline\multiver";Name = "Lunar";       Type = "mods" }
    @{ Path = "$env:APPDATA\Badlion Client";                 Name = "Badlion";       Type = "root" }
    @{ Path = "$env:APPDATA\Feather";                        Name = "Feather";       Type = "root" }
    @{ Path = "$env:APPDATA\PrismLauncher\instances";        Name = "Prism";         Type = "instances" }
    @{ Path = "$env:APPDATA\MultiMC\instances";              Name = "MultiMC";       Type = "instances" }
    @{ Path = "$env:APPDATA\ATLauncher\instances";           Name = "ATLauncher";    Type = "instances" }
    @{ Path = "$env:USERPROFILE\curseforge\minecraft\Instances";Name = "CurseForge";Type = "instances" }
    @{ Path = "$env:APPDATA\com.modrinth.theseus";           Name = "Modrinth";      Type = "instances" }
    @{ Path = "$env:APPDATA\.vimeworld";                     Name = "VimeWorld";     Type = "mods" }
    @{ Path = "C:\Games\.minecraft";                         Name = "Portable";      Type = "mods" }
    @{ Path = "D:\Games\.minecraft";                         Name = "Portable";      Type = "mods" }
) | Where-Object { Test-Path $_.Path }

$Script:KnownCheatHashes = @{}
$Script:ManifestRedFlags = @('Premain-Class','Agent-Class','Can-Redefine-Classes','Can-Retransform-Classes','Launcher-Agent-Class')
$Script:MetaRedFlags = @(
    'mixins.combat','mixins.movement','mixins.render','mixins.player',
    'mixins.exploit','mixins.world','mixins.hack','mixins.cheat',
    'client.combat','client.movement','client.render','client.player',
    'client.exploit','client.hack','client.cheat'
)

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  DISCOVERY                                                           ║
# ╚══════════════════════════════════════════════════════════════════════╝
function Find-AllJars {
    param([switch]$IncludeDownloads, [int]$MaxSizeMB = 100)

    $all = New-Object System.Collections.Generic.List[object]
    $targets = @() + $Script:MinecraftPaths
    if ($IncludeDownloads) {
        $targets += @{ Path = "$env:USERPROFILE\Downloads"; Name = "Downloads"; Type = "manual" }
        $targets += @{ Path = "$env:USERPROFILE\Desktop";   Name = "Desktop";   Type = "manual" }
    }

    $i = 0
    foreach ($t in $targets) {
        if (-not (Test-Path $t.Path)) { continue }
        $i++
        Write-Host "`r  [Discovery] $i/$($targets.Count): $($t.Name) → $($t.Path)" -NoNewline -ForegroundColor DarkGray
        try {
            $found = Get-ChildItem -Path $t.Path -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue -Force |
                     Where-Object { $_.Length -gt 0 -and $_.Length -lt ($MaxSizeMB * 1MB) }
            foreach ($jar in $found) {
                $all.Add([PSCustomObject]@{
                    FullPath = $jar.FullName; FileName = $jar.Name
                    Size = $jar.Length; Modified = $jar.LastWriteTime
                    Launcher = $t.Name; Category = $t.Type
                })
            }
        } catch { }
    }
    Write-Host ""
    $unique = $all | Sort-Object FullPath -Unique
    Write-Host "  [Discovery] Найдено JAR: $($unique.Count) (было $($all.Count))" -ForegroundColor Cyan
    return $unique
}

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  METADATA READERS                                                    ║
# ╚══════════════════════════════════════════════════════════════════════╝
function Get-JarHash {
    param([string]$Path)
    try {
        $sha = [System.Security.Cryptography.SHA256]::Create()
        $stream = [System.IO.File]::OpenRead($Path)
        $hash = $sha.ComputeHash($stream)
        $stream.Close(); $sha.Dispose()
        return ([System.BitConverter]::ToString($hash) -replace '-','').ToLower()
    } catch { return $null }
}

function Get-JarManifest {
    param([System.IO.Compression.ZipArchive]$Zip)
    $r = [PSCustomObject]@{ Found=$false; MainClass=$null; ImplementationTitle=$null; ImplementationVendor=$null; ImplementationVersion=$null; AgentFlags=@(); Raw=$null }
    $entry = $Zip.Entries | Where-Object { $_.FullName -eq 'META-INF/MANIFEST.MF' } | Select-Object -First 1
    if (-not $entry) { return $r }
    $r.Found = $true
    try {
        $s = $entry.Open(); $reader = New-Object System.IO.StreamReader($s)
        $raw = $reader.ReadToEnd(); $reader.Close(); $s.Close(); $r.Raw = $raw
        $kv = @{}; $lastKey = $null
        foreach ($line in ($raw -split "`r?`n")) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            if ($line -match '^\s+(.+)$' -and $lastKey) { $kv[$lastKey] += $Matches[1]; continue }
            if ($line -match '^([^:]+):\s*(.*)$') { $lastKey = $Matches[1].Trim(); $kv[$lastKey] = $Matches[2].Trim() }
        }
        if ($kv.ContainsKey('Main-Class')) { $r.MainClass = $kv['Main-Class'] }
        if ($kv.ContainsKey('Implementation-Title'))   { $r.ImplementationTitle = $kv['Implementation-Title'] }
        if ($kv.ContainsKey('Implementation-Vendor'))  { $r.ImplementationVendor = $kv['Implementation-Vendor'] }
        if ($kv.ContainsKey('Implementation-Version')) { $r.ImplementationVersion = $kv['Implementation-Version'] }
        foreach ($f in $Script:ManifestRedFlags) {
            if ($kv.ContainsKey($f)) { $r.AgentFlags += "$f = $($kv[$f])" }
        }
    } catch { }
    return $r
}

function Get-FabricMetadata {
    param([System.IO.Compression.ZipArchive]$Zip)
    $r = [PSCustomObject]@{ Found=$false; Id=$null; Name=$null; Version=$null; Author=$null; Mixins=@(); Entrypoints=@(); RedFlags=@() }
    $entry = $Zip.Entries | Where-Object { $_.FullName -eq 'fabric.mod.json' } | Select-Object -First 1
    if (-not $entry) { return $r }
    $r.Found = $true
    try {
        $s = $entry.Open(); $reader = New-Object System.IO.StreamReader($s)
        $json = $reader.ReadToEnd() | ConvertFrom-Json; $reader.Close(); $s.Close()
        if ($json.id)      { $r.Id = $json.id }
        if ($json.name)    { $r.Name = $json.name }
        if ($json.version) { $r.Version = $json.version }
        if ($json.author)  { $r.Author = "$($json.author)" }
        if ($json.authors) { $r.Author = "$($json.authors -join ', ')" }
        if ($json.mixins) {
            foreach ($m in $json.mixins) {
                $r.Mixins += "$m"
                foreach ($rf in $Script:MetaRedFlags) {
                    if ("$m" -match [regex]::Escape($rf)) { $r.RedFlags += "Mixin: $m" }
                }
            }
        }
        if ($json.entrypoints) {
            foreach ($epName in $json.entrypoints.PSObject.Properties.Name) {
                foreach ($ep in $json.entrypoints.$epName) { $r.Entrypoints += "$epName → $ep" }
            }
        }
        $combined = "$($r.Id) $($r.Name) $($r.Mixins -join ' ') $($r.Entrypoints -join ' ')".ToLower()
        foreach ($cheat in $Script:CheatNames) {
            if ($combined -match [regex]::Escape($cheat)) { $r.RedFlags += "Метаданные содержат '$cheat'" }
        }
    } catch { }
    return $r
}

function Get-ForgeMetadata {
    param([System.IO.Compression.ZipArchive]$Zip)
    $r = [PSCustomObject]@{ Found=$false; ModId=$null; DisplayName=$null; Version=$null; Authors=$null; MixinConfigs=@(); RedFlags=@() }
    $entry = $Zip.Entries | Where-Object { $_.FullName -eq 'META-INF/mods.toml' } | Select-Object -First 1
    if (-not $entry) { return $r }
    $r.Found = $true
    try {
        $s = $entry.Open(); $reader = New-Object System.IO.StreamReader($s)
        $raw = $reader.ReadToEnd(); $reader.Close(); $s.Close()
        foreach ($line in ($raw -split "`n")) {
            $line = $line.Trim()
            if ($line -match '^modId\s*=\s*"([^"]+)"')       { $r.ModId = $Matches[1] }
            if ($line -match '^displayName\s*=\s*"([^"]+)"') { $r.DisplayName = $Matches[1] }
            if ($line -match '^version\s*=\s*"([^"]+)"')     { $r.Version = $Matches[1] }
            if ($line -match '^authors\s*=\s*"([^"]+)"')     { $r.Authors = $Matches[1] }
            if ($line -match '^mixinConfigs\s*=\s*\[(.+)\]') {
                $r.MixinConfigs += ($Matches[1] -replace '"','').Split(',') | ForEach-Object { $_.Trim() }
            }
            foreach ($rf in $Script:MetaRedFlags) {
                if ($line.ToLower() -match [regex]::Escape($rf)) { $r.RedFlags += "mods.toml: $rf" }
            }
        }
        $combined = "$($r.ModId) $($r.DisplayName) $($r.MixinConfigs -join ' ')".ToLower()
        foreach ($cheat in $Script:CheatNames) {
            if ($combined -match [regex]::Escape($cheat)) { $r.RedFlags += "Метаданные Forge содержат '$cheat'" }
        }
    } catch { }
    return $r
}

function Get-McmodInfo {
    param([System.IO.Compression.ZipArchive]$Zip)
    $r = [PSCustomObject]@{ Found=$false; ModId=$null; Name=$null; Version=$null; AuthorList=$null; Description=$null; RedFlags=@() }
    $entry = $Zip.Entries | Where-Object { $_.FullName -eq 'mcmod.info' } | Select-Object -First 1
    if (-not $entry) { return $r }
    $r.Found = $true
    try {
        $s = $entry.Open(); $reader = New-Object System.IO.StreamReader($s)
        $raw = $reader.ReadToEnd(); $reader.Close(); $s.Close()
        $json = $raw | ConvertFrom-Json
        if ($json -is [array]) { $json = $json[0] }
        if ($json.modid)       { $r.ModId = $json.modid }
        if ($json.name)        { $r.Name = $json.name }
        if ($json.version)     { $r.Version = $json.version }
        if ($json.authorList)  { $r.AuthorList = "$($json.authorList -join ', ')" }
        if ($json.description) { $r.Description = $json.description }
        $combined = "$($r.ModId) $($r.Name) $($r.Description)".ToLower()
        foreach ($cheat in $Script:CheatNames) {
            if ($combined -match [regex]::Escape($cheat)) { $r.RedFlags += "mcmod.info содержит '$cheat'" }
        }
    } catch { }
    return $r
}

function Get-JarStats {
    param([System.IO.Compression.ZipArchive]$Zip)
    $stats = [PSCustomObject]@{ TotalEntries=0; ClassCount=0; ResourceCount=0; ShortClassCount=0; NestedJarCount=0; NativeCount=0; UniquePackages=0 }
    $packages = @{}
    foreach ($entry in $Zip.Entries) {
        $stats.TotalEntries++
        $name = $entry.FullName
        if ($name -match '\.class$') {
            $stats.ClassCount++
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($name)
            if ($fileName -match '^[a-z]{1,2}$') { $stats.ShortClassCount++ }
            $pkg = ($name -replace '/[^/]+$','')
            if ($pkg) { $packages[$pkg] = $true }
        }
        elseif ($name -match '\.(jar|zip)$') { $stats.NestedJarCount++ }
        elseif ($name -match '\.(dll|so|dylib)$') { $stats.NativeCount++ }
        else { $stats.ResourceCount++ }
    }
    $stats.UniquePackages = $packages.Count
    return $stats
}

function Read-JarMetadata {
    param([string]$JarPath, [switch]$ComputeHash)
    $m = [PSCustomObject]@{
        Path=$JarPath; FileName=[System.IO.Path]::GetFileName($JarPath)
        Size=0; Modified=$null; Hash=$null; HashMatch=$null
        Manifest=$null; Fabric=$null; Forge=$null; McmodInfo=$null; Stats=$null
        Error=$null; IsObfuscated=$false
    }
    try {
        $fi = Get-Item $JarPath
        $m.Size = $fi.Length; $m.Modified = $fi.LastWriteTime
        if ($ComputeHash) {
            $m.Hash = Get-JarHash -Path $JarPath
            if ($m.Hash -and $Script:KnownCheatHashes.ContainsKey($m.Hash)) {
                $m.HashMatch = $Script:KnownCheatHashes[$m.Hash]
            }
        }
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)
        $m.Manifest  = Get-JarManifest -Zip $zip
        $m.Fabric    = Get-FabricMetadata -Zip $zip
        $m.Forge     = Get-ForgeMetadata -Zip $zip
        $m.McmodInfo = Get-McmodInfo -Zip $zip
        $m.Stats     = Get-JarStats -Zip $zip
        $zip.Dispose()
        if ($m.Stats.ClassCount -gt 10) {
            if (($m.Stats.ShortClassCount / $m.Stats.ClassCount) -gt 0.5) { $m.IsObfuscated = $true }
        }
    } catch { $m.Error = $_.Exception.Message }
    return $m
}

function Show-MetadataSummary {
    param([array]$Metas)
    if (-not $Metas -or $Metas.Count -eq 0) { Write-Host "  Нет данных." -ForegroundColor Yellow; return }
    $err = ($Metas | Where-Object { $_.Error }).Count
    $ag  = ($Metas | Where-Object { $_.Manifest -and $_.Manifest.AgentFlags.Count -gt 0 }).Count
    $fab = ($Metas | Where-Object { $_.Fabric -and $_.Fabric.Found }).Count
    $for = ($Metas | Where-Object { $_.Forge -and $_.Forge.Found }).Count
    $mcm = ($Metas | Where-Object { $_.McmodInfo -and $_.McmodInfo.Found }).Count
    $obf = ($Metas | Where-Object { $_.IsObfuscated }).Count
    $hm  = ($Metas | Where-Object { $_.HashMatch }).Count
    Write-Host ""
    Write-Host "  ┌─── МЕТАДАННЫЕ ────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "  │ JAR:                    $($Metas.Count)" -ForegroundColor White
    Write-Host "  │ Ошибок:                 $err" -ForegroundColor $(if ($err -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  │ Java-Agent флаги:       $ag" -ForegroundColor $(if ($ag -gt 0) { "Red" } else { "Green" })
    Write-Host "  │ Fabric / Forge / 1.12-: $fab / $for / $mcm" -ForegroundColor White
    Write-Host "  │ Обфусцированных:        $obf" -ForegroundColor $(if ($obf -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  │ Hash-match:             $hm" -ForegroundColor $(if ($hm -gt 0) { "Red" } else { "Green" })
    Write-Host "  └───────────────────────────────────────────────────" -ForegroundColor Cyan
}

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  CONSTANT POOL PARSER (JVM)                                          ║
# ╚══════════════════════════════════════════════════════════════════════╝
function Get-ConstantPool {
    param([byte[]]$Bytes, [int]$MaxStrings = 8000, [int]$MaxRefs = 2000)
    $r = [PSCustomObject]@{
        Utf8Strings  = New-Object System.Collections.Generic.List[string]
        ClassNames   = New-Object System.Collections.Generic.List[string]
        MethodRefs   = New-Object System.Collections.Generic.List[string]
        FieldRefs    = New-Object System.Collections.Generic.List[string]
        StringLits   = New-Object System.Collections.Generic.List[string]
        TotalEntries = 0; Parsed = $false; Error = $null
    }
    try {
        if ($Bytes.Length -lt 10) { return $r }
        $magic = ([int]$Bytes[0] -shl 24) -bor ([int]$Bytes[1] -shl 16) -bor ([int]$Bytes[2] -shl 8) -bor [int]$Bytes[3]
        if ($magic -ne 0xCAFEBABE) { $r.Error = "Not .class"; return $r }
        $off = 8
        $cpCount = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
        $off += 2
        $r.TotalEntries = $cpCount
        $cpIndex = @{}; $i = 1
        while ($i -lt $cpCount -and $off -lt $Bytes.Length) {
            $tag = [int]$Bytes[$off]; $off++
            switch ($tag) {
                1 {
                    if ($off + 2 -gt $Bytes.Length) { break }
                    $len = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
                    $off += 2
                    if ($off + $len -le $Bytes.Length -and $len -gt 0) {
                        $str = [System.Text.Encoding]::UTF8.GetString($Bytes, $off, $len)
                        if ($r.Utf8Strings.Count -lt $MaxStrings) { $r.Utf8Strings.Add($str); $cpIndex[$i] = $str }
                    }
                    $off += $len
                }
                7 {
                    if ($off + 2 -gt $Bytes.Length) { break }
                    $idx = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]; $off += 2
                    if ($cpIndex.ContainsKey($idx)) { $r.ClassNames.Add($cpIndex[$idx]) }
                }
                8 {
                    if ($off + 2 -gt $Bytes.Length) { break }
                    $idx = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]; $off += 2
                    if ($cpIndex.ContainsKey($idx) -and $r.StringLits.Count -lt $MaxStrings) { $r.StringLits.Add($cpIndex[$idx]) }
                }
                3 { $off += 4 }; 4 { $off += 4 }
                5 { $off += 8; $i++ }; 6 { $off += 8; $i++ }
                9 {
                    if ($off + 4 -gt $Bytes.Length) { break }
                    $ci = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
                    $ni = ([int]$Bytes[$off + 2] -shl 8) -bor [int]$Bytes[$off + 3]; $off += 4
                    if ($r.FieldRefs.Count -lt $MaxRefs) {
                        $c = if ($cpIndex.ContainsKey($ci)) { $cpIndex[$ci] } else { "?" }
                        $n = if ($cpIndex.ContainsKey($ni)) { $cpIndex[$ni] } else { "?" }
                        $r.FieldRefs.Add("$c.$n")
                    }
                }
                10 {
                    if ($off + 4 -gt $Bytes.Length) { break }
                    $ci = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
                    $ni = ([int]$Bytes[$off + 2] -shl 8) -bor [int]$Bytes[$off + 3]; $off += 4
                    if ($r.MethodRefs.Count -lt $MaxRefs) {
                        $c = if ($cpIndex.ContainsKey($ci)) { $cpIndex[$ci] } else { "?" }
                        $n = if ($cpIndex.ContainsKey($ni)) { $cpIndex[$ni] } else { "?" }
                        $r.MethodRefs.Add("$c.$n")
                    }
                }
                11 { $off += 4 }
                12 { $off += 4 }
                15 { $off += 3 }
                16 { $off += 2 }
                17 { $off += 4 }
                18 { $off += 4 }
                19 { $off += 2 }
                20 { $off += 2 }
                default { $r.Error = "Unknown tag $tag"; break }
            }
            $i++
        }
        $r.Parsed = $true
    } catch { $r.Error = $_.Exception.Message }
    return $r
}

function Get-ClassFlags {
    param([byte[]]$Bytes)
    $r = [PSCustomObject]@{ IsPublic=$false; IsFinal=$false; IsInterface=$false; IsAbstract=$false; IsSynthetic=$false; IsAnnotation=$false; IsEnum=$false }
    try {
        if ($Bytes.Length -lt 10) { return $r }
        $off = 8
        $cpCount = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]; $off += 2
        $i = 1
        while ($i -lt $cpCount -and $off -lt $Bytes.Length) {
            $tag = [int]$Bytes[$off]; $off++
            switch ($tag) {
                1 { if ($off + 2 -gt $Bytes.Length) { break }; $len = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]; $off += 2 + $len }
                3 { $off += 4 }; 4 { $off += 4 }; 5 { $off += 8; $i++ }; 6 { $off += 8; $i++ }
                7 { $off += 2 }; 8 { $off += 2 }; 9 { $off += 4 }; 10 { $off += 4 }; 11 { $off += 4 }; 12 { $off += 4 }
                15 { $off += 3 }; 16 { $off += 2 }; 17 { $off += 4 }; 18 { $off += 4 }; 19 { $off += 2 }; 20 { $off += 2 }
                default { break }
            }
            $i++
        }
        if ($off + 2 -gt $Bytes.Length) { return $r }
        $flags = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
        $r.IsPublic     = [bool]($flags -band 0x0001)
        $r.IsFinal      = [bool]($flags -band 0x0010)
        $r.IsInterface  = [bool]($flags -band 0x0200)
        $r.IsAbstract   = [bool]($flags -band 0x0400)
        $r.IsSynthetic  = [bool]($flags -band 0x1000)
        $r.IsAnnotation = [bool]($flags -band 0x2000)
        $r.IsEnum       = [bool]($flags -band 0x4000)
    } catch { }
    return $r
}

function Find-SignaturesInClass {
    param($ClassName, $Utf8Strings, $MethodRefs, $FieldRefs, $ClassNames, $DefinitiveFuncs, $SignatureFuncs, $PackageIndicators, $Weights)
    $hits = New-Object System.Collections.Generic.List[object]
    $seen = @{}
    $classPkg = ($ClassName -replace '/[^/]+$','')
    foreach ($pkg in $PackageIndicators) {
        if ($classPkg -match [regex]::Escape($pkg)) {
            $k = "pkg:$pkg"
            if (-not $seen.ContainsKey($k)) {
                $seen[$k] = $true
                $hits.Add([PSCustomObject]@{ Category='Package'; Value=$pkg; Where=$ClassName; Score=$Weights.Package; Detail="Пакет: $classPkg" })
            }
        }
    }
    $shortName = ($ClassName -replace '^.*/','')
    foreach ($def in $DefinitiveFuncs) {
        if ($shortName -match [regex]::Escape($def)) {
            $k = "cls:$def"
            if (-not $seen.ContainsKey($k)) {
                $seen[$k] = $true
                $hits.Add([PSCustomObject]@{ Category='ClassName'; Value=$def; Where=$ClassName; Score=$Weights.ClassName; Detail="Имя класса: '$shortName'" })
            }
        }
    }
    foreach ($str in $Utf8Strings) {
        $sl = $str.ToLower()
        foreach ($def in $DefinitiveFuncs) {
            if ($sl -match $def) {
                $k = "str:$def"
                if (-not $seen.ContainsKey($k)) {
                    $seen[$k] = $true
                    $hits.Add([PSCustomObject]@{ Category='String'; Value=$def; Where=$ClassName; Score=$Weights.Definitive; Detail="UTF8: '$str'" })
                }
            }
        }
        foreach ($sig in $SignatureFuncs) {
            if ($sl -match $sig) {
                $k = "strs:$sig"
                if (-not $seen.ContainsKey($k)) {
                    $seen[$k] = $true
                    $hits.Add([PSCustomObject]@{ Category='Signature'; Value=$sig; Where=$ClassName; Score=$Weights.Signature; Detail="UTF8: '$str'" })
                }
            }
        }
    }
    foreach ($ref in $MethodRefs) {
        $rl = $ref.ToLower()
        foreach ($def in $DefinitiveFuncs) {
            if ($rl -match $def) {
                $k = "mref:$def"
                if (-not $seen.ContainsKey($k)) {
                    $seen[$k] = $true
                    $hits.Add([PSCustomObject]@{ Category='MethodRef'; Value=$def; Where=$ClassName; Score=$Weights.MethodName; Detail="Метод: $ref" })
                }
            }
        }
    }
    foreach ($ref in $FieldRefs) {
        $rl = $ref.ToLower()
        foreach ($def in $DefinitiveFuncs) {
            if ($rl -match $def) {
                $k = "fref:$def"
                if (-not $seen.ContainsKey($k)) {
                    $seen[$k] = $true
                    $hits.Add([PSCustomObject]@{ Category='FieldRef'; Value=$def; Where=$ClassName; Score=$Weights.FieldName; Detail="Поле: $ref" })
                }
            }
        }
    }
    return $hits
}

function Test-ClassObfuscation {
    param([string]$ClassName, $Utf8Strings)
    $score = 0; $reasons = @()
    $shortName = ($ClassName -replace '^.*/','')
    $pkg = ($ClassName -replace '/[^/]+$','')
    if ($shortName -match '^[a-zA-Z_$][a-zA-Z0-9_$]?$') { $score += 2; $reasons += "Короткое имя: '$shortName'" }
    if ($pkg -and $pkg -match '^[a-z](\/[a-z])*$' -and $pkg.Length -lt 8) { $score += 2; $reasons += "Короткий пакет: '$pkg'" }
    if ($Utf8Strings.Count -lt 5) { $score += 1; $reasons += "Мало строк: $($Utf8Strings.Count)" }
    $garbage = 0
    foreach ($s in ($Utf8Strings | Select-Object -First 30)) { if ($s -match '[\x00-\x1F\x7F-\xFF]') { $garbage++ } }
    if ($garbage -gt 5) { $score += 2; $reasons += "Нечитаемые символы: $garbage" }
    $tiny = ($Utf8Strings | Where-Object { $_.Length -le 2 }).Count
    if ($Utf8Strings.Count -gt 0 -and ($tiny / $Utf8Strings.Count) -gt 0.7) { $score += 2; $reasons += "Однобуквенные: $tiny/$($Utf8Strings.Count)" }
    return [PSCustomObject]@{ Score=$score; Reasons=$reasons; IsObfuscated=($score -ge 4) }
}

function Invoke-ClassDeepScan {
    param($ClassName, [byte[]]$Bytes, $DefinitiveFuncs, $SignatureFuncs, $PackageIndicators, $Weights)
    $r = [PSCustomObject]@{ ClassName=$ClassName; Score=0; Hits=@(); ObfuscationScore=0; ObfuscationReasons=@(); Error=$null }
    try {
        $cp = Get-ConstantPool -Bytes $Bytes
        if (-not $cp.Parsed) { $r.Error = $cp.Error; return $r }
        $obf = Test-ClassObfuscation -ClassName $ClassName -Utf8Strings $cp.Utf8Strings
        $r.ObfuscationScore = $obf.Score; $r.ObfuscationReasons = $obf.Reasons
        if ($obf.IsObfuscated) { $r.Score += $Weights.Obfuscated }
        $hits = Find-SignaturesInClass -ClassName $ClassName -Utf8Strings $cp.Utf8Strings -MethodRefs $cp.MethodRefs -FieldRefs $cp.FieldRefs -ClassNames $cp.ClassNames -DefinitiveFuncs $DefinitiveFuncs -SignatureFuncs $SignatureFuncs -PackageIndicators $PackageIndicators -Weights $Weights
        $r.Hits = $hits
        $sum = 0; $sc = @{}
        foreach ($h in $hits) {
            $k = "$($h.Category):$($h.Value)"
            if (-not $sc.ContainsKey($k)) { $sc[$k] = $true; $sum += $h.Score }
        }
        $r.Score += $sum
    } catch { $r.Error = $_.Exception.Message }
    return $r
}

function Invoke-JarDeepScan {
    param($JarPath, $JarFileName, $LauncherName, $DefinitiveFuncs, $SignatureFuncs, $PackageIndicators, $Weights, $Threshold)
    $r = [PSCustomObject]@{
        Path=$JarPath; FileName=$JarFileName; Launcher=$LauncherName
        Score=0; ClassCount=0; ScannedClasses=0; ObfuscatedClasses=0
        TopHits=@(); AllHits=@(); TopOffenders=@(); Error=$null; Duration=0
    }
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)
        $classes = $zip.Entries | Where-Object { $_.FullName -match '\.class$' -and $_.Length -lt 2MB }
        $r.ClassCount = $classes.Count
        $maxClasses = [Math]::Min(3000, $classes.Count)
        $proc = 0; $classScores = @(); $allHits = New-Object System.Collections.Generic.List[object]
        foreach ($entry in $classes) {
            if ($proc -ge $maxClasses) { break }
            $proc++
            try {
                $s = $entry.Open(); $ms = New-Object System.IO.MemoryStream
                $s.CopyTo($ms); $bytes = $ms.ToArray(); $s.Close(); $ms.Close()
                if ($bytes.Length -lt 10 -or $bytes.Length -gt 2MB) { continue }
                $className = $entry.FullName -replace '\.class$',''
                $scan = Invoke-ClassDeepScan -ClassName $className -Bytes $bytes -DefinitiveFuncs $DefinitiveFuncs -SignatureFuncs $SignatureFuncs -PackageIndicators $PackageIndicators -Weights $Weights
                $r.ScannedClasses++
                if ($scan.ObfuscationScore -ge 4) { $r.ObfuscatedClasses++ }
                if ($scan.Score -gt 0) {
                    $classScores += [PSCustomObject]@{ Class=$className; Score=$scan.Score; Hits=$scan.Hits }
                    foreach ($h in $scan.Hits) { $allHits.Add($h) }
                }
            } catch { }
        }
        $zip.Dispose()
        $total = 0; $uniq = @{}
        foreach ($h in $allHits) {
            $k = "$($h.Category):$($h.Value)"
            if (-not $uniq.ContainsKey($k)) { $uniq[$k] = $true; $total += $h.Score }
        }
        $r.Score = $total
        $r.TopOffenders = $classScores | Sort-Object Score -Descending | Select-Object -First 10
        $r.TopHits = $allHits | Group-Object Category, Value | ForEach-Object {
            [PSCustomObject]@{ Category=$_.Group[0].Category; Value=$_.Group[0].Value; Score=$_.Group[0].Score; Detail=$_.Group[0].Detail; Count=$_.Count }
        } | Sort-Object Score, Count -Descending | Select-Object -First 15
        $r.AllHits = $allHits
        if ($r.ClassCount -gt 20 -and ($r.ObfuscatedClasses / $r.ClassCount) -gt 0.5) { $r.Score += $Weights.Obfuscated }
    } catch { $r.Error = $_.Exception.Message }
    $timer.Stop(); $r.Duration = $timer.ElapsedMilliseconds
    if ($r.Score -lt $Threshold) { $r.TopHits = @(); $r.AllHits = @(); $r.TopOffenders = @() }
    return $r
}

function Invoke-JarDeepScanParallel {
    param([array]$Jars, [int]$Threads = 8, [int]$Threshold = 5)
    if (-not $Jars -or $Jars.Count -eq 0) { return @() }
    $cpu = [Environment]::ProcessorCount
    $actualThreads = [Math]::Max(1, [Math]::Min($cpu, $Threads))
    Write-Log "Deep Scan: $($Jars.Count) JAR, потоков: $actualThreads" "INFO"

    $pool = [RunspaceFactory]::CreateRunspacePool(1, $actualThreads)
    $pool.Open()

    $funcDefs = @(
        (Get-Item function:Invoke-JarDeepScan).Definition,
        (Get-Item function:Invoke-ClassDeepScan).Definition,
        (Get-Item function:Get-ConstantPool).Definition,
        (Get-Item function:Get-ClassFlags).Definition,
        (Get-Item function:Find-SignaturesInClass).Definition,
        (Get-Item function:Test-ClassObfuscation).Definition
    )

    $jobs = @()
    foreach ($jar in $Jars) {
        $ps = [PowerShell]::Create()
        $ps.RunspacePool = $pool
        $cmd = $ps.AddScript({
            param($JarPath, $JarFileName, $LauncherName, $Def, $Sig, $Pkg, $Weights, $Thr, $FuncDefs)
            foreach ($fd in $FuncDefs) { . ([ScriptBlock]::Create($fd)) }
            Invoke-JarDeepScan -JarPath $JarPath -JarFileName $JarFileName -LauncherName $LauncherName -DefinitiveFuncs $Def -SignatureFuncs $Sig -PackageIndicators $Pkg -Weights $Weights -Threshold $Thr
        })
        [void]$cmd.AddArgument($jar.FullPath)
        [void]$cmd.AddArgument($jar.FileName)
        [void]$cmd.AddArgument($jar.Launcher)
        [void]$cmd.AddArgument($Script:DefinitiveFuncs)
        [void]$cmd.AddArgument($Script:SignatureFuncs)
        [void]$cmd.AddArgument($Script:PackageIndicators)
        [void]$cmd.AddArgument($Script:SignatureWeights)
        [void]$cmd.AddArgument($Threshold)
        [void]$cmd.AddArgument($funcDefs)
        $jobs += [PSCustomObject]@{ PS=$ps; Handle=$ps.BeginInvoke(); Jar=$jar }
    }
    $results = New-Object System.Collections.Generic.List[object]
    $done = 0; $flagged = 0
    foreach ($job in $jobs) {
        try {
            $res = $job.PS.EndInvoke($job.Handle)
            $done++
            if ($res) {
                $results.Add($res)
                if ($res.Score -ge $Threshold) { $flagged++ }
            }
            $pct = [math]::Round(($done / $jobs.Count) * 100)
            $line = "  [Deep $pct%] $done/$($jobs.Count) — флагов: $flagged"
            Write-Host "`r$($line.PadRight(120))" -NoNewline -ForegroundColor DarkGray
        } catch { Write-Log "Deep ошибка $($job.Jar.FileName): $_" "WARN" }
        finally { $job.PS.Dispose() }
    }
    Write-Host ""
    $pool.Close(); $pool.Dispose()
    Write-Log "Deep Scan завершён: $($results.Count) JAR, флагов: $flagged" "INFO"
    return $results
}

function Show-DeepScanResults {
    param([array]$Results, [int]$Threshold = 5)
    if (-not $Results -or $Results.Count -eq 0) { Write-Log "Deep: результатов нет." "OK"; return }
    $flagged = $Results | Where-Object { $_.Score -ge $Threshold } | Sort-Object Score -Descending
    $clean = $Results.Count - $flagged.Count
    Write-Host ""
    Write-Host "  ┌─── DEEP SCAN ────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "  │ JAR:              $($Results.Count)" -ForegroundColor White
    Write-Host "  │ Чистых:           $clean" -ForegroundColor Green
    Write-Host "  │ Подозрительных:   $($flagged.Count)" -ForegroundColor $(if ($flagged.Count -gt 0) { "Red" } else { "Green" })
    Write-Host "  └──────────────────────────────────────────────────" -ForegroundColor Cyan
    if ($flagged.Count -eq 0) { Write-Log "Читов не обнаружено." "OK"; return }
    $top = $flagged | Select-Object -First 30
    foreach ($r in $top) {
        Write-Host ""
        $color = if ($r.Score -ge 30) { "Red" } elseif ($r.Score -ge 15) { "Magenta" } else { "Yellow" }
        Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $color
        Write-Host "  ║ ЧИТ: $($r.FileName)" -ForegroundColor $color
        Write-Host "  ║ Score: $($r.Score) | Классов: $($r.ScannedClasses)/$($r.ClassCount) | Обфусцировано: $($r.ObfuscatedClasses) | $($r.Duration)ms" -ForegroundColor $color
        Write-Host "  ║ Путь: $($r.Path)" -ForegroundColor DarkGray
        Write-Host "  ║ Лаунчер: $($r.Launcher)" -ForegroundColor DarkGray
        Write-Host "  ╠══════════════════════════════════════════════════════════════╣" -ForegroundColor $color
        foreach ($h in $r.TopHits | Select-Object -First 8) {
            Write-Host "  ║   [$($h.Category)] +$($h.Score) × $($h.Count): $($h.Value)" -ForegroundColor $color
            Write-Host "  ║     $($h.Detail)" -ForegroundColor DarkGray
        }
        if ($r.TopOffenders.Count -gt 0) {
            Write-Host "  ║ Классы-нарушители:" -ForegroundColor $color
            foreach ($off in $r.TopOffenders | Select-Object -First 3) {
                Write-Host "  ║   • $($off.Class) (score=$($off.Score))" -ForegroundColor DarkRed
            }
        }
        Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $color
        $Script:Report.Add("ЧИТ: $($r.Path) [score=$($r.Score), $($r.ObfuscatedClasses)/$($r.ClassCount) обфусцировано]")
        foreach ($h in $r.TopHits | Select-Object -First 5) {
            $Script:Report.Add("  [$($h.Category)] $($h.Value) — $($h.Detail)")
        }
    }
    if ($flagged.Count -gt $top.Count) {
        Write-Host ""
        Write-Host "  ... и ещё $($flagged.Count - $top.Count) подозрительных JAR" -ForegroundColor Yellow
    }
}

# ═══════════════════════════════════════════════════════════════════════
#  >>> PART A ЗАКОНЧЕН. Продолжение — Part B (Part 3+4 + всё остальное) <<<
# ═══════════════════════════════════════════════════════════════════════
Write-Host "  >>> PART A LOADED (ожидается Part B) <<<" -ForegroundColor Magenta
# ╔══════════════════════════════════════════════════════════════════════╗
# ║  PART 3 — NETWORK + NATIVE + NESTED + DANGEROUS                      ║
# ╚══════════════════════════════════════════════════════════════════════╝

$Script:SuspiciousDomains = @(
    'vape.gg','vape.rip','vapeclient','impactclient','wurstclient','sigma-client',
    'sigmaclient','meteorclient','aristois','liquidbounce','futureclient',
    'konas','zeusclient','richclient','novoline','astolfo','moonlight',
    'doomsday','nightware','extazyy','zamorozka','nursultan',
    'pastebin.com','hastebin.com','paste.ee','ghostbin.co','dpaste.org',
    'transfer.sh','file.io','anonfiles.com','0x0.st','termbin.com',
    'discord.com/api/webhooks','discordapp.com/api/webhooks',
    'ptb.discord.com/api/webhooks','canary.discord.com/api/webhooks',
    'api.telegram.org/bot',
    'iplogger.org','iplogger.com','2no.co','yip.su','iplogger.ru',
    'grabify.link','blasze.tk','iplogger.co','iplogger.info',
    'branchlock.net','zelix.com','stringfog','skidfuscator',
    'qprotect','bozar','paramorphism','reversing.zone'
)
$Script:DangerousPatterns = @{
    'Runtime.exec'          = 'Выполнение команд ОС'
    'ProcessBuilder'        = 'Создание процесса'
    'System.loadLibrary'    = 'Загрузка нативной библиотеки'
    'System.load'           = 'Загрузка нативной библиотеки'
    'URLClassLoader'        = 'Загрузка класса из URL'
    'defineClass'           = 'Динамическое определение класса'
    'Class.forName'         = 'Рефлексия — загрузка класса'
    'setAccessible(true)'   = 'Обход модификаторов доступа'
    'java/lang/Runtime'     = 'Ссылка на Runtime'
    'java/lang/reflect'     = 'Ссылка на reflection'
    'sun/misc/Unsafe'       = 'Unsafe — доступ к памяти'
    'jdk/internal/misc'     = 'Внутренние API JDK'
    'Instrumentation'       = 'Java-agent (инъекция)'
    'VirtualMachine.attach' = 'Присоединение к JVM'
    'Cipher.getInstance'    = 'Криптография (шифрование строк)'
    'Base64.getDecoder'     = 'Base64 (скрытие строк)'
    'gzip'                  = 'Сжатие (упаковка)'
    'InflaterInputStream'   = 'Распаковка вложенных данных'
}
$Script:NativeExtensions = @('.dll','.so','.dylib','.jnilib','.node')

function Find-NetworkStrings {
    param([array]$Utf8Strings)
    $r = [PSCustomObject]@{
        URLs=@(); IPs=@(); Domains=@(); Suspicious=@()
        DiscordWebhooks=@(); TelegramBots=@(); PastebinLinks=@(); Score=0
    }
    $seenU = @{}; $seenI = @{}; $seenD = @{}
    $urlRe = 'https?://[^\s"''<>)\]}]+'
    $ipRe  = '\b(?:\d{1,3}\.){3}\d{1,3}\b'
    $domRe = '\b[a-z0-9][a-z0-9\-]{0,62}(?:\.[a-z0-9\-]{1,62})+\.[a-z]{2,24}\b'
    foreach ($str in $Utf8Strings) {
        foreach ($m in [regex]::Matches($str, $urlRe, 'IgnoreCase')) {
            $u = $m.Value
            if (-not $seenU.ContainsKey($u) -and $r.URLs.Count -lt 100) { $seenU[$u]=$true; $r.URLs += $u }
        }
        foreach ($m in [regex]::Matches($str, $ipRe)) {
            $ip = $m.Value
            if ($ip -match '^(0\.|127\.|255\.|10\.|192\.168\.)') { continue }
            if ($ip -match '^[12]\.\d+\.\d+$') { continue }
            if (-not $seenI.ContainsKey($ip) -and $r.IPs.Count -lt 50) { $seenI[$ip]=$true; $r.IPs += $ip }
        }
        foreach ($m in [regex]::Matches($str, $domRe, 'IgnoreCase')) {
            $d = $m.Value.ToLower()
            if (-not $seenD.ContainsKey($d) -and $r.Domains.Count -lt 100) { $seenD[$d]=$true; $r.Domains += $d }
        }
        $sl = $str.ToLower()
        foreach ($susp in $Script:SuspiciousDomains) {
            if ($sl -match [regex]::Escape($susp)) { $r.Suspicious += "$susp ← $str"; $r.Score += 10 }
        }
        if ($str -match 'discord(?:app)?\.com/api/webhooks/\d+/[\w\-]+') { $r.DiscordWebhooks += $str; $r.Score += 30 }
        if ($str -match 'api\.telegram\.org/bot[\d]+:[\w\-]+') { $r.TelegramBots += $str; $r.Score += 30 }
        if ($str -match 'pastebin\.com/(raw/)?[\w]+') { $r.PastebinLinks += $str; $r.Score += 15 }
    }
    return $r
}

function Find-NativeLibs {
    param([System.IO.Compression.ZipArchive]$Zip)
    $r = [PSCustomObject]@{ NativeFiles=@(); Score=0 }
    foreach ($entry in $Zip.Entries) {
        $ext = [System.IO.Path]::GetExtension($entry.FullName).ToLower()
        if ($Script:NativeExtensions -contains $ext) {
            $r.NativeFiles += [PSCustomObject]@{ Name=$entry.FullName; Size=$entry.Length }
            if ($entry.Length -lt 5MB) { $r.Score += 15 } else { $r.Score += 8 }
        }
    }
    return $r
}

function Find-NestedJars {
    param([System.IO.Compression.ZipArchive]$Zip, [int]$CurrentDepth = 1, [int]$MaxDepth = 3)
    $r = [PSCustomObject]@{ NestedJars=@(); Score=0 }
    foreach ($entry in $Zip.Entries) {
        if ($entry.FullName -match '\.(jar|zip)$' -and $entry.Length -gt 100 -and $entry.Length -lt 20MB) {
            $r.NestedJars += [PSCustomObject]@{ Name=$entry.FullName; Size=$entry.Length; Depth=$CurrentDepth }
            if ($CurrentDepth -ge 2) { $r.Score += 20 } else { $r.Score += 5 }
            if ($CurrentDepth -lt $MaxDepth) {
                try {
                    $s = $entry.Open(); $ms = New-Object System.IO.MemoryStream
                    $s.CopyTo($ms); $ms.Position = 0
                    $inner = New-Object System.IO.Compression.ZipArchive($ms, [System.IO.Compression.ZipArchiveMode]::Read)
                    $innerRes = Find-NestedJars -Zip $inner -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth
                    foreach ($n in $innerRes.NestedJars) { $r.NestedJars += $n }
                    $r.Score += $innerRes.Score
                    $inner.Dispose(); $s.Close(); $ms.Close()
                } catch { }
            }
        }
    }
    return $r
}

function Find-DangerousPatterns {
    param([array]$Utf8Strings, [array]$MethodRefs, [array]$ClassNames)
    $r = [PSCustomObject]@{ Hits=@(); Score=0 }
    $seen = @{}
    $allText = ($Utf8Strings + $MethodRefs + $ClassNames) -join ' '
    foreach ($pattern in $Script:DangerousPatterns.Keys) {
        if ($allText -match [regex]::Escape($pattern)) {
            $k = "dp:$pattern"
            if (-not $seen.ContainsKey($k)) {
                $seen[$k] = $true
                $r.Hits += [PSCustomObject]@{ Pattern=$pattern; Desc=$Script:DangerousPatterns[$pattern] }
                switch ($pattern) {
                    'Runtime.exec'          { $r.Score += 15 }
                    'ProcessBuilder'        { $r.Score += 15 }
                    'System.loadLibrary'    { $r.Score += 20 }
                    'System.load'           { $r.Score += 20 }
                    'URLClassLoader'        { $r.Score += 25 }
                    'defineClass'           { $r.Score += 25 }
                    'setAccessible(true)'   { $r.Score += 10 }
                    'sun/misc/Unsafe'       { $r.Score += 20 }
                    'VirtualMachine.attach' { $r.Score += 25 }
                    'Instrumentation'       { $r.Score += 15 }
                    default                 { $r.Score += 5 }
                }
            }
        }
    }
    return $r
}

function Invoke-JarAuxScan {
    param($JarPath, $JarFileName, $LauncherName)
    $r = [PSCustomObject]@{
        Path=$JarPath; FileName=$JarFileName; Launcher=$LauncherName
        Network=$null; Native=$null; Nested=$null; Dangerous=$null
        TotalScore=0; Error=$null; Duration=0
    }
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)
        $allUtf8 = New-Object System.Collections.Generic.List[string]
        $allMRef = New-Object System.Collections.Generic.List[string]
        $allCN   = New-Object System.Collections.Generic.List[string]
        $classes = $zip.Entries | Where-Object { $_.FullName -match '\.class$' -and $_.Length -lt 2MB }
        $proc = 0; $maxC = [Math]::Min(1500, $classes.Count)
        foreach ($entry in $classes) {
            if ($proc -ge $maxC) { break }
            $proc++
            try {
                $s = $entry.Open(); $ms = New-Object System.IO.MemoryStream
                $s.CopyTo($ms); $bytes = $ms.ToArray(); $s.Close(); $ms.Close()
                if ($bytes.Length -lt 10) { continue }
                $cp = Get-ConstantPool -Bytes $bytes -MaxStrings 3000 -MaxRefs 500
                if ($cp.Parsed) {
                    foreach ($x in $cp.Utf8Strings) { $allUtf8.Add($x) }
                    foreach ($x in $cp.MethodRefs)  { $allMRef.Add($x) }
                    foreach ($x in $cp.ClassNames)  { $allCN.Add($x) }
                }
            } catch { }
        }
        $r.Network   = Find-NetworkStrings -Utf8Strings $allUtf8
        $r.TotalScore += $r.Network.Score
        $r.Native    = Find-NativeLibs -Zip $zip
        $r.TotalScore += $r.Native.Score
        if ($zip.Entries.Count -lt 5000) {
            $r.Nested = Find-NestedJars -Zip $zip -CurrentDepth 1 -MaxDepth 3
            $r.TotalScore += $r.Nested.Score
        } else {
            $r.Nested = [PSCustomObject]@{ NestedJars=@(); Score=0 }
        }
        $r.Dangerous = Find-DangerousPatterns -Utf8Strings $allUtf8 -MethodRefs $allMRef -ClassNames $allCN
        $r.TotalScore += $r.Dangerous.Score
        $zip.Dispose()
    } catch { $r.Error = $_.Exception.Message }
    $timer.Stop(); $r.Duration = $timer.ElapsedMilliseconds
    return $r
}

function Invoke-JarAuxScanParallel {
    param([array]$Jars, [int]$Threads = 8)
    if (-not $Jars -or $Jars.Count -eq 0) { return @() }
    $cpu = [Environment]::ProcessorCount
    $n = [Math]::Max(1, [Math]::Min($cpu, $Threads))
    Write-Log "Aux Scan: $($Jars.Count) JAR, потоков: $n" "INFO"
    $pool = [RunspaceFactory]::CreateRunspacePool(1, $n); $pool.Open()
    $funcDefs = @(
        (Get-Item function:Invoke-JarAuxScan).Definition,
        (Get-Item function:Get-ConstantPool).Definition,
        (Get-Item function:Find-NetworkStrings).Definition,
        (Get-Item function:Find-NativeLibs).Definition,
        (Get-Item function:Find-NestedJars).Definition,
        (Get-Item function:Find-DangerousPatterns).Definition
    )
    $suspJoin = ($Script:SuspiciousDomains -join '","')
    $dpJoin = ($Script:DangerousPatterns.Keys | ForEach-Object { "'$_' = '$($Script:DangerousPatterns[$_])';" }) -join ''
    $natJoin = ($Script:NativeExtensions -join '","')
    $constSetup = "`$Script:SuspiciousDomains = @(`"$suspJoin`"); `$Script:DangerousPatterns = @{$dpJoin}; `$Script:NativeExtensions = @(`"$natJoin`");"
    $jobs = @()
    foreach ($jar in $Jars) {
        $ps = [PowerShell]::Create()
        $ps.RunspacePool = $pool
        $cmd = $ps.AddScript({
            param($JarPath, $JarFileName, $LauncherName, $FuncDefs, $ConstSetup)
            . ([ScriptBlock]::Create($ConstSetup))
            foreach ($fd in $FuncDefs) { . ([ScriptBlock]::Create($fd)) }
            Invoke-JarAuxScan -JarPath $JarPath -JarFileName $JarFileName -LauncherName $LauncherName
        })
        [void]$cmd.AddArgument($jar.FullPath)
        [void]$cmd.AddArgument($jar.FileName)
        [void]$cmd.AddArgument($jar.Launcher)
        [void]$cmd.AddArgument($funcDefs)
        [void]$cmd.AddArgument($constSetup)
        $jobs += [PSCustomObject]@{ PS=$ps; Handle=$ps.BeginInvoke(); Jar=$jar }
    }
    $results = New-Object System.Collections.Generic.List[object]
    $done = 0
    foreach ($job in $jobs) {
        try {
            $res = $job.PS.EndInvoke($job.Handle)
            $done++
            if ($res) { $results.Add($res) }
            $pct = [math]::Round(($done / $jobs.Count) * 100)
            $line = "  [Aux $pct%] $done/$($jobs.Count)"
            Write-Host "`r$($line.PadRight(120))" -NoNewline -ForegroundColor DarkCyan
        } catch { Write-Log "Aux ошибка: $_" "WARN" }
        finally { $job.PS.Dispose() }
    }
    Write-Host ""
    $pool.Close(); $pool.Dispose()
    return $results
}

function Show-AuxScanResults {
    param([array]$Results)
    if (-not $Results -or $Results.Count -eq 0) { return }
    $flag = $Results | Where-Object { $_.TotalScore -gt 0 } | Sort-Object TotalScore -Descending
    Write-Host ""
    Write-Host "  ┌─── AUX SCAN ──────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "  │ Всего:            $($Results.Count)" -ForegroundColor White
    Write-Host "  │ С находками:      $($flag.Count)" -ForegroundColor $(if ($flag.Count -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  └───────────────────────────────────────────────────" -ForegroundColor Cyan
    if ($flag.Count -eq 0) { return }
    $net = $flag | Where-Object { $_.Network -and ($_.Network.Suspicious.Count -gt 0 -or $_.Network.DiscordWebhooks.Count -gt 0 -or $_.Network.TelegramBots.Count -gt 0) }
    if ($net.Count -gt 0) {
        Write-Host ""
        Write-Host "  ═══ NETWORK STRINGS ═══" -ForegroundColor Yellow
        foreach ($r in $net | Select-Object -First 15) {
            Write-Host "  [?] $($r.FileName) — network score: $($r.Network.Score)" -ForegroundColor Yellow
            foreach ($w in $r.Network.DiscordWebhooks | Select-Object -First 2) {
                Write-Host "      [!!!] DISCORD WEBHOOK: $w" -ForegroundColor Red
                $Script:Report.Add("DISCORD WEBHOOK в $($r.FileName): $w")
            }
            foreach ($t in $r.Network.TelegramBots | Select-Object -First 2) {
                Write-Host "      [!!!] TG BOT: $t" -ForegroundColor Red
                $Script:Report.Add("TG BOT в $($r.FileName): $t")
            }
            foreach ($s in $r.Network.Suspicious | Select-Object -First 5) {
                Write-Host "      [!] $s" -ForegroundColor DarkRed
            }
        }
    }
    $nat = $flag | Where-Object { $_.Native -and $_.Native.NativeFiles.Count -gt 0 }
    if ($nat.Count -gt 0) {
        Write-Host ""
        Write-Host "  ═══ NATIVE LIBS ═══" -ForegroundColor Yellow
        foreach ($r in $nat | Select-Object -First 10) {
            Write-Host "  [!] $($r.FileName) — нативов: $($r.Native.NativeFiles.Count)" -ForegroundColor Yellow
            foreach ($n in $r.Native.NativeFiles | Select-Object -First 3) {
                $kb = [math]::Round($n.Size / 1KB, 1)
                Write-Host "      • $($n.Name) ($kb KB)" -ForegroundColor DarkYellow
            }
        }
    }
    $nst = $flag | Where-Object { $_.Nested -and $_.Nested.NestedJars.Count -gt 0 }
    if ($nst.Count -gt 0) {
        Write-Host ""
        Write-Host "  ═══ NESTED JARS ═══" -ForegroundColor Yellow
        foreach ($r in $nst | Select-Object -First 10) {
            Write-Host "  [?] $($r.FileName) — вложенных: $($r.Nested.NestedJars.Count)" -ForegroundColor Yellow
            foreach ($n in $r.Nested.NestedJars | Select-Object -First 3) {
                $mb = [math]::Round($n.Size / 1MB, 2)
                Write-Host "      • depth=$($n.Depth): $($n.Name) ($mb MB)" -ForegroundColor DarkYellow
            }
        }
    }
    $dng = $flag | Where-Object { $_.Dangerous -and $_.Dangerous.Hits.Count -gt 0 }
    if ($dng.Count -gt 0) {
        Write-Host ""
        Write-Host "  ═══ DANGEROUS PATTERNS ═══" -ForegroundColor Yellow
        foreach ($r in $dng | Select-Object -First 10) {
            Write-Host "  [!] $($r.FileName) — score: $($r.Dangerous.Score)" -ForegroundColor Yellow
            foreach ($h in $r.Dangerous.Hits | Select-Object -First 5) {
                Write-Host "      • $($h.Pattern) — $($h.Desc)" -ForegroundColor DarkYellow
            }
            $Script:Report.Add("Dangerous в $($r.FileName): $($r.Dangerous.Hits.Count)")
        }
    }
}

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  PART 4 — EVERYTHING DIAGNOSTIC + FALLBACK                           ║
# ╚══════════════════════════════════════════════════════════════════════╝

$Script:FallbackSearchPaths = @(
    "$env:APPDATA\.minecraft","$env:APPDATA\.tlauncher","$env:USERPROFILE\.lunarclient",
    "$env:APPDATA\Badlion Client","$env:APPDATA\Feather","$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Desktop","$env:USERPROFILE\Documents","$env:LOCALAPPDATA\Temp",
    "$env:APPDATA","$env:LOCALAPPDATA","C:\ProgramData","C:\Games","D:\Games",
    "C:\Minecraft","D:\Minecraft"
) | Where-Object { Test-Path $_ -ErrorAction SilentlyContinue }

$Script:FallbackSkipPaths = @(
    '\\Windows\\WinSxS\\','\\Windows\\System32\\DriverStore\\','\\Windows\\servicing\\',
    '\\\$Recycle\.Bin\\','\\System Volume Information\\','\\node_modules\\',
    '\\\.git\\','\\\.gradle\\caches\\','\\\.m2\\repository\\','\\\.ivy2\\cache\\',
    '\\AppData\\Local\\Packages\\','\\AppData\\Local\\Microsoft\\Edge\\',
    '\\AppData\\Local\\Google\\Chrome\\','\\AppData\\Local\\Mozilla\\Firefox\\'
)
$Script:TargetExtensions = @('.exe','.jar','.zip','.rar','.dll','.7z')

if (-not $Script:EverythingState) {
    $Script:EverythingState = [PSCustomObject]@{
        ProcessRunning=$false; ProcessPids=@(); ProcessPath=$null
        ServiceInstalled=$false; ServiceRunning=$false; ServiceName=$null
        EsPath=$null; EsVersion=$null; EverythingVersion=$null
        IndexedDrives=@(); NonIndexedDrives=@()
        SearchWorking=$false; TestSearchCount=0
        IsAdmin=$false; Diagnosis=@(); LastError=$null
    }
}

function Test-EverythingProcess {
    $procs = Get-Process -Name "Everything" -ErrorAction SilentlyContinue
    if ($procs) {
        $Script:EverythingState.ProcessRunning = $true
        $Script:EverythingState.ProcessPids = @($procs | ForEach-Object { $_.Id })
        $Script:EverythingState.ProcessPath = $procs[0].Path
        $Script:EverythingState.Diagnosis += "[OK] Everything.exe запущен (PID: $($Script:EverythingState.ProcessPids -join ','))"
        return $true
    }
    $Script:EverythingState.Diagnosis += "[WARN] Everything.exe не запущен"
    return $false
}

function Test-EverythingService {
    $svc = Get-Service -Name "Everything" -ErrorAction SilentlyContinue
    if ($svc) {
        $Script:EverythingState.ServiceInstalled = $true
        $Script:EverythingState.ServiceName = $svc.Name
        $Script:EverythingState.ServiceRunning = ($svc.Status -eq 'Running')
        $Script:EverythingState.Diagnosis += "[OK] Служба Everything: $($svc.Status)"
    } else {
        $Script:EverythingState.Diagnosis += "[i] Служба Everything не установлена"
    }
}

function Find-EsExe {
    $cands = @(
        "$env:LOCALAPPDATA\Everything\es.exe","C:\Program Files\Everything\es.exe",
        "C:\Program Files (x86)\Everything\es.exe","$env:USERPROFILE\Downloads\Everything\es.exe"
    )
    foreach ($c in $cands) {
        if (Test-Path $c) { $Script:EverythingState.EsPath = $c; return $c }
    }
    $cmd = Get-Command "es.exe" -ErrorAction SilentlyContinue
    if ($cmd) { $Script:EverythingState.EsPath = $cmd.Source; return $cmd.Source }
    return $null
}

function Get-EverythingVersions {
    if (-not $Script:EverythingState.EsPath) { return }
    try {
        $v = & $Script:EverythingState.EsPath -version 2>&1
        if ($LASTEXITCODE -eq 0 -and $v) {
            $Script:EverythingState.EsVersion = "$v".Trim()
            $Script:EverythingState.Diagnosis += "[OK] es.exe: $($Script:EverythingState.EsVersion)"
        }
    } catch { }
}

function Test-EverythingIndexing {
    if (-not $Script:EverythingState.EsPath) { return }
    $Script:EverythingState.IndexedDrives = @()
    $Script:EverythingState.NonIndexedDrives = @()
    foreach ($d in (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 })) {
        $root = "$($d.Name):\"
        try {
            $probe = & $Script:EverythingState.EsPath -path $root -n 1 2>$null
            if ($probe -and $probe.Count -gt 0) {
                $Script:EverythingState.IndexedDrives += $root
                $Script:EverythingState.Diagnosis += "[OK] $root индексирован"
            } else {
                $Script:EverythingState.NonIndexedDrives += $root
                $Script:EverythingState.Diagnosis += "[WARN] $root НЕ индексирован"
            }
        } catch { $Script:EverythingState.NonIndexedDrives += $root }
    }
}

function Test-EverythingSearchWorking {
    if (-not $Script:EverythingState.EsPath) { return }
    try {
        $r = & $Script:EverythingState.EsPath -n 5 "*.exe" 2>$null
        if ($r -and $r.Count -gt 0) {
            $Script:EverythingState.SearchWorking = $true
            $Script:EverythingState.TestSearchCount = $r.Count
            $Script:EverythingState.Diagnosis += "[OK] Тест-поиск: $($r.Count) результатов"
        } else {
            $Script:EverythingState.Diagnosis += "[WARN] Тест-поиск вернул 0 — индекс пуст"
        }
    } catch { }
}

function Start-EverythingProcessIfNeeded {
    if ($Script:EverythingState.ProcessRunning) { return $true }
    $cands = @(
        "C:\Program Files\Everything\Everything.exe",
        "C:\Program Files (x86)\Everything\Everything.exe",
        "$env:LOCALAPPDATA\Everything\Everything.exe"
    )
    $exe = $cands | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $exe) {
        $dir = "$env:LOCALAPPDATA\Everything"
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        $zip = "$env:TEMP\EverythingPortable.zip"
        try {
            Invoke-WebRequest -Uri "https://www.voidtools.com/Everything-1.4.1.1026.x64.zip" -OutFile $zip -UseBasicParsing -TimeoutSec 60
            Expand-Archive -Path $zip -DestinationPath $dir -Force
            Remove-Item $zip -Force -ErrorAction SilentlyContinue
            $exe = Join-Path $dir "Everything.exe"
        } catch { return $false }
    }
    try {
        Start-Process $exe -ArgumentList "-startup" -WindowStyle Minimized
        for ($i = 0; $i -lt 20; $i++) {
            Start-Sleep -Seconds 1
            if (Get-Process Everything -ErrorAction SilentlyContinue) { break }
        }
        Start-Sleep -Seconds 3
        return (Test-EverythingProcess)
    } catch { return $false }
}

function Invoke-EverythingDiagnostic {
    Write-Log "=== ДИАГНОСТИКА EVERYTHING ===" "TITLE"
    $Script:EverythingState.Diagnosis = @()
    $Script:EverythingState.IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($Script:EverythingState.IsAdmin) { $Script:EverythingState.Diagnosis += "[OK] Администратор" }
    else { $Script:EverythingState.Diagnosis += "[WARN] НЕ администратор" }
    Test-EverythingProcess | Out-Null
    if (-not $Script:EverythingState.ProcessRunning) { Start-EverythingProcessIfNeeded | Out-Null }
    Test-EverythingService
    Find-EsExe | Out-Null
    if (-not $Script:EverythingState.EsPath) {
        Write-Log "es.exe не найден — fallback будет использован" "WARN"
        return $Script:EverythingState
    }
    Get-EverythingVersions
    Test-EverythingIndexing
    Test-EverythingSearchWorking
    return $Script:EverythingState
}

function Show-EverythingDiagnostic {
    param($State)
    if (-not $State) { $State = $Script:EverythingState }
    Write-Host ""
    Write-Host "  ┌─── EVERYTHING DIAGNOSTIC ─────────────────────────────" -ForegroundColor Cyan
    Write-Host "  │ Process:      $(if ($State.ProcessRunning) { "RUNNING ($($State.ProcessPids -join ','))" } else { "NOT RUNNING" })" -ForegroundColor $(if ($State.ProcessRunning) { "Green" } else { "Red" })
    Write-Host "  │ Service:      $(if ($State.ServiceInstalled) { if ($State.ServiceRunning) { "RUNNING" } else { "STOPPED" } } else { "не установлена" })" -ForegroundColor $(if ($State.ServiceRunning) { "Green" } else { "Yellow" })
    Write-Host "  │ es.exe:       $(if ($State.EsPath) { $State.EsPath } else { "НЕ НАЙДЕН" })" -ForegroundColor $(if ($State.EsPath) { "Green" } else { "Red" })
    Write-Host "  │ es версия:    $(if ($State.EsVersion) { $State.EsVersion } else { "—" })" -ForegroundColor White
    Write-Host "  │ Indexed:      $($State.IndexedDrives.Count) — $($State.IndexedDrives -join ', ')" -ForegroundColor $(if ($State.IndexedDrives.Count -gt 0) { "Green" } else { "Red" })
    Write-Host "  │ Non-indexed:  $($State.NonIndexedDrives.Count) — $($State.NonIndexedDrives -join ', ')" -ForegroundColor $(if ($State.NonIndexedDrives.Count -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  │ Test search:  $(if ($State.SearchWorking) { "OK ($($State.TestSearchCount))" } else { "ПУСТО" })" -ForegroundColor $(if ($State.SearchWorking) { "Green" } else { "Red" })
    Write-Host "  ├───────────────────────────────────────────────────────" -ForegroundColor Cyan
    foreach ($line in $State.Diagnosis) {
        $c = "Gray"
        if ($line -match '^\[OK\]')   { $c = "Green" }
        if ($line -match '^\[WARN\]') { $c = "Yellow" }
        if ($line -match '^\[ERR\]')  { $c = "Red" }
        Write-Host "  │ $line" -ForegroundColor $c
    }
    Write-Host "  └───────────────────────────────────────────────────────" -ForegroundColor Cyan
}

function Invoke-FileSystemSearchFallback {
    param([string[]]$Patterns, [int]$MaxResults = 500, [int]$MaxDepth = 8)
    Write-Log "Fallback: Get-ChildItem по ключевым папкам..." "INFO"
    $results = New-Object System.Collections.Generic.List[string]
    $regex = ($Patterns | ForEach-Object { [regex]::Escape($_) }) -join '|'
    foreach ($base in $Script:FallbackSearchPaths) {
        if ($results.Count -ge $MaxResults) { break }
        if (-not (Test-Path $base -ErrorAction SilentlyContinue)) { continue }
        Write-Host "`r  [FS] $base ($($results.Count))" -NoNewline -ForegroundColor DarkGray
        $stack = New-Object System.Collections.Stack
        $stack.Push(@{ Path=$base; Depth=0 })
        while ($stack.Count -gt 0 -and $results.Count -lt $MaxResults) {
            $cur = $stack.Pop()
            if ($cur.Depth -gt $MaxDepth) { continue }
            try {
                $files = Get-ChildItem -Path $cur.Path -File -ErrorAction SilentlyContinue -Force |
                         Where-Object { $Script:TargetExtensions -contains $_.Extension.ToLower() -and $_.Name -match $regex }
                foreach ($f in $files) {
                    if ($results.Count -ge $MaxResults) { break }
                    $results.Add($f.FullName)
                }
                $dirs = Get-ChildItem -Path $cur.Path -Directory -ErrorAction SilentlyContinue -Force
                foreach ($d in $dirs) {
                    $skip = $false
                    foreach ($skp in $Script:FallbackSkipPaths) { if ($d.FullName -match $skp) { $skip = $true; break } }
                    if ($skip) { continue }
                    $stack.Push(@{ Path=$d.FullName; Depth=($cur.Depth + 1) })
                }
            } catch { }
        }
    }
    Write-Host ""
    return $results
}

function Invoke-WhereExeFallback {
    param([string[]]$Patterns, [int]$MaxResults = 500)
    Write-Log "Fallback: where.exe /r C:\ ..." "INFO"
    $results = New-Object System.Collections.Generic.List[string]
    foreach ($p in $Patterns) {
        if ($results.Count -ge $MaxResults) { break }
        try {
            $out = & cmd.exe /c "where /r C:\ *$p* 2>nul" 2>$null
            if ($out) {
                foreach ($l in $out) {
                    if ($results.Count -ge $MaxResults) { break }
                    if ($l -match '\.(exe|jar|zip|rar|dll|7z)$' -and (Test-Path $l -ErrorAction SilentlyContinue)) { $results.Add($l) }
                }
            }
        } catch { }
    }
    return $results
}

function Invoke-MultiStageSearch {
    param([string[]]$Patterns, [int]$MaxResults = 500)
    $all = New-Object System.Collections.Generic.List[string]
    $seen = @{}; $stages = @()
    if ($Script:EverythingState.SearchWorking -and $Script:EverythingState.EsPath) {
        Write-Log "Ступень 1: es.exe -regex..." "INFO"
        try {
            $re = $Patterns -join '|'
            $r = & $Script:EverythingState.EsPath -regex $re -n $MaxResults 2>$null
            if ($r) {
                $filtered = $r | Where-Object { $_ -match '\.(exe|jar|zip|rar|dll|7z)$' -and (Test-Path $_ -ErrorAction SilentlyContinue) }
                foreach ($x in $filtered) { if (-not $seen.ContainsKey($x)) { $seen[$x]=$true; $all.Add($x) } }
                if ($all.Count -gt 0) { $stages += "Everything: $($all.Count)" }
                Write-Log "  → Everything: $($all.Count)" "OK"
            } else {
                Write-Log "  → Everything: 0" "WARN"
            }
        } catch { }
    }
    if ($all.Count -eq 0) {
        Write-Log "Ступень 2: Get-ChildItem fallback..." "INFO"
        $fs = Invoke-FileSystemSearchFallback -Patterns $Patterns -MaxResults $MaxResults
        foreach ($x in $fs) { if (-not $seen.ContainsKey($x)) { $seen[$x]=$true; $all.Add($x) } }
        if ($all.Count -gt 0) { $stages += "FS: $($all.Count)" }
    }
    if ($all.Count -eq 0 -and $Patterns.Count -le 5) {
        Write-Log "Ступень 3: where.exe..." "INFO"
        $we = Invoke-WhereExeFallback -Patterns $Patterns -MaxResults $MaxResults
        foreach ($x in $we) { if (-not $seen.ContainsKey($x)) { $seen[$x]=$true; $all.Add($x) } }
        if ($all.Count -gt 0) { $stages += "where: $($all.Count)" }
    }
    Write-Host ""
    Write-Host "  ┌─── ИТОГ ─────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "  │ Всего: $($all.Count)" -ForegroundColor $(if ($all.Count -gt 0) { "Red" } else { "Green" })
    Write-Host "  │ Ступени: $($stages -join ', ')" -ForegroundColor White
    Write-Host "  └───────────────────────────────────────────────────────" -ForegroundColor Cyan
    return $all
}

function Start-EverythingScan {
    Write-Log "=== EVERYTHING ===" "TITLE"
    $state = Invoke-EverythingDiagnostic
    Show-EverythingDiagnostic -State $state
    $patterns = @(
        'impact','wurst','sigma','meteor','aristois','future','konas','zeusclient',
        'vape','doomsday','nightware','liquidbounce','novoline','astolfo','moonlight',
        'nurik','celestial','expensive','zamorozka','celka','arbuz','britva','bariton',
        'rogalik','haruka','wissend','fluger','vortex','astra','newcode','bleachhack',
        'huzuni','skillclient','nodus','inertia','ares','exire','jex','hakari','hush',
        'hach','luminex','nuclear','remix','cuckoo','pandora','azura','akrien',
        'minced','deadcode','takker','faker','xameleon','fuzeclient','venus',
        'catlavan','seppuku','koks','kov','stealth','valor','horizon','eagle',
        'sakura','kami','raphael','incognito','trident','insomnia','ether'
    )
    $results = Invoke-MultiStageSearch -Patterns $patterns -MaxResults 1000
    if ($results.Count -eq 0) {
        Write-Log "Совпадений нет." "OK"
        if (-not $state.SearchWorking) {
            Write-Log "Индекс Everything пуст. Проверь Tools → Options → Indexes → NTFS → Force Rebuild." "WARN"
        }
        return
    }
    Write-Host ""
    Write-Log "НАЙДЕНО $($results.Count):" "FOUND"
    $grouped = $results | Group-Object { [System.IO.Path]::GetExtension($_).ToLower() } | Sort-Object Count -Descending
    foreach ($g in $grouped) {
        Write-Host ""
        Write-Host "  ═══ $($g.Name) ($($g.Count)) ═══" -ForegroundColor Yellow
        foreach ($f in $g.Group | Select-Object -First 30) {
            $sz = "?"
            try { $sz = [math]::Round((Get-Item $f).Length / 1KB, 1) } catch { }
            Write-Host "    [!] $f ($sz KB)" -ForegroundColor Red
            $Script:Report.Add("Everything: $f")
        }
        if ($g.Count -gt 30) { Write-Host "    ... и ещё $($g.Count - 30)" -ForegroundColor DarkYellow }
    }
}

function Start-EverythingDiagnosticOnly {
    $state = Invoke-EverythingDiagnostic
    Show-EverythingDiagnostic -State $state
}

function Ensure-Everything {
    if (-not $Script:EverythingState.EsPath -or -not $Script:EverythingState.SearchWorking) {
        Invoke-EverythingDiagnostic | Out-Null
    }
    return $Script:EverythingState.EsPath
}

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  PROCESS MEMORY SCANNER                                              ║
# ╚══════════════════════════════════════════════════════════════════════╝
function Test-ProcessMemory {
    Write-Log "=== ПАМЯТЬ JVM ===" "TITLE"
    $targets = Get-Process -Name javaw,java -ErrorAction SilentlyContinue
    if (-not $targets) { Write-Log "Java-процессы не запущены." "WARN"; return }
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
    $patterns = @('l.png','killaura','aimbot','vape','sigma','meteor','hitbox_expand','autototem','tracers')
    $PQI = 0x0400; $PVR = 0x0010; $MEMC = 0x1000
    $READABLE = 0x02, 0x04, 0x20, 0x40
    foreach ($proc in $targets) {
        Write-Log "PID $($proc.Id) ($($proc.ProcessName))..." "INFO"
        $h = [MemReader]::OpenProcess($PQI -bor $PVR, $false, $proc.Id)
        if ($h -eq [IntPtr]::Zero) { Write-Log "OpenProcess failed (нужен админ)." "WARN"; continue }
        $addr = [IntPtr]::Zero
        $mbiSize = [System.Runtime.InteropServices.Marshal]::SizeOf([type][MEMORY_BASIC_INFORMATION])
        $regions = 0; $total = 0
        $found = @{}
        while ($true) {
            $mbi = New-Object MEMORY_BASIC_INFORMATION
            $ret = [MemReader]::VirtualQueryEx($h, $addr, [ref]$mbi, $mbiSize)
            if ($ret -eq 0) { break }
            if ($mbi.State -eq $MEMC -and ($READABLE -contains [int]$mbi.Protect)) {
                $size = [int]$mbi.RegionSize
                if ($size -gt 0 -and $size -lt 50MB) {
                    $buf = New-Object byte[] $size
                    $read = [IntPtr]::Zero
                    if ([MemReader]::ReadProcessMemory($h, $mbi.BaseAddress, $buf, $size, [ref]$read)) {
                        $regions++; $total += [int]$read
                        $text = [System.Text.Encoding]::ASCII.GetString($buf, 0, [int]$read)
                        foreach ($pat in $patterns) {
                            if ($text -match [regex]::Escape($pat)) {
                                $key = "p:$pat"
                                if (-not $found.ContainsKey($key)) {
                                    $found[$key] = $true
                                    Write-Log "ПАМЯТЬ: '$pat' в PID $($proc.Id) @ $($mbi.BaseAddress)" "FOUND"
                                }
                            }
                        }
                    }
                }
            }
            $addr = [IntPtr]([long]$mbi.BaseAddress + [long]$mbi.RegionSize)
        }
        [MemReader]::CloseHandle($h) | Out-Null
        Write-Log "PID $($proc.Id): $regions регионов, $([math]::Round($total/1MB,1)) MB" "INFO"
    }
}

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  SERVICES / PROCESSES / STRINGS / BAM / PREFETCH / AMCACHE / NETWORK ║
# ╚══════════════════════════════════════════════════════════════════════╝
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
    $pat = ($Script:CheatNames -join '|')
    $found = Get-Process | Where-Object { $_.ProcessName -match $pat }
    if ($found) { foreach ($p in $found) { Write-Log "ПРОЦЕСС: $($p.ProcessName) (PID $($p.Id))" "FOUND" } }
    else { Write-Log "Подозрительных процессов нет." "OK" }
}

function Test-Strings {
    Write-Log "=== СТРОКИ ===" "TITLE"
    $targets = @(@{ Path = "$env:WINDIR\explorer.exe"; Patterns = @("deltadlc","nursultam","celestial") })
    $cands = @("C:\Program Files\Java","C:\Program Files\Eclipse Adoptium","$env:APPDATA\.minecraft\runtime","$env:USERPROFILE\.jdks")
    foreach ($c in $cands) {
        if (Test-Path $c) {
            $jp = (Get-ChildItem -Path $c -Filter "javaw.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 3).FullName
            foreach ($p in $jp) { $targets += @{ Path = $p; Patterns = @("l.png") } }
        }
    }
    foreach ($t in $targets) {
        if (-not (Test-Path $t.Path)) { continue }
        $sz = (Get-Item $t.Path).Length / 1MB
        if ($sz -gt 100) { continue }
        Write-Log "Читаю $($t.Path)..." "INFO"
        try { $bytes = [System.IO.File]::ReadAllBytes($t.Path) } catch { continue }
        $hit = $false
        foreach ($pat in $t.Patterns) {
            $a = [System.Text.Encoding]::ASCII.GetBytes($pat)
            $u = [System.Text.Encoding]::Unicode.GetBytes($pat)
            if ((Find-ByteString -Haystack $bytes -Needle $a) -ge 0) { Write-Log "ASCII '$pat' в $([System.IO.Path]::GetFileName($t.Path))" "FOUND"; $hit = $true }
            if ((Find-ByteString -Haystack $bytes -Needle $u) -ge 0) { Write-Log "UTF16 '$pat' в $([System.IO.Path]::GetFileName($t.Path))" "FOUND"; $hit = $true }
        }
        if (-not $hit) { Write-Log "$([System.IO.Path]::GetFileName($t.Path)): чисто" "OK" }
    }
}

function Test-BAM {
    Write-Log "=== BAM ===" "TITLE"
    $paths = @("HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings","HKLM:\SYSTEM\CurrentControlSet\Services\bam\UserSettings")
    $found = $false
    foreach ($bp in $paths) {
        if (-not (Test-Path $bp)) { continue }
        foreach ($sid in (Get-ChildItem $bp -ErrorAction SilentlyContinue)) {
            $vals = Get-ItemProperty -Path $sid.PSPath -ErrorAction SilentlyContinue
            foreach ($p in $vals.PSObject.Properties) {
                if ($p.Name -match '\\') {
                    foreach ($c in $Script:CheatNames) {
                        if ($p.Name -match [regex]::Escape($c)) { Write-Log "BAM: $($p.Name)" "FOUND"; $found = $true }
                    }
                }
            }
        }
    }
    if (-not $found) { Write-Log "BAM: чисто" "OK" }
}

function Test-Prefetch {
    Write-Log "=== PREFETCH ===" "TITLE"
    $dir = "$env:WINDIR\Prefetch"
    if (-not (Test-Path $dir)) { Write-Log "Prefetch недоступен." "WARN"; return }
    $files = Get-ChildItem $dir -Filter "*.pf" -ErrorAction SilentlyContinue
    $found = $false
    foreach ($f in $files) {
        $n = $f.Name.ToLower()
        foreach ($c in $Script:CheatNames) {
            if ($n -match [regex]::Escape($c)) { Write-Log "PREFETCH: $($f.Name)" "FOUND"; $found = $true }
        }
    }
    if (-not $found) { Write-Log "Prefetch: чисто" "OK" }
}

function Test-Amcache {
    Write-Log "=== AMCACHE ===" "TITLE"
    $p = "C:\Windows\AppCompat\Programs\Amcache.hve"
    if (-not (Test-Path $p)) { Write-Log "Amcache не найден." "WARN"; return }
    try {
        $bytes = [System.IO.File]::ReadAllBytes($p)
        $found = $false
        foreach ($c in $Script:CheatNames) {
            $u = [System.Text.Encoding]::Unicode.GetBytes($c)
            if ((Find-ByteString -Haystack $bytes -Needle $u) -ge 0) { Write-Log "AMCACHE: '$c'" "FOUND"; $found = $true }
        }
        if (-not $found) { Write-Log "Amcache: чисто" "OK" }
    } catch { Write-Log "Amcache ошибка: $_" "WARN" }
}

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
    try {
        $conns = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | Where-Object { $_.RemotePort -in @(25565,25566,19132) }
        if ($conns) { foreach ($c in $conns) { Write-Log "TCP: $($c.RemoteAddress):$($c.RemotePort) (PID $($c.OwningProcess))" "INFO" } }
        else { Write-Log "TCP: нет MC-подключений." "OK" }
    } catch { }
}

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  TELEGRAM                                                            ║
# ╚══════════════════════════════════════════════════════════════════════╝
function Send-Report {
    if ($Config.TelegramBotToken -eq "ТВОЙ_ТОКЕН_БОТА") { Write-Log "TG не настроен." "WARN"; return }
    $tmp = "$env:TEMP\ec_$(Get-Date -Format yyyyMMdd_HHmmss).txt"
    $Script:Report -join "`r`n" | Out-File $tmp -Encoding UTF8
    try {
        $uri = "https://api.telegram.org/bot$($Config.TelegramBotToken)/sendDocument"
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            Invoke-RestMethod -Uri $uri -Method Post -Form @{ chat_id=$Config.TelegramChatId; document=(Get-Item $tmp) } | Out-Null
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

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  ГЛАВНАЯ Start-JarScan (объединяет всё)                              ║
# ╚══════════════════════════════════════════════════════════════════════╝
function Start-JarScan {
    param(
        [switch]$ModsOnly,
        [switch]$AllDisks,
        [switch]$IncludeDownloads,
        [switch]$ComputeHash,
        [switch]$MetadataOnly,
        [switch]$SkipAux
    )
    Write-Log "=== JAR АНАЛИЗ v7.0 ===" "TITLE"

    # 1. Discovery
    Write-Log "Этап 1/4: Поиск JAR..." "INFO"
    $jars = Find-AllJars -IncludeDownloads:$IncludeDownloads
    if ($jars.Count -eq 0) { Write-Log "Не найдено .jar" "WARN"; return }

    # 2. Metadata
    Write-Log "Этап 2/4: Метаданные..." "INFO"
    $metas = New-Object System.Collections.Generic.List[object]
    $i = 0
    foreach ($jar in $jars) {
        $i++
        $pct = [math]::Round(($i / $jars.Count) * 100)
        Write-Host "`r  [Meta $pct%] $i/$($jars.Count) — $($jar.FileName.PadRight(50).Substring(0,[Math]::Min(50,$jar.FileName.Length)))" -NoNewline -ForegroundColor DarkGray
        $metas.Add((Read-JarMetadata -JarPath $jar.FullPath -ComputeHash:$ComputeHash))
    }
    Write-Host ""
    Show-MetadataSummary -Metas $metas
    $Script:LastJarMetas = $metas

    foreach ($m in $metas) {
        $rs = @()
        if ($m.Manifest -and $m.Manifest.AgentFlags.Count -gt 0) { foreach ($f in $m.Manifest.AgentFlags) { $rs += "Java-Agent: $f" } }
        if ($m.HashMatch) { $rs += "Hash совпадает: $($m.HashMatch)" }
        if ($m.Fabric -and $m.Fabric.RedFlags.Count -gt 0) { foreach ($f in $m.Fabric.RedFlags) { $rs += $f } }
        if ($m.Forge -and $m.Forge.RedFlags.Count -gt 0) { foreach ($f in $m.Forge.RedFlags) { $rs += $f } }
        if ($m.McmodInfo -and $m.McmodInfo.RedFlags.Count -gt 0) { foreach ($f in $m.McmodInfo.RedFlags) { $rs += $f } }
        if ($rs.Count -gt 0) {
            Write-Log "ПОДОЗРИТЕЛЬНО (metadata): $($m.Path)" "FOUND"
            foreach ($r in $rs) { Write-Host "      → $r" -ForegroundColor DarkRed; $Script:Report.Add("      → $r") }
        }
    }
    if ($MetadataOnly) { Write-Log "Metadata-only — стоп." "WARN"; return }

    # 3-4. Фильтр и глубокий скан
    $toScan = @()
    foreach ($jar in $jars) {
        if (Test-Whitelisted -FullPath $jar.FullPath -Name $jar.FileName.ToLower()) { continue }
        $toScan += [PSCustomObject]@{ FullPath=$jar.FullPath; FileName=$jar.FileName; Launcher=$jar.Launcher }
    }
    Write-Log "После whitelist: $($toScan.Count) JAR" "INFO"
    if ($toScan.Count -eq 0) { Write-Log "Нечего сканировать." "OK"; return }

    # 3. Deep
    Write-Log "Этап 3/4: Глубокий байткод-скан..." "INFO"
    $deep = Invoke-JarDeepScanParallel -Jars $toScan -Threshold $Script:ScoreThreshold
    $Script:LastDeepResults = $deep
    Show-DeepScanResults -Results $deep -Threshold $Script:ScoreThreshold

    # 4. Aux
    if (-not $SkipAux) {
        Write-Log "Этап 4/4: Aux (network/native/nested/dangerous)..." "INFO"
        $aux = Invoke-JarAuxScanParallel -Jars $toScan
        $Script:LastAuxResults = $aux
        Show-AuxScanResults -Results $aux
    }

    Write-Log "=== ЗАВЕРШЕНО ===" "TITLE"
}

function Start-JarScanParallel {
    param([switch]$AllDisks, [switch]$ModsOnly)
    Start-JarScan -AllDisks:$AllDisks -ModsOnly:$ModsOnly
}

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  MENU + MAIN LOOP                                                    ║
# ╚══════════════════════════════════════════════════════════════════════╝
function Show-Menu {
    Write-Host ""
    Write-Host "  [1]  ПОЛНЫЙ СКАН" -ForegroundColor White
    Write-Host "  [2]  JAR скан — mods/ (быстро)" -ForegroundColor White
    Write-Host "  [3]  JAR скан — ВСЕ .jar на ПК" -ForegroundColor White
    Write-Host "  [4]  Процессы + Память JVM" -ForegroundColor White
    Write-Host "  [5]  Everything (диагностика + поиск)" -ForegroundColor White
    Write-Host "  [6]  Строки (explorer/javaw)" -ForegroundColor White
    Write-Host "  [7]  Артефакты (BAM/Prefetch/Amcache)" -ForegroundColor White
    Write-Host "  [8]  Сеть" -ForegroundColor White
    Write-Host "  [9]  Отправить в Telegram" -ForegroundColor White
    Write-Host "  [10] Только диагностика Everything" -ForegroundColor White
    Write-Host "  [0]  Выход" -ForegroundColor White
    Write-Host ""
}

Write-Host "  >>> PART B LOADED — FULL ENGINE READY <<<" -ForegroundColor Magenta
Write-Host "  >>> v7.0 — все модули инициализированы <<<" -ForegroundColor Magenta

$Script:Report.Add("=== ENGINE CHECK v7.0 ===")
$Script:Report.Add("Дата: $(Get-Date)")
$Script:Report.Add("ПК: $env:COMPUTERNAME")
$Script:Report.Add("")

Show-Banner
$exit = $false
while (-not $exit) {
    Show-Menu
    $c = Read-Host "  Выбор"
    $Script:StartTime = Get-Date
    switch ($c) {
        "1" {
            Test-Services
            Test-Processes
            Start-JarScan
            Test-ProcessMemory
            Start-EverythingScan
            Test-Strings
            Test-BAM
            Test-Prefetch
            Test-Amcache
            Test-Network
        }
        "2" { Start-JarScan -ModsOnly }
        "3" { Start-JarScan -IncludeDownloads }
        "4" { Test-Processes; Test-ProcessMemory }
        "5" { Start-EverythingScan }
        "6" { Test-Strings }
        "7" { Test-BAM; Test-Prefetch; Test-Amcache }
        "8" { Test-Network }
        "9" { Send-Report }
        "10" { Start-EverythingDiagnosticOnly }
        "0" { $exit = $true; continue }
        default { Write-Host "  Неверно." -ForegroundColor Red; continue }
    }
    $el = (Get-Date) - $Script:StartTime
    Write-Host ""
    Write-Host "  Готово за $($el.ToString('mm\:ss')). Флагов: $($Script:Threats)" -ForegroundColor Cyan
    Write-Host "  Enter для возврата..."
    Read-Host | Out-Null
    Show-Banner
}
