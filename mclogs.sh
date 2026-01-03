#!/bin/bash

# ==============================================================================
# FAKE MINECRAFT SERVER LOG GENERATOR V2 (High Realism)
# ==============================================================================

# --- Config ---
VERSION="1.20.4-R0.1-SNAPSHOT"
LEVEL="world"
PORT=25565

# --- Massive Data Arrays ---

PLAYERS=(
    "Steve" "Alex" "xX_Slayer_Xx" "CraftMaster99" "DreamStan404" 
    "TechnoNeverDies" "ItsMeMario" "NoobSaibot" "RedstoneWiz" 
    "BuilderBob" "TntLover" "ZombieHunter" "CreeperHugger"
    "SpeedRun_01" "AFK_King" "IronGolem" "DiamondHands"
    "VegetableSoup" "CatMaid" "Edgelord2000" "GenericSteve"
    "Herobrine" "Notch" "Dinnerbone" "Jeb_" "Grian" "Mumbo"
    "TommyInnit" "Philza" "WilburSoot" "Tubbo" "Ranboo"
    "PewDiePie" "JackSepticEye" "Markiplier" "DanTDM"
    "CaptainSparklez" "StampyLongHead" "PopularMMOs"
    "Direwolf20" "SethBling" "Etho" "Docm77" "BdoubleO100"
    "Keralis" "TangoTek" "ImpulseSV" "Zedaph" "Cleo"
    "FalseSymmetry" "GeminiTay" "Pearl" "Scar" "Cubfan135"
)

# Realistic chat messages including slang, typos, and common server tropes
CHATS=(
    "anyone got spare iron?" "where is the stronghold?" "lag" "LAGGGG"
    "can someone sleep?" "SLEEP PLS" "stop stealing my crops" "tp me pls"
    "selling mending book for 20 diamonds" "watch out for the creeper at spawn"
    "who wants to raid the ocean monument?" "brb dinner" "lol" "gg" "ez" "L"
    "admin can i have op?" "server dead?" "inviting to faction, msg me"
    "how do i claim land?" "is pvp on?" "why is my ping so high"
    "anyone wanna team?" "selling stacks of obby" "wtb elytra"
    "coord leak: 2000 64 -500" "come grief this base" "report xX_Slayer_Xx hacking"
    "killaura reported" "fly hacks detected" "my dad owns microsoft he will ban u"
    "f" "rip" "bruh" "cringe" "based" "pog" "sheesh"
    "can i have free items?" "drop party at spawn!!!" "who has slimeballs?"
    "buying netherite scrap 5k each" "tpa accepted" "warping to shop"
    "clearlag took my sword wtf" "admin abuse" "reset the end pls"
)

DEATHS=(
    "was shot by Skeleton" "was blown up by Creeper" "fell from a high place"
    "burned to death" "tried to swim in lava" "drowned" "was slain by Zombie"
    "hit the ground too hard" "experienced kinetic energy" "blew up"
    "was squashed by a falling anvil" "was pricked to death" "walked into a cactus whilst trying to escape Creeper"
    "starved to death" "suffocated in a wall" "withered away"
    "was killed by magic" "was impaled by Trident"
)

COMMANDS=(
    "gamemode creative" "time set day" "weather clear" "tp @a 0 100 0" 
    "give @p diamond_sword" "op Alex" "ban Herobrine" "kick NoobSaibot spam"
    "whitelist add Friend" "stop" "restart" "reload confirm"
    "worldborder set 10000" "kill @e[type=item]" "difficulty hard"
    "effect give @a speed 9999 255" "say SERVER RESTART IN 5 MINS"
)

WARNINGS=(
    "Can't keep up! Is the server overloaded? Running 2005ms or 40 ticks behind"
    "Can't keep up! Is the server overloaded? Running 5032ms or 100 ticks behind"
    "Mismatch in destroy block pos: 120, 64, -200"
    "Player moved too quickly! (-1200.5, 64.0, 500.2)"
    "Player moved wrongly!"
    "Fetching packet 0x2A threw exception"
    "Ambiguity between arguments [teleport, tp] and alias [tp]"
    "Loaded class com.destroystokyo.paper.event.entity.PreCreatureSpawnEvent"
)

PLUGINS=(
    "[Essentials] Teleporting..."
    "[WorldEdit] restored 5032 blocks."
    "[CoreProtect] &ePurging old data..."
    "[Vault] Economy linked: Essentials Economy"
    "[LuckPerms] Loading configuration..."
    "[Multiverse-Core] Loading World & Settings - 'world_nether'"
    "[ViaVersion] Loading 1.20.4 mapping..."
)

JAVA_ERRORS=(
    "java.lang.NullPointerException"
    "java.net.SocketException: Connection reset"
    "java.io.IOException: The existing connection was forcibly closed by the remote host"
    "java.util.ConcurrentModificationException"
    "org.bukkit.plugin.InvalidPluginException"
)

# --- Helpers ---

get_time() { date +"%H:%M:%S"; }

