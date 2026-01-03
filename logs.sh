#!/bin/bash
# REALISTIC MINECRAFT LOG GENERATOR (With Pacing)

# --- CONFIGURATION ---
# Adjust these to make it faster or slower
MIN_DELAY=0.2    # Minimum seconds between lines
MAX_DELAY=1.5    # Maximum seconds between lines
BURST_CHANCE=10  # % chance to print a burst of lines (lag/crash)

PLAYERS=("Technoblade" "Dream" "Steve" "Alex" "TommyInnit" "Tubbo" "Philza" "Grian" "MumboJumbo")
CHATS=("lag" "coords?" "F" "gg" "bruh" "admin help" "anyone has food?" "start the event" "L" "server dying?")
WARNS=("Can't keep up! Is the server overloaded?" "Moved too quickly!" "UUID of player is already defined")

get_time() { date "+%H:%M:%S"; }

# Function to sleep randomly to simulate human/server timing
realistic_pause() {
    # Bash hack to get a float between MIN_DELAY and MAX_DELAY
    # This generates a random delay, e.g., 0.4s, 1.2s, 0.8s
    local delay=$(awk -v min=$MIN_DELAY -v max=$MAX_DELAY 'BEGIN{srand(); print min+rand()*(max-min)}')
    sleep $delay
}

log_msg() {
    echo "[$(get_time)] [Server thread/INFO]: $1"
}

log_chat() {
    local p=${PLAYERS[$RANDOM % ${#PLAYERS[@]}]}
    local m=${CHATS[$RANDOM % ${#CHATS[@]}]}
    echo "[$(get_time)] [Async Chat Thread - #1/INFO]: <$p> $m"
}

# STARTUP SEQUENCE (Fast burst)
echo "Starting Minecraft server..."
sleep 1
log_msg "Loading properties"
log_msg "Default game type: SURVIVAL"
log_msg "Starting Minecraft server on *:25565"
sleep 2

# INFINITE LOOP
while true; do
    RAND=$(($RANDOM % 100))

    # 1. Normal Chat/Info (Slow, readable speed)
    if [ $RAND -lt 60 ]; then
        log_chat
        realistic_pause

    # 2. Player Join/Leave (Medium pause)
    elif [ $RAND -lt 80 ]; then
        p=${PLAYERS[$RANDOM % ${#PLAYERS[@]}]}
        if (( RANDOM % 2 == 0 )); then
            log_msg "$p joined the game"
        else
            log_msg "$p left the game"
        fi
        sleep 1

    # 3. BURST/CRASH EVENT (Fast! No sleep between lines)
    elif [ $RAND -lt 90 ]; then
        echo "[$(get_time)] [Server thread/WARN]: Can't keep up! Is the server overloaded? Running 2005ms or 40 ticks behind"
        # Print a quick burst of errors without pausing
        for i in {1..5}; do
             echo "        at net.minecraft.server.MinecraftServer.tick(MinecraftServer.java:1200)"
        done
        # Pause after the crash to "recover"
        sleep 3

    # 4. Quiet Moment (Server is thinking)
    else
        # Do nothing for 2-4 seconds (silence)
        sleep $(($RANDOM % 3 + 2))
    fi
done
