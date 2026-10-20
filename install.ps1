# Windows App Installer — interaktivt menybasert
# Kjør: irm https://olewol.github.io/windows-installer/install.ps1 | iex
# Eller: .\install.ps1

param(
    [switch]$All,           # Installer alt uten meny
    [switch]$Core,          # Kun core-apper
    [switch]$Dev,           # Kun dev-apper
    [switch]$List,          # Vis liste og avslutt
    [string]$Skip = "",     # Kommaseparerte apper å hoppe over
    [switch]$Help           # Vis hjelp
)

# ============================================================
# APP-DEFINISJONER
# ============================================================

$apps = @(
    # --- Core (alle trenger) ---
    @{ id = "Notepad++.Notepad++";       name = "Notepad++";              cat = "core"; manual = $false; url = "https://notepad-plus-plus.org"; choco = $null },
    @{ id = "Mozilla.Firefox";           name = "Mozilla Firefox";        cat = "core"; manual = $false; url = "https://www.mozilla.org/firefox"; choco = $null },
    @{ id = "7zip.7zip";                 name = "7-Zip";                 cat = "core"; manual = $false; url = "https://www.7-zip.org"; choco = $null },
    @{ id = "Git.Git";                   name = "Git";                   cat = "core"; manual = $false; url = "https://git-scm.com"; choco = $null },
    @{ id = "Bitwarden.Bitwarden";       name = "Bitwarden";             cat = "core"; manual = $false; url = "https://bitwarden.com"; choco = $null },
    @{ id = "Microsoft.PowerShell";      name = "PowerShell 7";          cat = "core"; manual = $false; url = "https://github.com/PowerShell/PowerShell"; choco = $null },
    @{ id = "Microsoft.WindowsTerminal"; name = "Windows Terminal";      cat = "core"; manual = $false; url = "https://github.com/microsoft/terminal"; choco = $null },

    # --- Media ---
    @{ id = "clsid2.mpc-hc";             name = "Media Player Classic HC"; cat = "media"; manual = $false; url = "https://mpc-hc.org"; choco = $null },
    @{ id = "Daum.PotPlayer";            name = "PotPlayer";             cat = "media"; manual = $false; url = "https://potplayer.daum.net"; choco = $null },
    @{ id = "Stremio.Stremio";           name = "Stremio";               cat = "media"; manual = $false; url = "https://www.stremio.com"; choco = $null },
    @{ id = "VideoLAN.VLC";              name = "VLC";                   cat = "media"; manual = $false; url = "https://www.videolan.org/vlc"; choco = $null },
    @{ id = "Zoom.Zoom";                 name = "Zoom Workplace";        cat = "media"; manual = $false; url = "https://zoom.us"; choco = $null },

    # --- Dev ---
    @{ id = "Neovim.Neovim";             name = "Neovim";                cat = "dev";  manual = $false; url = "https://neovim.io"; choco = $null },
    @{ id = "VSCodium.VSCodium";         name = "VSCodium";              cat = "dev";  manual = $false; url = "https://vscodium.com"; choco = $null },
    @{ id = "Microsoft.PowerToys";       name = "PowerToys";             cat = "dev";  manual = $false; url = "https://github.com/microsoft/PowerToys"; choco = $null },
    @{ id = "NodeJS";                    name = "Node.js";               cat = "dev";  manual = $false; wingetId = "OpenJS.NodeJS"; url = "https://nodejs.org"; choco = $null },
    @{ id = "Python";                    name = "Python 3.12";           cat = "dev";  manual = $false; wingetId = "Python.Python.3.12"; url = "https://www.python.org"; choco = $null },

    # --- Network/VM ---
    @{ id = "tailscale.tailscale";       name = "Tailscale";             cat = "net";  manual = $false; url = "https://tailscale.com"; choco = $null },
    @{ id = "Mobatek.MobaXterm";         name = "MobaXterm";             cat = "net";  manual = $false; url = "https://mobaxterm.mobatek.net"; choco = $null },
    @{ id = "VMware.WorkstationPro";     name = "VMware Workstation Pro"; cat = "net";  manual = $false; url = "https://www.vmware.com/products/workstation-pro.html"; choco = $null },
    @{ id = "WiresharkFoundation.Wireshark"; name = "Wireshark";         cat = "net";  manual = $false; url = "https://www.wireshark.org"; choco = $null },

    # --- Tools ---
    @{ id = "JGraph.Draw";               name = "draw.io";               cat = "tools"; manual = $false; url = "https://www.drawio.com"; choco = $null },
    @{ id = "ShareX.ShareX";             name = "ShareX";                cat = "tools"; manual = $false; url = "https://getsharex.com"; choco = $null },
    @{ id = "OBSProject.OBSStudio";      name = "OBS Studio";            cat = "tools"; manual = $false; url = "https://obsproject.com"; choco = $null },
    @{ id = "Google.Chrome";             name = "Google Chrome";         cat = "tools"; manual = $false; url = "https://www.google.com/chrome"; choco = $null },
    @{ id = "Docker.DockerDesktop";      name = "Docker Desktop";        cat = "tools"; manual = $false; url = "https://www.docker.com/products/docker-desktop"; choco = $null },

    # --- Adobe ---
    @{ id = "Adobe.Acrobat.Reader.64-bit"; name = "Adobe Acrobat Reader (64-bit)"; cat = "adobe"; manual = $false; url = "https://www.adobe.com/acrobat/pdf-reader.html"; choco = $null },

    # --- Manuelle (ikke i winget) ---
    @{ id = "CiscoPacketTracer";         name = "Cisco Packet Tracer";   cat = "manual"; manual = $true; url = "https://www.netacad.com/cisco-packet-tracer"; choco = $null },
    @{ id = "CCCP";                     name = "CCCP Codec Pack";       cat = "manual"; manual = $true; url = "https://www.cccp-project.net/"; choco = "cccp" },
    @{ id = "OpenCodeCLI";              name = "OpenCode CLI (AI)";     cat = "manual"; manual = $true; url = "https://opencode.ai"; choco = $null },
    @{ id = "Aider";                    name = "Aider (AI coding)";     cat = "manual"; manual = $true; url = "https://aider.chat"; choco = $null },
    @{ id = "Athas";                    name = "Athas (AI editor)";     cat = "manual"; manual = $true; url = "https://athas.dev"; choco = $null },
    @{ id = "Helix";                    name = "Helix (editor)";        cat = "manual"; manual = $true; url = "https://helix-editor.com"; choco = "helix" },
    @{ id = "Zed";                      name = "Zed (editor)";          cat = "manual"; manual = $true; url = "https://zed.dev"; choco = "zed" }
)

