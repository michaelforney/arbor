#!/bin/bash
# Copyright 2010 Wulf C. Krueger <philantrop@exherbo.org>
# Distributed under the terms of the GNU General Public License v2
# Based in part upon 'checkroot'/'checkfs'/'bootmisc' from Gentoo, which is:
#     Copyright 1999-2007 Gentoo Foundation

# Only use commands from / to avoid the need to mount /usr at this point of the boot process.
# Consider using busybox if need be.
awk="/bin/awk"
fsck="/sbin/fsck"
grep="/bin/grep"
mount="/bin/mount"
reboot="/sbin/reboot"
rm="/bin/rm"
sulogin="/sbin/sulogin"

retval=0

if [[ -f /forcefsck ]] || $(${grep} -q "forcefsck" /proc/cmdline) ; then
    ${fsck} -C -a -f /
    retval=$?
else
    # Obey the fs_passno setting for / (see fstab(5))
    # - find the / entry
    # - make sure we have 6 fields
    # - see if fs_passno is something other than 0
    if [[ -n $(${awk} '($1 ~ /^(\/|UUID|LABEL)/ && $2 == "/" && NF == 6 && $6 != 0) { print }' /etc/fstab) ]]; then
        ${fsck} -C -T -a /
        retval=$?
    else
        retval=0
    fi
fi

if [[ ${retval} -eq 2 || ${retval} -eq 3 ]] ; then
    echo "Filesystem repaired, but reboot needed!"
    ${reboot} -f
elif [[ ${retval} -gt 3 ]] ; then
    echo "Filesystem couldn't be fixed."
    ${sulogin}
    echo "Unmounting filesystems"
    ${mount} -a -o remount,ro &> /dev/null
    echo "Rebooting"
    ${reboot} -f
fi

if [[ -f /forcefsck ]] ; then
    echo "A full fsck has been forced"
    ${fsck} -C -T -R -A -a -f
    retval=$?
    ${rm} -f /forcefsck
else
    ${fsck} -C -T -R -A -a
    retval=$?
fi
if [[ ${retval} -gt 3 ]] ; then
    echo "fsck could not correct all errors, manual repair needed"
    ${sulogin}
fi
