#!/sbin/runscript
# Copyright 2008 Bernd Steinhauser <berniyh@exherbo.org>
# Distributed under the terms of the GNU General Public License v2
# Based in part upon 'fancontrol-init.d' from Gentoo, which is:
# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

CONFIG=/etc/conf.d/fancontrol
PID=/run/fancontrol.pid

depend() {
    after lm_sensors
}

checkconfig() {
    if [ ! -f ${CONFIG} ]; then
        eerror "Configuration file ${CONFIG} not found"
        return 1
    fi
}

start() {
    checkconfig || return 1

    ebegin "Starting fancontrol"
    start-stop-daemon --start --quiet --background --pidfile ${PID} \
        --exec /usr/sbin/fancontrol -- ${CONFIG}
    eend ${?}
}

stop() {
    ebegin "Stopping fancontrol"
    start-stop-daemon --stop --pidfile ${PID}
    eend ${?}
}