# ============================================================
# PAKKEBEHANDLERE
# ============================================================

function Test-Choco { return (Get-Command choco -ErrorAction SilentlyContinue) -ne $null }
function Test-Scoop { return (Get-Command scoop -ErrorAction SilentlyContinue) -ne $null }

function Install-Choco {
    Write-Host "`n=== Installerer Chocolatey ===" -ForegroundColor Yellow
    $confirm = Read-Host "Bekreft installasjon av Chocolatey? (j/n)"
    if ($confirm -ne "j") { return $false }
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    if (Test-Choco) { Write-Host "  OK: Chocolatey installert" -ForegroundColor Green; return $true }
    Write-Host "  FEIL: Chocolatey-installasjon feilet" -ForegroundColor Red
    return $false
}

function Install-Scoop {
    Write-Host "`n=== Installerer Scoop ===" -ForegroundColor Yellow
    $confirm = Read-Host "Bekreft installasjon av Scoop? (j/n)"
    if ($confirm -ne "j") { return $false }
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    if (Test-Scoop) { Write-Host "  OK: Scoop installert" -ForegroundColor Green; return $true }
    Write-Host "  FEIL: Scoop-installasjon feilet" -ForegroundColor Red
    return $false
}

function Get-PackageManager {
    if (Test-Choco) { return "choco" }
    if (Test-Scoop) { return "scoop" }
    return $null
}

function Prompt-InstallPackageManager {
    Write-Host "`n=== Ingen alternativ pakkebehandler funnet ===" -ForegroundColor Yellow
    Write-Host "Noen apper er ikke i winget og trenger Chocolatey/Scoop." -ForegroundColor White
    $choice = Read-Host "Installer Chocolatey? (j/n)"
    if ($choice -eq "j") { return Install-Choco }
    $choice2 = Read-Host "Installer Scoop i stedet? (j/n)"
    if ($choice2 -eq "j") { return Install-Scoop }
    Write-Host "  Hopper over — bruker direct download fallback" -ForegroundColor Yellow
    return $false
}

