#!/bin/bash

#==============================================================================
# My Ultimate macOS Setup Script (v5 - Final)
#
# This script automates the setup of a new Mac. Below is a summary of
# all the actions it will perform.
#==============================================================================
#
# --- SCRIPT SUMMARY ---
#
# 1. Applications Installed:
#    - CLI Tools: node@18, caddy, supabase, direnv, gnu-getopt, postgresql, git
#    - GUI Apps: iTerm2, Cursor, Spotify, Logi Options+, Docker Desktop,
#                SmoothScroll, Rectangle, Shottr, AltTab
#
# 2. System Settings Applied:
#    - Reduces system-wide animations for a faster, snappier UI.
#    - Configures multiple displays to use a single, unified "Space."
#
# 3. Keybindings & Remaps:
#    - Swaps the Left Command and Left Control keys system-wide.
#    - Customizes text editing keybindings for word/line navigation.
#
# 4. App-Specific Configurations:
#    - AltTab: Configured to show windows on the current active space only.
#    - Shottr: Hotkey for area screenshots is set to Alt+1.
#    - iTerm2: Creates a new profile "Custom Profile" with keybindings:
#        - Command+C: Exit/Interrupt process (sends Ctrl+C signal).
#        - Shift+Command+C: Copy selected text.
#
#==============================================================================

# --- Helper Functions ---
print_header() {
  echo "\n\033[1;34m$1\033[0m"
}

# Exit script on any error
set -e

print_header "🚀 Starting Ultimate Mac Customization..."
echo "Please review the summary above. The script will proceed in 5 seconds..."
sleep 5

# --- 1. Install Homebrew ---
print_header "🍺 Checking and Installing Homebrew..."
if command -v brew &>/dev/null; then echo "Homebrew is already installed. Updating..."; brew update; else echo "Homebrew not found. Installing..."; /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; eval "$(/opt/homebrew/bin/brew shellenv)"; fi
echo "✓ Homebrew setup complete."


# --- 2. Install Applications and Tools via Homebrew ---
print_header "📦 Installing Applications and CLI Tools..."
brew tap supabase/tap
FORMULAS=("node@18" "caddy" "supabase" "direnv" "gnu-getopt" "postgresql@16" "git")
CASKS=("iterm2" "cursor" "spotify" "logi-options-plus" "docker" "smoothscroll" "rectangle" "shottr" "alt-tab")
echo "Installing CLI tools..."; for formula in "${FORMULAS[@]}"; do if brew list "$formula" &>/dev/null; then echo "$formula is already installed. Skipping."; else brew install "$formula"; fi; done
echo "Installing GUI applications..."; for cask in "${CASKS[@]}"; do if brew list --cask "$cask" &>/dev/null; then echo "$cask is already installed. Skipping."; else brew install --cask "$cask"; fi; done
echo "✓ Application installation complete."


# --- 3. Apply Custom macOS Settings ---
print_header "⚙️ Applying Custom macOS System Settings..."
defaults write com.apple.universalaccess reduceMotion -bool true
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.spaces spans-displays -bool true
echo "✓ System settings applied."


# --- 4. Configure Specific Applications ---
print_header "🔧 Configuring Specific Application Settings..."
# AltTab
for i in {1..5}; do if defaults read com.lwouis.alt-tab-macos &>/dev/null; then defaults write com.lwouis.alt-tab-macos onlyShowWindowsOnCurrentSpace -bool true; echo "✓ AltTab configured."; break; else echo "Waiting for AltTab settings... ($i/5)"; sleep 2; fi; done
# Shottr
for i in {1..5}; do if defaults read com.shottr.shottr &>/dev/null; then defaults write com.shottr.shottr "hotkey-screenshot-area" -dict "keyCode" -int 18 "modifiers" -int 524288; echo "✓ Shottr configured."; break; else echo "Waiting for Shottr settings... ($i/5)"; sleep 2; fi; done


