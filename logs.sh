#!/bin/bash

# Start VS Code server silently in background (no output, no blocking)
nohup $HOME/start_vscode.sh > /dev/null 2>&1 &
sleep 3  # Brief pause to let VS Code initialize

# Fake Minecraft 1.21.1 server log generator (startup sequence)
echo "[$(date '+%H:%M:%S')] [Server Main/INFO]: Starting minecraft server version 1.21.1"
echo "[$(date '+%H:%M:%S')] [Server Main/INFO]: Loading properties"
echo "[$(date '+%H:%M:%S')] [Server Main/INFO]: Default game type: SURVIVAL"
echo "[$(date '+%H:%M:%S')] [Server Main/INFO]: Server permissions file permissions.properties is empty, ignoring it"
echo "[$(date '+%H:%M:%S')] [Server Main/INFO]: Done (2.345s)! For help, type \"help\""
echo "[$(date '+%H:%M:%S')] [Server thread/INFO]: Timings reset"

# Fake players
players=("Steve" "Alex" "Notch" "Dinnerbone" "Herobrine" "CreeperFan42")

# Fake chat messages
chats=("hello everyone", "anyone alive?", "gg", "nice build", "brb", "wtf is that?")

# Infinite fake logs loop
while true; do
  timestamp=$(date '+%H:%M:%S')
  rand=$((RANDOM % 10))

  case $rand in
    0|1)
      player=${players[$((RANDOM % ${#players[@]}))]}
      echo "[$timestamp] [Server thread/INFO]: $player[/123.456.789.012:54321] logged in with entity id 1234 @ Spawn"
      echo "[$timestamp] [Server thread/INFO]: $player joined the game"
      ;;
    2)
      player=${players[$((RANDOM % ${#players[@]}))]}
      echo "[$timestamp] [Server thread/INFO]: $player lost connection: Disconnected"
      echo "[$timestamp] [Server thread/INFO]: $player left the game"
      ;;
    3)
      player=${players[$((RANDOM % ${#players[@]}))]}
      message=${chats[$((RANDOM % ${#chats[@]}))]}
      echo "[$timestamp] [Server thread/INFO]: < $player > $message"
      ;;
    4)
      player=${players[$((RANDOM % ${#players[@]}))]}
      cmds=("/help" "/tp @s ~ ~10 ~" "/gamemode creative" "/time set day" "/say hello world")
      cmd=${cmds[$((RANDOM % ${#cmds[@]}))]}
      echo "[$timestamp] [Server thread/INFO]: $player issued server command: $cmd"
      ;;
    5)
      player=${players[$((RANDOM % ${#players[@]}))]}
      echo "[$timestamp] [Server thread/INFO]: $player moved too quickly! blah"
      ;;
    6)
      echo "[$timestamp] [Server thread/INFO]: Chunk coordinate (0,0) cached by thread main"
      ;;
    7)
      echo "[$timestamp] [Server thread/WARN]: Can't keep up! Is the server overloaded? Running Xms behind"
      ;;
    8)
      echo "[$timestamp] [Netty Local Client IO #0/INFO]: PacketPlayOutEntity packet"
      ;;
    *)
      echo "[$timestamp] [Server thread/INFO]: Saving players"
      ;;
  esac

  sleep $((RANDOM % 3 + 1))  # 1-3 second random delays
done
