<#
.SYNOPSIS
    EngineCheck - ScreenShare Checker for Minecraft
.DESCRIPTION
    Single-file checker. Run via: irm <raw-url> | iex
    Modules: Services, Processes, JAR Analysis, Strings Scan, Network, Telegram Report.
#>

# ============================================================
# CONFIGURATION (заполни перед использованием)
# ============================================================
$Config = @{
    TelegramBotToken = "ТВОЙ_ТОКЕН_БОТА"
    TelegramChatId   = "ТВОЙ_CHAT_ID"
    MaxJarSizeMB     = 50
    ScanTimeoutSec   = 600
}

# ============================================================
# CHEAT SIGNATURES (из твоего списка)
# ============================================================
$Script:CheatNames = @(
    "impact","wurst","bleachhack","bleach_hack","aristois","huzuni","skillclient","skill_client",
    "nodus","inertia","ares","sigma","meteor","atomic","zamorozka","liquidbounce","liquid_bounce",
    "nurik","nursultan","celestial","calestial","celka","expensive","neverhook","excellent",
    "wexside","wild","minced","deadcode","akrien","future","dreampool","vape","infinity",
    "squad","norules","no_rules","konas","zeusclient","zeus_client","richclient","rich_client",
    "ghostclient","ghost_client","rusherhack","rusher_hack","thunderhack","thunder_hack",
    "moonhack","moon_hack","winner","nova","exire","doomsday","nightware","ricardo","extazyy",
    "troxill","arbuz","dauntiblyat","takker","faker","xameleon","fuzeclient","fuze_client",
    "wisefolder","wise_folder","netlimiter","net_limiter","feather","delta","eclipse","venus",
    "jex","hakari","hush","hach","rogalik","catlavan","haruka","wissend","fluger","sperma",
    "vortex","newcode","astra","britva","bariton","luminex","nuclear"
)

