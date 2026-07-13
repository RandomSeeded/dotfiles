#!/usr/bin/env bash
# macOS system preferences. Idempotent — safe to re-run.
#
#   ./macos.sh
#
# Only the settings that actually differ from stock macOS are here. An audit of this
# machine found ~10 real deviations; everything else (trackpad gestures, key repeat,
# text substitution, hot corners, dark mode, screenshots, the Dock's app list) is at
# Apple's defaults. Writing those back would be noise, so they're deliberately absent.
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }

# ── Mouse / scrolling ──────────────────────────────────────────
info "Scrolling"
# Natural scrolling OFF (traditional direction). One global key — covers mouse AND trackpad.
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# ── Keyboard modifier remapping ────────────────────────────────
# These live in the PER-HOST global domain and are keyed by USB vendor-product ID.
# Two things to know:
#   1. `-currentHost` is mandatory. Writing to the plain global domain does nothing.
#   2. They only bind if the same hardware is attached. The external-keyboard entries
#      are no-ops on a Mac without those keyboards plugged in — harmless, but inert.
#   3. Requires logout/login (or replugging the keyboard) to take effect. No killall helps.
#
# HID codes are 0x700000000 + usage:
#   30064771129 = 0x39 Caps Lock    30064771113 = 0x29 Escape
#   30064771298 = 0xE2 Left Option  30064771299 = 0xE3 Left Command
#   30064771302 = 0xE6 Right Option 30064771303 = 0xE7 Right Command
info "Keyboard modifier maps"

# Apple internal keyboard (1452-835): Caps Lock -> Escape.
# NOTE: keyed by product ID. A different-generation MacBook may enumerate a different
# one, in which case this is inert and you must redo Caps Lock -> Escape by hand in
# System Settings > Keyboard > Keyboard Shortcuts > Modifier Keys.
defaults -currentHost write -g com.apple.keyboard.modifiermapping.1452-835-0 -array \
  '{HIDKeyboardModifierMappingSrc = 30064771129; HIDKeyboardModifierMappingDst = 30064771113;}'

# Dygma Defy (13807-18) and second external keyboard (5426-178):
# swap Option <-> Command on both sides.
for kb in 13807-18-0 5426-178-0; do
  defaults -currentHost write -g "com.apple.keyboard.modifiermapping.$kb" -array \
    '{HIDKeyboardModifierMappingSrc = 30064771298; HIDKeyboardModifierMappingDst = 30064771299;}' \
    '{HIDKeyboardModifierMappingSrc = 30064771299; HIDKeyboardModifierMappingDst = 30064771298;}' \
    '{HIDKeyboardModifierMappingSrc = 30064771302; HIDKeyboardModifierMappingDst = 30064771303;}' \
    '{HIDKeyboardModifierMappingSrc = 30064771303; HIDKeyboardModifierMappingDst = 30064771302;}'
done

# ── Keyboard shortcuts ─────────────────────────────────────────
info "Freeing Ctrl+Space / Ctrl+Opt+Space"
# Disable the input-source switchers so editors can use Ctrl+Space for autocomplete.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 \
  '{enabled = 0; value = {parameters = (32, 49, 262144); type = standard;};}'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 \
  '{enabled = 0; value = {parameters = (32, 49, 786432); type = standard;};}'

# ── Dock ───────────────────────────────────────────────────────
info "Dock"
defaults write com.apple.dock autohide -bool true
# The Dock's app list is deliberately NOT versioned — this machine's is Apple's stock
# list, so committing it would just write Apple's defaults back to Apple.

# ── Finder ─────────────────────────────────────────────────────
info "Finder"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view

# ── Windows ────────────────────────────────────────────────────
info "Windows"
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false

# ── Menu bar ───────────────────────────────────────────────────
info "Menu bar"
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true

# ── Apply ──────────────────────────────────────────────────────
info "Restarting Dock, Finder, ControlCenter"
killall Dock Finder ControlCenter 2>/dev/null || true

cat <<'EOF'

Done. Two things this script cannot do:
  • Keyboard modifier maps need a logout/login (or keyboard replug) to bind.
  • Privacy permissions (Accessibility / Screen Recording / Full Disk Access /
    Automation) are in the SIP-protected TCC database and must be re-granted by
    hand: iTerm, VS Code, Claude, Docker, Bazecor, Zoom.
EOF
