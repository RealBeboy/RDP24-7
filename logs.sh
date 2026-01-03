#!/bin/bash
# -----------------------------------------------------------------------------
# MINECRAFT LOG GENERATOR - PRO EDITION
# Generates high-fidelity, chaotic, and realistic Minecraft server logs.
# Features:
#   - Authentic Java Stack Traces (NPEs, Watchdogs, Timeout exceptions)
#   - Plugin Startup Sequences (Essentials, WorldEdit, Vault)
#   - Async Chat/Command Threading simulation
#   - RCON/Console Interactions
#   - Weighted Random Event Distribution
# -----------------------------------------------------------------------------

LOG_LIMIT=${1:-2000}  # Default to 2000 lines. Pass 0 for infinite.
CURRENT_LINE=0
START_TIME=$(date +%s)
SESSION_ID=$(uuidgen | cut -c-8)

# --- CONFIGURATION & DATA POOLS ---

PLAYERS=(
    "Technoblade" "Dream" "Grian" "MumboJumbo" "Steve" "Alex" "xQc" "Philza"
    "TommyInnit" "WilburSoot" "Ranboo" "Tubbo" "GeorgeNotFound" "Sapnap"
    "BadBoyHalo" "Skeppy" "CaptainSparklez" "AntVenom" "falsesymmetry" "GeminiTay"
    "Etho" "BdoubleO100" "GoodTimeWithScar" "PearlescentMoon" "SmallishBeans"
    "ldshadowlady" "fruitberries" "Illumina" "Purpled" "Quig"
)

# Realistic IP addresses (Sanitized)
IPS=(
    "192.168.1.45" "10.0.0.52" "172.16.254.1" "84.12.34.112" "23.45.67.89"
    "123.45.67.89" "98.76.54.32" "45.32.11.22" "67.89.12.34" "12.34.56.78"
)

CHATS=(
    "anyone got food?" "lag" "can someone sleep?" "where is my base coords?"
    "bruh" "Selling mending books for 10 diamonds" "tp me pls"
    "creeper just blew up my chest monster" "stop spamming" "admin abuse"
    "F" "gg" "who wants to trade?" "why is the server tps so low?"
    "nether hub is broken" "coords?" "bet" "based" "cringe" "ez"
    "L" "ratio" "stfu" "my dog died :(" "wait, what?" "server restart when?"
)

COMMANDS=(
    "/spawn" "/home" "/tpa Dream" "/tpahere TommyInnit" "/gamemode creative"
    "/op Steve" "/ban Alex Hacking" "/kick Philza AFK" "/time set day"
    "/weather clear" "/region claim base" "/wand" "//set air" "//undo"
    "/msg Dream hello" "/r why?" "/list" "/help"
)

WARNS=(
    "Can't keep up! Is the server overloaded? Running 2005ms or 40 ticks behind"
    "Can't keep up! Is the server overloaded? Running 5082ms or 101 ticks behind"
    "Mismatch in destroy block pos: BlockPos{x=120, y=64, z=-200}"
    "Moved too quickly! 10.4532, 0.0, -2.312"
    "Ambiguity between arguments [teleport, destination] and [teleport, targets] with inputs: [Player]"
    "handleDisconnection() called twice"
    "Fetching packet for removed entity EntityChicken['Chicken'/145, l='ServerLevel', x=100.5, y=64.0, z=-100.5]"
    "Unable to play empty soundEvent: minecraft:entity.generic.explode"
    "Ignoring unknown attribute 'minecraft:generic.attack_knockback'"
)

