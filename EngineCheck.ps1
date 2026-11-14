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
