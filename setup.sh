#!/bin/bash
set -e

echo "=== 1. Очистка системы от лишнего мусора ==="
sudo apt purge -y libreoffice* abiword gnumeric simple-scan thunderbird telegram-desktop || true
sudo apt autoremove -y
sudo apt clean

echo "=== 2. Обновление и установка базовых утилит, Wine, Flatpak и софта ==="
sudo apt update
sudo apt install -y tint2 feh rofi picom curl wget git unzip obs-studio wine wine32 wine64 flatpak fastfetch cava btop fonts-noto-cjk

echo "=== 3. Настройка постоянного разрешения экрана 1280x800 (навсегда) ==="
sudo mkdir -p /etc/X11/xorg.conf.d
sudo bash -c 'cat << "XORG" > /etc/X11/xorg.conf.d/10-monitor.conf
Section "Screen"
    Identifier "Screen0"
    SubSection "Display"
        Modes "1280x800"
    EndSubSection
EndSection
XORG'

# Применяем сразу для текущей сессии без перезагрузки
xrandr -s 1280x800 || true

echo "=== 4. Установка картинки на обои ==="
mkdir -p ~/Pictures
wget -O ~/Pictures/wallpaper.jpg "https://images.wallpapersden.com/image/download/night-anime-anime-girls-kitagawa-marin-gerda-rubia-hd_bW5qa22UmZqaraWkpJRmbmdlrWZlbWU.jpg"

echo "=== 5. Установка Spotify и Prism Launcher через Flatpak ==="
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub org.prismlauncher.PrismLauncher

echo "=== 6. Установка AnyDesk ==="
cd /tmp
wget -O anydesk.deb https://download.anydesk.com/linux/anydesk_6.3.2-1_amd64.deb || wget -O anydesk.deb https://download.anydesk.com/linux/anydesk_6.2.1-1_amd64.deb
sudo apt install -y ./anydesk.deb || sudo apt --fix-broken install -y
rm -f anydesk.deb
cd ~

echo "=== 7. Установка Google Chrome ==="
cd /tmp
wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./chrome.deb
rm chrome.deb
cd ~

