#!/bin/bash

# ==============================================================================
# FAKE MINECRAFT SERVER LOG GENERATOReasdfasdfasdf
# ==============================================================================
# This script generates an infinite stream of realistic Minecraft server logs.
# It simulates startup, player activity, chat, errors, and server lag.
# ==============================================================================

# --- Configuration ---
SERVER_VERSION="1.20.4"
LEVEL_NAME="world"
MAX_PLAYERS=20
PORT=25565

# --- Data Arrays (The "Content") ---

PLAYERS=(
    "Steve" "Alex" "Herobrine" "Notch" "Dream" "Technoblade" 
    "xX_Gamer_Xx" "CraftMaster99" "NoobSlayer" "RedstoneEng" 
    "BuilderBob" "TntLover" "ZombieHunter" "CreeperHugger"
    "SpeedRunner_01" "AFK_King" "IronGolemMiner" "DiamondHands"
)

CHATS=(
    "anyone got spare iron?"
    "where is the stronghold?"
    "lag"
    "can someone sleep?"
    "stop stealing my crops"
    "tp me pls"
    "selling mending book for 20 diamonds"
    "watch out for the creeper at spawn"
    "who wants to raid the ocean monument?"
    "brb dinner"
    "lol"
    "gg"
    "F"
)

DEATHS=(
    "was shot by Skeleton"
    "was blown up by Creeper"
    "fell from a high place"
    "burned to death"
    "tried to swim in lava"
    "drowned"
    "was slain by Zombie"
    "hit the ground too hard"
    "experienced kinetic energy"
)

ADVANCEMENTS=(
    "Stone Age" "Getting an Upgrade" "Acquire Hardware" "Suit Up"
    "Hot Stuff" "Isn't It Iron Pick" "Not Today, Thank You" "Ice Bucket Challenge"
    "Diamonds!" "We Need to Go Deeper" "Cover Me with Debris"
    "Enchanter" "Eye Spy" "The End?"
)

COMMANDS=(
    "gamemode creative" "time set day" "weather clear" "tp @a 0 100 0" 
    "give @p diamond_sword" "op Alex" "ban Herobrine"
)

# --- Helper Functions ---

get_time() {
    date +"%H:%M:%S"
}

log_info() {
    echo "[$1] [Server thread/INFO]: $2"
}

log_warn() {
    echo "[$1] [Server thread/WARN]: $2"
}

log_chat() {
    # Chat often runs on an Async thread
    echo "[$1] [Async Chat Thread - #0/INFO]: <$2> $3"
}

rand_delay() {
    # Sleep between 0.1 and 1.5 seconds to simulate real processing time
    # Occasional burst speed
    if (( $RANDOM % 10 == 0 )); then
        sleep 0.05
    else
        sleep $(awk -v min=0.1 -v max=1.5 'BEGIN{srand(); print min+rand()*(max-min)}')
    fi
}

# --- Simulation Phases ---

simulate_startup() {
    local T=$(get_time)
    echo "[$T] [Server thread/INFO]: Starting minecraft server version $SERVER_VERSION"
    sleep 0.2
    T=$(get_time)
    echo "[$T] [Server thread/INFO]: Loading properties"
    sleep 0.1
    T=$(get_time)
    echo "[$T] [Server thread/INFO]: Default game type: SURVIVAL"
    T=$(get_time)
    echo "[$T] [Server thread/INFO]: Generating keypair"
    sleep 0.5
    T=$(get_time)
    echo "[$T] [Server thread/INFO]: Starting Minecraft server on *:$PORT"
    sleep 0.2
    T=$(get_time)
    echo "[$T] [Server thread/INFO]: Using default channel type"
    sleep 0.5
    
    # Simulate spawn area preparation
    for i in {0..100..20}; do
        T=$(get_time)
        echo "[$T] [Server thread/INFO]: Preparing spawn area: $i%"
        sleep 0.3
    done
    
    T=$(get_time)
    echo "[$T] [Server thread/INFO]: Preparing start region for dimension minecraft:overworld"
    sleep 1
    T=$(get_time)
    echo "[$T] [Server thread/INFO]: Time elapsed: $(( $RANDOM % 5000 + 2000 )) ms"
    T=$(get_time)
    echo "[$T] [Server thread/INFO]: Done ($(( $RANDOM % 10 )).$(( $RANDOM % 999 ))s)! For help, type \"help\""
}

# --- Main Logic ---

# 1. Run Startup
simulate_startup

# 2. Infinite Gameplay Loop
while true; do
    T=$(get_time)
    RAND=$(( $RANDOM % 100 ))
    PLAYER=${PLAYERS[$RANDOM % ${#PLAYERS[@]}]}
    
    # Weight probabilities for different events
    if (( RAND < 5 )); then
        # 5% chance: Player Join
        log_info "$T" "$PLAYER joined the game"
        
    elif (( RAND < 8 )); then
        # 3% chance: Player Leave
        log_info "$T" "$PLAYER left the game"
        
    elif (( RAND < 10 )); then
        # 2% chance: Advancement
        ADV=${ADVANCEMENTS[$RANDOM % ${#ADVANCEMENTS[@]}]}
        log_info "$T" "$PLAYER has made the advancement [$ADV]"
        
    elif (( RAND < 15 )); then
        # 5% chance: Death
        DEATH_MSG=${DEATHS[$RANDOM % ${#DEATHS[@]}]}
        log_info "$T" "$PLAYER $DEATH_MSG"
        
    elif (( RAND < 40 )); then
        # 25% chance: Chat Message
        MSG=${CHATS[$RANDOM % ${#CHATS[@]}]}
        log_chat "$T" "$PLAYER" "$MSG"
        
    elif (( RAND < 45 )); then
        # 5% chance: Command Usage (logged)
        CMD=${COMMANDS[$RANDOM % ${#COMMANDS[@]}]}
        log_info "$T" "$PLAYER issued server command: /$CMD"
        
    elif (( RAND < 48 )); then
        # 3% chance: Warning / Lag
        TICKS=$(( $RANDOM % 100 + 20 ))
        MS=$(( TICKS * 50 ))
        log_warn "$T" "Can't keep up! Is the server overloaded? Running ${MS}ms or $TICKS ticks behind"
        
    elif (( RAND < 50 )); then
        # 2% chance: Authentication/UUID stuff
        UUID=$(cat /proc/sys/kernel/random/uuid)
        log_info "$T" "UUID of player $PLAYER is $UUID"
        
    elif (( RAND < 52 )); then
        # 2% chance: Auto-save
        log_info "$T" "Saving the game (Automatic)"
        sleep 0.5
        T=$(get_time)
        log_info "$T" "Saved the game"
    fi
    
    # Add realistic delay between logs
    rand_delay
done
