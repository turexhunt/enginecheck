# ╔══════════════════════════════════════════════════════════════════════╗
# ║  JAR SCANNER v7.0 — PART 1/7                                         ║
# ║  Модуль: DISCOVERY + МЕТАДАННЫЕ                                      ║
# ║  Ищет ВСЕ JAR во всех лаунчерах, читает манифест, mods.toml,          ║
# ║  fabric.mod.json, mcmod.info, SHA256, размер, дату.                  ║
# ╚══════════════════════════════════════════════════════════════════════╝

# ═══════════════════════════════════════════════════════════════════════
# КОНСТАНТЫ: пути всех известных лаунчеров Minecraft
# ═══════════════════════════════════════════════════════════════════════
$Script:MinecraftPaths = @(
    # ─── Vanilla ──────────────────────────────────────────────────────
    @{ Path = "$env:APPDATA\.minecraft";               Name = "Vanilla";       Type = "mods" }
    @{ Path = "$env:APPDATA\.minecraft\mods";          Name = "Vanilla";       Type = "mods" }
    @{ Path = "$env:APPDATA\.minecraft\versions";      Name = "Vanilla";       Type = "versions" }
    @{ Path = "$env:APPDATA\.minecraft\custom_mods";   Name = "Vanilla";       Type = "mods" }
    # ─── TLauncher ────────────────────────────────────────────────────
    @{ Path = "$env:APPDATA\.tlauncher\legacy\Minecraft";              Name = "TLauncher"; Type = "root" }
    @{ Path = "$env:APPDATA\.tlauncher\legacy\Minecraft\mods";         Name = "TLauncher"; Type = "mods" }
    @{ Path = "$env:APPDATA\.tlauncher\legacy\Minecraft\versions";     Name = "TLauncher"; Type = "versions" }
    @{ Path = "$env:APPDATA\.tlauncher\legacy\Minecraft\libraries";    Name = "TLauncher"; Type = "libraries" }
    # ─── Lunar Client ────────────────────────────────────────────────
    @{ Path = "$env:USERPROFILE\.lunarclient";                          Name = "Lunar";     Type = "root" }
    @{ Path = "$env:USERPROFILE\.lunarclient\offline\multiver";        Name = "Lunar";     Type = "mods" }
    @{ Path = "$env:USERPROFILE\.lunarclient\offline\1.8";             Name = "Lunar";     Type = "mods" }
    @{ Path = "$env:USERPROFILE\.lunarclient\offline\1.16";            Name = "Lunar";     Type = "mods" }
    @{ Path = "$env:USERPROFILE\.lunarclient\offline\1.18";            Name = "Lunar";     Type = "mods" }
    @{ Path = "$env:USERPROFILE\.lunarclient\offline\1.21";            Name = "Lunar";     Type = "mods" }
    # ─── Badlion ────────────────────────────────────────────────────
    @{ Path = "$env:APPDATA\Badlion Client";                            Name = "Badlion";   Type = "root" }
    @{ Path = "$env:APPDATA\Badlion Client\minecraft";                 Name = "Badlion";   Type = "mods" }
    # ─── Feather ────────────────────────────────────────────────────
    @{ Path = "$env:APPDATA\Feather";                                   Name = "Feather";   Type = "root" }
    # ─── LabyMod ────────────────────────────────────────────────────
    @{ Path = "$env:APPDATA\.minecraft\laby-mod";                      Name = "LabyMod";   Type = "mods" }
    # ─── Prism / PolyMC / MultiMC ───────────────────────────────────
    @{ Path = "$env:APPDATA\PrismLauncher\instances";                  Name = "Prism";     Type = "instances" }
    @{ Path = "$env:APPDATA\PolyMC\instances";                         Name = "PolyMC";    Type = "instances" }
    @{ Path = "$env:APPDATA\MultiMC\instances";                        Name = "MultiMC";   Type = "instances" }
    @{ Path = "$env:APPDATA\multimc\instances";                        Name = "MultiMC";   Type = "instances" }
    # ─── ATLauncher ─────────────────────────────────────────────────
    @{ Path = "$env:APPDATA\ATLauncher\instances";                     Name = "ATLauncher"; Type = "instances" }
    # ─── GDLauncher ─────────────────────────────────────────────────
    @{ Path = "$env:APPDATA\gdlauncher_next\instances";                Name = "GDLauncher"; Type = "instances" }
    @{ Path = "$env:APPDATA\gdlauncher\instances";                     Name = "GDLauncher"; Type = "instances" }
    # ─── Technic ────────────────────────────────────────────────────
    @{ Path = "$env:APPDATA\.technic\modpacks";                        Name = "Technic";   Type = "instances" }
    # ─── CurseForge / Overwolf ──────────────────────────────────────
    @{ Path = "$env:USERPROFILE\curseforge\minecraft\Instances";      Name = "CurseForge"; Type = "instances" }
    @{ Path = "$env:USERPROFILE\Documents\curseforge\minecraft\Instances"; Name = "CurseForge"; Type = "instances" }
    @{ Path = "$env:USERPROFILE\Documents\Curse\Minecraft\Instances"; Name = "CurseForge"; Type = "instances" }
    # ─── Modrinth ───────────────────────────────────────────────────
    @{ Path = "$env:APPDATA\com.modrinth.theseus";                     Name = "Modrinth";  Type = "instances" }
    # ─── Русские сервера / сборки ───────────────────────────────────
    @{ Path = "$env:APPDATA\.vimeworld";                               Name = "VimeWorld"; Type = "mods" }
    @{ Path = "$env:APPDATA\.mcskill";                                 Name = "McSkill";   Type = "mods" }
    @{ Path = "$env:APPDATA\.grand";                                   Name = "Grand";     Type = "mods" }
    @{ Path = "$env:APPDATA\.holyworld";                               Name = "HolyWorld"; Type = "mods" }
    @{ Path = "$env:APPDATA\.reallyworld";                             Name = "ReallyWorld"; Type = "mods" }
    # ─── Портативные / ручные установки ─────────────────────────────
    @{ Path = "C:\Games\.minecraft";                                   Name = "Portable";  Type = "mods" }
    @{ Path = "D:\Games\.minecraft";                                   Name = "Portable";  Type = "mods" }
    @{ Path = "C:\Minecraft";                                          Name = "Portable";  Type = "mods" }
    @{ Path = "D:\Minecraft";                                          Name = "Portable";  Type = "mods" }
) | Where-Object { Test-Path $_.Path }

# ═══════════════════════════════════════════════════════════════════════
# БАЗА SHA256 известных читов (пустая — заполняй по мере находок)
# ═══════════════════════════════════════════════════════════════════════
$Script:KnownCheatHashes = @{
    # "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" = "Vape V4"
}

# ═══════════════════════════════════════════════════════════════════════
# Флаги в MANIFEST.MF — указывают на java-agent (чит через атаку)
# ═══════════════════════════════════════════════════════════════════════
$Script:ManifestRedFlags = @(
    'Premain-Class','Agent-Class','Can-Redefine-Classes',
    'Can-Retransform-Classes','Launcher-Agent-Class'
)

# ═══════════════════════════════════════════════════════════════════════
# Флаги в mods.toml / fabric.mod.json — читерские пакеты
# ═══════════════════════════════════════════════════════════════════════
$Script:MetaRedFlags = @(
    'mixins.combat','mixins.movement','mixins.render','mixins.player',
    'mixins.exploit','mixins.world','mixins.hack','mixins.cheat',
    'client.combat','client.movement','client.render','client.player',
    'client.exploit','client.hack','client.cheat'
)

# ═══════════════════════════════════════════════════════════════════════
# 1.1 — DISCOVERY: рекурсивный поиск всех JAR во всех путях
# ═══════════════════════════════════════════════════════════════════════
function Find-AllJars {
    param(
        [switch]$IncludeDownloads,
        [int]$MaxSizeMB = 100,
        [int]$MaxDepth = 10
    )

    $all = New-Object System.Collections.Generic.List[object]
    $searchTargets = $Script:MinecraftPaths

    if ($IncludeDownloads) {
        $searchTargets += @{ Path = "$env:USERPROFILE\Downloads"; Name = "Downloads"; Type = "manual" }
        $searchTargets += @{ Path = "$env:USERPROFILE\Desktop";   Name = "Desktop";   Type = "manual" }
    }

    $totalScanned = 0
    foreach ($target in $searchTargets) {
        if (-not (Test-Path $target.Path)) { continue }
        $totalScanned++
        Write-Host "`r  [Discovery] $($totalScanned)/$($searchTargets.Count): $($target.Name) → $($target.Path)" -NoNewline -ForegroundColor DarkGray

        try {
            $found = Get-ChildItem -Path $target.Path -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue -Force |
                     Where-Object { $_.Length -gt 0 -and $_.Length -lt ($MaxSizeMB * 1MB) }

            foreach ($jar in $found) {
                $all.Add([PSCustomObject]@{
                    FullPath = $jar.FullName
                    FileName = $jar.Name
                    Size     = $jar.Length
                    Modified = $jar.LastWriteTime
                    Launcher = $target.Name
                    Category = $target.Type
                })
            }
        } catch {
            # Пропускаем недоступные папки
        }
    }

    Write-Host ""
    Write-Host "  [Discovery] Всего найдено .jar: $($all.Count)" -ForegroundColor Cyan

    # Дедупликация по полному пути
    $unique = $all | Sort-Object FullPath -Unique
    if ($unique.Count -lt $all.Count) {
        Write-Host "  [Discovery] После дедупликации: $($unique.Count)" -ForegroundColor Cyan
    }
    return $unique
}

# ═══════════════════════════════════════════════════════════════════════
# 1.2 — SHA256 файла (быстро, потоково)
# ═══════════════════════════════════════════════════════════════════════
function Get-JarHash {
    param([string]$Path)
    try {
        $sha = [System.Security.Cryptography.SHA256]::Create()
        $stream = [System.IO.File]::OpenRead($Path)
        $hash = $sha.ComputeHash($stream)
        $stream.Close()
        $sha.Dispose()
        return ([System.BitConverter]::ToString($hash) -replace '-','').ToLower()
    } catch {
        return $null
    }
}

# ═══════════════════════════════════════════════════════════════════════
# 1.3 — Чтение MANIFEST.MF из JAR
# ═══════════════════════════════════════════════════════════════════════
function Get-JarManifest {
    param([System.IO.Compression.ZipArchive]$Zip)

    $result = [PSCustomObject]@{
        Found           = $false
        MainClass       = $null
        ImplementationVendor = $null
        ImplementationTitle  = $null
        ImplementationVersion = $null
        AgentFlags      = @()
        Raw             = $null
    }

    $entry = $Zip.Entries | Where-Object { $_.FullName -eq 'META-INF/MANIFEST.MF' } | Select-Object -First 1
    if (-not $entry) { return $result }

    $result.Found = $true
    try {
        $stream = $entry.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        $raw = $reader.ReadToEnd()
        $reader.Close()
        $stream.Close()
        $result.Raw = $raw

        # Парсинг строк вида "Key: Value" (учитываем продолжения через пробел)
        $lines = $raw -split "`r?`n"
        $kv = @{}
        $lastKey = $null
        foreach ($line in $lines) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }
            if ($line -match '^\s+(.+)$' -and $lastKey) {
                $kv[$lastKey] += $Matches[1]
                continue
            }
            if ($line -match '^([^:]+):\s*(.*)$') {
                $lastKey = $Matches[1].Trim()
                $kv[$lastKey] = $Matches[2].Trim()
            }
        }

        if ($kv.ContainsKey('Main-Class'))              { $result.MainClass = $kv['Main-Class'] }
        if ($kv.ContainsKey('Implementation-Vendor'))   { $result.ImplementationVendor = $kv['Implementation-Vendor'] }
        if ($kv.ContainsKey('Implementation-Title'))    { $result.ImplementationTitle = $kv['Implementation-Title'] }
        if ($kv.ContainsKey('Implementation-Version'))  { $result.ImplementationVersion = $kv['Implementation-Version'] }

        foreach ($flag in $Script:ManifestRedFlags) {
            if ($kv.ContainsKey($flag)) {
                $result.AgentFlags += "$flag = $($kv[$flag])"
            }
        }
    } catch {
        # Игнорируем ошибки чтения манифеста
    }
    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 1.4 — Чтение fabric.mod.json