# ============================================================
# INTERAKTIV BEKREFTELSE MED CHECKMARKS
# ============================================================

function Confirm-InstallList {
    param([array]$appList, [string]$title = "Bekreft installasjon")
    
    $selected = @()
    foreach ($app in $appList) {
        $selected += @{ app = $app; checked = $true }
    }
    
    while ($true) {
        Clear-Host
        Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║  $title" -ForegroundColor Cyan
        Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Apper som vil bli installert:" -ForegroundColor Yellow
        Write-Host ""
        
        $i = 1
        foreach ($item in $selected) {
            $check = if ($item.checked) { "[x]" } else { "[ ]" }
            $color = if ($item.checked) { "Green" } else { "DarkGray" }
            $type = if ($item.app.manual) { "AUTO" } else { "winget" }
            Write-Host ("  {0,3}. {1} {2,-35} ({3})" -f $i, $check, $item.app.name, $type) -ForegroundColor $color
            $i++
        }
        
        $checkedCount = ($selected | Where-Object { $_.checked }).Count
        Write-Host ""
        Write-Host "  Valgt: $checkedCount av $($selected.Count) apper" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Kommandoer:" -ForegroundColor Yellow
        Write-Host "  [nummer]  — toggle app av/på (f.eks. 3,5,7)" -ForegroundColor White
        Write-Host "  [a]       — velg alle" -ForegroundColor White
        Write-Host "  [n]       — fjern alle" -ForegroundColor White
        Write-Host "  [OK]      — bekreft og installer" -ForegroundColor Green
        Write-Host "  [avbryt]  — avbryt" -ForegroundColor Red
        Write-Host ""
        
        $input = Read-Host "Valg"
        
        if ($input -eq "OK" -or $input -eq "ok" -or $input -eq "j") {
            $toInstall = $selected | Where-Object { $_.checked } | ForEach-Object { $_.app }
            if ($toInstall.Count -eq 0) {
                Write-Host "Ingen apper valgt. Avbryter." -ForegroundColor Red
                Start-Sleep -Seconds 1
                return $null
            }
            return $toInstall
        }
        
        if ($input -eq "avbryt" -or $input -eq "q" -or $input -eq "Q") {
            return $null
        }
        
        if ($input -eq "a") {
            foreach ($item in $selected) { $item.checked = $true }
            continue
        }
        
        if ($input -eq "n") {
            foreach ($item in $selected) { $item.checked = $false }
            continue
        }
        
        $nums = $input -split ',' | ForEach-Object { $_.Trim() }
        foreach ($num in $nums) {
            if ($num -match '^\d+$') {
                $idx = [int]$num - 1
                if ($idx -ge 0 -and $idx -lt $selected.Count) {
                    $selected[$idx].checked = -not $selected[$idx].checked
                }
            }
        }
    }
}

# ============================================================
# INSTALLASJONSFUNKSJONER
# ============================================================

function Install-WingetApp {
    param([hashtable]$app)
    $wingetId = if ($app.wingetId) { $app.wingetId } else { $app.id }
    Write-Host "`n--- Installerer $($app.name) ($wingetId) ---" -ForegroundColor Yellow
    winget install -e --id $wingetId --accept-source-agreements --accept-package-agreements --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  OK: $($app.name)" -ForegroundColor Green
    } else {
        Write-Host "  FEIL eller allerede installert: $($app.name) (exit: $LASTEXITCODE)" -ForegroundColor Red
    }
}

function Install-ChocoApp {
    param([hashtable]$app)
    $chocoId = $app.choco
    if (-not $chocoId) { return $false }
    Write-Host "`n--- Installerer $($app.name) via Chocolatey ($chocoId) ---" -ForegroundColor Yellow
    choco install $chocoId -y --no-progress 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Host "  OK: $($app.name)" -ForegroundColor Green; return $true }
    Write-Host "  FEIL: Chocolatey installasjon feilet" -ForegroundColor Red
    return $false
}

function Install-ScoopApp {
    param([hashtable]$app)
    $scoopId = $app.id.ToLower()
    Write-Host "`n--- Installerer $($app.name) via Scoop ($scoopId) ---" -ForegroundColor Yellow
    scoop install $scoopId 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Host "  OK: $($app.name)" -ForegroundColor Green; return $true }
    Write-Host "  FEIL: Scoop installasjon feilet" -ForegroundColor Red
    return $false
}

