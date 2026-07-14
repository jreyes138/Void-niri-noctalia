# Void-niri-noctalia

Complete desktop configuration for **Void Linux** with the **niri** Wayland compositor and **Noctalia** shell.

## What's included

| Component | Tool | Config |
|-----------|------|--------|
| Compositor | niri 26.04 | `config/niri/config.kdl` |
| Shell | Noctalia v5 | `config/noctalia/config.toml` |
| Terminal | Ghostty | `config/ghostty/config` |
| Browser | Zen | `config/mimeapps.list` |
| Editor (TUI) | micro | `config/micro/settings.json` |
| Editor (modal) | nvim | `config/nvim/init.lua` |
| File manager | yazi | `config/yazi/yazi.toml` |
| Launcher | fuzzel | — |
| Email | Tutanota (flatpak) | — |
| Shell | bash | `config/.bashrc` |
| Pager | bat | `config/bat/config` |
| ls replacement | eza | — |

## Keybinds

| Key | Action |
|-----|--------|
| `Mod+T` | Terminal (ghostty) |
| `Mod+B` | Browser (zen) |
| `Mod+E` | File manager (yazi) |
| `Mod+M` | Email (tutanota) |
| `Mod+D` | App launcher (fuzzel) |
| `Mod+Space` | Noctalia launcher |
| `Mod+S` | Noctalia control center |
| `Mod+Comma` | Noctalia settings |
| `Mod+Q` | Close window |
| `Mod+Tab` | Overview |
| `Mod+1-9` | Switch workspace |
| `Mod+Shift+1-9` | Move window to workspace |
| `Mod+Left/Right/Up/Down` | Focus direction |
| `Mod+Shift+Arrow` | Move window/column |
| `Mod+F` | Maximize column |
| `Mod+Shift+F` | Fullscreen window |
| `Mod+C` | Center column |
| `Mod+R` | Expand to available width |
| `Mod+Return` | Terminal (alternative) |

## Theming

All apps follow the **Noctalia global theme** (currently Ayu dark):

- **Ghostty** — Noctalia builtin template (auto-generated `noctalia` theme)
- **nvim** — Noctalia community `neovim` template (base16 + matugen.lua, hot-reload via SIGUSR1)
- **yazi** — Noctalia community `yazi` template (noctalia flavor)
- **micro** — `noctalia-sync-themes` script generates colorscheme from ghostty theme
- **bat** — `noctalia-sync-themes` script generates tmTheme from ghostty theme

The `colors_changed` hook in Noctalia runs `noctalia-sync-themes` automatically when the theme changes.

## Top bar

- Full-width, transparent (opacity 0.0, radius 0, no margins)
- Blur applied only to the bar via niri `layer-rule`
- Dock disabled

## Prerequisites

- Void Linux (x86_64) with xbps
- AMD GPU (amdgpu) or compatible
- sudo access

## Installation

```bash
git clone git@github.com:jreyes138/Void-niri-noctalia.git
cd Void-niri-noctalia
chmod +x bootstrap.sh
./bootstrap.sh
```

The script will:
1. Install all required packages via xbps
2. Install Nerd Fonts (JetBrains Mono, FiraCode, Meslo, Hack)
3. Symlink all configs to `~/.config/`
4. Install the niri-session wrapper to `/usr/local/bin/`
5. Enable runit services (elogind, dbus, seatd, greetd, etc.)
6. Set up flatpak (userspace) with flathub
7. Set Zen as default browser
8. Build bat cache and install nvim plugins
9. Run theme sync

After installation, **log out and log back in** to start the niri session.

## Structure

```
Void-niri-noctalia/
├── bootstrap.sh              # One-shot setup script
├── config/
│   ├── .bashrc               # Shell config (aliases, prompt, functions)
│   ├── .bash_profile         # Sources .bashrc
│   ├── niri/
│   │   ├── config.kdl        # Niri compositor config (keybinds, layout, blur)
│   │   └── noctalia.kdl      # Noctalia-generated niri theme include
│   ├── noctalia/
│   │   └── config.toml       # Noctalia shell config (bar, dock, theme, hooks)
│   ├── ghostty/
│   │   └── config            # Ghostty terminal config
│   ├── micro/
│   │   ├── settings.json     # micro editor settings
│   │   └── colorschemes/
│   │       └── noctalia.micro  # Generated colorscheme
│   ├── bat/
│   │   ├── config            # bat pager config
│   │   └── themes/
│   │       └── noctalia.tmTheme  # Generated theme
│   ├── nvim/
│   │   └── init.lua          # Neovim config (lazy.nvim + base16 + Noctalia theme)
│   └── yazi/
│       ├── yazi.toml         # yazi file manager config
│       ├── keymap.toml      # keymap (quit without confirmation)
│       ├── theme.toml        # theme reference (flavor: noctalia)
│       └── flavors/
│           └── noctalia.yazi/
│               └── flavor.toml  # Generated yazi flavor
└── scripts/
    ├── niri-session          # Session wrapper (dbus, pipewire, wireplumber)
    └── noctalia-sync-themes  # Syncs micro + bat themes from ghostty/Noctalia
```