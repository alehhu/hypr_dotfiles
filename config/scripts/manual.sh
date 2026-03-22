#!/bin/bash

# Define the manual content with clean formatting
cat << EOF
                    󱐌 QUICK ACTIONS MANUAL 󱐌
================================================================

🦇 SERVER MODE
   Disables GUI, Bluetooth, and Docker/Minikube. Enables TLP power 
   saving. Ideal for long battery life or headless work.

🚀 DESKTOP MODE
   The opposite of Server Mode. Starts the GUI, enables all radios, 
   and sets the system to Max Performance.

⚙️  BOOT PROFILES (CLI/GUI)
   Sets the default target for your NEXT system startup. Use CLI 
   if you want to boot into a terminal by default.

🌐 TRANSLATE SELECTION
   Takes whatever text you have highlighted with your mouse and 
   instantly translates it to Italian via a notification.

🔍 EXTRACT TEXT (OCR)
   Allows you to select any area on your screen (even in images) 
   and converts it to text, copying it to your clipboard.

🖌️  PICK COLOR
   Interactive eye-dropper. Click any pixel on your screen to 
   copy its HEX code to your clipboard.

📖 DEFINE WORD
   Look up English definitions for a word. It checks your 
   clipboard first, then asks for manual input.

🧪 LAB UP / DOWN
   Granular control for your Dev environment. Specifically 
   toggles Docker and Minikube services.

⚡ POWER / 📡 RADIO CONTROLS
   Quick toggles for TLP power management and Wi-Fi/Bluetooth 
   antennas.

🎨 CHANGE WALLPAPER
   Picks a random image, applies it, and regenerates your entire 
   system color scheme (Waybar, Rofi, Terminal) to match.

================================================================
          Press [Q] or [Ctrl+C] to close this manual.
EOF

# Keep the terminal open until the user wants to close it
read -n 1 -s
