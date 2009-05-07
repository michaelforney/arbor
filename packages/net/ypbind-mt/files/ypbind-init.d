#!/sbin/runscript
# Copyright (c) 2009 Saleem Abdulrasool <compnerd@compnerd.org>
# Distributed under the terms of the GNU General Public License v2

depend() {
   need net portmap
   use domainname
}

start() {
   ebegin "Starting ypbind"
   start-stop-daemon --start --quiet --exec /usr/sbin/ypbind
   eend $?
}

stop() {
   ebegin "Stopping ypbind"
   start-stop-daemon --stop --quiet --exec /usr/sbin/ypbind
   eend $?
}

