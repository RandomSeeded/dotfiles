#!/usr/bin/env bash
# Capture this machine's iTerm2 preferences into the repo, minus machine-local state.
#
#   ./iterm2/export.sh
#
# Quit iTerm2 first if you want a guaranteed-complete capture — iTerm2 batches its
# writes and only fully flushes on quit. `defaults export` reads through cfprefsd
# (not the raw file), so it sees everything iTerm2 has written so far either way.
#
# The reverse direction (repo -> machine) is done by install.sh via `defaults import`.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$DOTFILES/iterm2/com.googlecode.iterm2.plist"
TMP="$(mktemp -t iterm2plist).plist"
trap 'rm -f "$TMP"' EXIT

defaults export com.googlecode.iterm2 "$TMP"

# Drop keys that are per-machine state, not preferences. Committing these means every
# iTerm2 launch dirties the repo, and restoring them onto another Mac is meaningless.
# NoSyncRecordedVariables alone is ~20KB of cached variable names (tmuxWindowPane,
# tmuxStatusLeft, ...) — a autocomplete cache, not settings.
python3 - "$TMP" "$DEST" <<'PY'
import plistlib, sys

src, dest = sys.argv[1], sys.argv[2]

DROP_PREFIXES = (
    "NSWindow Frame",                    # window/panel positions
    "NSSplitView",                       # panel splitter positions
    "NSToolbar Configuration",           # toolbar layout
    "NoSyncFrame_",                      # more window positions
    "NoSyncSavedWindowPositions",
    "NoSyncRecordedVariables",           # ~20KB autocomplete cache
    "NoSyncInstallationId",              # per-install UUID
    "NoSyncLastOSVersion",
    "NoSyncAllAppVersions",
    "NoSyncRestoreWindowsCount",
    "NoSyncLaunchExperienceControllerRunCount",
    "NoSyncOnboardingWindowHasBeenShown",
    "NoSyncBrowserUpsell",
    "NoSyncBFPRecents",                  # recent-file picker history
    "NoSyncNextAnnoyanceTime",
    "NoSyncTipOfTheDay",
    "NoSyncPermissionToShowTip",
    "NoSyncHaveUsedCopyMode",
    "NoSyncUserHasSelectedCommand",
    "NoSyncLastSystemPythonVersionRequirement",
    "NoSyncNeverAskAboutMouseReportingFrustration",
    "iTerm Version",
    "SULastCheckTime",                   # Sparkle updater state (not preferences)
    "SUUpdateRelaunchingMarker",
    "SUHasLaunchedBefore",
    "SUUpdateGroupIdentifier",
    # Set by install.sh on the target machine, not carried between them.
    "LoadPrefsFromCustomFolder",
    "PrefsCustomFolder",
)

d = plistlib.load(open(src, "rb"))
before = len(d)
kept = {k: v for k, v in d.items() if not k.startswith(DROP_PREFIXES)}

with open(dest, "wb") as f:
    plistlib.dump(kept, f, sort_keys=True)

print(f"  kept {len(kept)} keys, dropped {before - len(kept)} machine-local keys")

profiles = kept.get("New Bookmarks", [])
print(f"  {len(profiles)} profile(s):")
for p in profiles:
    bits = []
    if p.get("Initial Text"):
        bits.append(f"initial text={p['Initial Text']!r}")
    if p.get("Normal Font"):
        bits.append(f"font={p['Normal Font']!r}")
    print(f"    - {p.get('Name')}: " + ", ".join(bits))
PY

echo "Wrote $DEST"
echo "Review with: git -C \"$DOTFILES\" diff --stat iterm2/"