function Install-ManualApp {
    param([hashtable]$app)
    
    Write-Host "`n--- Manuell app: $($app.name) ---" -ForegroundColor Magenta
    
    if ($app.id -eq "CiscoPacketTracer") {
        Write-Host "  Krever NetAcad-konto — MÅ lastes ned manuelt" -ForegroundColor Red
        Write-Host "  Last ned fra: https://www.netacad.com/cisco-packet-tracer" -ForegroundColor Yellow
        Start-Process "https://www.netacad.com/cisco-packet-tracer"
        return
    }
    
    if ($app.id -eq "OpenCodeCLI") {
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            Write-Host "  Installerer via npm..." -ForegroundColor Yellow
            npm install -g opencode 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { Write-Host "  OK: OpenCode CLI installert" -ForegroundColor Green }
            else { Write-Host "  FEIL: npm install feilet" -ForegroundColor Red; Write-Host "  Lenke: https://opencode.ai" -ForegroundColor Yellow }
        } else {
            Write-Host "  npm ikke funnet — installer Node.js først" -ForegroundColor Red
            Write-Host "  Lenke: https://opencode.ai" -ForegroundColor Yellow
        }
        return
    }
    
    if ($app.id -eq "Aider") {
        if (Get-Command pip -ErrorAction SilentlyContinue) {
            Write-Host "  Installerer via pip..." -ForegroundColor Yellow
            pip install aider-chat 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { Write-Host "  OK: Aider installert" -ForegroundColor Green }
            else { Write-Host "  FEIL: pip install feilet" -ForegroundColor Red; Write-Host "  Lenke: https://aider.chat" -ForegroundColor Yellow }
        } else {
            Write-Host "  pip ikke funnet — installer Python først" -ForegroundColor Red
            Write-Host "  Lenke: https://aider.chat" -ForegroundColor Yellow
        }
        return
    }
    
    $pm = Get-PackageManager
    if ($pm -eq "choco" -and $app.choco) {
        $success = Install-ChocoApp -app $app
        if ($success) { return }
    }
    if ($pm -eq "scoop") {
        $success = Install-ScoopApp -app $app
        if ($success) { return }
    }
    
    $directUrls = @{
        "CCCP" = @{ url = "https://www.cccp-project.net/downloads/latest/CCCP-2022-10-09.exe"; installer = "CCCP-Setup.exe"; args = "/S"; fallback = "https://www.cccp-project.net/" }
        "Helix" = @{ url = "https://github.com/helix-editor/helix/releases/latest/download/helix-x86_64-windows.zip"; installer = "helix.zip"; extract = $true; fallback = "https://helix-editor.com" }
        "Zed" = @{ url = "https://github.com/zed-industries/zed/releases/latest/download/Zed-x86_64.exe"; installer = "Zed-Setup.exe"; args = "/S"; fallback = "https://zed.dev" }
        "Athas" = @{ url = "https://athas.dev/download/windows"; installer = "Athas-Setup.exe"; args = "/S"; fallback = "https://athas.dev" }
    }
    
    $dl = $directUrls[$app.id]
    if ($dl) {
        $tempDir = "$env:TEMP\manual-install"
        if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir | Out-Null }
        $installerPath = Join-Path $tempDir $dl.installer
        Write-Host "  Laster ned $($app.name)..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $dl.url -OutFile $installerPath -UseBasicParsing -ErrorAction Stop
            if ($dl.extract) {
                Write-Host "  Pakker ut..." -ForegroundColor Yellow
                Expand-Archive -Path $installerPath -DestinationPath "$tempDir\$($app.id)" -Force
                Write-Host "  OK: $($app.name) pakket ut til $tempDir\$($app.id)" -ForegroundColor Green
            } else {
                Write-Host "  Installerer..." -ForegroundColor Yellow
                Start-Process -FilePath $installerPath -ArgumentList $dl.args -Wait -NoNewWindow
                Write-Host "  OK: $($app.name) installert" -ForegroundColor Green
            }
        } catch {
            Write-Host "  Nedlasting feilet: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "  Lenke: $($dl.fallback)" -ForegroundColor Yellow
            Start-Process $dl.fallback
        }
    } else {
        Write-Host "  Ingen automatisk installasjon tilgjengelig" -ForegroundColor Red
        Write-Host "  Lenke: $($app.url)" -ForegroundColor Yellow
        Start-Process $app.url
    }
}

