#!/bin/bash
set -e

echo "=== 1. Очистка кэша APT ==="
sudo apt clean || true

echo "=== 2. Обновление и установка базовых утилит, Wine, Flatpak и софта ==="
sudo apt update || true
sudo apt install -y tint2 feh rofi picom curl wget git unzip obs-studio wine wine32 wine64 flatpak fastfetch cava btop fonts-noto-cjk || true

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

xrandr -s 1280x800 || true

echo "=== 4. Установка картинки на обои ==="
mkdir -p ~/Pictures
wget -O ~/Pictures/wallpaper.jpg "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?q=80&w=1920&auto=format&fit=crop" || true

echo "=== 5. Установка Spotify и Prism Launcher через Flatpak ==="
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
flatpak install -y flathub com.spotify.Client || true
flatpak install -y flathub org.prismlauncher.PrismLauncher || true

echo "=== 6. Установка AnyDesk ==="
cd /tmp
wget -O anydesk.deb https://download.anydesk.com/linux/anydesk_6.3.2-1_amd64.deb || wget -O anydesk.deb https://download.anydesk.com/linux/anydesk_6.2.1-1_amd64.deb || true
sudo apt install -y ./anydesk.deb || sudo apt --fix-broken install -y || true
rm -f anydesk.deb
cd ~

echo "=== 7. Установка Google Chrome ==="
cd /tmp
wget -O chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb || true
sudo apt install -y ./chrome.deb || true
rm -f chrome.deb
cd ~

echo "=== 8. Установка Legcord (Discord) ==="
mkdir -p ~/Applications/Legcord
cd /tmp
LEGCORD_URL=$(curl -s https://api.github.com/repos/Legcord/Legcord/releases/latest | grep "browser_download_url.*AppImage" | cut -d '"' -f 4 | head -n 1)
if [ -n "$LEGCORD_URL" ]; then
    wget -O ~/Applications/Legcord/Legcord.AppImage "$LEGCORD_URL" || true
    chmod +x ~/Applications/Legcord/Legcord.AppImage || true
fi
cd ~

echo "=== 9. Установка MaterialGram ==="
mkdir -p ~/Applications/MaterialGram
cd /tmp
MG_URL=$(curl -s https://api.github.com/repos/kukuruzka165/MaterialGram/releases/latest | grep "browser_download_url.*tar.xz" | cut -d '"' -f 4 | head -n 1)
if [ -n "$MG_URL" ]; then
    wget -O materialgram.tar.xz "$MG_URL" || true
    tar -xf materialgram.tar.xz -C ~/Applications/MaterialGram --strip-components=1 || true
    rm -f materialgram.tar.xz
    chmod +x ~/Applications/MaterialGram/* 2>/dev/null || true
fi
cd ~

echo "=== 10. Скачивание Voidstar (Roblox) ==="
mkdir -p ~/Applications/Voidstar
cd /tmp
VOIDSTAR_URL=$(curl -s https://api.github.com/repos/voidstar-client/voidstar/releases/latest | grep "browser_download_url.*zip" | cut -d '"' -f 4 | head -n 1)
if [ -n "$VOIDSTAR_URL" ]; then
    wget -O voidstar.zip "$VOIDSTAR_URL" || true
    unzip -o voidstar.zip -d ~/Applications/Voidstar/ || true
    rm -f voidstar.zip
fi
cd ~

echo "=== 11. Настройка Wine и установка osu! Stable ==="
export WINEPREFIX="$HOME/.wine_osu"
export WINEARCH="win32"
winecfg /v win10 || true
cd /tmp
wget -O osuinstall.exe https://malsync.net/osuinstall.exe || wget -O osuinstall.exe https://ppy.sh/osuinstall.exe || true
wine osuinstall.exe || true
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

echo "=== 13. Настройка стиля Fluxbox под темный ночной стиль ==="
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

echo "=== ВСЁ ГОТОВО! УСТАНОВКА УСПЕШНО ЗАВЕРШЕНА! ==="
