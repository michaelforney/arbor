#!/bin/bash

# Copyright 2007 Bryan Østergaard
# Distributed under the terms of the GNU General Public License v2
# Automake wrapper v0.1

AUTOMAKE_VERSIONS="1.9:1.9.6 1.8:1.8.5 1.7:1.7.9 1.6:1.6.3 1.4:1.4_p6"
AUTOMAKE_PROGRAM="$(basename $0)"

# Default to latest if WANT_AUTOMAKE isn't set
if [[ "${WANT_AUTOMAKE}x" == "x" ]]; then
	WANT_AUTOMAKE="latest"
fi

if [[ -x "/usr/bin/${AUTOMAKE_PROGRAM}-${WANT_AUTOMAKE}" ]]; then
	TARGET="/usr/bin/${AUTOMAKE_PROGRAM}-${WANT_AUTOMAKE}"
fi

if [[ "${WANT_AUTOMAKE}" != "latest" ]]; then
	WANT_VERSION="${AUTOMAKE_VERSIONS%%:${WANT_AUTOMAKE}*}"
	if [[ "${WANT_VERSION}" != "${AUTOMAKE_VERSIONS}" ]]; then
		WANT_VERSION="${WANT_VERSION##* }"
	fi
	if [[ "${WANT_VERSION}" != "${AUTOMAKE_VERSIONS}" ]]; then
		TARGET="/usr/bin/${AUTOMAKE_PROGRAM}-${WANT_VERSION}"
	fi
else
	# Handle "latest" version
	WANT_VERSION="$(ls /usr/bin/automake-* | grep -v wrapper | sort -n | tail -n 1)"
	WANT_VERSION="${WANT_VERSION##*automake-}"
	TARGET="/usr/bin/${AUTOMAKE_PROGRAM}-${WANT_VERSION}"
fi

# Exit with error code 1 if TARGET is unset
if [[ "${TARGET}x" == "x" ]]; then
	exit 1
fi

# Execute program
${TARGET} $@