$Script:CheatStrings = @(
    "killaura","aimbot","aimassist","hitbox","autototem","auto_totem","reach","velocity",
    "antiknockback","nuker","scaffold","fly","speed","esp","tracers","xray","x_ray",
    "cheat","hack","inject","bypass","anticheat"
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
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ███████╗███╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗           ║
║   ██╔════╝████╗  ██║██╔════╝ ██║████╗  ██║██╔════╝           ║
║   █████╗  ██╔██╗ ██║██║  ███╗██║██╔██╗ ██║█████╗             ║
║   ██╔══╝  ██║╚██╗██║██║   ██║██║██║╚██╗██║██╔══╝             ║
║   ███████╗██║ ╚████║╚██████╔╝██║██║ ╚████║███████╗           ║
║   ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝           ║
║                                                              ║
║              SCREENSHARE CHECKER v1.0                        ║
║              Minecraft Cheat Detection                       ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
"@
    Write-Host $banner -ForegroundColor Cyan
    Write-Host ""
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor DarkCyan
    Write-Host "│ $($Title.PadRight(59)) │" -ForegroundColor DarkCyan
    Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor DarkCyan
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

function Write-Progress-Bar {
    param([int]$Current, [int]$Total, [string]$Activity)
    $percent = [math]::Round(($Current / $Total) * 100)
    $filled = [math]::Round($percent / 5)
    $bar = ("█" * $filled).PadRight(20, "░")
    Write-Host "`r  [$bar] $percent% - $Activity" -NoNewline -ForegroundColor Cyan
}

# ============================================================
# MODULE 1: SERVICES
# ============================================================
function Test-Services {
    Write-Section "MODULE 1: SERVICES CHECK"
    $i = 0
    foreach ($svc in $Script:RequiredServices) {
        $i++
        Write-Progress-Bar -Current $i -Total $Script:RequiredServices.Count -Activity "Checking $svc"
        try {
            $service = Get-Service -Name $svc -ErrorAction Stop
            if ($service.Status -eq 'Running') {
                Write-Result "Service $svc : RUNNING" "OK"
            } else {
                Write-Result "Service $svc : $($service.Status) (SUSPICIOUS)" "FOUND"
            }
        } catch {
            Write-Result "Service $svc : NOT FOUND (SUSPICIOUS)" "FOUND"
        }
    }
    Write-Host ""
}

# ============================================================
# MODULE 2: PROCESSES
# ============================================================
function Test-Processes {
    Write-Section "MODULE 2: PROCESS SCAN"
    $pattern = ($Script:CheatNames -join "|")
    $processes = Get-Process | Where-Object { $_.ProcessName -match $pattern }
    
    if ($processes) {
        foreach ($proc in $processes) {
            Write-Result "FOUND PROCESS: $($proc.ProcessName) (PID: $($proc.Id))" "FOUND"
        }
    } else {
        Write-Result "No suspicious processes found." "OK"
    }
    Write-Host ""
}

# ============================================================
# MODULE 3: JAR ANALYZER
# ============================================================
function Test-Jars {
    Write-Section "MODULE 3: JAR ANALYSIS"
    
    $searchPaths = @(
        "$env:APPDATA\.minecraft",
        "$env:APPDATA\.minecraft\mods",
        "$env:APPDATA\.minecraft\versions",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Desktop"
    ) | Where-Object { Test-Path $_ }
    
    if ($searchPaths.Count -eq 0) {
        Write-Result "No Minecraft/download folders found." "WARN"
        return
    }
    
    $jars = @()
    foreach ($path in $searchPaths) {
        $found = Get-ChildItem -Path $path -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue |
                 Where-Object { $_.Length -lt ($Config.MaxJarSizeMB * 1MB) }
        $jars += $found
    }
    
    Write-Result "Found $($jars.Count) JAR files to scan." "INFO"
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    $suspiciousCount = 0
    $i = 0
    foreach ($jar in $jars) {
        $i++
        Write-Progress-Bar -Current $i -Total $jars.Count -Activity "Scanning $($jar.Name)"
        
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
            $jarName = $jar.Name.ToLower()
            $isSuspicious = $false
            $reasons = @()
            
            foreach ($cheat in $Script:CheatNames) {
                if ($jarName -match [regex]::Escape($cheat)) {
                    $reasons += "Name contains: $cheat"
                    $isSuspicious = $true
                }
            }
            
            foreach ($entry in $zip.Entries) {
                $entryName = $entry.FullName.ToLower()
                
                if ($entryName -match "\.class$") {
                    foreach ($str in $Script:CheatStrings) {
                        if ($entryName -match [regex]::Escape($str)) {
                            $reasons += "Class: $($entry.FullName) contains '$str'"
                            $isSuspicious = $true
                            break
                        }
                    }
                }
                
                if ($entryName -match "^[a-z]\.class$" -or $entryName -match "^[a-z]{2}\.class$") {
                    $reasons += "Possible obfuscation: $($entry.FullName)"
                    $isSuspicious = $true
                }
            }
            
            $zip.Dispose()
            
            if ($isSuspicious) {
                $suspiciousCount++
                Write-Host ""
                Write-Result "SUSPICIOUS JAR: $($jar.FullName)" "FOUND"
                foreach ($r in $reasons | Select-Object -First 5) {
                    Write-Host "      -> $r" -ForegroundColor DarkRed
                    $Script:Report.Add("      -> $r")
                }
            }
        } catch {
            Write-Result "Error reading $($jar.Name): $($_.Exception.Message)" "WARN"
        }
    }
    
    Write-Host ""
    if ($suspiciousCount -eq 0) {
        Write-Result "No suspicious JARs found (scanned $($jars.Count))." "OK"
    } else {
        Write-Result "TOTAL SUSPICIOUS JARS: $suspiciousCount" "FOUND"
    }
    Write-Host ""
}

# ============================================================
# MODULE 4: STRINGS SCAN
# ============================================================
function Test-Strings {
    Write-Section "MODULE 4: STRINGS SCAN"
    
    $targets = @(
        @{ Path = "$env:WINDIR\explorer.exe"; Patterns = @("deltadlc","wild","nursultam","celestial","aspect","toshiba") },
        @{ Path = "$env:WINDIR\System32\javaw.exe"; Patterns = @("l.png") }
    )
    
    foreach ($target in $targets) {
        if (-not (Test-Path $target.Path)) {
            Write-Result "File not found: $($target.Path)" "WARN"
            continue
        }
        
        try {
            $fileInfo = Get-Item $target.Path
            if ($fileInfo.Length -gt 50MB) {
                Write-Result "File too large, skipping: $($fileInfo.Name)" "WARN"
                continue
            }
            
            $bytes = [System.IO.File]::ReadAllBytes($target.Path)
            $text = [System.Text.Encoding]::ASCII.GetString($bytes)
            
            $foundInFile = $false
            foreach ($pattern in $target.Patterns) {
                if ($text -match [regex]::Escape($pattern)) {
                    Write-Result "FOUND in $($fileInfo.Name): '$pattern'" "FOUND"
                    $foundInFile = $true
                }
            }
            if (-not $foundInFile) {
                Write-Result "No suspicious strings in $($fileInfo.Name)" "OK"
            }
        } catch {
            Write-Result "Error reading $($fileInfo.Name): $($_.Exception.Message)" "WARN"
        }
    }
    Write-Host ""
}

