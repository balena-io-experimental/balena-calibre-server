#!/bin/bash

# An idling function that allows trapping signals, etc
function idling {
    while : ; do
        sleep 600 &
        wait %1
    done
}

# Proper cleanup on container stop
function finish {
    echo "✋ Shutting down Calibre"
    CALIBRE_PID=$(cat /var/run/calibre.pid)
    kill "$CALIBRE_PID"
    timeout 10 tail --pid="$CALIBRE_PID" -f /dev/null
    echo "🏁 Finished, bye!"
    exit
}
trap finish SIGINT SIGTERM

# Workaround for Python's getaddrinfo to function
echo "127.0.0.1 $(hostname)" >> /etc/hosts

echo "📚 Creating library folder."
mkdir /calibre_data/library 2>/dev/null || echo "📖 Library folder already exists."

calibre_args=(
    '/calibre_data/library'
    '--port=80'
    '--enable-use-sendfile'
    '--enable-use-bonjour'
    '--ban-for=15'
    '--ban-after=3'
    '--enable-auth'
    '--auth-mode=auto'
    '--userdb=/calibre_data/users.sqlite'
    '--pidfile=/var/run/calibre.pid'
    '--daemonize'
    '--log=/dev/stdout'
    )

if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
    # Set up user from env vars
    echo "👥 Setting up or updating users."
    ./calibre-userset "$USERNAME" "$PASSWORD"
elif [ ! -f "/calibre_data/users.sqlite" ]; then
    echo "👤 No user database created yet. Can't start Calibre without that. Please provide a default USERNAME and PASSWORD via environment variables!"
    idling
fi

# Create library on first run
calibredb --with-library=/calibre_data/library/ list > /dev/null

echo "✨ Starting Calibre Server with command line:" "${calibre_args[@]}"
calibre-server "${calibre_args[@]}"

# Simple idling in a way that signals are still trapped
idling
