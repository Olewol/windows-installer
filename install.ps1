# Windows App Installer — interaktivt menybasert
# Kjør: irm https://olewol.github.io/windows-installer/install.ps1 | iex
# Eller: .\install.ps1

param(
    [switch]$All,
    [switch]$Core,
    [switch]$Dev,
    [switch]$List,
    [string]$Skip = "",
    [switch]$Help
)

# ============================================================
# APP-DEFINISJONER
# ============================================================

$apps = @(
    @{ id = "Notepad++.Notepad++";       name = "Notepad++";              cat = "core"; manual = $false; url = "https://notepad-plus-plus.org"; choco = $null },
    @{ id = "Mozilla.Firefox";           name = "Mozilla Firefox";        cat = "core"; manual = $false; url = "https://www.mozilla.org/firefox"; choco = $null },
    @{ id = "7zip.7zip";                 name = "7-Zip";                 cat = "core"; manual = $false; url = "https://www.7-zip.org"; choco = $null },
    @{ id = "Git.Git";                   name = "Git";                   cat = "core"; manual = $false; url = "https://git-scm.com"; choco = $null },
    @{ id = "Bitwarden.Bitwarden";       name = "Bitwarden";             cat = "core"; manual = $false; url = "https://bitwarden.com"; choco = $null },
    @{ id = "Microsoft.PowerShell";      name = "PowerShell 7";          cat = "core"; manual = $false; url = "https://github.com/PowerShell/PowerShell"; choco = $null },
    @{ id = "Microsoft.WindowsTerminal"; name = "Windows Terminal";      cat = "core"; manual = $false; url = "https://github.com/microsoft/terminal"; choco = $null },
    @{ id = "clsid2.mpc-hc";             name = "Media Player Classic HC"; cat = "media"; manual = $false; url = "https://mpc-hc.org"; choco = $null },
    @{ id = "Daum.PotPlayer";            name = "PotPlayer";             cat = "media"; manual = $false; url = "https://potplayer.daum.net"; choco = $null },
    @{ id = "Stremio.Stremio";           name = "Stremio";               cat = "media"; manual = $false; url = "https://www.stremio.com"; choco = $null },
    @{ id = "VideoLAN.VLC";              name = "VLC";                   cat = "media"; manual = $false; url = "https://www.videolan.org/vlc"; choco = $null },
    @{ id = "Zoom.Zoom";                 name = "Zoom Workplace";        cat = "media"; manual = $false; url = "https://zoom.us"; choco = $null },
    @{ id = "Neovim.Neovim";             name = "Neovim";                cat = "dev";  manual = $false; url = "https://neovim.io"; choco = $null },
    @{ id = "VSCodium.VSCodium";         name = "VSCodium";              cat = "dev";  manual = $false; url = "https://vscodium.com"; choco = $null },
    @{ id = "Microsoft.PowerToys";       name = "PowerToys";             cat = "dev";  manual = $false; url = "https://github.com/microsoft/PowerToys"; choco = $null },
    @{ id = "NodeJS";                    name = "Node.js";               cat = "dev";  manual = $false; wingetId = "OpenJS.NodeJS"; url = "https://nodejs.org"; choco = $null },
    @{ id = "Python";                    name = "Python 3.12";           cat = "dev";  manual = $false; wingetId = "Python.Python.3.12"; url = "https://www.python.org"; choco = $null },
    @{ id = "tailscale.tailscale";       name = "Tailscale";             cat = "net";  manual = $false; url = "https://tailscale.com"; choco = $null },
    @{ id = "Mobatek.MobaXterm";         name = "MobaXterm";             cat = "net";  manual = $false; url = "https://mobaxterm.mobatek.net"; choco = $null },
    @{ id = "VMware.WorkstationPro";     name = "VMware Workstation Pro"; cat = "net";  manual = $false; url = "https://www.vmware.com/products/workstation-pro.html"; choco = $null },
    @{ id = "WiresharkFoundation.Wireshark"; name = "Wireshark";         cat = "net";  manual = $false; url = "https://www.wireshark.org"; choco = $null },
    @{ id = "JGraph.Draw";               name = "draw.io";               cat = "tools"; manual = $false; url = "https://www.drawio.com"; choco = $null },
    @{ id = "ShareX.ShareX";             name = "ShareX";                cat = "tools"; manual = $false; url = "https://getsharex.com"; choco = $null },
    @{ id = "OBSProject.OBSStudio";      name = "OBS Studio";            cat = "tools"; manual = $false; url = "https://obsproject.com"; choco = $null },
    @{ id = "Google.Chrome";             name = "Google Chrome";         cat = "tools"; manual = $false; url = "https://www.google.com/chrome"; choco = $null },
    @{ id = "Docker.DockerDesktop";      name = "Docker Desktop";        cat = "tools"; manual = $false; url = "https://www.docker.com/products/docker-desktop"; choco = $null },
    @{ id = "Adobe.Acrobat.Reader.64-bit"; name = "Adobe Acrobat Reader (64-bit)"; cat = "adobe"; manual = $false; url = "https://www.adobe.com/acrobat/pdf-reader.html"; choco = $null },
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
# INTERAKTIVT UI MED PILTASTER + SPACE
# ============================================================

function Show-InteractiveSelector {
    param([array]$appList, [string]$title = "Velg apper")
    
    $items = @()
    foreach ($app in $appList) {
        $items += @{ app = $app; selected = $true }
    }
    
    $cursor = 0
    $pageSize = [Math]::Max(5, $Host.UI.RawUI.WindowSize.Height - 10)
    $scrollOffset = 0
    
    while ($true) {
        Clear-Host
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "  ║  $($title.PadRight(52))║" -ForegroundColor Cyan
        Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  ↑↓ naviger  |  Space toggle  |  a=alle  n=ingen  |  Enter=bekreft  |  Esc=avbryt" -ForegroundColor DarkYellow
        Write-Host ""
        
        $endIdx = [Math]::Min($scrollOffset + $pageSize, $items.Count)
        for ($i = $scrollOffset; $i -lt $endIdx; $i++) {
            $item = $items[$i]
            $check = if ($item.selected) { "[x]" } else { "[ ]" }
            $marker = if ($i -eq $cursor) { "►" } else { " " }
            if ($i -eq $cursor) {
                $color = "White"
            } elseif ($item.selected) {
                $color = "Green"
            } else {
                $color = "DarkGray"
            }
            $type = if ($item.app.manual) { "AUTO" } else { "wg  " }
            $line = "  $marker $check $($item.app.name.PadRight(30)) $type"
            if ($i -eq $cursor) {
                Write-Host $line -ForegroundColor $color -BackgroundColor DarkBlue
            } else {
                Write-Host $line -ForegroundColor $color
            }
        }
        
        if ($items.Count -gt $pageSize) {
            Write-Host ""
            Write-Host "  ($($scrollOffset + 1)-$endIdx av $($items.Count))" -ForegroundColor DarkGray
        }
        
        $selectedCount = ($items | Where-Object { $_.selected }).Count
        Write-Host ""
        Write-Host "  Valgt: $selectedCount av $($items.Count) apper" -ForegroundColor Cyan
        Write-Host ""
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($key.VirtualKeyCode) {
            38 {
                if ($cursor -gt 0) { $cursor-- }
                if ($cursor -lt $scrollOffset) { $scrollOffset = $cursor }
            }
            40 {
                if ($cursor -lt ($items.Count - 1)) { $cursor++ }
                if ($cursor -ge ($scrollOffset + $pageSize)) { $scrollOffset = $cursor - $pageSize + 1 }
            }
            32 {
                $items[$cursor].selected = -not $items[$cursor].selected
            }
            13 {
                $result = @()
                foreach ($item in $items) {
                    if ($item.selected) { $result += $item.app }
                }
                if ($result.Count -eq 0) {
                    Write-Host "  Ingen apper valgt!" -ForegroundColor Red
                    Start-Sleep -Seconds 1
                    continue
                }
                return $result
            }
            27 { return $null }
            65 { foreach ($item in $items) { $item.selected = $true } }
            78 { foreach ($item in $items) { $item.selected = $false } }
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
    Write-Host "║         Windows App Installer                            ║" -ForegroundColor Cyan
    Write-Host "║         https://olewol.github.io/windows-installer/      ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Show-Header
    Write-Host "  Velg utgangspunkt:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Kjerne-apper (7 apps)" -ForegroundColor White
    Write-Host "  [2] Kjerne + Media (12 apps)" -ForegroundColor White
    Write-Host "  [3] Kjerne + Dev (12 apps)" -ForegroundColor White
    Write-Host "  [4] Kjerne + Nettverk/VM (11 apps)" -ForegroundColor White
    Write-Host "  [5] Kjerne + Verktøy (12 apps)" -ForegroundColor White
    Write-Host "  [6] Alt (34 apps)" -ForegroundColor White
    Write-Host "  [7] Velg fritt (alle apper)" -ForegroundColor White
    Write-Host "  [8] Vis full liste" -ForegroundColor White
    Write-Host "  [Q] Avslutt" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Etter valg: piltaster + Space for å toggle, Enter for å bekrefte" -ForegroundColor DarkGray
    Write-Host ""
}

function Install-Selected {
    param([array]$selected)
    $toInstall = Show-InteractiveSelector -appList $selected -title "Velg apper (Space=toggle, Enter=bekreft)"
    if (-not $toInstall) {
        Write-Host "Avbrutt." -ForegroundColor Red
        return
    }
    $wingetApps = $toInstall | Where-Object { -not $_.manual }
    $manualApps = $toInstall | Where-Object { $_.manual }
    if ($wingetApps.Count -gt 0) {
        Write-Host "`n=== Installerer $($wingetApps.Count) winget-apper ===" -ForegroundColor Cyan
        foreach ($app in $wingetApps) { Install-WingetApp -app $app }
    }
    if ($manualApps.Count -gt 0) {
        $needsPM = $manualApps | Where-Object { $_.choco -ne $null }
        if ($needsPM.Count -gt 0 -and -not (Test-Choco) -and -not (Test-Scoop)) {
            Prompt-InstallPackageManager | Out-Null
        }
        Write-Host "`n=== Installerer $($manualApps.Count) manuelle apper (auto) ===" -ForegroundColor Magenta
        foreach ($app in $manualApps) { Install-ManualApp -app $app }
    }
    Write-Host "`n=== Ferdig! ===" -ForegroundColor Green
}

# ============================================================
# HOVEDLOGIKK
# ============================================================

if ($Help) {
    Write-Host "Bruk: install.ps1 [parametere]"
    Write-Host "  -All  -Core  -Dev  -List  -Skip 'app1,app2'  -Help"
    exit
}

if ($List) {
    $i = 1
    foreach ($app in $apps) {
        $status = if ($app.manual) { "[AUTO]" } else { "[winget]" }
        Write-Host ("  {0,3}. {1,-35} {2}  {3}" -f $i, $app.name, $status, $app.url) -ForegroundColor $(if ($app.manual) { "Magenta" } else { "Green" })
        $i++
    }
    Write-Host "`nTotalt: $($apps.Count) apper" -ForegroundColor Cyan
    exit
}

if ($Skip) {
    $skipList = $Skip -split ',' | ForEach-Object { $_.Trim() }
    $apps = $apps | Where-Object { $skipList -notcontains $_.name }
}

if ($All) { Install-Selected -selected $apps; exit }
if ($Core) { $coreApps = $apps | Where-Object { $_.cat -eq "core" }; Install-Selected -selected $coreApps; exit }
if ($Dev) { $devApps = $apps | Where-Object { $_.cat -eq "dev" }; Install-Selected -selected $devApps; exit }

while ($true) {
    Show-Menu
    $choice = Read-Host "Valg"
    switch ($choice) {
        "1" { $coreApps = $apps | Where-Object { $_.cat -eq "core" }; Install-Selected -selected $coreApps; Read-Host "`nTrykk Enter for å fortsette" }
        "2" { $s = $apps | Where-Object { $_.cat -eq "core" -or $_.cat -eq "media" }; Install-Selected -selected $s; Read-Host "`nTrykk Enter for å fortsette" }
        "3" { $s = $apps | Where-Object { $_.cat -eq "core" -or $_.cat -eq "dev" }; Install-Selected -selected $s; Read-Host "`nTrykk Enter for å fortsette" }
        "4" { $s = $apps | Where-Object { $_.cat -eq "core" -or $_.cat -eq "net" }; Install-Selected -selected $s; Read-Host "`nTrykk Enter for å fortsette" }
        "5" { $s = $apps | Where-Object { $_.cat -eq "core" -or $_.cat -eq "tools" }; Install-Selected -selected $s; Read-Host "`nTrykk Enter for å fortsette" }
        "6" { Install-Selected -selected $apps; Read-Host "`nTrykk Enter for å fortsette" }
        "7" { Install-Selected -selected $apps; Read-Host "`nTrykk Enter for å fortsette" }
        "8" {
            $i = 1
            foreach ($app in $apps) {
                $status = if ($app.manual) { "[AUTO]" } else { "[winget]" }
                Write-Host ("  {0,3}. {1,-35} {2}  {3}" -f $i, $app.name, $status, $app.url) -ForegroundColor $(if ($app.manual) { "Magenta" } else { "Green" })
                $i++
            }
            Write-Host "`nTotalt: $($apps.Count) apper" -ForegroundColor Cyan
            Read-Host "`nTrykk Enter for å fortsette"
        }
        "q" { exit }
        "Q" { exit }
        default { Write-Host "Ugyldig valg. Prøv igjen." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}