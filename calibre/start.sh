#!/bin/bash

# Proper cleanup on container stop
function finish {
    echo "Shutting down Calibre"
    CALIBRE_PID=$(cat /var/run/calibre.pid)
    kill "$CALIBRE_PID"
    timeout 10 tail --pid="$CALIBRE_PID" -f /dev/null
    echo "Finished, bye!"
    exit
}
trap finish SIGINT SIGTERM

# Workaround for Python's getaddrinfo to function
echo "127.0.0.1 $(hostname)" >> /etc/hosts

mkdir /calibre_data/library

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
    ./calibre-userset "$USERNAME" "$PASSWORD"
fi

# Create library on first run
calibredb --with-library=/calibre_data/library/ list > /dev/null

echo "Starting Calibre Server with command line:" "${calibre_args[@]}"
calibre-server "${calibre_args[@]}"

# Simple idling in a way that signals are still trapped
while : ; do
    sleep 600 &
    wait %1
done
