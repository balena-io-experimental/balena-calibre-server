#!/bin/bash

echo "🛑 Stopping running Calibre server to adjust users"
CALIBRE_PID=$(cat /var/run/calibre.pid)
if [ -n "$CALIBRE_PID" ]; then
    kill "$CALIBRE_PID" 2>/dev/null || true
    timeout 10 tail --pid="$CALIBRE_PID" -f /dev/null
fi

calibre-server --manage-users --userdb=/calibre_data/users.sqlite

echo "♻️ Please restart the service to run Calibre server again!"
