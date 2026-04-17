#!/bin/bash
# ═══════════════════════════════════════════════════════════
# Hook 10: Desktop Notification
# Event: Notification
# macOS notification when Claude needs input
# ═══════════════════════════════════════════════════════════

osascript -e 'display notification "Claude needs your attention" with title "God System" sound name "Ping"' 2>/dev/null || true

exit 0