# Java Stack Trace Elements for realistic crashes
STACK_TRACES=(
    "at net.minecraft.server.level.ServerLevel.tick(ServerLevel.java:688)"
    "at net.minecraft.server.MinecraftServer.tickChildren(MinecraftServer.java:1602)"
    "at net.minecraft.server.dedicated.DedicatedServer.tickChildren(DedicatedServer.java:483)"
    "at net.minecraft.server.MinecraftServer.tickServer(MinecraftServer.java:1466)"
    "at net.minecraft.server.MinecraftServer.runServer(MinecraftServer.java:1210)"
    "at net.minecraft.server.MinecraftServer.lambda$spin$0(MinecraftServer.java:320)"
    "at java.base/java.lang.Thread.run(Thread.java:1589)"
    "at com.earth2me.essentials.Essentials.onCommand(Essentials.java:452) ~[Essentials-2.20.1.jar:?]"
    "at org.bukkit.command.PluginCommand.execute(PluginCommand.java:45) ~[paper-api-1.20.4-R0.1-SNAPSHOT.jar:?]"
)

EXCEPTIONS=(
    "java.lang.NullPointerException: Cannot invoke \"net.minecraft.world.entity.Entity.getUUID()\" because \"entity\" is null"
    "java.util.ConcurrentModificationException"
    "java.io.IOException: Connection reset by peer"
    "java.net.SocketTimeoutException: Read timed out"
    "org.bukkit.event.EventException: null"
)

# --- UTILITY FUNCTIONS ---

get_time() {
    date "+%H:%M:%S"
}

get_thread() {
    # Randomly select a thread name to simulate async operations
    local threads=("Server thread" "Server thread" "Server thread" "User Authenticator #1" "Async Chat Thread - #1" "Worker-Main-2")
    echo "${threads[$RANDOM % ${#threads[@]}]}"
}

log_line() {
    local level=$1
    local msg=$2
    local thread=$(get_thread)
    
    # "Server thread" is the most common, force it for standard INFO
    if [[ "$level" == "INFO" && $((RANDOM % 10)) -gt 2 ]]; then
        thread="Server thread"
    fi

    echo "[$(get_time)] [$thread/$level]: $msg"
    ((CURRENT_LINE++))
}

# --- EVENT GENERATORS ---

