#!/usr/bin/env bash
# Void-niri-noctalia: bootstrap script
# Installs all required packages and symlinks configs to ~/.config
# Run on a fresh Void Linux installation.
#
# Usage: ./bootstrap.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"

echo "=== Void-niri-noctalia bootstrap ==="
echo ""

# ── Check we're on Void Linux ──────────────────────────────────────────────────
if ! command -v xbps-install &>/dev/null; then
    echo "Error: This script is for Void Linux. xbps-install not found."
    exit 1
fi

# ── Install packages ──────────────────────────────────────────────────────────
echo ">> Installing packages..."
PACKAGES=(
    niri noctalia wezterm ghostty fuzzel
    micro bat eza nvim yazi
    pipewire wireplumber
    xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk xdg-desktop-portal-wlr
    gnome-keyring sdbus-c++ xfce-polkit
    bash-completion
    fontconfig
    elogind dbus seatd polkitd
    socklog-unix nanoklogd
    NetworkManager chronyd
    git flatpak
    wtype wlr-randr
)

echo "The following packages will be installed:"
for pkg in "${PACKAGES[@]}"; do echo "  $pkg"; done
echo ""
read -rp "Proceed with installation? [Y/n] " confirm
[[ "$confirm" =~ ^[Yy]?$ ]] || { echo "Aborted."; exit 1; }

sudo xbps-install -Su
sudo xbps-install -y "${PACKAGES[@]}"

# ── Install Nerd Fonts ────────────────────────────────────────────────────────
echo ""
echo ">> Installing Nerd Fonts (JetBrains Mono, FiraCode, Meslo, Hack)..."
FONT_DIR="$HOME/.local/share/fonts/nerd-fonts"
mkdir -p "$FONT_DIR"
for font in JetBrainsMono FiraCode Meslo Hack; do
    if ! ls "$FONT_DIR"/${font}*.ttf &>/dev/null; then
        echo "  Downloading $font..."
        curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip" -o /tmp/${font}.zip
        unzip -qo /tmp/${font}.zip -d "$FONT_DIR" 2>/dev/null || echo "  Warning: $font download failed"
        rm -f /tmp/${font}.zip
    else
        echo "  $font already installed"
    fi
done
sudo xbps-install -y nerd-fonts-symbols-ttf 2>/dev/null || true
fc-cache -f

# ── Symlink configs ───────────────────────────────────────────────────────────
echo ""
echo ">> Symlinking config files..."

link_config() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "  Backing up existing $dest -> ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi
    ln -sfn "$src" "$dest"
    echo "  Linked: $dest -> $src"
}

# Niri
link_config "$CONFIG_DIR/niri/config.kdl" "$HOME/.config/niri/config.kdl"
link_config "$CONFIG_DIR/niri/noctalia.kdl" "$HOME/.config/niri/noctalia.kdl"

# Noctalia
link_config "$CONFIG_DIR/noctalia/config.toml" "$HOME/.config/noctalia/config.toml"

# Ghostty
link_config "$CONFIG_DIR/ghostty/config" "$HOME/.config/ghostty/config"

# Micro
link_config "$CONFIG_DIR/micro/settings.json" "$HOME/.config/micro/settings.json"
link_config "$CONFIG_DIR/micro/colorschemes/noctalia.micro" "$HOME/.config/micro/colorschemes/noctalia.micro"

# Bat
link_config "$CONFIG_DIR/bat/config" "$HOME/.config/bat/config"
link_config "$CONFIG_DIR/bat/themes/noctalia.tmTheme" "$HOME/.config/bat/themes/noctalia.tmTheme"

# Nvim
link_config "$CONFIG_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"

# Yazi
link_config "$CONFIG_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
link_config "$CONFIG_DIR/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
link_config "$CONFIG_DIR/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
link_config "$CONFIG_DIR/yazi/flavors/noctalia.yazi/flavor.toml" "$HOME/.config/yazi/flavors/noctalia.yazi/flavor.toml"

# Shell
link_config "$CONFIG_DIR/.bashrc" "$HOME/.bashrc"
link_config "$CONFIG_DIR/.bash_profile" "$HOME/.bash_profile"

# Scripts
link_config "$SCRIPT_DIR/scripts/noctalia-sync-themes" "$HOME/.local/bin/noctalia-sync-themes"
link_config "$SCRIPT_DIR/scripts/niri-session" "/usr/local/bin/niri-session" 2>/dev/null || echo "  Skipped niri-session (needs sudo)"

echo ""
echo ">> Setting up niri-session..."
read -rp "Install niri-session wrapper to /usr/local/bin? [Y/n] " confirm
if [[ "$confirm" =~ ^[Yy]?$ ]]; then
    sudo cp "$SCRIPT_DIR/scripts/niri-session" /usr/local/bin/niri-session
    sudo chmod +x /usr/local/bin/niri-session
    sudo sed -i "s|Exec=niri --session|Exec=/usr/local/bin/niri-session|" /usr/share/wayland-sessions/niri.desktop 2>/dev/null || true
    echo "  niri-session installed"
fi

# ── Enable services ───────────────────────────────────────────────────────────
echo ""
echo ">> Enabling runit services..."
SERVICES=(elogind dbus seatd polkitd greetd udevd socklog-unix nanoklogd NetworkManager chronyd sshd)
for svc in "${SERVICES[@]}"; do
    if [ ! -d "/var/service/$svc" ] && [ -d "/etc/sv/$svc" ]; then
        sudo ln -s "/etc/sv/$svc" "/var/service/$svc"
        echo "  Enabled: $svc"
    else
        echo "  Already enabled: $svc"
    fi
done

# ── Flatpak ────────────────────────────────────────────────────────────────────
echo ""
echo ">> Setting up flatpak (userspace)..."
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

# ── XDG_DATA_DIRS ──────────────────────────────────────────────────────────────
# Already in .bashrc and niri config, but let's verify
echo ">> XDG_DATA_DIRS is set in .bashrc, niri config, and niri-session"

# ── Default browser ───────────────────────────────────────────────────────────
echo ""
echo ">> Setting default browser..."
mkdir -p "$HOME/.config"
cat > "$HOME/.config/mimeapps.list" << 'MIME'
[Default Applications]
x-scheme-handler/http=zen.desktop
x-scheme-handler/https=zen.desktop
x-scheme-handler/chrome=zen.desktop
text/html=zen.desktop
application/xhtml+xml=zen.desktop

[Added Associations]
x-scheme-handler/http=zen.desktop
x-scheme-handler/https=zen.desktop
MIME

# ── Bat cache ─────────────────────────────────────────────────────────────────
echo ">> Building bat cache..."
bat cache --build 2>/dev/null || true

# ── Nvim plugins ──────────────────────────────────────────────────────────────
echo ">> Installing nvim plugins..."
nvim --headless "+Lazy! sync" "+qa" 2>/dev/null || true

# ── Sync themes ────────────────────────────────────────────────────────────────
echo ">> Running theme sync..."
noctalia-sync-themes 2>/dev/null || true

echo ""
echo "=== Bootstrap complete! ==="
echo "Log out and log back in to start your niri session."
echo "Key keybinds: Mod+T (terminal), Mod+B (browser), Mod+D (launcher), Mod+E (files), Mod+M (email)"