echo "=== 8. Установка Legcord (Discord) ==="
mkdir -p ~/Applications/Legcord
cd /tmp
LEGCORD_URL=$(curl -s https://api.github.com/repos/Legcord/Legcord/releases/latest | grep "browser_download_url.*AppImage" | cut -d '"' -f 4 | head -n 1)
if [ -n "$LEGCORD_URL" ]; then
    wget -O ~/Applications/Legcord/Legcord.AppImage "$LEGCORD_URL"
    chmod +x ~/Applications/Legcord/Legcord.AppImage
fi
cd ~

echo "=== 9. Установка MaterialGram ==="
mkdir -p ~/Applications/MaterialGram
cd /tmp
MG_URL=$(curl -s https://api.github.com/repos/kukuruzka165/MaterialGram/releases/latest | grep "browser_download_url.*tar.xz" | cut -d '"' -f 4 | head -n 1)
if [ -n "$MG_URL" ]; then
    wget -O materialgram.tar.xz "$MG_URL"
    tar -xf materialgram.tar.xz -C ~/Applications/MaterialGram --strip-components=1
    rm materialgram.tar.xz
    chmod +x ~/Applications/MaterialGram/* 2>/dev/null || true
fi
cd ~

echo "=== 10. Скачивание Voidstar (Roblox) ==="
mkdir -p ~/Applications/Voidstar
cd /tmp
VOIDSTAR_URL=$(curl -s https://api.github.com/repos/voidstar-client/voidstar/releases/latest | grep "browser_download_url.*zip" | cut -d '"' -f 4 | head -n 1)
if [ -n "$VOIDSTAR_URL" ]; then
    wget -O voidstar.zip "$VOIDSTAR_URL"
    unzip -o voidstar.zip -d ~/Applications/Voidstar/
    rm voidstar.zip
fi
cd ~

echo "=== 11. Настройка Wine и установка osu! Stable ==="
export WINEPREFIX="$HOME/.wine_osu"
export WINEARCH="win32"
winecfg /v win10
cd /tmp
wget -O osuinstall.exe https://malsync.net/osuinstall.exe || wget -O osuinstall.exe https://ppy.sh/osuinstall.exe
wine osuinstall.exe
rm -f osuinstall.exe
cd ~

echo "=== 12. Создание ярлыков для меню Rofi ==="
mkdir -p ~/.local/share/applications

cat << DESKTOP > ~/.local/share/applications/osu-stable.desktop
[Desktop Entry]
Name=osu! Stable
Exec=env WINEPREFIX="$HOME/.wine_osu" wine "C:\\users\\$USER\\AppData\\Local\\osu!\\osu!.exe"
Type=Application
Categories=Game;
Icon=wine
DESKTOP

cat << DESKTOP > ~/.local/share/applications/legcord.desktop
[Desktop Entry]
Name=Legcord
Exec=$HOME/Applications/Legcord/Legcord.AppImage
Type=Application
Categories=Network;
Icon=discord
DESKTOP

MG_EXEC=$(find ~/Applications/MaterialGram -maxdepth 1 -type f -executable | head -n 1)
if [ -n "$MG_EXEC" ]; then
cat << DESKTOP > ~/.local/share/applications/materialgram.desktop
[Desktop Entry]
Name=MaterialGram
Exec=$MG_EXEC
Type=Application
Categories=Network;InstantMessaging;
Icon=telegram
DESKTOP
fi

VOIDSTAR_EXE=$(find ~/Applications/Voidstar -maxdepth 2 -name "*.exe" | head -n 1)
if [ -n "$VOIDSTAR_EXE" ]; then
cat << DESKTOP > ~/.local/share/applications/voidstar.desktop
[Desktop Entry]
Name=Voidstar (Roblox)
Exec=wine "$VOIDSTAR_EXE"
Type=Application
Categories=Game;
Icon=wine
DESKTOP
fi

echo "=== 13. Настройка стиля Fluxbox под цвет обоев (темно-синий/ночной стиль) ==="
mkdir -p ~/.config/tint2
mkdir -p ~/.config/rofi

cat << 'TINT2' > ~/.config/tint2/tint2rc
panel_items = TSC
panel_size = 80% 48
panel_position = bottom center horizontal
panel_margin = 0 10
panel_padding = 6 6
panel_background_id = 1
wm_menu = 0
panel_layer = top

rounded = 16
border_width = 1
border_color = #b4befe 30
background_color = #11111b 80

taskbar_mode = single_desktop
taskbar_sort = none
taskbar_padding = 4 4 4
taskbar_background_id = 0
taskbar_active_background_id = 0
task_icon = 1
task_text = 0
task_centered = 1
task_maximum_size = 40 40
task_padding = 6 6
task_background_id = 0
task_active_background_id = 2
task_active_background_color = #313244 100
task_active_rounded = 12

time1_format = %H:%M
time1_font = sans-serif 11
clock_font_color = #cdd6f4 100
clock_padding = 8 0
TINT2

cat << 'ROFI' > ~/.config/rofi/config.rasi
configuration {
    modi: "drun,run";
    show-icons: true;
    font: "sans-serif 11";
}
@theme "Arc-Dark"
ROFI

if ! grep -q "rofi -show drun" ~/.fluxbox/keys 2>/dev/null; then
    echo "Mod1 space :Exec rofi -show drun" >> ~/.fluxbox/keys
fi

STARTUP_FILE="$HOME/.fluxbox/startup"
if [ -f "$STARTUP_FILE" ] && ! grep -q "tint2" "$STARTUP_FILE"; then
    sed -i '/exec fluxbox/i feh --bg-scale ~/Pictures/wallpaper.jpg &' "$STARTUP_FILE"
    sed -i '/exec fluxbox/i tint2 &' "$STARTUP_FILE"
    sed -i '/exec fluxbox/i picom --backend xrender --vsync &' "$STARTUP_FILE"
fi

echo "=== ВСЁ ГОТОВО! РАЗРЕШЕНИЕ 1280x800 ЗАФИКСИРОВАНО НАВСЕГДА, ОБОИ И СОФТ УСТАНОВЛЕНЫ! ==="
