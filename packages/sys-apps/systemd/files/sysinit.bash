#!/bin/bash
# Copyright 2010 Wulf C. Krueger <philantrop@exherbo.org>
# Distributed under the terms of the GNU General Public License v2
# Based in part upon 'checkroot'/'checkfs'/'bootmisc' from Gentoo, which is:
#     Copyright 1999-2007 Gentoo Foundation

# Only use commands from / to avoid the need to mount /usr at this point of the boot process.
# Consider using busybox if need be.
awk="/bin/awk"
find="/bin/busybox find"
fsck="/sbin/fsck"
grep="/bin/grep"
lvm="/sbin/lvm"
mount="/bin/mount"
reboot="/sbin/reboot"
rm="/bin/rm"
rmdir="/bin/rmdir"
sort="/bin/sort"
sulogin="/sbin/sulogin"
touch="/bin/touch"
xargs="/bin/busybox xargs"

retval=0

# If / root is already mounted rw for some reason, re-mount it ro.
if ${touch} -c / >& /dev/null ; then
    ${mount} -n -o remount,ro /
fi

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

# Should we mount root rw? The touch check is to see if the / is
# already mounted rw in which case there's nothing for us to do
if ${mount} -vf -o remount / 2> /dev/null | \
   ${awk} '{ if ($6 ~ /rw/) exit 0; else exit 1; }' && \
   ! ${touch} -c / >& /dev/null
then
    ${mount} -n -o remount,rw / &> /dev/null
    if [[ $? -ne 0 ]] ; then
        echo "Root filesystem could not be mounted read/write :("
        ${sulogin}
    fi
fi

# Clean up /tmp directory if it's not on a tmpfs anyway.
# Can't check /proc/self/mountinfo since tmp.service is started later than this.
if ! [[ -L /etc/systemd/system/local-fs.target.wants/tmp.service ]] && [[ -d /tmp ]]; then
    cd /tmp
    exceptions="
        '!' -name . -a
        '!' '(' -user 0 -a
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
    eval ${find} . -xdev -depth ${exceptions} ! -type d -print0 | ${xargs} -0 ${rm} -f --
    eval ${find} . -xdev -depth ${exceptions}   -type d ! -name "." -print0 | ${sort} -rz | ${xargs} -0 ${rmdir} --ignore-fail-on-non-empty
fi

# Check for /etc/resolv.conf, and create if missing
[[ -f /etc/resolv.conf ]] || ${touch} /etc/resolv.conf &> /dev/null

# vim:ts=4
