#!/bin/bash

# --- CONFIGURATION ---
# Default Values
PORT_RDP=3389
RDP_PASS="password"

# Parse arguments
for ARG in "$@"; do
    case $ARG in
        port=*)
            PORT_RDP="${ARG#*=}"
            ;;
        password=*)
            RDP_PASS="${ARG#*=}"
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
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}=================================================${NC}"
echo -e "${CYAN}   🚀 Desktop: RDP Edition (Hard-Stop Fix)       ${NC}"
echo -e "${CYAN}   🎯 RDP Port:     $PORT_RDP                    ${NC}"
echo -e "${CYAN}   🔑 Password:     $RDP_PASS                    ${NC}"
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

# --- A. NUCLEAR CLEANUP (Fix for Hard Stops) ---
echo "${YELLOW}🧹 Force Cleaning previous session leftovers...${NC}"

# 1. Kill any zombie processes inside the container
pkill -9 -f vnc
pkill -9 -f Xvnc
pkill -9 -f xrdp
pkill -9 -f xrdp-sesman

# 2. Delete ALL Lock Files (This fixes the 'cannot connect' issue)
# VNC Locks
rm -rf /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1
rm -rf /root/.vnc/*.pid
rm -rf /root/.vnc/*.log

# XRDP Locks
rm -rf /var/run/xrdp/*
rm -rf /var/run/xrdp.pid
rm -rf /var/run/xrdp-sesman.pid

# 3. Re-create directories with correct permissions
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix
mkdir -p /var/run/xrdp
chmod 777 /var/run/xrdp

# --- B. Install Dependencies ---
if ! command -v tint2 &> /dev/null; then
    echo "📦 Installing Desktop & RDP Tools..."
    apt-get update
    apt-get install -y --no-install-recommends \
        xfwm4 \
        xfce4-terminal \
        tint2 \
        tigervnc-standalone-server \
        tigervnc-common \
        xrdp \
        firefox \
        dbus-x11 \
        ttf-wqy-zenhei \
        libgtk-3-0 \
        adwaita-icon-theme-full \
        sudo \
        mousepad
    apt-get clean
fi

# --- C. Set Passwords ---
mkdir -p /root/.vnc
echo "$RDP_PASS" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd
echo "root:$RDP_PASS" | chpasswd

# --- D. Configure XRDP (Reset every time) ---
# We write a fresh config to ensure no corruption
mv /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak 2>/dev/null

cat << 'XRDP' > /etc/xrdp/xrdp.ini
[globals]
bitmap_cache=yes
bitmap_compression=yes
port=$PORT_RDP
crypt_level=low
channel_code=1
max_bpp=24

[xrdp1]
name=Desktop
lib=libvnc.so
username=root
password=ask
ip=127.0.0.1
port=5901
XRDP

if [ ! -f /etc/xrdp/rsakeys.ini ]; then
    xrdp-keygen xrdp auto
fi

# --- E. Desktop & Taskbar ---
mkdir -p /root/.local/share/applications/
mkdir -p /root/.config/tint2

# Tint2 Config
cat << 'TINT' > /root/.config/tint2/tint2rc
panel_position = bottom center horizontal
panel_size = 100% 35
panel_layer = top
panel_monitor = all
wm_menu = 1
background_color = #222222 100
border_color = #222222 100
panel_items = LTSC
launcher_icon_theme = Adwaita
launcher_padding = 8 0 8
launcher_icon_size = 24
launcher_item_app = /usr/share/applications/firefox.desktop
launcher_item_app = /usr/share/applications/xfce4-terminal.desktop
taskbar_mode = multi_desktop
taskbar_padding = 6 0 6
taskbar_active_background_id = 1
taskbar_name = 1
clock_font_color = #eeeeee 100
clock_padding = 8 0 8
TINT

# XStartup Script
cat << 'STARTUP' > /root/.vnc/xstartup
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
eval \$(dbus-launch --sh-syntax --exit-with-session)
xfwm4 --compositor=off &
tint2 &
xfce4-terminal --disable-server --geometry=80x24 &
while true; do
    if ! pgrep -x "firefox" > /dev/null; then
        firefox --no-sandbox --width 1280 --height 680 &
    fi
    sleep 5
done &
tail -f /dev/null
STARTUP
chmod +x /root/.vnc/xstartup

# --- F. START SERVICES ---
echo "${GREEN}🟢 Starting VNC Server (Internal)...${NC}"
# Double check locks one last time
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1

# Start VNC
vncserver :1 -geometry 1280x720 -depth 24 -localhost yes -rfbauth /root/.vnc/passwd

echo "⏳ Waiting for VNC..."
sleep 2

echo "${GREEN}🟢 Starting RDP Services...${NC}"
# Start Session Manager (Critical for RDP login to work)
/usr/sbin/xrdp-sesman &

# Start XRDP in foreground to keep the server alive
/usr/sbin/xrdp --nodaemon
EOF

chmod +x "$ROOTFS/root/init.sh"

# 6. Launch
echo -e "${GREEN}[+] Launching...${NC}"
echo -e "${CYAN}IP:       (YOUR_IP):$PORT_RDP${NC}"
echo -e "${CYAN}Username: root${NC}"
echo -e "${CYAN}Password: $RDP_PASS${NC}"

export PROOT_NO_SECCOMP=1
export PROOT_TMP_DIR="$TMP_DIR"

./proot \
    -S "$ROOTFS" \
    -b /dev -b /proc -b /sys \
    -w /root \
    /usr/bin/env -i HOME=/root TERM=xterm-256color PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /bin/bash /root/init.sh
