# Windows App Installer

Interaktivt PowerShell-script som installerer Windows-apper via `winget`.

## Hurtigstart

```powershell
irm https://olewol.github.io/windows-installer/install.ps1 | iex
```

## Parametere

```powershell
.\install.ps1 -All          # Installer alt
.\install.ps1 -Core         # Kun core-apper
.\install.ps1 -Dev          # Kun dev-apper
.\install.ps1 -List         # Vis full liste
.\install.ps1 -Skip "Git,7-Zip"  # Hopp over spesifikke apper
.\install.ps1 -Help         # Vis hjelp
```

## Menyvalg

| Valg | Beskrivelse |
|------|-------------|
| 1 | Installer ALLE apper |
| 2 | Installer kun winget-apper (automatisk) |
| 3 | Velg kategorier (core, media, dev, net, tools, adobe) |
| 4 | Velg individuelle apper (av/på) |
| 5 | Kun manuelle apper (vis lenker) |
| 6 | Vis full liste |
| Q | Avslutt |

## App-liste (34 apper)

### Winget (27)
Notepad++, Firefox, 7-Zip, Git, Bitwarden, PowerShell 7, Windows Terminal, MPC-HC, PotPlayer, Stremio, VLC, Zoom, Neovim, VSCodium, PowerToys, Node.js, Python 3.12, Tailscale, MobaXterm, VMware Workstation Pro, Wireshark, draw.io, ShareX, OBS Studio, Google Chrome, Docker Desktop, Adobe Acrobat Reader

### Manuell (7)
Cisco Packet Tracer, CCCP, OpenCode CLI, Aider, Athas, Helix, Zed