function Show-Header {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         Windows App Installer — bekreftelse             ║" -ForegroundColor Cyan
    Write-Host "║         https://olewol.github.io/windows-installer/      ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Show-Header
    Write-Host "Velg installasjonsmodus:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Installer ALLE apper" -ForegroundColor White
    Write-Host "  [2] Installer KUN winget-apper" -ForegroundColor White
    Write-Host "  [3] Velg kategorier (core, media, dev, net, tools, adobe, manual)" -ForegroundColor White
    Write-Host "  [4] Velg individuelle apper (av/på)" -ForegroundColor White
    Write-Host "  [5] Kun manuelle apper (auto: choco/npm/pip/direct)" -ForegroundColor White
    Write-Host "  [6] Vis full liste og avslutt" -ForegroundColor White
    Write-Host "  [Q] Avslutt" -ForegroundColor Red
    Write-Host ""
}

function Show-AppList {
    param([array]$appList, [string]$title = "App-liste")
    Write-Host "`n=== $title ===" -ForegroundColor Cyan
    $i = 1
    foreach ($app in $appList) {
        $status = if ($app.manual) { "[AUTO]" } else { "[winget]" }
        $color = if ($app.manual) { "Magenta" } else { "Green" }
        Write-Host ("  {0,3}. {1,-35} {2}" -f $i, $app.name, $status) -ForegroundColor $color
        $i++
    }
    Write-Host ""
}