# Different thread names for realism
log_info() { echo "[$1] [Server thread/INFO]: $2"; }
log_warn() { echo "[$1] [Server thread/WARN]: $2"; }
log_error() { echo "[$1] [Server thread/ERROR]: $2"; }
log_chat() { echo "[$1] [Async Chat Thread - #0/INFO]: <$2> $3"; }
log_auth() { echo "[$1] [User Authenticator #$((RANDOM % 5 + 1))/INFO]: $2"; }
log_netty() { echo "[$1] [Netty Epoll Server IO #$((RANDOM % 3))/INFO]: $2"; }

rand_delay() {
    # Most logs are fast, some pause
    if (( $RANDOM % 20 == 0 )); then sleep 0.5; else sleep 0.05; fi
}

# --- Startup Simulation ---
echo "Starting fake Minecraft server log stream..."
sleep 1

T=$(get_time)
log_info "$T" "Starting minecraft server version $VERSION"
log_info "$T" "Loading properties"
log_info "$T" "Default game type: SURVIVAL"
log_info "$T" "Generating keypair"
log_info "$T" "Starting Minecraft server on *:$PORT"
log_info "$T" "Using default channel type"

# Plugin Load Simulation
for plugin in "${PLUGINS[@]}"; do
    T=$(get_time); log_info "$T" "$plugin"; sleep 0.1
done

# Spawn Area
for i in {0..100..25}; do
    T=$(get_time); log_info "$T" "Preparing spawn area: $i%"; sleep 0.2
done
log_info "$(get_time)" "Done ($(( $RANDOM % 10 )).$(( $RANDOM % 999 ))s)! For help, type \"help\""

# --- Main Loop ---
while true; do
    T=$(get_time)
    RAND=$(( $RANDOM % 1000 ))
    PLAYER=${PLAYERS[$RANDOM % ${#PLAYERS[@]}]}
    
    if (( RAND < 50 )); then # Join (5%)
        UUID=$(cat /proc/sys/kernel/random/uuid)
        log_auth "$T" "UUID of player $PLAYER is $UUID"
        log_netty "$T" "Connection from /192.168.1.$((RANDOM%255)):$((RANDOM%60000))"
        log_info "$T" "$PLAYER[/192.168.1.$((RANDOM%255)):$((RANDOM%60000))] logged in with entity id $((RANDOM%10000)) at ([world]$((RANDOM%2000)).5, 64.0, $((RANDOM%2000)).5)"
        log_info "$T" "$PLAYER joined the game"
        
    elif (( RAND < 90 )); then # Leave (4%)
        log_info "$T" "$PLAYER left the game"
        log_info "$T" "$PLAYER lost connection: Disconnected"
        
    elif (( RAND < 350 )); then # Chat (26%)
        MSG=${CHATS[$RANDOM % ${#CHATS[@]}]}
        # Add random rank prefixes occasionally
        if (( RANDOM % 3 == 0 )); then PREFIX="[Admin]"; elif (( RANDOM % 3 == 0 )); then PREFIX="[VIP]"; else PREFIX=""; fi
        # 10% chance the message is shouted (caps)
        if (( RANDOM % 10 == 0 )); then MSG=${MSG^^}; fi
        log_chat "$T" "${PREFIX}${PLAYER}" "$MSG"
        
    elif (( RAND < 400 )); then # Death (5%)
        DEATH_MSG=${DEATHS[$RANDOM % ${#DEATHS[@]}]}
        log_info "$T" "$PLAYER $DEATH_MSG"
        
    elif (( RAND < 430 )); then # Command (3%)
        CMD=${COMMANDS[$RANDOM % ${#COMMANDS[@]}]}
        log_info "$T" "$PLAYER issued server command: /$CMD"
        
    elif (( RAND < 450 )); then # Warn/Lag (2%)
        WARN=${WARNINGS[$RANDOM % ${#WARNINGS[@]}]}
        log_warn "$T" "$WARN"
        
    elif (( RAND < 460 )); then # Java Error (1%)
        ERR=${JAVA_ERRORS[$RANDOM % ${#JAVA_ERRORS[@]}]}
        log_error "$T" "Could not pass event PlayerMoveEvent to Essentials v2.19.0"
        echo "$ERR"
        echo "        at com.earth2me.essentials.EssentialsPlayerListener.onPlayerMove(EssentialsPlayerListener.java:120)"
        echo "        at com.destroystokyo.paper.event.executor.asm.generated.GeneratedEventExecutor450.execute(Unknown Source)"
        echo "        at org.bukkit.plugin.EventExecutor.lambda\$create\$1(EventExecutor.java:69)"
        
    elif (( RAND < 470 )); then # Auto Save (1%)
        log_info "$T" "Saving the game (Automatic)"
        sleep 0.2
        T=$(get_time)
        log_info "$T" "Saved the game"
        
    elif (( RAND < 475 )); then # Advancement (0.5%)
        log_info "$T" "$PLAYER has made the advancement [We Need to Go Deeper]"
        log_chat "$T" "$PLAYER" "finally!"
        
    fi
    
    rand_delay
done