# ═══════════════════════════════════════════════════════════════════════
function Get-FabricMetadata {
    param([System.IO.Compression.ZipArchive]$Zip)

    $result = [PSCustomObject]@{
        Found   = $false
        Id      = $null
        Name    = $null
        Version = $null
        Author  = $null
        Mixins  = @()
        Entrypoints = @()
        RedFlags = @()
    }

    $entry = $Zip.Entries | Where-Object { $_.FullName -eq 'fabric.mod.json' } | Select-Object -First 1
    if (-not $entry) { return $result }

    $result.Found = $true
    try {
        $stream = $entry.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        $json = $reader.ReadToEnd() | ConvertFrom-Json
        $reader.Close()
        $stream.Close()

        if ($json.id)      { $result.Id = $json.id }
        if ($json.name)    { $result.Name = $json.name }
        if ($json.version) { $result.Version = $json.version }
        if ($json.author)  { $result.Author = "$($json.author)" }
        if ($json.authors) { $result.Author = "$($json.authors -join ', ')" }

        # Mixins
        if ($json.mixins) {
            foreach ($m in $json.mixins) {
                $result.Mixins += "$m"
                foreach ($rf in $Script:MetaRedFlags) {
                    if ("$m" -match [regex]::Escape($rf)) {
                        $result.RedFlags += "Mixin: $m"
                    }
                }
            }
        }

        # Entrypoints
        if ($json.entrypoints) {
            foreach ($epName in $json.entrypoints.PSObject.Properties.Name) {
                foreach ($ep in $json.entrypoints.$epName) {
                    $result.Entrypoints += "$epName → $ep"
                }
            }
        }

        # Ищем читерские слова в имени/id/entrypoints
        $combined = "$($result.Id) $($result.Name) $($result.Mixins -join ' ') $($result.Entrypoints -join ' ')".ToLower()
        foreach ($cheat in $Script:CheatNames) {
            if ($combined -match [regex]::Escape($cheat)) {
                $result.RedFlags += "Метаданные содержат '$cheat'"
            }
        }
    } catch {
        # Ошибки парсинга JSON — пропускаем
    }
    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 1.5 — Чтение Forge mods.toml
# ═══════════════════════════════════════════════════════════════════════
function Get-ForgeMetadata {
    param([System.IO.Compression.ZipArchive]$Zip)

    $result = [PSCustomObject]@{
        Found        = $false
        ModId        = $null
        DisplayName  = $null
        Version      = $null
        Authors      = $null
        MixinConfigs = @()
        RedFlags     = @()
    }

    $entry = $Zip.Entries | Where-Object {
        $_.FullName -match '^META-INF/(mods\.toml|MANIFEST\.MF)$' -or
        $_.FullName -eq 'META-INF/mods.toml'
    } | Where-Object { $_.FullName -eq 'META-INF/mods.toml' } | Select-Object -First 1

    if (-not $entry) { return $result }
    $result.Found = $true

    try {
        $stream = $entry.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        $raw = $reader.ReadToEnd()
        $reader.Close()
        $stream.Close()

        # Простой парсинг TOML-подобного формата
        foreach ($line in ($raw -split "`n")) {
            $line = $line.Trim()
            if ($line -match '^modId\s*=\s*"([^"]+)"')       { $result.ModId = $Matches[1] }
            if ($line -match '^displayName\s*=\s*"([^"]+)"') { $result.DisplayName = $Matches[1] }
            if ($line -match '^version\s*=\s*"([^"]+)"')     { $result.Version = $Matches[1] }
            if ($line -match '^authors\s*=\s*"([^"]+)"')     { $result.Authors = $Matches[1] }
            if ($line -match '^mixinConfigs\s*=\s*\[(.+)\]') {
                $result.MixinConfigs += ($Matches[1] -replace '"','').Split(',') | ForEach-Object { $_.Trim() }
            }
            foreach ($rf in $Script:MetaRedFlags) {
                if ($line.ToLower() -match [regex]::Escape($rf)) {
                    $result.RedFlags += "mods.toml: $rf"
                }
            }
        }

        $combined = "$($result.ModId) $($result.DisplayName) $($result.MixinConfigs -join ' ')".ToLower()
        foreach ($cheat in $Script:CheatNames) {
            if ($combined -match [regex]::Escape($cheat)) {
                $result.RedFlags += "Метаданные Forge содержат '$cheat'"
            }
        }
    } catch { }
    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 1.6 — Чтение mcmod.info (старый Forge 1.12-)
# ═══════════════════════════════════════════════════════════════════════
function Get-McmodInfo {
    param([System.IO.Compression.ZipArchive]$Zip)

    $result = [PSCustomObject]@{
        Found       = $false
        ModId       = $null
        Name        = $null
        Version     = $null
        AuthorList  = $null
        Description = $null
        RedFlags    = @()
    }

    $entry = $Zip.Entries | Where-Object { $_.FullName -eq 'mcmod.info' } | Select-Object -First 1
    if (-not $entry) { return $result }
    $result.Found = $true

    try {
        $stream = $entry.Open()
        $reader = New-Object System.IO.StreamReader($stream)
        $raw = $reader.ReadToEnd()
        $reader.Close()
        $stream.Close()

        $json = $raw | ConvertFrom-Json
        if ($json -is [array]) { $json = $json[0] }
        if ($json.modid)       { $result.ModId = $json.modid }
        if ($json.name)        { $result.Name = $json.name }
        if ($json.version)     { $result.Version = $json.version }
        if ($json.authorList)  { $result.AuthorList = "$($json.authorList -join ', ')" }
        if ($json.description) { $result.Description = $json.description }

        $combined = "$($result.ModId) $($result.Name) $($result.Description)".ToLower()
        foreach ($cheat in $Script:CheatNames) {
            if ($combined -match [regex]::Escape($cheat)) {
                $result.RedFlags += "mcmod.info содержит '$cheat'"
            }
        }
    } catch { }
    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 1.7 — Подсчёт статистики содержимого JAR
# ═══════════════════════════════════════════════════════════════════════
function Get-JarStats {
    param([System.IO.Compression.ZipArchive]$Zip)

    $stats = [PSCustomObject]@{
        TotalEntries       = 0
        ClassCount         = 0
        ResourceCount      = 0
        PackageCount       = 0
        ShortClassCount    = 0     # a.class, b.class
        NestedJarCount     = 0
        NativeCount        = 0     # .dll, .so, .dylib
        TopPackages        = @()
        UniquePackages     = 0
    }

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
    $stats.PackageCount = $packages.Count
    $stats.TopPackages = $packages.Keys | Select-Object -First 20

    return $stats
}

# ═══════════════════════════════════════════════════════════════════════
# 1.8 — Анализ одного JAR: собрать ВСЕ метаданные в одну структуру
# ═══════════════════════════════════════════════════════════════════════
function Read-JarMetadata {
    param(
        [string]$JarPath,
        [switch]$ComputeHash
    )

    $meta = [PSCustomObject]@{
        Path       = $JarPath
        FileName   = [System.IO.Path]::GetFileName($JarPath)
        Size       = 0
        Modified   = $null
        Hash       = $null
        HashMatch  = $null        # Имя чита, если хэш совпал с KnownCheatHashes
        Manifest   = $null
        Fabric     = $null
        Forge      = $null
        McmodInfo  = $null
        Stats      = $null
        Error      = $null
        IsObfuscated = $false
    }

    try {
        $fileInfo = Get-Item $JarPath
        $meta.Size = $fileInfo.Length
        $meta.Modified = $fileInfo.LastWriteTime

        if ($ComputeHash) {
            $meta.Hash = Get-JarHash -Path $JarPath
            if ($meta.Hash -and $Script:KnownCheatHashes.ContainsKey($meta.Hash)) {
                $meta.HashMatch = $Script:KnownCheatHashes[$meta.Hash]
            }
        }

        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)

        $meta.Manifest  = Get-JarManifest -Zip $zip
        $meta.Fabric    = Get-FabricMetadata -Zip $zip
        $meta.Forge     = Get-ForgeMetadata -Zip $zip
        $meta.McmodInfo = Get-McmodInfo -Zip $zip
        $meta.Stats     = Get-JarStats -Zip $zip

        $zip.Dispose()

        # Эвристика обфускации
        if ($meta.Stats.ClassCount -gt 10) {
            $ratio = $meta.Stats.ShortClassCount / $meta.Stats.ClassCount
            if ($ratio -gt 0.5) { $meta.IsObfuscated = $true }
        }
    } catch {
        $meta.Error = $_.Exception.Message
    }

    return $meta
}

# ═══════════════════════════════════════════════════════════════════════
# 1.9 — Пакетный анализ: все JAR → метаданные (последовательно, без потоков)
# ═══════════════════════════════════════════════════════════════════════
function Get-AllJarMetadata {
    param(
        [switch]$IncludeDownloads,
        [switch]$ComputeHash
    )

    $jars = Find-AllJars -IncludeDownloads:$IncludeDownloads
    if ($jars.Count -eq 0) {
        Write-Host "  [!] Не найдено ни одного .jar" -ForegroundColor Yellow
        return @()
    }

    $metas = New-Object System.Collections.Generic.List[object]
    $i = 0
    foreach ($jar in $jars) {
        $i++
        $pct = [math]::Round(($i / $jars.Count) * 100)
        Write-Host "`r  [Metadata] $i/$($jars.Count) ($pct%) — $($jar.FileName.PadRight(50).Substring(0,50))" -NoNewline -ForegroundColor DarkGray

        $m = Read-JarMetadata -JarPath $jar.FullPath -ComputeHash:$ComputeHash
        $metas.Add($m)
    }
    Write-Host ""
    Write-Host "  [Metadata] Обработано JAR: $($metas.Count)" -ForegroundColor Cyan

    return $metas
}

# ═══════════════════════════════════════════════════════════════════════
# 1.10 — Краткий отчёт по метаданным (без анализа байткода)
# ═══════════════════════════════════════════════════════════════════════
function Show-MetadataSummary {
    param([array]$Metas)

    if (-not $Metas -or $Metas.Count -eq 0) {
        Write-Host "  Нет данных для отчёта." -ForegroundColor Yellow
        return
    }

    $withError     = ($Metas | Where-Object { $_.Error }).Count
    $withAgentFlag = ($Metas | Where-Object { $_.Manifest -and $_.Manifest.AgentFlags.Count -gt 0 }).Count
    $withFabric    = ($Metas | Where-Object { $_.Fabric -and $_.Fabric.Found }).Count
    $withForge     = ($Metas | Where-Object { $_.Forge -and $_.Forge.Found }).Count
    $withMcmod     = ($Metas | Where-Object { $_.McmodInfo -and $_.McmodInfo.Found }).Count
    $obfuscated    = ($Metas | Where-Object { $_.IsObfuscated }).Count
    $hashMatches   = ($Metas | Where-Object { $_.HashMatch }).Count

    Write-Host ""
    Write-Host "  ┌─── СВОДКА МЕТАДАННЫХ ──────────────────────────────" -ForegroundColor Cyan
    Write-Host "  │ Всего JAR:                $($Metas.Count)" -ForegroundColor White
    Write-Host "  │ Ошибок чтения:            $withError" -ForegroundColor $(if ($withError -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  │ С Manifest-Agent флагами: $withAgentFlag" -ForegroundColor $(if ($withAgentFlag -gt 0) { "Red" } else { "Green" })
    Write-Host "  │ Fabric модов:             $withFabric" -ForegroundColor White
    Write-Host "  │ Forge модов:              $withForge" -ForegroundColor White
    Write-Host "  │ mcmod.info (1.12-):       $withMcmod" -ForegroundColor White
    Write-Host "  │ Обфусцированных:          $obfuscated" -ForegroundColor $(if ($obfuscated -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  │ Совпадений по хэшу:       $hashMatches" -ForegroundColor $(if ($hashMatches -gt 0) { "Red" } else { "Green" })
    Write-Host "  └───────────────────────────────────────────────────" -ForegroundColor Cyan

    # Показываем JAR с agent-флагами
    $flagged = $Metas | Where-Object { $_.Manifest -and $_.Manifest.AgentFlags.Count -gt 0 }
    if ($flagged.Count -gt 0) {
        Write-Host ""
        Write-Host "  ── JAR с Java-Agent флагами (подозрительно) ──" -ForegroundColor Red
        foreach ($f in $flagged) {
            Write-Host "    [!] $($f.Path)" -ForegroundColor Red
            foreach ($flag in $f.Manifest.AgentFlags) {
                Write-Host "        → $flag" -ForegroundColor DarkRed
            }
        }
    }

    # Показываем сильнобфусцированные
    $heavyObf = $Metas | Where-Object {
        $_.IsObfuscated -and $_.Stats.ClassCount -gt 20
    } | Sort-Object { $_.Stats.ShortClassCount } -Descending | Select-Object -First 10
    if ($heavyObf.Count -gt 0) {
        Write-Host ""
        Write-Host "  ── ТОП обфусцированных JAR ──" -ForegroundColor Yellow
        foreach ($f in $heavyObf) {
            $ratio = [math]::Round(($f.Stats.ShortClassCount / $f.Stats.ClassCount) * 100)
            Write-Host "    [?] $($f.FileName) — $ratio% коротких классов ($($f.Stats.ShortClassCount)/$($f.Stats.ClassCount))" -ForegroundColor Yellow
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════
# 1.11 — ГЛАВНАЯ: сканирование с метаданными (пока без байткода)
# ═══════════════════════════════════════════════════════════════════════
function Start-JarScan {
    param(
        [switch]$ModsOnly,
        [switch]$AllDisks,
        [switch]$IncludeDownloads,
        [switch]$ComputeHash
    )

    Write-Log "=== JAR АНАЛИЗ (МЕТАДАННЫЕ) ===" "TITLE"

    # Если указан AllDisks — добавляем все диски в общий список
    if ($AllDisks) {
        $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 }
        foreach ($drive in $drives) {
            $Script:MinecraftPaths += @{ Path = "$($drive.Name):\"; Name = "Disk$($drive.Name)"; Type = "manual" }
        }
    }

    # Если ModsOnly — фильтруем только категорию mods
    if ($ModsOnly) {
        $Script:MinecraftPaths = $Script:MinecraftPaths | Where-Object { $_.Type -eq "mods" }
    }

    $metas = Get-AllJarMetadata -IncludeDownloads:$IncludeDownloads -ComputeHash:$ComputeHash
    if (-not $metas -or $metas.Count -eq 0) {
        Write-Log "Нечего сканировать." "WARN"
        return
    }

    # Сохраняем в глобальную переменную для следующих частей (Part 2+)
    $Script:LastJarMetas = $metas

    Show-MetadataSummary -Metas $metas

    # Отдельно флагим то, что нашли по метаданным
    $flagged = 0
    foreach ($m in $metas) {
        $reasons = @()
        if ($m.Manifest -and $m.Manifest.AgentFlags.Count -gt 0) {
            foreach ($f in $m.Manifest.AgentFlags) { $reasons += "Java-Agent: $f" }
        }
        if ($m.HashMatch) { $reasons += "SHA256 совпадает с: $($m.HashMatch)" }
        if ($m.Fabric -and $m.Fabric.RedFlags.Count -gt 0) {
            foreach ($f in $m.Fabric.RedFlags) { $reasons += $f }
        }
        if ($m.Forge -and $m.Forge.RedFlags.Count -gt 0) {
            foreach ($f in $m.Forge.RedFlags) { $reasons += $f }
        }
        if ($m.McmodInfo -and $m.McmodInfo.RedFlags.Count -gt 0) {
            foreach ($f in $m.McmodInfo.RedFlags) { $reasons += $f }
        }

        if ($reasons.Count -gt 0) {
            $flagged++
            Write-Log "ПОДОЗРИТЕЛЬНО: $($m.Path)" "FOUND"
            foreach ($r in $reasons) {
                Write-Host "      → $r" -ForegroundColor DarkRed
                $Script:Report.Add("      → $r")
            }
        }
    }

    Write-Log "Просканировано JAR (metadata): $($metas.Count), флагов: $flagged" "INFO"
    Write-Log "Данные сохранены в `$Script:LastJarMetas для Part 2 (байткод)" "INFO"
}

# ═══════════════════════════════════════════════════════════════════════
# 1.12 — Заглушка для совместимости с меню (Part 2+ переопределит)
# ═══════════════════════════════════════════════════════════════════════
function Start-JarScanParallel {
    param([switch]$AllDisks, [switch]$ModsOnly)
    Start-JarScan -AllDisks:$AllDisks -ModsOnly:$ModsOnly
}
# ╔══════════════════════════════════════════════════════════════════════╗
# ║  JAR SCANNER v7.0 — PART 2/7                                         ║
# ║  Модуль: CONSTANT POOL PARSER + DEEP BYTECODE ANALYSIS               ║
# ║  Читает каждый .class, парсит constant pool (все 14 тегов),          ║
# ║  извлекает строки, пакеты, ссылки на методы, детектит обфускацию.    ║
# ║  Параллельный (RunspacePool), совместим с PS 5.1.                    ║
# ╚══════════════════════════════════════════════════════════════════════╝

# ═══════════════════════════════════════════════════════════════════════
# ВЕСА СИГНАТУР (score-based детект)
# ═══════════════════════════════════════════════════════════════════════
$Script:SignatureWeights = @{
    Definitive = 10    # killaura, aimbot, autototem — мгновенный флаг
    Signature  = 3     # tracers, esp — нужна комбинация
    Package    = 5     # functions/combat/, module/hack/
    ClassName  = 8     # класс с именем Combat.*, KillAura.*
    MethodName = 6     # метод attackEntity, renderESP
    FieldName  = 4     # поле hitboxExpansion
    Agent      = 15    # Java-Agent флаги
    HashMatch  = 100   # совпадение SHA256 с известным читом
    Obfuscated = 4     # сильная обфускация
}
$Script:ScoreThreshold = 5
$Script:DefinitiveThreshold = 15   # столько нужно для красного флага

# ═══════════════════════════════════════════════════════════════════════
# 2.1 — Полный парсер constant pool (все 14 тегов JVM)
# ═══════════════════════════════════════════════════════════════════════
function Get-ConstantPool {
    param(
        [byte[]]$Bytes,
        [int]$MaxStrings = 8000,
        [int]$MaxRefs = 2000
    )

    $result = [PSCustomObject]@{
        Utf8Strings   = New-Object System.Collections.Generic.List[string]
        ClassNames    = New-Object System.Collections.Generic.List[string]
        MethodRefs    = New-Object System.Collections.Generic.List[string]
        FieldRefs     = New-Object System.Collections.Generic.List[string]
        StringLits    = New-Object System.Collections.Generic.List[string]
        Interfaces    = New-Object System.Collections.Generic.List[string]
        TotalEntries  = 0
        Parsed        = $false
        Error         = $null
    }

    try {
        if ($Bytes.Length -lt 10) { return $result }

        # Magic (4) + minor (2) + major (2) = 8 байт заголовка
        $magic = ([int]$Bytes[0] -shl 24) -bor ([int]$Bytes[1] -shl 16) -bor ([int]$Bytes[2] -shl 8) -bor [int]$Bytes[3]
        if ($magic -ne 0xCAFEBABE) {
            $result.Error = "Не .class файл (magic=$([System.BitConverter]::ToString($Bytes[0..3])))"
            return $result
        }

        $off = 8
        $cpCount = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
        $off += 2
        $result.TotalEntries = $cpCount

        # Хранилище для разрешения ссылок: индекс → значение
        $cpIndex = @{}
        $i = 1

        while ($i -lt $cpCount -and $off -lt $Bytes.Length) {
            if ($off -ge $Bytes.Length) { break }
            $tag = [int]$Bytes[$off]; $off++

            switch ($tag) {
                # UTF8 — основной источник строк
                1 {
                    if ($off + 2 -gt $Bytes.Length) { break }
                    $len = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
                    $off += 2
                    if ($off + $len -le $Bytes.Length -and $len -gt 0) {
                        $str = [System.Text.Encoding]::UTF8.GetString($Bytes, $off, $len)
                        if ($result.Utf8Strings.Count -lt $MaxStrings) {
                            $result.Utf8Strings.Add($str)
                            $cpIndex[$i] = $str
                        }
                    }
                    $off += $len
                }

                # Class reference — индекс в UTF8 таблице
                7 {
                    if ($off + 2 -gt $Bytes.Length) { break }
                    $idx = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
                    $off += 2
                    if ($cpIndex.ContainsKey($idx)) {
                        $result.ClassNames.Add($cpIndex[$idx])
                    }
                    $cpIndex[$i] = "CLASS_REF_$idx"
                }

                # String literal
                8 {
                    if ($off + 2 -gt $Bytes.Length) { break }
                    $idx = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
                    $off += 2
                    if ($cpIndex.ContainsKey($idx) -and $result.StringLits.Count -lt $MaxStrings) {
                        $result.StringLits.Add($cpIndex[$idx])
                    }
                }

                # Integer / Float — 4 байта
                3 { $off += 4 }
                4 { $off += 4 }

                # Long / Double — 8 байт + занимают 2 слота
                5 { $off += 8; $i++ }
                6 { $off += 8; $i++ }

                # Fieldref / Methodref / InterfaceMethodref — 4 байта (class_idx + name_type_idx)
                9 {
                    if ($off + 4 -gt $Bytes.Length) { break }
                    $classIdx = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
                    $ntIdx    = ([int]$Bytes[$off + 2] -shl 8) -bor [int]$Bytes[$off + 3]
                    $off += 4
                    if ($result.FieldRefs.Count -lt $MaxRefs) {
                        $cls = if ($cpIndex.ContainsKey($classIdx)) { $cpIndex[$classIdx] } else { "?" }
                        $nt = if ($cpIndex.ContainsKey($ntIdx)) { $cpIndex[$ntIdx] } else { "?" }
                        $result.FieldRefs.Add("$cls.$nt")
                    }
                }
                10 {
                    if ($off + 4 -gt $Bytes.Length) { break }
                    $classIdx = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
                    $ntIdx    = ([int]$Bytes[$off + 2] -shl 8) -bor [int]$Bytes[$off + 3]
                    $off += 4
                    if ($result.MethodRefs.Count -lt $MaxRefs) {
                        $cls = if ($cpIndex.ContainsKey($classIdx)) { $cpIndex[$classIdx] } else { "?" }
                        $nt = if ($cpIndex.ContainsKey($ntIdx)) { $cpIndex[$ntIdx] } else { "?" }
                        $result.MethodRefs.Add("$cls.$nt")
                    }
                }
                11 {
                    if ($off + 4 -gt $Bytes.Length) { break }
                    $off += 4
                }

                # NameAndType — 4 байта
                12 { $off += 4 }

                # MethodHandle — 3 байта
                15 { $off += 3 }

                # MethodType — 2 байта
                16 { $off += 2 }

                # Dynamic / InvokeDynamic — 4 байта
                17 { $off += 4 }
                18 { $off += 4 }

                # Module / Package — 2 байта
                19 { $off += 2 }
                20 { $off += 2 }

                default {
                    # Неизвестный тег — прерываем, чтобы не сломать поток
                    $result.Error = "Неизвестный тег CP: $tag @ $off"
                    break
                }
            }
            $i++
        }

        $result.Parsed = $true
    } catch {
        $result.Error = $_.Exception.Message
    }

    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 2.2 — Анализ access flags и интерфейсов класса
# ═══════════════════════════════════════════════════════════════════════
function Get-ClassFlags {
    param([byte[]]$Bytes)

    $result = [PSCustomObject]@{
        IsPublic      = $false
        IsFinal       = $false
        IsInterface   = $false
        IsAbstract    = $false
        IsSynthetic   = $false
        IsAnnotation  = $false
        IsEnum        = $false
        SuperClass    = $null
        InterfaceList = @()
    }

    try {
        if ($Bytes.Length -lt 10) { return $result }

        # Пропускаем: magic(4) + version(4) + cp_count(2) + cp[]
        # Нам нужен весь CP, чтобы дойти до access_flags
        $off = 8
        $cpCount = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
        $off += 2
        $i = 1

        while ($i -lt $cpCount -and $off -lt $Bytes.Length) {
            $tag = [int]$Bytes[$off]; $off++
            switch ($tag) {
                1 {
                    if ($off + 2 -gt $Bytes.Length) { break }
                    $len = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
                    $off += 2 + $len
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

        # access_flags (2 байта) — битовая маска
        if ($off + 2 -gt $Bytes.Length) { return $result }
        $flags = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
        $off += 2

        $result.IsPublic     = [bool]($flags -band 0x0001)
        $result.IsFinal      = [bool]($flags -band 0x0010)
        $result.IsInterface  = [bool]($flags -band 0x0200)
        $result.IsAbstract   = [bool]($flags -band 0x0400)
        $result.IsSynthetic  = [bool]($flags -band 0x1000)
        $result.IsAnnotation = [bool]($flags -band 0x2000)
        $result.IsEnum       = [bool]($flags -band 0x4000)

        # this_class (2) + super_class (2)
        $off += 2  # this_class
        $off += 2  # super_class

        # interfaces_count (2) + interfaces[]
        if ($off + 2 -gt $Bytes.Length) { return $result }
        $ifaceCount = ([int]$Bytes[$off] -shl 8) -bor [int]$Bytes[$off + 1]
        $off += 2
        $off += ($ifaceCount * 2)  # 2 байта на интерфейс

        $result.InterfaceList = @()  # индексы; разрешать не будем, для статистики хватит
    } catch { }
    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 2.3 — Поиск сигнатур в строках + пакетах + именах методов
# ═══════════════════════════════════════════════════════════════════════
function Find-SignaturesInClass {
    param(
        [string]$ClassName,        # Внутреннее имя: com/example/Foo
        [string]$ClassBytesRaw,    # Не используется, оставлено для сигнатуры
        [array]$Utf8Strings,       # Все UTF8 из constant pool
        [array]$MethodRefs,        # Ссылки на методы
        [array]$FieldRefs,         # Ссылки на поля
        [array]$ClassNames,        # Ссылки на классы
        [array]$DefinitiveFuncs,
        [array]$SignatureFuncs,
        [array]$PackageIndicators,
        [hashtable]$Weights
    )

    $hits = New-Object System.Collections.Generic.List[object]
    $seen = @{}

    # 2.3.1 — Пакет
    $classPkg = ($ClassName -replace '/[^/]+$','')
    foreach ($pkg in $PackageIndicators) {
        if ($classPkg -match [regex]::Escape($pkg)) {
            $key = "pkg:$pkg"
            if (-not $seen.ContainsKey($key)) {
                $seen[$key] = $true
                $hits.Add([PSCustomObject]@{
                    Category = 'Package'
                    Value    = $pkg
                    Where    = $ClassName
                    Score    = $Weights.Package
                    Detail   = "Пакет: $classPkg"
                })
            }
        }
    }

    # 2.3.2 — Имя класса (последний сегмент)
    $shortName = ($ClassName -replace '^.*/','')
    foreach ($def in $DefinitiveFuncs) {
        if ($shortName -match [regex]::Escape($def)) {
            $key = "cls:$def"
            if (-not $seen.ContainsKey($key)) {
                $seen[$key] = $true
                $hits.Add([PSCustomObject]@{
                    Category = 'ClassName'
                    Value    = $def
                    Where    = $ClassName
                    Score    = $Weights.ClassName
                    Detail   = "Имя класса содержит '$def'"
                })
            }
        }
    }

    # 2.3.3 — UTF8 строки (самое частое место читов)
    foreach ($str in $Utf8Strings) {
        $strLower = $str.ToLower()
        foreach ($def in $DefinitiveFuncs) {
            if ($strLower -match $def) {
                $key = "str:$def"
                if (-not $seen.ContainsKey($key)) {
                    $seen[$key] = $true
                    $hits.Add([PSCustomObject]@{
                        Category = 'String'
                        Value    = $def
                        Where    = $ClassName
                        Score    = $Weights.Definitive
                        Detail   = "UTF8: '$str'"
                    })
                }
            }
        }
        foreach ($sig in $SignatureFuncs) {
            if ($strLower -match $sig) {
                $key = "strs:$sig"
                if (-not $seen.ContainsKey($key)) {
                    $seen[$key] = $true
                    $hits.Add([PSCustomObject]@{
                        Category = 'Signature'
                        Value    = $sig
                        Where    = $ClassName
                        Score    = $Weights.Signature
                        Detail   = "UTF8: '$str'"
                    })
                }
            }
        }
    }

    # 2.3.4 — Methodref (прямые вызовы чужих методов)
    foreach ($ref in $MethodRefs) {
        $refLower = $ref.ToLower()
        foreach ($def in $DefinitiveFuncs) {
            if ($refLower -match $def) {
                $key = "mref:$def"
                if (-not $seen.ContainsKey($key)) {
                    $seen[$key] = $true
                    $hits.Add([PSCustomObject]@{
                        Category = 'MethodRef'
                        Value    = $def
                        Where    = $ClassName
                        Score    = $Weights.MethodName
                        Detail   = "Вызов метода: $ref"
                    })
                }
            }
        }
    }

    # 2.3.5 — Fieldref
    foreach ($ref in $FieldRefs) {
        $refLower = $ref.ToLower()
        foreach ($def in $DefinitiveFuncs) {
            if ($refLower -match $def) {
                $key = "fref:$def"
                if (-not $seen.ContainsKey($key)) {
                    $seen[$key] = $true
                    $hits.Add([PSCustomObject]@{
                        Category = 'FieldRef'
                        Value    = $def
                        Where    = $ClassName
                        Score    = $Weights.FieldName
                        Detail   = "Поле: $ref"
                    })
                }
            }
        }
    }

    return $hits
}

# ═══════════════════════════════════════════════════════════════════════
# 2.4 — Эвристика обфускации для одного класса
# ═══════════════════════════════════════════════════════════════════════
function Test-ClassObfuscation {
    param(
        [string]$ClassName,
        [array]$Utf8Strings
    )

    $score = 0
    $reasons = @()

    $shortName = ($ClassName -replace '^.*/','')
    $pkg = ($ClassName -replace '/[^/]+$','')

    # Короткое имя класса (a, b, aa, ab)
    if ($shortName -match '^[a-zA-Z_$][a-zA-Z0-9_$]?$') {
        $score += 2
        $reasons += "Короткое имя класса: '$shortName'"
    }

    # Короткий пакет (a/b/c, x/y)
    if ($pkg -and $pkg -match '^[a-z](\/[a-z])*$' -and $pkg.Length -lt 8) {
        $score += 2
        $reasons += "Короткий пакет: '$pkg'"
    }

    # Очень мало строк UTF8 (обфускатор их удаляет)
    if ($Utf8Strings.Count -lt 5) {
        $score += 1
        $reasons += "Мало строк UTF8: $($Utf8Strings.Count)"
    }

    # Нечитаемые символы в строках
    $garbageCount = 0
    foreach ($s in ($Utf8Strings | Select-Object -First 30)) {
        if ($s -match '[\x00-\x1F\x7F-\xFF]') { $garbageCount++ }
    }
    if ($garbageCount -gt 5) {
        $score += 2
        $reasons += "Строки с нечитаемыми символами: $garbageCount"
    }

    # Строки, состоящие из 1-2 символов
    $tinyStrings = ($Utf8Strings | Where-Object { $_.Length -le 2 }).Count
    if ($Utf8Strings.Count -gt 0 -and ($tinyStrings / $Utf8Strings.Count) -gt 0.7) {
        $score += 2
        $reasons += "Много однобуквенных строк: $tinyStrings/$($Utf8Strings.Count)"
    }

    return [PSCustomObject]@{
        Score   = $score
        Reasons = $reasons
        IsObfuscated = $score -ge 4
    }
}

# ═══════════════════════════════════════════════════════════════════════
# 2.5 — Глубокий анализ одного .class файла
# ═══════════════════════════════════════════════════════════════════════
function Invoke-ClassDeepScan {
    param(
        [string]$ClassName,
        [byte[]]$Bytes,
        [array]$DefinitiveFuncs,
        [array]$SignatureFuncs,
        [array]$PackageIndicators,
        [hashtable]$Weights
    )

    $result = [PSCustomObject]@{
        ClassName    = $ClassName
        Score        = 0
        Hits         = @()
        ObfuscationScore = 0
        ObfuscationReasons = @()
        Error        = $null
    }

    try {
        # 1. Constant pool
        $cp = Get-ConstantPool -Bytes $Bytes
        if (-not $cp.Parsed) {
            $result.Error = $cp.Error
            return $result
        }

        # 2. Access flags
        $flags = Get-ClassFlags -Bytes $Bytes

        # 3. Обфускация
        $obf = Test-ClassObfuscation -ClassName $ClassName -Utf8Strings $cp.Utf8Strings
        $result.ObfuscationScore = $obf.Score
        $result.ObfuscationReasons = $obf.Reasons
        if ($obf.IsObfuscated) {
            $result.Score += $Weights.Obfuscated
        }

        # 4. Сигнатуры
        $hits = Find-SignaturesInClass `
            -ClassName $ClassName `
            -ClassBytesRaw '' `
            -Utf8Strings $cp.Utf8Strings `
            -MethodRefs $cp.MethodRefs `
            -FieldRefs $cp.FieldRefs `
            -ClassNames $cp.ClassNames `
            -DefinitiveFuncs $DefinitiveFuncs `
            -SignatureFuncs $SignatureFuncs `
            -PackageIndicators $PackageIndicators `
            -Weights $Weights

        $result.Hits = $hits

        # 5. Суммируем score (уникальные категории)
        $sumScore = 0
        $seenCat = @{}
        foreach ($h in $hits) {
            $key = "$($h.Category):$($h.Value)"
            if (-not $seenCat.ContainsKey($key)) {
                $seenCat[$key] = $true
                $sumScore += $h.Score
            }
        }
        $result.Score += $sumScore

    } catch {
        $result.Error = $_.Exception.Message
    }

    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 2.6 — Глубокий анализ одного JAR (все .class + агрегация score)
# ═══════════════════════════════════════════════════════════════════════
function Invoke-JarDeepScan {
    param(
        [string]$JarPath,
        [string]$JarFileName,
        [string]$LauncherName,
        [array]$DefinitiveFuncs,
        [array]$SignatureFuncs,
        [array]$PackageIndicators,
        [hashtable]$Weights,
        [int]$Threshold
    )

    $result = [PSCustomObject]@{
        Path              = $JarPath
        FileName          = $JarFileName
        Launcher          = $LauncherName
        Score             = 0
        ClassCount        = 0
        ScannedClasses    = 0
        ObfuscatedClasses = 0
        TopHits           = @()
        AllHits           = @()
        TopOffenders      = @()    # классы с наибольшим score
        Error             = $null
        Duration          = 0
    }

    $timer = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)

        $classes = $zip.Entries | Where-Object { $_.FullName -match '\.class$' -and $_.Length -lt 2MB }
        $result.ClassCount = $classes.Count

        # Лимит: не более 3000 классов на JAR (иначе бесконечно)
        $maxClasses = [Math]::Min(3000, $classes.Count)
        $processed = 0

        $classScores = @()
        $allHits = New-Object System.Collections.Generic.List[object]

        foreach ($entry in $classes) {
            if ($processed -ge $maxClasses) { break }
            $processed++

            try {
                $stream = $entry.Open()
                $ms = New-Object System.IO.MemoryStream
                $stream.CopyTo($ms)
                $bytes = $ms.ToArray()
                $stream.Close()
                $ms.Close()

                if ($bytes.Length -lt 10 -or $bytes.Length -gt 2MB) { continue }

                $className = $entry.FullName -replace '\.class$',''
                $scan = Invoke-ClassDeepScan `
                    -ClassName $className `
                    -Bytes $bytes `
                    -DefinitiveFuncs $DefinitiveFuncs `
                    -SignatureFuncs $SignatureFuncs `
                    -PackageIndicators $PackageIndicators `
                    -Weights $Weights

                $result.ScannedClasses++

                if ($scan.ObfuscationScore -ge 4) { $result.ObfuscatedClasses++ }

                if ($scan.Score -gt 0) {
                    $classScores += [PSCustomObject]@{
                        Class = $className
                        Score = $scan.Score
                        Hits  = $scan.Hits
                    }
                    foreach ($h in $scan.Hits) { $allHits.Add($h) }
                }
            } catch {
                # Игнорируем отдельные сломанные классы
            }
        }
        $zip.Dispose()

        # Агрегация score по JAR
        $totalScore = 0
        $uniqueSignatures = @{}
        foreach ($h in $allHits) {
            $key = "$($h.Category):$($h.Value)"
            if (-not $uniqueSignatures.ContainsKey($key)) {
                $uniqueSignatures[$key] = $true
                $totalScore += $h.Score
            }
        }
        $result.Score = $totalScore

        # Топ классов по score
        $result.TopOffenders = $classScores | Sort-Object Score -Descending | Select-Object -First 10

        # Топ уникальных хитов
        $result.TopHits = $allHits |
            Group-Object Category, Value |
            ForEach-Object {
                [PSCustomObject]@{
                    Category = $_.Group[0].Category
                    Value    = $_.Group[0].Value
                    Score    = $_.Group[0].Score
                    Detail   = $_.Group[0].Detail
                    Count    = $_.Count
                }
            } | Sort-Object Score, Count -Descending | Select-Object -First 15

        $result.AllHits = $allHits

        # Штраф за сильную обфускацию (если классы > 20 и обфусцировано > 50%)
        if ($result.ClassCount -gt 20 -and ($result.ObfuscatedClasses / $result.ClassCount) -gt 0.5) {
            $result.Score += $Weights.Obfuscated
        }
    } catch {
        $result.Error = $_.Exception.Message
    }

    $timer.Stop()
    $result.Duration = $timer.ElapsedMilliseconds

    # Обнуляем причины, если score ниже порога
    if ($result.Score -lt $Threshold) {
        $result.TopHits = @()
        $result.AllHits = @()
        $result.TopOffenders = @()
    }

    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 2.7 — Параллельный запуск (RunspacePool, PS 5.1-совместимо)
# ═══════════════════════════════════════════════════════════════════════
function Invoke-JarDeepScanParallel {
    param(
        [array]$Jars,           # Массив объектов { FullPath, FileName, Launcher }
        [int]$Threads = 8,
        [int]$Threshold = 5
    )

    if (-not $Jars -or $Jars.Count -eq 0) {
        Write-Log "Нет JAR для глубокого скана." "WARN"
        return @()
    }

    $cpu = [Environment]::ProcessorCount
    $actualThreads = [Math]::Max(1, [Math]::Min($cpu, $Threads))
    Write-Log "Глубокий скан: $($Jars.Count) JAR, потоков: $actualThreads (CPU: $cpu)" "INFO"

    $pool = [RunspaceFactory]::CreateRunspacePool(1, $actualThreads)
    $pool.Open()

    # Извлекаем определение функции, чтобы передать в поток
    $funcDef = (Get-Item function:Invoke-JarDeepScan).Definition
    $cpDef   = (Get-Item function:Get-ConstantPool).Definition
    $flagDef = (Get-Item function:Get-ClassFlags).Definition
    $sigDef  = (Get-Item function:Find-SignaturesInClass).Definition
    $obfDef  = (Get-Item function:Test-ClassObfuscation).Definition
    $clsDef  = (Get-Item function:Invoke-ClassDeepScan).Definition

    $jobs = @()
    $jobIdx = 0
    foreach ($jar in $Jars) {
        $jobIdx++
        $ps = [PowerShell]::Create()
        $ps.RunspacePool = $pool

        [void]$ps.AddScript({
            param($JarPath, $JarFileName, $LauncherName,
                  $Def, $Sig, $Pkg, $Weights, $Threshold,
                  $FuncDefs)
            # Восстанавливаем все функции в этом Runspace
            foreach ($fd in $FuncDefs) {
                . ([ScriptBlock]::Create($fd))
            }
            Invoke-JarDeepScan `
                -JarPath $JarPath `
                -JarFileName $JarFileName `
                -LauncherName $LauncherName `
                -DefinitiveFuncs $Def `
                -SignatureFuncs $Sig `
                -PackageIndicators $Pkg `
                -Weights $Weights `
                -Threshold $Threshold
        }).AddArgument($jar.FullPath) `
          .AddArgument($jar.FileName) `
          .AddArgument($jar.Launcher) `
          .AddArgument($Script:DefinitiveFuncs) `
          .AddArgument($Script:SignatureFuncs) `
          .AddArgument($Script:PackageIndicators) `
          .AddArgument($Script:SignatureWeights) `
          .AddArgument($Threshold) `
          .AddArgument(@($funcDef, $cpDef, $flagDef, $sigDef, $obfDef, $clsDef))

        $jobs += [PSCustomObject]@{
            PS     = $ps
            Handle = $ps.BeginInvoke()
            Jar    = $jar
        }
    }

    # Собираем результаты
    $results = New-Object System.Collections.Generic.List[object]
    $done = 0
    $flagged = 0

    foreach ($job in $jobs) {
        try {
            $res = $job.PS.EndInvoke($job.Handle)
            $done++

            if ($res) {
                $results.Add($res)
                if ($res.Score -ge $Threshold) { $flagged++ }
            }

            $pct = [math]::Round(($done / $jobs.Count) * 100)
            $line = "  [$pct%] $done/$($jobs.Count) — флагов: $flagged — последний: $($job.Jar.FileName.Substring(0, [Math]::Min(40, $job.Jar.FileName.Length)))"
            Write-Host "`r$($line.PadRight(120))" -NoNewline -ForegroundColor DarkGray
        } catch {
            Write-Log "Ошибка обработки $($job.Jar.FileName): $_" "WARN"
        } finally {
            $job.PS.Dispose()
        }
    }
    Write-Host ""

    $pool.Close()
    $pool.Dispose()

    Write-Log "Глубокий скан завершён: $($results.Count) JAR, флагов: $flagged" "INFO"
    return $results
}

# ═══════════════════════════════════════════════════════════════════════
# 2.8 — Вывод результатов глубокого скана
# ═══════════════════════════════════════════════════════════════════════
function Show-DeepScanResults {
    param([array]$Results, [int]$Threshold = 5)

    if (-not $Results -or $Results.Count -eq 0) {
        Write-Log "Результатов нет." "OK"
        return
    }

    $flagged = $Results | Where-Object { $_.Score -ge $Threshold } | Sort-Object Score -Descending
    $clean = $Results.Count - $flagged.Count

    Write-Host ""
    Write-Host "  ┌─── РЕЗУЛЬТАТЫ ГЛУБОКОГО СКАНА ─────────────────────" -ForegroundColor Cyan
    Write-Host "  │ Всего JAR:        $($Results.Count)" -ForegroundColor White
    Write-Host "  │ Чистых:           $clean" -ForegroundColor Green
    Write-Host "  │ Подозрительных:   $($flagged.Count)" -ForegroundColor $(if ($flagged.Count -gt 0) { "Red" } else { "Green" })
    Write-Host "  └────────────────────────────────────────────────────" -ForegroundColor Cyan

    if ($flagged.Count -eq 0) {
        Write-Host ""
        Write-Log "Читов не обнаружено." "OK"
        return
    }

    # Топ-30 (чтобы не заспамить консоль)
    $top = $flagged | Select-Object -First 30
    foreach ($r in $top) {
        Write-Host ""
        $scoreColor = if ($r.Score -ge 30) { "Red" } elseif ($r.Score -ge 15) { "Magenta" } else { "Yellow" }
        Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $scoreColor
        Write-Host "  ║ ЧИТ: $($r.FileName)" -ForegroundColor $scoreColor
        Write-Host "  ║ Score: $($r.Score) | Классов: $($r.ScannedClasses)/$($r.ClassCount) | Обфусцировано: $($r.ObfuscatedClasses) | $($r.Duration)ms" -ForegroundColor $scoreColor
        Write-Host "  ║ Путь: $($r.Path)" -ForegroundColor DarkGray
        Write-Host "  ║ Лаунчер: $($r.Launcher)" -ForegroundColor DarkGray
        Write-Host "  ╠══════════════════════════════════════════════════════════════╣" -ForegroundColor $scoreColor

        foreach ($h in $r.TopHits | Select-Object -First 8) {
            Write-Host "  ║   [$($h.Category)] +$($h.Score) × $($h.Count): $($h.Value)" -ForegroundColor $scoreColor
            Write-Host "  ║     $($h.Detail)" -ForegroundColor DarkGray
        }

        if ($r.TopOffenders.Count -gt 0) {
            Write-Host "  ║ Классы-нарушители:" -ForegroundColor $scoreColor
            foreach ($off in $r.TopOffenders | Select-Object -First 3) {
                Write-Host "  ║   • $($off.Class) (score=$($off.Score))" -ForegroundColor DarkRed
            }
        }
        Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $scoreColor

        $Script:Report.Add("ЧИТ: $($r.Path) [score=$($r.Score), $($r.ObfuscatedClasses)/$($r.ClassCount) обфусцировано]")
        foreach ($h in $r.TopHits | Select-Object -First 5) {
            $Script:Report.Add("  [$($h.Category)] $($h.Value) — $($h.Detail)")
        }
    }

    if ($flagged.Count -gt $top.Count) {
        Write-Host ""
        Write-Host "  ... и ещё $($flagged.Count - $top.Count) подозрительных JAR (полный список в отчёте)" -ForegroundColor Yellow
    }
}

# ═══════════════════════════════════════════════════════════════════════
# 2.9 — ОСНОВНАЯ ФУНКЦИЯ (переопределяет Start-JarScan из Part 1)
# ═══════════════════════════════════════════════════════════════════════
function Start-JarScan {
    param(
        [switch]$ModsOnly,
        [switch]$AllDisks,
        [switch]$IncludeDownloads,
        [switch]$ComputeHash,
        [switch]$MetadataOnly
    )

    Write-Log "=== JAR АНАЛИЗ (v7.0 DEEP) ===" "TITLE"

    # 1. DISCOVERY (Part 1)
    Write-Log "Этап 1/3: Поиск JAR..." "INFO"
    $jars = Find-AllJars -IncludeDownloads:$IncludeDownloads
    if ($jars.Count -eq 0) {
        Write-Log "Не найдено ни одного .jar" "WARN"
        return
    }
    Write-Log "Найдено JAR: $($jars.Count)" "OK"

    # 2. MЕТАДАННЫЕ (Part 1)
    Write-Log "Этап 2/3: Чтение метаданных (manifest, mods.toml, fabric.mod.json)..." "INFO"
    $metas = New-Object System.Collections.Generic.List[object]
    $i = 0
    foreach ($jar in $jars) {
        $i++
        $pct = [math]::Round(($i / $jars.Count) * 100)
        Write-Host "`r  [$pct%] $i/$($jars.Count) — $($jar.FileName.PadRight(60).Substring(0,60))" -NoNewline -ForegroundColor DarkGray
        $m = Read-JarMetadata -JarPath $jar.FullPath -ComputeHash:$ComputeHash
        $metas.Add($m)
    }
    Write-Host ""
    Write-Log "Обработано метаданных: $($metas.Count)" "OK"
    Show-MetadataSummary -Metas $metas

    # Отдельно флагим по метаданным
    foreach ($m in $metas) {
        $reasons = @()
        if ($m.Manifest -and $m.Manifest.AgentFlags.Count -gt 0) {
            foreach ($f in $m.Manifest.AgentFlags) { $reasons += "Java-Agent: $f" }
        }
        if ($m.HashMatch) { $reasons += "SHA256 совпадает с: $($m.HashMatch)" }
        if ($m.Fabric -and $m.Fabric.RedFlags.Count -gt 0) {
            foreach ($f in $m.Fabric.RedFlags) { $reasons += $f }
        }
        if ($m.Forge -and $m.Forge.RedFlags.Count -gt 0) {
            foreach ($f in $m.Forge.RedFlags) { $reasons += $f }
        }
        if ($m.McmodInfo -and $m.McmodInfo.RedFlags.Count -gt 0) {
            foreach ($f in $m.McmodInfo.RedFlags) { $reasons += $f }
        }

        if ($reasons.Count -gt 0) {
            Write-Log "ПОДОЗРИТЕЛЬНО (metadata): $($m.Path)" "FOUND"
            foreach ($r in $reasons) {
                Write-Host "      → $r" -ForegroundColor DarkRed
                $Script:Report.Add("      → $r")
            }
        }
    }

    $Script:LastJarMetas = $metas

    if ($MetadataOnly) {
        Write-Log "Metadata-only режим — глубокий скан пропущен." "WARN"
        return
    }

    # 3. ГЛУБОКИЙ СКАН (Part 2)
    Write-Log "Этап 3/3: Глубокий анализ байткода (constant pool)..." "INFO"

    # Передаём в параллельный скан только JAR, которые не были отсеяны
    $toScan = @()
    foreach ($jar in $jars) {
        # Пропускаем известные безопасные (whitelist) — это уже сделано в Find-AllJars? Нет, сделаем здесь
        if (Test-Whitelisted -FullPath $jar.FullPath -Name $jar.FileName.ToLower()) { continue }
        $toScan += [PSCustomObject]@{
            FullPath = $jar.FullPath
            FileName = $jar.FileName
            Launcher = $jar.Launcher
        }
    }

    Write-Log "После whitelist осталось: $($toScan.Count) JAR для глубокого скана" "INFO"

    if ($toScan.Count -eq 0) {
        Write-Log "Все JAR в whitelist — глубокий скан не требуется." "OK"
        return
    }

    $deep = Invoke-JarDeepScanParallel -Jars $toScan -Threshold $Script:ScoreThreshold
    $Script:LastDeepResults = $deep

    Show-DeepScanResults -Results $deep -Threshold $Script:ScoreThreshold
}

# ═══════════════════════════════════════════════════════════════════════
# 2.10 — Совместимость: Start-JarScanParallel (для меню) → Start-JarScan
# ═══════════════════════════════════════════════════════════════════════
function Start-JarScanParallel {
    param([switch]$AllDisks, [switch]$ModsOnly)
    Start-JarScan -AllDisks:$AllDisks -ModsOnly:$ModsOnly
}

Write-Host "  >>> PART 2 LOADED — Constant Pool Parser + Deep Bytecode <<<" -ForegroundColor Magenta
# ╔══════════════════════════════════════════════════════════════════════╗
# ║  JAR SCANNER v7.0 — PART 3/7                                         ║
# ║  Модули:                                                             ║
# ║    3.1 Network Strings — URL, IP, домены внутри JAR                  ║
# ║    3.2 Native Scanner — .dll / .so / .dylib внутри JAR               ║
# ║    3.3 Nested JARs — .jar внутри .jar (рекурсивно)                   ║
# ║    3.4 Dangerous Patterns — Runtime.exec, reflection, defineClass    ║
# ║    3.5 Интеграция в Start-JarScan                                    ║
# ╚══════════════════════════════════════════════════════════════════════╝

# ═══════════════════════════════════════════════════════════════════════
# КОНСТАНТЫ Part 3
# ═══════════════════════════════════════════════════════════════════════

# Подозрительные домены / TLD, куда читы стучат (C2, лицензии, авторизация)
$Script:SuspiciousDomains = @(
    # Читерские CDN / сайты
    'vape.gg','vape.rip','vapeclient','impactclient','wurstclient','sigma-client',
    'sigmaclient','meteorclient','aristois','liquidbounce','futureclient',
    'konas','zeusclient','richclient','novoline','astolfo','moonlight',
    'doomsday','nightware','extazyy','zamorozka','nursultan',
    # Пастбины / временный хостинг
    'pastebin.com','hastebin.com','paste.ee','ghostbin.co','dpaste.org',
    'transfer.sh','file.io','anonfiles.com','0x0.st','termbin.com',
    # Discord webhooks (кража токенов/логов)
    'discord.com/api/webhooks','discordapp.com/api/webhooks',
    'ptb.discord.com/api/webhooks','canary.discord.com/api/webhooks',
    # Telegram bot API (C2 через TG)
    'api.telegram.org/bot',
    # IP-логгеры
    'iplogger.org','iplogger.com','2no.co','yip.su','iplogger.ru',
    'grabify.link','blasze.tk','iplogger.co','iplogger.info',
    # Обфускаторы / крипторы
    'branchlock.net','radon.execute','zelix.com','stringfog','skidfuscator',
    'qprotect','bozar','paramorphism','reversing.zone'
)

# Опасные Java-паттерны (динамическая загрузка, exec, рефлексия)
$Script:DangerousPatterns = @{
    'Runtime.exec'         = 'Динамическое выполнение команды'
    'ProcessBuilder'       = 'Создание процесса'
    'System.loadLibrary'   = 'Загрузка нативной библиотеки'
    'System.load'          = 'Загрузка нативной библиотеки'
    'URLClassLoader'       = 'Динамическая загрузка класса из URL'
    'defineClass'          = 'Динамическое определение класса (обход)'
    'Class.forName'        = 'Рефлексия — загрузка класса по имени'
    'setAccessible(true)'  = 'Обход модификаторов доступа'
    'java/lang/Runtime'    = 'Прямая ссылка на Runtime'
    'java/lang/reflect'    = 'Прямая ссылка на reflection'
    'sun/misc/Unsafe'      = 'Unsafe — низкоуровневый доступ к памяти'
    'jdk/internal/misc'    = 'Внутренние API JDK'
    'Instrumentation'      = 'Java-agent (инъекция)'
    'VirtualMachine.attach'= 'Присоединение к JVM (агент)'
    'Cipher.getInstance'   = 'Криптография (шифрование строк)'
    'Base64.getDecoder'    = 'Декодирование Base64 (скрытие строк)'
    'XORKey'               = 'XOR-шифрование строк'
    'AESKey'               = 'AES-шифрование строк'
    'gzip'                 = 'Сжатие (упаковка читов)'
    'InflaterInputStream'  = 'Распаковка вложенных данных'
}

# Расширения нативов
$Script:NativeExtensions = @('.dll','.so','.dylib','.jnilib','.node')

# ═══════════════════════════════════════════════════════════════════════
# 3.1 — NETWORK STRINGS: поиск URL, IP, доменов в тексте
# ═══════════════════════════════════════════════════════════════════════
function Find-NetworkStrings {
    param([array]$Utf8Strings)

    $result = [PSCustomObject]@{
        URLs              = New-Object System.Collections.Generic.List[string]
        IPs               = New-Object System.Collections.Generic.List[string]
        Domains           = New-Object System.Collections.Generic.List[string]
        Suspicious        = New-Object System.Collections.Generic.List[string]
        DiscordWebhooks   = New-Object System.Collections.Generic.List[string]
        TelegramBots      = New-Object System.Collections.Generic.List[string]
        PastebinLinks     = New-Object System.Collections.Generic.List[string]
        Score             = 0
    }

    $seenURL = @{}
    $seenIP  = @{}
    $seenDom = @{}

    # Регулярки
    $urlRegex = 'https?://[^\s"''<>)\]}]+'
    $ipRegex  = '\b(?:\d{1,3}\.){3}\d{1,3}\b'
    $domRegex = '\b[a-z0-9][a-z0-9\-]{0,62}(?:\.[a-z0-9\-]{1,62})+\.[a-z]{2,24}\b'

    foreach ($str in $Utf8Strings) {
        # URL
        foreach ($m in [regex]::Matches($str, $urlRegex, 'IgnoreCase')) {
            $url = $m.Value
            if (-not $seenURL.ContainsKey($url)) {
                $seenURL[$url] = $true
                if ($result.URLs.Count -lt 100) { $result.URLs.Add($url) }
            }
        }

        # IP
        foreach ($m in [regex]::Matches($str, $ipRegex)) {
            $ip = $m.Value
            # Отсекаем version-строки (1.21.11, 1.20.1) и локальные
            if ($ip -match '^(0\.|127\.|255\.|10\.|192\.168\.|172\.(1[6-9]|2\d|3[01])\.)') { continue }
            if ($ip -match '^1\.\d+\.\d+$') { continue }  # версии майна
            if ($ip -match '^2\.\d+\.\d+$') { continue }
            if (-not $seenIP.ContainsKey($ip)) {
                $seenIP[$ip] = $true
                if ($result.IPs.Count -lt 50) { $result.IPs.Add($ip) }
            }
        }

        # Домены
        foreach ($m in [regex]::Matches($str, $domRegex, 'IgnoreCase')) {
            $dom = $m.Value.ToLower()
            if (-not $seenDom.ContainsKey($dom)) {
                $seenDom[$dom] = $true
                if ($result.Domains.Count -lt 100) { $result.Domains.Add($dom) }
            }
        }

        # Быстрый поиск по списку подозрительных
        $strLower = $str.ToLower()
        foreach ($susp in $Script:SuspiciousDomains) {
            if ($strLower -match [regex]::Escape($susp)) {
                $result.Suspicious.Add("$susp ← $str")
                $result.Score += 10
            }
        }

        # Discord webhook
        if ($str -match 'discord(?:app)?\.com/api/webhooks/\d+/[\w\-]+') {
            $result.DiscordWebhooks.Add($str)
            $result.Score += 30
        }

        # Telegram bot
        if ($str -match 'api\.telegram\.org/bot[\d]+:[\w\-]+') {
            $result.TelegramBots.Add($str)
            $result.Score += 30
        }

        # Pastebin
        if ($str -match 'pastebin\.com/(raw/)?[\w]+') {
            $result.PastebinLinks.Add($str)
            $result.Score += 15
        }
    }

    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 3.2 — NATIVE SCANNER: поиск .dll / .so / .dylib внутри JAR
# ═══════════════════════════════════════════════════════════════════════
function Find-NativeLibs {
    param([System.IO.Compression.ZipArchive]$Zip)

    $result = [PSCustomObject]@{
        NativeFiles = New-Object System.Collections.Generic.List[object]
        Score       = 0
    }

    foreach ($entry in $Zip.Entries) {
        $ext = [System.IO.Path]::GetExtension($entry.FullName).ToLower()
        if ($Script:NativeExtensions -contains $ext) {
            $fileInfo = [PSCustomObject]@{
                Name       = $entry.FullName
                Size       = $entry.Length
                CompressedSize = $entry.CompressedLength
            }
            $result.NativeFiles.Add($fileInfo)

            # Score: небольшие нативы в JAR — часто читы с нативным крашем/инжектом
            if ($entry.Length -lt 5MB) { $result.Score += 15 }
            else                       { $result.Score += 8 }
        }
    }

    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 3.3 — NESTED JARs: .jar внутри .jar (рекурсивно, до 3 уровней)
# ═══════════════════════════════════════════════════════════════════════
function Find-NestedJars {
    param(
        [System.IO.Compression.ZipArchive]$Zip,
        [int]$CurrentDepth = 1,
        [int]$MaxDepth = 3
    )

    $result = [PSCustomObject]@{
        NestedJars = New-Object System.Collections.Generic.List[object]
        Score      = 0
    }

    foreach ($entry in $Zip.Entries) {
        if ($entry.FullName -match '\.(jar|zip)$' -and $entry.Length -gt 100 -and $entry.Length -lt 20MB) {
            $info = [PSCustomObject]@{
                Name   = $entry.FullName
                Size   = $entry.Length
                Depth  = $CurrentDepth
            }
            $result.NestedJars.Add($info)

            # Score: вложенные JAR — часто маскировка (fat-jar или обфускация)
            if ($CurrentDepth -ge 2) { $result.Score += 20 }  # глубокая матрёшка
            else                     { $result.Score += 5 }

            # Рекурсивно внутрь (если разрешено)
            if ($CurrentDepth -lt $MaxDepth) {
                try {
                    $stream = $entry.Open()
                    $ms = New-Object System.IO.MemoryStream
                    $stream.CopyTo($ms)
                    $ms.Position = 0
                    $innerZip = New-Object System.IO.Compression.ZipArchive($ms, [System.IO.Compression.ZipArchiveMode]::Read)
                    $innerResult = Find-NestedJars -Zip $innerZip -CurrentDepth ($CurrentDepth + 1) -MaxDepth $MaxDepth
                    foreach ($n in $innerResult.NestedJars) {
                        $result.NestedJars.Add($n)
                        $result.Score += $innerResult.Score
                    }
                    $innerZip.Dispose()
                    $stream.Close()
                    $ms.Close()
                } catch { }
            }
        }
    }

    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 3.4 — DANGEROUS PATTERNS: Runtime.exec, reflection, defineClass
# ═══════════════════════════════════════════════════════════════════════
function Find-DangerousPatterns {
    param(
        [array]$Utf8Strings,
        [array]$MethodRefs,
        [array]$ClassNames
    )

    $result = [PSCustomObject]@{
        Hits  = New-Object System.Collections.Generic.List[object]
        Score = 0
    }

    $seen = @{}
    $allText = ($Utf8Strings + $MethodRefs + $ClassNames) -join ' '

    foreach ($pattern in $Script:DangerousPatterns.Keys) {
        $desc = $Script:DangerousPatterns[$pattern]
        if ($allText -match [regex]::Escape($pattern)) {
            $key = "dp:$pattern"
            if (-not $seen.ContainsKey($key)) {
                $seen[$key] = $true
                $result.Hits.Add([PSCustomObject]@{
                    Pattern = $pattern
                    Desc    = $desc
                })
                # Вес зависит от опасности паттерна
                switch ($pattern) {
                    'Runtime.exec'         { $result.Score += 15 }
                    'ProcessBuilder'       { $result.Score += 15 }
                    'System.loadLibrary'   { $result.Score += 20 }
                    'System.load'          { $result.Score += 20 }
                    'URLClassLoader'       { $result.Score += 25 }
                    'defineClass'          { $result.Score += 25 }
                    'setAccessible(true)'  { $result.Score += 10 }
                    'sun/misc/Unsafe'      { $result.Score += 20 }
                    'VirtualMachine.attach'{ $result.Score += 25 }
                    'Instrumentation'      { $result.Score += 15 }
                    default                { $result.Score += 5 }
                }
            }
        }
    }

    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 3.5 — Комплексный анализ одного JAR (Network + Native + Nested + Dangerous)
# ═══════════════════════════════════════════════════════════════════════
function Invoke-JarAuxScan {
    param(
        [string]$JarPath,
        [string]$JarFileName,
        [string]$LauncherName
    )

    $result = [PSCustomObject]@{
        Path             = $JarPath
        FileName         = $JarFileName
        Launcher         = $LauncherName
        Network          = $null
        Native           = $null
        Nested           = $null
        Dangerous        = $null
        TotalScore       = 0
        Error            = $null
        Duration         = 0
    }

    $timer = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)

        # Собираем все UTF8-строки + ссылки из constant pool всех классов
        $allUtf8 = New-Object System.Collections.Generic.List[string]
        $allMethodRefs = New-Object System.Collections.Generic.List[string]
        $allClassNames = New-Object System.Collections.Generic.List[string]

        $classEntries = $zip.Entries | Where-Object { $_.FullName -match '\.class$' -and $_.Length -lt 2MB }
        $processed = 0
        $maxClasses = [Math]::Min(1500, $classEntries.Count)

        foreach ($entry in $classEntries) {
            if ($processed -ge $maxClasses) { break }
            $processed++

            try {
                $stream = $entry.Open()
                $ms = New-Object System.IO.MemoryStream
                $stream.CopyTo($ms)
                $bytes = $ms.ToArray()
                $stream.Close()
                $ms.Close()

                if ($bytes.Length -lt 10) { continue }

                $cp = Get-ConstantPool -Bytes $bytes -MaxStrings 3000 -MaxRefs 500
                if ($cp.Parsed) {
                    foreach ($s in $cp.Utf8Strings)     { $allUtf8.Add($s) }
                    foreach ($m in $cp.MethodRefs)      { $allMethodRefs.Add($m) }
                    foreach ($c in $cp.ClassNames)      { $allClassNames.Add($c) }
                }
            } catch { }
        }

        # 3.1 Network
        $result.Network = Find-NetworkStrings -Utf8Strings $allUtf8
        $result.TotalScore += $result.Network.Score

        # 3.2 Native
        $result.Native = Find-NativeLibs -Zip $zip
        $result.TotalScore += $result.Native.Score

        # 3.3 Nested (только для маленьких архивов, чтобы не тормозить)
        if ($zip.Entries.Count -lt 5000) {
            $result.Nested = Find-NestedJars -Zip $zip -CurrentDepth 1 -MaxDepth 3
            $result.TotalScore += $result.Nested.Score
        } else {
            $result.Nested = [PSCustomObject]@{
                NestedJars = @()
                Score = 0
            }
        }

        # 3.4 Dangerous
        $result.Dangerous = Find-DangerousPatterns -Utf8Strings $allUtf8 -MethodRefs $allMethodRefs -ClassNames $allClassNames
        $result.TotalScore += $result.Dangerous.Score

        $zip.Dispose()
    } catch {
        $result.Error = $_.Exception.Message
    }

    $timer.Stop()
    $result.Duration = $timer.ElapsedMilliseconds

    return $result
}

# ═══════════════════════════════════════════════════════════════════════
# 3.6 — Параллельный запуск Aux Scan (Network + Native + Nested + Dangerous)
# ═══════════════════════════════════════════════════════════════════════
function Invoke-JarAuxScanParallel {
    param(
        [array]$Jars,
        [int]$Threads = 8
    )

    if (-not $Jars -or $Jars.Count -eq 0) {
        return @()
    }

    $cpu = [Environment]::ProcessorCount
    $actualThreads = [Math]::Max(1, [Math]::Min($cpu, $Threads))
    Write-Log "Aux Scan: $($Jars.Count) JAR, потоков: $actualThreads" "INFO"

    $pool = [RunspaceFactory]::CreateRunspacePool(1, $actualThreads)
    $pool.Open()

    # Определения функций для передачи в потоки
    $funcDefs = @(
        (Get-Item function:Invoke-JarAuxScan).Definition,
        (Get-Item function:Get-ConstantPool).Definition,
        (Get-Item function:Find-NetworkStrings).Definition,
        (Get-Item function:Find-NativeLibs).Definition,
        (Get-Item function:Find-NestedJars).Definition,
        (Get-Item function:Find-DangerousPatterns).Definition
    )
    # Добавляем константы в виде скрипт-блока
    $constSetup = @"
`$Script:SuspiciousDomains = @('$($Script:SuspiciousDomains -join "','")')
`$Script:DangerousPatterns = @{$(foreach ($k in $Script:DangerousPatterns.Keys) { "'$k' = '$($Script:DangerousPatterns[$k])';" })}
`$Script:NativeExtensions = @('$($Script:NativeExtensions -join "','")')
"@

    $jobs = @()
    foreach ($jar in $Jars) {
        $ps = [PowerShell]::Create()
        $ps.RunspacePool = $pool

        [void]$ps.AddScript({
            param($JarPath, $JarFileName, $LauncherName, $FuncDefs, $ConstSetup)
            # Восстанавливаем константы
            . ([ScriptBlock]::Create($ConstSetup))
            # Восстанавливаем функции
            foreach ($fd in $FuncDefs) {
                . ([ScriptBlock]::Create($fd))
            }
            Invoke-JarAuxScan -JarPath $JarPath -JarFileName $JarFileName -LauncherName $LauncherName
        }).AddArgument($jar.FullPath) `
          .AddArgument($jar.FileName) `
          .AddArgument($jar.Launcher) `
          .AddArgument($funcDefs) `
          .AddArgument($constSetup)

        $jobs += [PSCustomObject]@{
            PS     = $ps
            Handle = $ps.BeginInvoke()
            Jar    = $jar
        }
    }

    $results = New-Object System.Collections.Generic.List[object]
    $done = 0

    foreach ($job in $jobs) {
        try {
            $res = $job.PS.EndInvoke($job.Handle)
            $done++
            if ($res) { $results.Add($res) }

            $pct = [math]::Round(($done / $jobs.Count) * 100)
            Write-Host "`r  [Aux $pct%] $done/$($jobs.Count) — $($job.Jar.FileName.Substring(0, [Math]::Min(50, $job.Jar.FileName.Length)))" -NoNewline -ForegroundColor DarkCyan
        } catch {
            Write-Log "Aux ошибка $($job.Jar.FileName): $_" "WARN"
        } finally {
            $job.PS.Dispose()
        }
    }
    Write-Host ""

    $pool.Close()
    $pool.Dispose()

    return $results
}

# ═══════════════════════════════════════════════════════════════════════
# 3.7 — Вывод результатов Aux Scan
# ═══════════════════════════════════════════════════════════════════════
function Show-AuxScanResults {
    param([array]$Results)

    if (-not $Results -or $Results.Count -eq 0) {
        Write-Log "Aux Scan: результатов нет." "OK"
        return
    }

    # Фильтруем только те, где score > 0
    $flagged = $Results | Where-Object { $_.TotalScore -gt 0 } | Sort-Object TotalScore -Descending

    Write-Host ""
    Write-Host "  ┌─── AUX SCAN (Network + Native + Nested + Dangerous) ─────" -ForegroundColor Cyan
    Write-Host "  │ Всего JAR:        $($Results.Count)" -ForegroundColor White
    Write-Host "  │ С находками:      $($flagged.Count)" -ForegroundColor $(if ($flagged.Count -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  └──────────────────────────────────────────────────────────" -ForegroundColor Cyan

    if ($flagged.Count -eq 0) { return }

    # 3.7.1 Network strings
    $netFlagged = $flagged | Where-Object { $_.Network -and ($_.Network.URLs.Count -gt 0 -or $_.Network.Suspicious.Count -gt 0 -or $_.Network.DiscordWebhooks.Count -gt 0) }
    if ($netFlagged.Count -gt 0) {
        Write-Host ""
        Write-Host "  ═══ NETWORK STRINGS (URL / домены / webhooks) ═══" -ForegroundColor Yellow
        foreach ($r in $netFlagged | Select-Object -First 15) {
            $totalNetScore = $r.Network.Score
            if ($totalNetScore -eq 0) { continue }

            Write-Host ""
            Write-Host "  [?] $($r.FileName) — Network score: $totalNetScore" -ForegroundColor Yellow

            if ($r.Network.DiscordWebhooks.Count -gt 0) {
                Write-Host "      [!!!] DISCORD WEBHOOK — кража логов/токенов:" -ForegroundColor Red
                foreach ($w in $r.Network.DiscordWebhooks | Select-Object -First 3) {
                    Write-Host "        $w" -ForegroundColor DarkRed
                    $Script:Report.Add("DISCORD WEBHOOK в $($r.FileName): $w")
                }
            }
            if ($r.Network.TelegramBots.Count -gt 0) {
                Write-Host "      [!!!] TELEGRAM BOT — C2 через Telegram:" -ForegroundColor Red
                foreach ($t in $r.Network.TelegramBots | Select-Object -First 3) {
                    Write-Host "        $t" -ForegroundColor DarkRed
                    $Script:Report.Add("TG BOT в $($r.FileName): $t")
                }
            }
            if ($r.Network.PastebinLinks.Count -gt 0) {
                Write-Host "      [!!] PASTEBIN — удалённая конфигурация:" -ForegroundColor Magenta
                foreach ($p in $r.Network.PastebinLinks | Select-Object -First 3) {
                    Write-Host "        $p" -ForegroundColor DarkRed
                }
            }
            if ($r.Network.Suspicious.Count -gt 0) {
                Write-Host "      [!] Подозрительные домены:" -ForegroundColor Red
                foreach ($s in $r.Network.Suspicious | Select-Object -First 5) {
                    Write-Host "        $s" -ForegroundColor DarkRed
                }
            }
            if ($r.Network.IPs.Count -gt 0) {
                Write-Host "      [i] IP-адреса: $($r.Network.IPs -join ', ')" -ForegroundColor DarkYellow
            }
        }
    }

    # 3.7.2 Native libs
    $nativeFlagged = $flagged | Where-Object { $_.Native -and $_.Native.NativeFiles.Count -gt 0 }
    if ($nativeFlagged.Count -gt 0) {
        Write-Host ""
        Write-Host "  ═══ NATIVE LIBS (.dll / .so внутри JAR) ═══" -ForegroundColor Yellow
        foreach ($r in $nativeFlagged | Select-Object -First 10) {
            Write-Host ""
            Write-Host "  [!] $($r.FileName) — нативов: $($r.Native.NativeFiles.Count)" -ForegroundColor Yellow
            foreach ($n in $r.Native.NativeFiles | Select-Object -First 5) {
                $sizeKB = [math]::Round($n.Size / 1KB, 1)
                Write-Host "      • $($n.Name) ($sizeKB KB)" -ForegroundColor DarkYellow
            }
            $Script:Report.Add("Native libs в $($r.FileName): $($r.Native.NativeFiles.Count) файлов")
        }
    }

    # 3.7.3 Nested jars
    $nestedFlagged = $flagged | Where-Object { $_.Nested -and $_.Nested.NestedJars.Count -gt 0 }
    if ($nestedFlagged.Count -gt 0) {
        Write-Host ""
        Write-Host "  ═══ NESTED JARS (матрёшка) ═══" -ForegroundColor Yellow
        foreach ($r in $nestedFlagged | Select-Object -First 10) {
            Write-Host ""
            Write-Host "  [?] $($r.FileName) — вложенных: $($r.Nested.NestedJars.Count)" -ForegroundColor Yellow
            foreach ($n in $r.Nested.NestedJars | Select-Object -First 5) {
                $sizeMB = [math]::Round($n.Size / 1MB, 2)
                $indent = "  " * $n.Depth
                Write-Host "      $indent• depth=$($n.Depth): $($n.Name) ($sizeMB MB)" -ForegroundColor DarkYellow
            }
        }
    }

    # 3.7.4 Dangerous patterns
    $dangerFlagged = $flagged | Where-Object { $_.Dangerous -and $_.Dangerous.Hits.Count -gt 0 }
    if ($dangerFlagged.Count -gt 0) {
        Write-Host ""
        Write-Host "  ═══ DANGEROUS PATTERNS (exec / reflection / unsafe) ═══" -ForegroundColor Yellow
        foreach ($r in $dangerFlagged | Select-Object -First 10) {
            Write-Host ""
            Write-Host "  [!] $($r.FileName) — dangerous score: $($r.Dangerous.Score)" -ForegroundColor Yellow
            foreach ($h in $r.Dangerous.Hits | Select-Object -First 8) {
                Write-Host "      • $($h.Pattern) — $($h.Desc)" -ForegroundColor DarkYellow
            }
            $Script:Report.Add("Dangerous в $($r.FileName): $($r.Dangerous.Hits.Count) паттернов")
        }
    }
}

# ═══════════════════════════════════════════════════════════════════════
# 3.8 — ГЛАВНАЯ: полный скан (переопределяет Start-JarScan из Part 2)
# ═══════════════════════════════════════════════════════════════════════
function Start-JarScan {
    param(
        [switch]$ModsOnly,
        [switch]$AllDisks,
        [switch]$IncludeDownloads,
        [switch]$ComputeHash,
        [switch]$MetadataOnly,
        [switch]$SkipAux
    )

    Write-Log "=== JAR АНАЛИЗ (v7.0 FULL) ===" "TITLE"

    # ═══ ЭТАП 1: DISCOVERY ═══
    Write-Log "Этап 1/4: Поиск JAR..." "INFO"
    $jars = Find-AllJars -IncludeDownloads:$IncludeDownloads
    if ($jars.Count -eq 0) {
        Write-Log "Не найдено ни одного .jar" "WARN"
        return
    }
    Write-Log "Найдено JAR: $($jars.Count)" "OK"

    # ═══ ЭТАП 2: МЕТАДАННЫЕ ═══
    Write-Log "Этап 2/4: Метаданные (manifest, mods.toml, fabric.mod.json)..." "INFO"
    $metas = New-Object System.Collections.Generic.List[object]
    $i = 0
    foreach ($jar in $jars) {
        $i++
        $pct = [math]::Round(($i / $jars.Count) * 100)
        Write-Host "`r  [Meta $pct%] $i/$($jars.Count) — $($jar.FileName.PadRight(50).Substring(0,50))" -NoNewline -ForegroundColor DarkGray
        $m = Read-JarMetadata -JarPath $jar.FullPath -ComputeHash:$ComputeHash
        $metas.Add($m)
    }
    Write-Host ""
    Write-Log "Метаданных обработано: $($metas.Count)" "OK"
    Show-MetadataSummary -Metas $metas

    # Флаги по метаданным
    foreach ($m in $metas) {
        $reasons = @()
        if ($m.Manifest -and $m.Manifest.AgentFlags.Count -gt 0) {
            foreach ($f in $m.Manifest.AgentFlags) { $reasons += "Java-Agent: $f" }
        }
        if ($m.HashMatch) { $reasons += "SHA256 совпадает с: $($m.HashMatch)" }
        if ($m.Fabric -and $m.Fabric.RedFlags.Count -gt 0) {
            foreach ($f in $m.Fabric.RedFlags) { $reasons += $f }
        }
        if ($m.Forge -and $m.Forge.RedFlags.Count -gt 0) {
            foreach ($f in $m.Forge.RedFlags) { $reasons += $f }
        }
        if ($m.McmodInfo -and $m.McmodInfo.RedFlags.Count -gt 0) {
            foreach ($f in $m.McmodInfo.RedFlags) { $reasons += $f }
        }
        if ($reasons.Count -gt 0) {
            Write-Log "ПОДОЗРИТЕЛЬНО (metadata): $($m.Path)" "FOUND"
            foreach ($r in $reasons) {
                Write-Host "      → $r" -ForegroundColor DarkRed
                $Script:Report.Add("      → $r")
            }
        }
    }

    $Script:LastJarMetas = $metas
    if ($MetadataOnly) {
        Write-Log "Metadata-only режим — скан остановлен." "WARN"
        return
    }

    # Фильтр для дальнейшего скана
    $toScan = @()
    foreach ($jar in $jars) {
        if (Test-Whitelisted -FullPath $jar.FullPath -Name $jar.FileName.ToLower()) { continue }
        $toScan += [PSCustomObject]@{
            FullPath = $jar.FullPath
            FileName = $jar.FileName
            Launcher = $jar.Launcher
        }
    }
    Write-Log "После whitelist: $($toScan.Count) JAR" "INFO"

    if ($toScan.Count -eq 0) {
        Write-Log "Все JAR в whitelist — сканирование не требуется." "OK"
        return
    }

    # ═══ ЭТАП 3: ГЛУБОКИЙ СКАН БАЙТКОДА (Part 2) ═══
    Write-Log "Этап 3/4: Байткод (constant pool)..." "INFO"
    $deep = Invoke-JarDeepScanParallel -Jars $toScan -Threshold $Script:ScoreThreshold
    $Script:LastDeepResults = $deep
    Show-DeepScanResults -Results $deep -Threshold $Script:ScoreThreshold

    # ═══ ЭТАП 4: AUX SCAN (Part 3) ═══
    if (-not $SkipAux) {
        Write-Log "Этап 4/4: Network + Native + Nested + Dangerous..." "INFO"
        $aux = Invoke-JarAuxScanParallel -Jars $toScan
        $Script:LastAuxResults = $aux
        Show-AuxScanResults -Results $aux

        # Добавляем в общий отчёт
        $auxFlagged = $aux | Where-Object { $_.TotalScore -gt 0 } | Sort-Object TotalScore -Descending
        if ($auxFlagged.Count -gt 0) {
            $Script:Report.Add("")
            $Script:Report.Add("=== AUX SCAN RESULT ===")
            foreach ($r in $auxFlagged | Select-Object -First 20) {
                $Script:Report.Add("$($r.FileName) — aux score: $($r.TotalScore)")
            }
        }
    } else {
        Write-Log "Aux Scan пропущен (-SkipAux)." "WARN"
    }

    Write-Log "=== JAR АНАЛИЗ ЗАВЕРШЁН ===" "TITLE"
}

# ═══════════════════════════════════════════════════════════════════════
# 3.9 — Обновлённые опции меню (совместимость)
# ═══════════════════════════════════════════════════════════════════════
function Start-JarScanParallel {
    param([switch]$AllDisks, [switch]$ModsOnly)
    Start-JarScan -AllDisks:$AllDisks -ModsOnly:$ModsOnly
}

Write-Host "  >>> PART 3 LOADED — Network + Native + Nested + Dangerous <<<" -ForegroundColor Magenta
