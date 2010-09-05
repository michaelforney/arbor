#!/bin/bash
# Copyright 2010 Wulf C. Krueger <philantrop@exherbo.org>
# Distributed under the terms of the GNU General Public License v2
# Based in part upon 'bootmisc' from Gentoo, which is:
#     Copyright 1999-2007 Gentoo Foundation

# Take care of random stuff [ /var/lock | /var/run | pam ]
rm -rf /var/run/console.lock /var/run/console/*

# Clean up any stale locks.
find /var/lock -type f -print0 | xargs -0 rm -f --

# Clean up /var/run and create /var/run/utmp so that we can login.
for x in $(find /var/run/ ! -type d ! -name utmp ! -name innd.pid ! -name random-seed) ; do
    local daemon=${x##*/}
    daemon=${daemon%*.pid}
    # Do not remove pidfiles of already running daemons
    if [[ -z $(ps --no-heading -C "${daemon}") ]] ; then
        if [[ -f ${x} || -L ${x} ]] ; then
            rm -f "${x}"
        fi
    fi
done

# Create the .keep to stop the PM from removing /var/lock
> /var/lock/.keep

# Clean up /tmp directory
if [[ -d /tmp ]] ; then
    cd /tmp
    local exceptions="
        '!' -name . -a
        '!' '(' -uid 0 -a
            '('
                -path './lost+found/*' -o
                -path './quota.user' -o
            -path './quota.user/*' -o
            -path './aquota.user/*' -o
            -path './quota.group/*' -o
            -path './aquota.group/*' -o
            -path './.journal/*'
        ')' -o '(' -type d -a
        '('
            -path './lost+found' -o
            -path './quota.user' -o
            -path './aquota.user' -o
            -path './quota.group' -o
            -path './aquota.group' -o
            -path './.journal'
        ')' ')'
    ')'"
    # First kill most files, then kill empty dirs
    eval find . -xdev -depth ${exceptions} ! -type d -print0 | xargs -0 rm -f --
    eval find . -xdev -depth ${exceptions}   -type d -empty -exec rmdir '{}' \\';'

    (
        # Make sure our X11 stuff have the correct permissions
        # Omit the chown as bootmisc is run before network is up
        # and users may be using lame LDAP auth #139411
        rm -rf /tmp/.{ICE,X11}-unix
        mkdir -p /tmp/.{ICE,X11}-unix
        #chown 0:0 /tmp/.{ICE,X11}-unix
        chmod 1777 /tmp/.{ICE,X11}-unix
        [[ -x /sbin/restorecon ]] && restorecon /tmp/.{ICE,X11}-unix
    ) &> /dev/null
fi

# Create an 'after-boot' dmesg log
touch /var/log/dmesg
chmod 640 /var/log/dmesg
dmesg > /var/log/dmesg

# Check for /etc/resolv.conf, and create if missing
[[ -f /etc/resolv.conf ]] || touch /etc/resolv.conf &> /dev/null

# vim:ts=4
