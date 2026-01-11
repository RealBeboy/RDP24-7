#!/bin/bash

# --- CONFIGURATION ---
# Default Values
PORT_NOVNC=26426
VNC_PASS="password"

# Parse arguments (e.g., bash server.sh port=1234 password=secret)
for ARG in "$@"; do
    case $ARG in
        port=*)
            PORT_NOVNC="${ARG#*=}"
            ;;
        password=*)
            VNC_PASS="${ARG#*=}"
            ;;
    esac
done

INSTALL_DIR="$HOME/desktop_env"
ROOTFS="$INSTALL_DIR/rootfs"
PROOT_BIN="$INSTALL_DIR/proot"
TMP_DIR="$INSTALL_DIR/tmp"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=================================================${NC}"
echo -e "${CYAN}   🚀 Desktop: Clean Start (No Auto-Firefox)     ${NC}"
echo -e "${CYAN}   🎯 Port selected: $PORT_NOVNC                 ${NC}"
echo -e "${CYAN}   🔑 VNC Password:  $VNC_PASS                   ${NC}"
echo -e "${CYAN}=================================================${NC}"

# 1. Setup Directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$TMP_DIR"
cd "$INSTALL_DIR" || exit

# 2. Install PROOT
if [ ! -f "$PROOT_BIN" ]; then
    echo -e "${GREEN}[+] Downloading Proot...${NC}"
    curl -Lo proot "https://proot.gitlab.io/proot/bin/proot"
    chmod +x proot
fi

# 3. Download Ubuntu 20.04 Rootfs
if [ ! -d "$ROOTFS" ]; then
    echo -e "${GREEN}[+] Downloading Ubuntu 20.04 Rootfs...${NC}"
    curl -Lo rootfs.tar.gz "https://cdimage.ubuntu.com/ubuntu-base/releases/20.04/release/ubuntu-base-20.04.4-base-amd64.tar.gz"
    mkdir -p "$ROOTFS"
    echo -e "${GREEN}[+] Extracting Rootfs...${NC}"
    tar -xzf rootfs.tar.gz -C "$ROOTFS" --exclude="dev/*"
    rm rootfs.tar.gz
fi

# 4. Permissions
chmod -R 755 "$ROOTFS/bin" "$ROOTFS/usr/bin" "$ROOTFS/sbin" "$ROOTFS/usr/sbin" "$ROOTFS/etc"
echo "nameserver 8.8.8.8" > "$ROOTFS/etc/resolv.conf"

# 5. Internal Setup Script
cat << EOF > "$ROOTFS/root/init.sh"
#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root
export USER=root
export DEBIAN_FRONTEND=noninteractive

# A. Install Dependencies
if ! command -v tint2 &> /dev/null; then
    echo "📦 Installing Desktop Tools..."
    apt-get update
    apt-get install -y --no-install-recommends \
        xfwm4 \
        xfce4-terminal \
        tint2 \
        tigervnc-standalone-server \
        tigervnc-common \
        novnc \
        python3-websockify \
        python3-numpy \
        firefox \
        dbus-x11 \
        ttf-wqy-zenhei \
        libgtk-3-0 \
        adwaita-icon-theme-full
    apt-get clean
fi

# B. Set VNC Password
mkdir -p /root/.vnc
echo "$VNC_PASS" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# C. CREATE CUSTOM LAUNCHERS
mkdir -p /root/.local/share/applications/

# 1. Firefox Launcher
cat << 'DESKTOP' > /root/.local/share/applications/firefox-custom.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Comment=Browse the Web
Exec=firefox --no-sandbox
Icon=firefox
Terminal=false
StartupNotify=false
DESKTOP

# 2. Terminal Launcher
cat << 'DESKTOP' > /root/.local/share/applications/terminal-custom.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Terminal
Comment=Command Line
Exec=xfce4-terminal --disable-server
Icon=utilities-terminal
Terminal=false
StartupNotify=true
DESKTOP

# D. CONFIGURE TINT2 (Taskbar)
mkdir -p /root/.config/tint2
cat << 'TINT' > /root/.config/tint2/tint2rc
# Tint2 Config
panel_position = bottom center horizontal
panel_size = 100% 35
panel_layer = top
panel_monitor = all
wm_menu = 1

# Colors
background_color = #222222 100
border_color = #222222 100

# Items
panel_items = LTSC

# Launcher
launcher_icon_theme = Adwaita
launcher_padding = 8 0 8
launcher_icon_size = 24
launcher_item_app = /root/.local/share/applications/firefox-custom.desktop
launcher_item_app = /root/.local/share/applications/terminal-custom.desktop

# Taskbar
taskbar_mode = multi_desktop
taskbar_padding = 6 0 6
taskbar_active_background_id = 1
taskbar_name = 1
taskbar_hide_if_empty = 0
taskbar_distribute_size = 1
taskbar_background_id = 0
taskbar_line_size = 2
taskbar_line_color = #444444 100
taskbar_active_line_color = #DDDDDD 100

# Clock
time1_format = %H:%M
time1_font = Sans Bold 10
clock_font_color = #eeeeee 100
clock_padding = 8 0 8
TINT

# E. STARTUP SCRIPT
cat << 'STARTUP' > /root/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# 1. Start DBus
eval \$(dbus-launch --sh-syntax --exit-with-session)

# 2. Start Window Manager
xfwm4 --compositor=off &

# 3. Start Tint2 Taskbar
tint2 &

# 4. Open one Terminal so the screen isn't blank
xfce4-terminal --disable-server --geometry=80x24 &

tail -f /dev/null
STARTUP
chmod +x /root/.vnc/xstartup

# F. Launch Services
rm -rf /tmp/.X1-lock /tmp/.X11-unix
mkdir -p /tmp/.X11-unix

echo "🟢 Starting VNC..."
vncserver :1 -geometry 1280x720 -depth 24 -localhost no -rfbauth /root/.vnc/passwd

echo "🟢 Starting noVNC on port $PORT_NOVNC..."
websockify --web=/usr/share/novnc $PORT_NOVNC localhost:5901
EOF

chmod +x "$ROOTFS/root/init.sh"

# 6. Launch
echo -e "${GREEN}[+] Launching...${NC}"
echo -e "${CYAN}Access: http://(YOUR_IP):$PORT_NOVNC/vnc.html${NC}"
echo -e "${CYAN}Password: $VNC_PASS${NC}"

export PROOT_NO_SECCOMP=1
export PROOT_TMP_DIR="$TMP_DIR"

./proot \
    -S "$ROOTFS" \
    -b /dev -b /proc -b /sys \
    -w /root \
    /usr/bin/env -i HOME=/root TERM=xterm-256color PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash /root/init.sh
