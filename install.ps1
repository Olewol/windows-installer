# Windows App Installer — interaktivt menybasert
# Kjør: irm https://olewol.github.io/windows-installer/install.ps1 | iex
# Eller: .\install.ps1

param(
    [switch]$All,           # Installer alt uten meny
    [switch]$Core,          # Kun core-apps
    [switch]$Dev,           # Kun dev-apps
    [switch]$List,          # Vis liste og avslutt
    [string]$Skip = "",     # Kommaseparerte apper å hoppe over
    [switch]$Help           # Vis hjelp
)

# ============================================================
# APP-DEFINISJONER
# ============================================================

# Format: @{ id = "winget-id"; name = "Visningsnavn"; category = "kategori"; manual = $false; url = "" }
# manual = $true betyr at appen ikke er i winget og må lastes ned manuelt

$apps = @(
    # --- Core (alle trenger) ---
    @{ id = "Notepad++.Notepad++";       name = "Notepad++";              cat = "core"; manual = $false },
    @{ id = "Mozilla.Firefox";           name = "Mozilla Firefox";        cat = "core"; manual = $false },
    @{ id = "7zip.7zip";                 name = "7-Zip";                 cat = "core"; manual = $false },
    @{ id = "Git.Git";                   name = "Git";                   cat = "core"; manual = $false },
    @{ id = "Bitwarden.Bitwarden";       name = "Bitwarden";             cat = "core"; manual = $false },
    @{ id = "Microsoft.PowerShell";      name = "PowerShell 7";          cat = "core"; manual = $false },
    @{ id = "Microsoft.WindowsTerminal"; name = "Windows Terminal";      cat = "core"; manual = $false },

    # --- Media ---
    @{ id = "clsid2.mpc-hc";             name = "Media Player Classic HC"; cat = "media"; manual = $false },
    @{ id = "Daum.PotPlayer";            name = "PotPlayer";             cat = "media"; manual = $false },
    @{ id = "Stremio.Stremio";           name = "Stremio";               cat = "media"; manual = $false },
    @{ id = "VideoLAN.VLC";              name = "VLC";                   cat = "media"; manual = $false },
    @{ id = "Zoom.Zoom";                 name = "Zoom Workplace";        cat = "media"; manual = $false },

    # --- Dev ---
    @{ id = "Neovim.Neovim";             name = "Neovim";                cat = "dev";  manual = $false },
    @{ id = "VSCodium.VSCodium";         name = "VSCodium";              cat = "dev";  manual = $false },
    @{ id = "Microsoft.PowerToys";       name = "PowerToys";             cat = "dev";  manual = $false },
    @{ id = "NodeJS";                    name = "Node.js";               cat = "dev";  manual = $false; wingetId = "OpenJS.NodeJS" },
    @{ id = "Python";                    name = "Python 3.12";           cat = "dev";  manual = $false; wingetId = "Python.Python.3.12" },

    # --- Network/VM ---
    @{ id = "tailscale.tailscale";       name = "Tailscale";             cat = "net";  manual = $false },
    @{ id = "Mobatek.MobaXterm";         name = "MobaXterm";             cat = "net";  manual = $false },
    @{ id = "VMware.WorkstationPro";     name = "VMware Workstation Pro"; cat = "net";  manual = $false },
    @{ id = "WiresharkFoundation.Wireshark"; name = "Wireshark";         cat = "net";  manual = $false },

    # --- Tools ---
    @{ id = "JGraph.Draw";               name = "draw.io";               cat = "tools"; manual = $false },
    @{ id = "ShareX.ShareX";             name = "ShareX";                cat = "tools"; manual = $false },
    @{ id = "OBSProject.OBSStudio";      name = "OBS Studio";            cat = "tools"; manual = $false },
    @{ id = "Google.Chrome";             name = "Google Chrome";         cat = "tools"; manual = $false },
    @{ id = "Docker.DockerDesktop";      name = "Docker Desktop";        cat = "tools"; manual = $false },

    # --- Adobe ---
    @{ id = "Adobe.Acrobat.Reader.64-bit"; name = "Adobe Acrobat Reader (64-bit)"; cat = "adobe"; manual = $false },

    # --- Manuelle (ikke i winget) ---
    @{ id = "CiscoPacketTracer";         name = "Cisco Packet Tracer";   cat = "manual"; manual = $true; url = "https://www.netacad.com/cisco-packet-tracer" },
    @{ id = "CCCP";                     name = "CCCP Codec Pack";       cat = "manual"; manual = $true; url = "https://www.cccp-project.net/" },
    @{ id = "OpenCodeCLI";              name = "OpenCode CLI (AI)";     cat = "manual"; manual = $true; url = "https://opencode.ai" },
    @{ id = "Aider";                    name = "Aider (AI coding)";     cat = "manual"; manual = $true; url = "https://aider.chat" },
    @{ id = "Athas";                    name = "Athas (AI editor)";     cat = "manual"; manual = $true; url = "https://athas.dev" },
    @{ id = "Helix";                    name = "Helix (editor)";        cat = "manual"; manual = $true; url = "https://helix-editor.com" },
    @{ id = "Zed";                      name = "Zed (editor)";          cat = "manual"; manual = $true; url = "https://zed.dev" }
)