# ============================================================
# MODULE 5: NETWORK
# ============================================================
function Test-Network {
    Write-Section "MODULE 5: NETWORK CHECK"
    try {
        $connections = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue |
                       Where-Object { $_.RemotePort -in @(25565, 25566, 19132) }
        if ($connections) {
            foreach ($conn in $connections) {
                Write-Result "Connection: $($conn.RemoteAddress):$($conn.RemotePort) (PID: $($conn.OwningProcess))" "INFO"
            }
        } else {
            Write-Result "No active Minecraft port connections." "OK"
        }
    } catch {
        Write-Result "Network check error: $_" "WARN"
    }
    Write-Host ""
}

# ============================================================
# TELEGRAM REPORT
# ============================================================
function Send-TelegramReport {
    param([string]$ReportText)
    
    if ($Config.TelegramBotToken -eq "ТВОЙ_ТОКЕН_БОТА") {
        Write-Result "Telegram not configured, report not sent." "WARN"
        return
    }
    
    $tempFile = "$env:TEMP\enginecheck_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $ReportText | Out-File -FilePath $tempFile -Encoding UTF8
    
    try {
        $uri = "https://api.telegram.org/bot$($Config.TelegramBotToken)/sendDocument"
        
        if ($PSVersionTable.PSVersion.Major -ge 7) {
            $Form = @{
                chat_id = $Config.TelegramChatId
                document = Get-Item $tempFile
                caption = "EngineCheck Report - Threats Found: $($Script:ThreatsFound)"
            }
            Invoke-RestMethod -Uri $uri -Method Post -Form $Form -ErrorAction Stop
        } else {
            $boundary = [System.Guid]::NewGuid().ToString()
            $fileBytes = [System.IO.File]::ReadAllBytes($tempFile)
            $enc = [System.Text.Encoding]::GetEncoding('ISO-8859-1')
            $fileEnc = $enc.GetString($fileBytes)
            $LF = "`r`n"
            
            $body = (
                "--$boundary",
                "Content-Disposition: form-data; name=`"chat_id`"$LF",
                $Config.TelegramChatId,
                "--$boundary",
                "Content-Disposition: form-data; name=`"document`"; filename=`"report.txt`"",
                "Content-Type: application/octet-stream$LF",
                $fileEnc,
                "--$boundary--$LF"
            ) -join $LF
            
            Invoke-RestMethod -Uri $uri -Method Post -ContentType "multipart/form-data; boundary=$boundary" -Body $body -ErrorAction Stop
        }
        
        Write-Result "Report sent to Telegram." "OK"
    } catch {
        Write-Result "Telegram send error: $($_.Exception.Message)" "WARN"
    } finally {
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    }
}

# ============================================================
# MAIN EXECUTION
# ============================================================
Write-Banner

$startTime = Get-Date
$Script:Report.Add("=== ENGINE CHECK REPORT ===")
$Script:Report.Add("Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$Script:Report.Add("Computer: $env:COMPUTERNAME")
$Script:Report.Add("User: $env:USERNAME")
$Script:Report.Add("")

Test-Services
Test-Processes
Test-Jars
Test-Strings
Test-Network

$elapsed = (Get-Date) - $startTime
$Script:Report.Add("")
$Script:Report.Add("=== COMPLETED ===")
$Script:Report.Add("Duration: $($elapsed.ToString('mm\:ss'))")
$Script:Report.Add("Total threats found: $($Script:ThreatsFound)")

# Final Summary
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                      SCAN COMPLETE                           ║" -ForegroundColor Cyan
Write-Host "╠══════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
if ($Script:ThreatsFound -eq 0) {
    Write-Host "║  RESULT: CLEAN - No threats detected                         ║" -ForegroundColor Green
} else {
    Write-Host "║  RESULT: $($Script:ThreatsFound) THREAT(S) FOUND                              ║" -ForegroundColor Red
}
Write-Host "║  Duration: $($elapsed.ToString('mm\:ss'))                                           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$finalReport = $Script:Report -join "`r`n"
Send-TelegramReport -ReportText $finalReport

Write-Host "Press Enter to exit..." -ForegroundColor Cyan
Read-Host
