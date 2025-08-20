#!/bin/bash

#==============================================================================
# macOS Custom Shortcut Script
#
# This script applies three specific, persistent keyboard customizations:
# 1. Swaps the Left Command and Left Control keys.
# 2. Sets Cmd+Shift+Arrow keys for word-by-word text selection.
# 3. Remaps the Right Shift key to act as the Right Option (Alt) key.
#==============================================================================

# --- Helper Function ---
print_header() {
  echo "\n\033[1;34m$1\033[0m"
}

# Exit script on any error
set -e

print_header "🚀 Applying Custom Keyboard Shortcuts..."

# --- 1. Create Custom Text Editing Keybindings ---
print_header "⌨️ Setting up text selection shortcuts..."
KEYBINDINGS_DIR="$HOME/Library/KeyBindings"
mkdir -p "$KEYBINDINGS_DIR"

cat > "$KEYBINDINGS_DIR/DefaultKeyBinding.dict" << 'EOF'
{
    /* Remap Command + Shift + Arrow for Word Selection */
    "@$\UF702" = "moveWordLeftAndModifySelection:";    /* Cmd + Shift + Left */
    "@$\UF703" = "moveWordRightAndModifySelection:";   /* Cmd + Shift + Right*/
}
EOF
echo "✓ Text selection keybindings created."


# --- 2. Swap Modifier Keys (Ctrl/Cmd and Right Shift) ---
print_header "⚙️ Remapping modifier keys..."
PLIST_FILE="$HOME/Library/LaunchAgents/com.user.custom-key-remaps.plist"

# Create a single configuration file for all modifier key changes
cat > "$PLIST_FILE" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.custom-key-remaps</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x7000000E0,"HIDKeyboardModifierMappingDst":0x7000000E3},{"HIDKeyboardModifierMappingSrc":0x7000000E3,"HIDKeyboardModifierMappingDst":0x7000000E0},{"HIDKeyboardModifierMappingSrc":0x7000000E5,"HIDKeyboardModifierMappingDst":0x7000000E6}]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOL

# Unload any previous version and load the new one to apply changes immediately
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"
echo "✓ Left Ctrl/Cmd swapped and Right Shift remapped."


# --- Finalization ---
print_header "✅ All Shortcuts Applied!"
echo "\033[1;33mThe modifier key swaps are active now.\033[0m"
echo "\033[1;33mFor the text selection shortcuts to work everywhere, please log out and log back in.\033[0m"