# ============================================================
# HJELPEFUNKSJONER
# ============================================================

function Show-Header {
    Clear-Host
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║         Windows App Installer — winget + manuelt         ║" -ForegroundColor Cyan
    Write-Host "║         https://olewol.github.io/windows-installer/      ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Show-Header
    Write-Host "Velg installasjonsmodus:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] Installer ALLE apper (winget + manuell liste)" -ForegroundColor White
    Write-Host "  [2] Installer KUN winget-apper (automatisk)" -ForegroundColor White
    Write-Host "  [3] Velg kategorier (core, media, dev, net, tools, adobe)" -ForegroundColor White
    Write-Host "  [4] Velg individuelle apper (av/på)" -ForegroundColor White
    Write-Host "  [5] Kun manuelle apper (vis lenker)" -ForegroundColor White
    Write-Host "  [6] Vis full liste og avslutt" -ForegroundColor White
    Write-Host "  [Q] Avslutt" -ForegroundColor Red
    Write-Host ""
}

function Show-AppList {
    param([array]$appList, [string]$title = "App-liste")
    Write-Host "`n=== $title ===" -ForegroundColor Cyan
    $i = 1
    foreach ($app in $appList) {
        $status = if ($app.manual) { "[MANUELL]" } else { "[winget]" }
        $color = if ($app.manual) { "Magenta" } else { "Green" }
        Write-Host ("  {0,3}. {1,-35} {2}" -f $i, $app.name, $status) -ForegroundColor $color
        $i++
    }
    Write-Host ""
}

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

function Show-ManualApps {
    param([array]$appList)
    Write-Host "`n=== Manuelle apper (ikke i winget) ===" -ForegroundColor Magenta
    foreach ($app in $appList) {
        if ($app.manual) {
            Write-Host "  $($app.name)" -ForegroundColor Magenta
            Write-Host "    Last ned: $($app.url)" -ForegroundColor Yellow
        }
    }
    Write-Host ""
}

function Install-Selected {
    param([array]$selected)
    $wingetApps = $selected | Where-Object { -not $_.manual }
    $manualApps = $selected | Where-Object { $_.manual }

    Write-Host "`n=== Installerer $($wingetApps.Count) winget-apper ===" -ForegroundColor Cyan
    foreach ($app in $wingetApps) {
        Install-WingetApp -app $app
    }

    if ($manualApps.Count -gt 0) {
        Show-ManualApps -appList $manualApps
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
    Write-Host "Winget: $wingetCount | Manuell: $manualCount" -ForegroundColor Cyan
    exit
}

# Filtrer bort skip-apper
if ($Skip) {
    $skipList = $Skip -split ',' | ForEach-Object { $_.Trim() }
    $apps = $apps | Where-Object { $skipList -notcontains $_.name }
}

if ($All) {
    Install-Selected -selected $apps
    exit
}

if ($Core) {
    $selected = $apps | Where-Object { $_.cat -eq "core" -or $_.manual -eq $false -and $_.cat -eq "core" }
    Install-Selected -selected ($apps | Where-Object { $_.cat -eq "core" })
    exit
}

if ($Dev) {
    Install-Selected -selected ($apps | Where-Object { $_.cat -eq "dev" })
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
                Show-AppList -appList $selected -title "Valgte apper"
                $confirm = Read-Host "Installer disse? (j/n)"
                if ($confirm -eq "j") {
                    Install-Selected -selected $selected
                }
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
                Show-AppList -appList $selected -title "Valgte apper"
                $confirm = Read-Host "Installer disse? (j/n)"
                if ($confirm -eq "j") {
                    Install-Selected -selected $selected
                }
            }
            Read-Host "`nTrykk Enter for å fortsette"
        }
        "5" {
            $manualApps = $apps | Where-Object { $_.manual }
            Show-ManualApps -appList $manualApps
            Read-Host "`nTrykk Enter for å fortsette"
        }
        "6" {
            Show-AppList -appList $apps -title "Alle apper ($($apps.Count) totalt)"
            $wingetCount = ($apps | Where-Object { -not $_.manual }).Count
            $manualCount = ($apps | Where-Object { $_.manual }).Count
            Write-Host "Winget: $wingetCount | Manuell: $manualCount" -ForegroundColor Cyan
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