function Show-ManualApps {
    param([array]$appList)
    Write-Host "`n=== Manuelle apper (automatisk installasjon) ===" -ForegroundColor Magenta
    foreach ($app in $appList) {
        if ($app.manual) {
            $method = switch ($app.id) {
                "CiscoPacketTracer" { "MANUELL (NetAcad-konto kreves)" }
                "OpenCodeCLI" { "npm install -g opencode" }
                "Aider" { "pip install aider-chat" }
                default { "Chocolatey/Scoop → direct download fallback" }
            }
            Write-Host "  $($app.name)" -ForegroundColor Magenta
            Write-Host "    Metode: $method" -ForegroundColor Yellow
            Write-Host "    Info: $($app.url)" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

function Install-Selected {
    param([array]$selected)
    
    # Bekreftelse med checkmarks
    $toInstall = Confirm-InstallList -appList $selected -title "Bekreft installasjon"
    if (-not $toInstall) {
        Write-Host "Avbrutt." -ForegroundColor Red
        return
    }
    
    $wingetApps = $toInstall | Where-Object { -not $_.manual }
    $manualApps = $toInstall | Where-Object { $_.manual }

    if ($wingetApps.Count -gt 0) {
        Write-Host "`n=== Installerer $($wingetApps.Count) winget-apper ===" -ForegroundColor Cyan
        foreach ($app in $wingetApps) {
            Install-WingetApp -app $app
        }
    }

    if ($manualApps.Count -gt 0) {
        $needsPM = $manualApps | Where-Object { $_.choco -ne $null }
        if ($needsPM.Count -gt 0 -and -not (Test-Choco) -and -not (Test-Scoop)) {
            Prompt-InstallPackageManager | Out-Null
        }
        
        Write-Host "`n=== Installerer $($manualApps.Count) manuelle apper (auto) ===" -ForegroundColor Magenta
        foreach ($app in $manualApps) {
            Install-ManualApp -app $app
        }
    }

    Write-Host "`n=== Ferdig! ===" -ForegroundColor Green
}

# ============================================================
# HOVEDLOGIKK
# ============================================================

if ($Help) {
    Write-Host "Bruk: install.ps1 [parametere]"
    Write-Host ""
    Write-Host "Parametere:"
    Write-Host "  -All          Installer alle apper uten meny"
    Write-Host "  -Core         Installer kun core-apper"
    Write-Host "  -Dev          Installer kun dev-apper"
    Write-Host "  -List         Vis full liste og avslutt"
    Write-Host "  -Skip 'app1,app2'  Hopp over spesifikke apper"
    Write-Host "  -Help         Vis denne hjelpen"
    Write-Host ""
    Write-Host "Eksempler:"
    Write-Host "  irm https://olewol.github.io/windows-installer/install.ps1 | iex"
    Write-Host "  .\install.ps1 -All"
    Write-Host "  .\install.ps1 -Core -Skip 'Git,7-Zip'"
    Write-Host "  .\install.ps1 -List"
    exit
}

if ($List) {
    Show-AppList -appList $apps -title "Alle apper ($($apps.Count) totalt)"
    $wingetCount = ($apps | Where-Object { -not $_.manual }).Count
    $manualCount = ($apps | Where-Object { $_.manual }).Count
    Write-Host "Winget: $wingetCount | Manuell (auto): $manualCount" -ForegroundColor Cyan
    exit
}

if ($Skip) {
    $skipList = $Skip -split ',' | ForEach-Object { $_.Trim() }
    $apps = $apps | Where-Object { $skipList -notcontains $_.name }
}

if ($All) {
    Install-Selected -selected $apps
    exit
}

if ($Core) {
    $toInstall = Confirm-InstallList -appList ($apps | Where-Object { $_.cat -eq "core" }) -title "Bekreft core-apper"
    if ($toInstall) { Install-Selected -selected $toInstall }
    exit
}

if ($Dev) {
    $toInstall = Confirm-InstallList -appList ($apps | Where-Object { $_.cat -eq "dev" }) -title "Bekreft dev-apper"
    if ($toInstall) { Install-Selected -selected $toInstall }
    exit
}

# Interaktiv meny
while ($true) {
    Show-Menu
    $choice = Read-Host "Valg"

    switch ($choice) {
        "1" {
            Install-Selected -selected $apps
            Read-Host "`nTrykk Enter for å fortsette"
        }
        "2" {
            $wingetOnly = $apps | Where-Object { -not $_.manual }
            Install-Selected -selected $wingetOnly
            Read-Host "`nTrykk Enter for å fortsette"
        }
        "3" {
            Show-Header
            Write-Host "Tilgjengelige kategorier: core, media, dev, net, tools, adobe, manual" -ForegroundColor Yellow
            $cats = Read-Host "Skriv kategorier (kommaseparert, f.eks. core,dev)"
            $catList = $cats -split ',' | ForEach-Object { $_.Trim() }
            $selected = $apps | Where-Object { $catList -contains $_.cat }
            if ($selected.Count -eq 0) {
                Write-Host "Ingen apper funnet for de valgte kategoriene." -ForegroundColor Red
            } else {
                Install-Selected -selected $selected
            }
            Read-Host "`nTrykk Enter for å fortsette"
        }
        "4" {
            Show-Header
            Write-Host "Velg apper (skriv numre kommaseparert, f.eks. 1,3,5):" -ForegroundColor Yellow
            Show-AppList -appList $apps -title "Alle apper"
            $nums = Read-Host "Numre"
            $indices = $nums -split ',' | ForEach-Object { [int]$_.Trim() - 1 }
            $selected = @()
            foreach ($idx in $indices) {
                if ($idx -ge 0 -and $idx -lt $apps.Count) {
                    $selected += $apps[$idx]
                }
            }
            if ($selected.Count -eq 0) {
                Write-Host "Ingen gyldige valg." -ForegroundColor Red
            } else {
                Install-Selected -selected $selected
            }
            Read-Host "`nTrykk Enter for å fortsette"
        }
        "5" {
            $manualApps = $apps | Where-Object { $_.manual }
            Show-ManualApps -appList $manualApps
            $confirm = Read-Host "Installer manuelle apper? (j/n)"
            if ($confirm -eq "j") {
                $needsPM = $manualApps | Where-Object { $_.choco -ne $null }
                if ($needsPM.Count -gt 0 -and -not (Test-Choco) -and -not (Test-Scoop)) {
                    Prompt-InstallPackageManager | Out-Null
                }
                $toInstall = Confirm-InstallList -appList $manualApps -title "Bekreft manuelle apper"
                if ($toInstall) {
                    foreach ($app in $toInstall) {
                        Install-ManualApp -app $app
                    }
                }
            }
            Read-Host "`nTrykk Enter for å fortsette"
        }
        "6" {
            Show-AppList -appList $apps -title "Alle apper ($($apps.Count) totalt)"
            $wingetCount = ($apps | Where-Object { -not $_.manual }).Count
            $manualCount = ($apps | Where-Object { $_.manual }).Count
            Write-Host "Winget: $wingetCount | Manuell (auto): $manualCount" -ForegroundColor Cyan
            Read-Host "`nTrykk Enter for å fortsette"
        }
        "q" { exit }
        "Q" { exit }
        default {
            Write-Host "Ugyldig valg. Prøv igjen." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}