#!/usr/bin/env bash
# vim: set et sw=4 sts=4 ts=4 ft=sh :

# Copyright 2007 Bryan Østergaard <kloeri@exherbo.org>
# Copyright 2008 Ingmar Vanhassel <ingmar@exherbo.org>
# Distributed under the terms of the GNU General Public License v2
# Automake wrapper v0.2 -- http://www.exherbo.org

# Keep versions sorted highest to lowest.
AUTOMAKE_VERSIONS=( 1.10 1.9 1.8 1.7 1.6 1.5 1.4 )
AUTOMAKE_PROGRAM="$(basename $0)"

# Default to latest if WANT_AUTOMAKE isn't set
if [[ -z ${WANT_AUTOMAKE} || ${WANT_AUTOMAKE} == latest ]]; then
    WANT_AUTOMAKE=${AUTOMAKE_VERSIONS[0]}
fi

if [[ -x /usr/bin/${AUTOMAKE_PROGRAM}-${WANT_AUTOMAKE} ]]; then
    TARGET="/usr/bin/${AUTOMAKE_PROGRAM}-${WANT_AUTOMAKE}"
fi

# Exit with error code 1 if TARGET is unset
if [[ -z ${TARGET} ]]; then
    exit 1
fi

# Execute program
${TARGET} $@