# Generates a realistic 5-15 line Java stack trace
gen_stack_trace() {
    local exception=${EXCEPTIONS[$RANDOM % ${#EXCEPTIONS[@]}]}
    log_line "ERROR" "Could not pass event PlayerInteractEvent to Essentials v2.20.1"
    log_line "ERROR" "$exception"
    
    local depth=$(( (RANDOM % 10) + 5 ))
    for ((i=0; i<depth; i++)); do
        local trace=${STACK_TRACES[$RANDOM % ${#STACK_TRACES[@]}]}
        echo "        $trace"
    done
    echo "        ... 15 more"
    ((CURRENT_LINE+=depth+2))
}

# Simulates a plugin loading sequence (multi-line)
gen_plugin_load() {
    local plugins=("Essentials" "WorldEdit" "Vault" "LuckPerms" "CoreProtect")
    local plugin=${plugins[$RANDOM % ${#plugins[@]}]}
    
    log_line "INFO" "[$plugin] Enabling $plugin v$(($RANDOM % 5)).$(($RANDOM % 20)).$(($RANDOM % 10))"
    log_line "INFO" "[$plugin] Loading configuration..."
    
    if [ "$plugin" == "Essentials" ]; then
        log_line "INFO" "[$plugin] Loaded 1532 items from items.json."
        log_line "INFO" "[$plugin] Using locale en_US"
        log_line "INFO" "[$plugin] Payment method found (Vault - Economy)"
    elif [ "$plugin" == "WorldEdit" ]; then
        log_line "INFO" "WEPIF: Using the Bukkit Permissions API."
        log_line "INFO" "[$plugin] Registered 145 commands."
    elif [ "$plugin" == "LuckPerms" ]; then
        log_line "INFO" "[$plugin] Loading storage provider... [H2]"
        log_line "INFO" "[$plugin] Performing initial data load..."
        log_line "INFO" "[$plugin] Successfully registered Vault permission & chat hook."
    fi
    log_line "INFO" "[$plugin] Done."
}

# Simulates RCON or Console command interaction
gen_rcon_log() {
    local ip=${IPS[$RANDOM % ${#IPS[@]}]}
    log_line "INFO" "RCON Connection from /$ip"
    log_line "INFO" "[Rcon] Received command: save-all"
    log_line "INFO" "Saving the game..."
    log_line "INFO" "Saved the game"
}

# Simulates Player Join/Leave with Authenticator
gen_join_leave() {
    local player=${PLAYERS[$RANDOM % ${#PLAYERS[@]}]}
    local ip=${IPS[$RANDOM % ${#IPS[@]}]}
    local uuid=$(uuidgen)
    local entity_id=$((RANDOM % 5000 + 100))

    if (( RANDOM % 2 == 0 )); then
        # JOIN SEQUENCE
        echo "[$(get_time)] [User Authenticator #1/INFO]: UUID of player $player is $uuid"
        log_line "INFO" "$player[/$ip] logged in with entity id $entity_id at ([world]$(($RANDOM % 2000)), 64.0, $(($RANDOM % 2000)))"
        log_line "INFO" "$player joined the game"
    else
        # LEAVE SEQUENCE
        log_line "INFO" "$player left the game"
        log_line "INFO" "$player lost connection: Disconnected"
    fi
}

gen_chat_command() {
    local player=${PLAYERS[$RANDOM % ${#PLAYERS[@]}]}
    if (( RANDOM % 3 == 0 )); then
        # COMMAND
        local cmd=${COMMANDS[$RANDOM % ${#COMMANDS[@]}]}
        log_line "INFO" "$player issued server command: $cmd"
        if [[ "$cmd" == "//set"* ]]; then
            log_line "INFO" "[WorldEdit] $player set $(($RANDOM % 5000)) blocks."
        fi
    else
        # CHAT
        local msg=${CHATS[$RANDOM % ${#CHATS[@]}]}
        echo "[$(get_time)] [Async Chat Thread - #1/INFO]: <$player> $msg"
        ((CURRENT_LINE++))
    fi
}

# --- MAIN EXECUTION LOOP ---

# Start with a full server startup simulation
log_line "INFO" "Starting minecraft server version 1.20.4"
log_line "INFO" "Loading properties"
log_line "INFO" "Default game type: SURVIVAL"
log_line "INFO" "Generating keypair"
log_line "INFO" "Starting Minecraft server on *:25565"
gen_plugin_load
gen_plugin_load
log_line "INFO" "Preparing level \"world\""
log_line "INFO" "Done ($(($RANDOM % 10)).$(($RANDOM % 99))s)! For help, type \"help\""

# Infinite Loop Generator
while [ "$LOG_LIMIT" -eq 0 ] || [ "$CURRENT_LINE" -lt "$LOG_LIMIT" ]; do
    
    # Advanced Weighted Randomness
    RAND=$(($RANDOM % 100))

    if [ $RAND -lt 40 ]; then
        # 40% - Chat or Command
        gen_chat_command
    elif [ $RAND -lt 60 ]; then
        # 20% - Join/Leave
        gen_join_leave
    elif [ $RAND -lt 70 ]; then
        # 10% - Warnings
        msg=${WARNS[$RANDOM % ${#WARNS[@]}]}
        log_line "WARN" "$msg"
    elif [ $RAND -lt 75 ]; then
        # 5% - RCON/Save Event
        gen_rcon_log
    elif [ $RAND -lt 80 ]; then
        # 5% - Plugin Load (Simulate reload/late load)
        gen_plugin_load
    elif [ $RAND -lt 95 ]; then
        # 15% - System Noise (Advancements, random blocks)
        player=${PLAYERS[$RANDOM % ${#PLAYERS[@]}]}
        case $((RANDOM % 3)) in
            0) log_line "INFO" "$player has made the advancement [Diamonds!]" ;;
            1) log_line "INFO" "Villager EntityVillager['Villager'/324, l='ServerLevel', x=-10.5, y=64.0, z=12.5] died, message: 'Villager was slain by Zombie'" ;;
            2) log_line "INFO" "UUID of player $player is $(uuidgen)" ;;
        esac
    else
        # 5% - CRITICAL ERROR / STACK TRACE
        gen_stack_trace
    fi

    # sleep 0.05 # Uncomment for realtime simulation
done