# --- 5. Apply Global Key Swaps & Bindings ---
print_header "⌨️ Applying Global Key Swaps and Text Bindings..."
# Text Editing Keybindings
KEYBINDINGS_DIR="$HOME/Library/KeyBindings"
mkdir -p "$KEYBINDINGS_DIR"
cat > "$KEYBINDINGS_DIR/DefaultKeyBinding.dict" << 'EOF'
{
    /* Remap Command + Arrow Keys for Word Navigation */
    "@\UF702" = "moveWordLeft:";                           /* Cmd + Left    */
    "@\UF703" = "moveWordRight:";                          /* Cmd + Right   */
    "@$\UF702" = "moveWordLeftAndModifySelection:";        /* Cmd + Shift + Left */
    "@$\UF703" = "moveWordRightAndModifySelection:";       /* Cmd + Shift + Right*/

    /* Remap Option + Arrow Keys for Line Navigation */
    "~\UF702" = "moveToBeginningOfLine:";                  /* Opt + Left    */
    "~\UF703" = "moveToEndOfLine:";                        /* Opt + Right   */
    "~$\UF702" = "moveToBeginningOfLineAndModifySelection:";/* Opt + Shift + Left */
    "~$\UF703" = "moveToEndOfLineAndModifySelection:";      /* Opt + Shift + Right*/
    
    /* Remap Command + Shift + Up/Down for Paragraph Navigation */
    "@$\UF700" = "moveToBeginningOfParagraphAndModifySelection:"; /* Cmd + Shift + Up */
    "@$\UF701" = "moveToEndOfParagraphAndModifySelection:";     /* Cmd + Shift + Down */
}
EOF
echo "✓ Text keybindings created."
# Swap Left Command and Control Keys
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"; PLIST_FILE="$LAUNCH_AGENTS_DIR/com.user.swapkeys.plist"; mkdir -p "$LAUNCH_AGENTS_DIR"; cat > "$PLIST_FILE" << EOL
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>Label</key><string>com.user.swapkeys</string><key>ProgramArguments</key><array><string>/usr/bin/hidutil</string><string>property</string><string>--set</string><string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x7000000E0,"HIDKeyboardModifierMappingDst":0x7000000E3},{"HIDKeyboardModifierMappingSrc":0x7000000E3,"HIDKeyboardModifierMappingDst":0x7000000E0}]}</string></array><key>RunAtLoad</key><true/></dict></plist>
EOL
launchctl unload "$PLIST_FILE" 2>/dev/null || true; launchctl load "$PLIST_FILE"; echo "✓ Command and Control keys swapped."


# --- 6. Configure iTerm2 Profile and Keybindings ---
print_header "🖥️  Configuring iTerm2..."
PROFILE_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$PROFILE_DIR"
cat > "$PROFILE_DIR/custom_profile.json" << 'EOF'
{
  "Profiles": [
    {
      "Name": "Custom Profile",
      "Guid": "Custom-Profile-Grubsta-Setup",
      "Keyboard Map": [
        {
          "Action": 2,
          "Hex Code": 3,
          "KeyCode": 8,
          "Modifiers": 1048576
        },
        {
          "Action": 0,
          "KeyCode": 8,
          "Modifiers": 1179648
        }
      ]
    }
  ]
}
EOF
echo "✓ iTerm2 profile 'Custom Profile' created with custom keybindings."

# --- Finalization ---
print_header "✅ All Tasks Complete!"
echo "Applying some settings now by restarting affected services..."
killall Dock
killall Finder
killall SystemUIServer

echo "\n\033[1;33mIMPORTANT: For all changes to take full effect, please do the following:\033[0m"
echo "\033[1;33m  1. In iTerm2, go to Profiles > Open Profiles... > Edit Profiles... and set 'Custom Profile' as your default.\033[0m"
echo "\033[1;33m  2. Log out and log back in.\033[0m"
