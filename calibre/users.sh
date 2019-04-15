#!/bin/bash

echo "🛑 Stopping running Calibre server to adjust users"
killall $(cat /var/run/calibre.pid) 2> /dev/null || true

calibre-server --manage-users --userdb=/calibre_data/users.sqlite

echo "♻️ Please restart the service to run Calibre server again!"
