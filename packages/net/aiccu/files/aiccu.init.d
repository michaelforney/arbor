#!/sbin/runscript
# Copyright 2009 Mike Kelly
# Distributed under the terms of the GNU General Public License v2

depend() {
    need net
}

start() {
    ebegin "Starting aiccu"
    aiccu start
    eend $?
}

stop() {
    ebegin "Stopping aiccu"
    aiccu stop
    eend $?
}

