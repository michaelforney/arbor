#!/bin/bash

# Copyright 2007 Bryan Østergaard
# Distributed under the terms of the GNU General Public License v2
# Autoconf wrapper v0.1

AUTOCONF_VERSIONS="2.61:2.5 2.13:2.1"
AUTOCONF_PROGRAM="$(basename $0)"

# Default to latest if WANT_AUTOCONF isn't set
if [[ "${WANT_AUTOCONF}x" == "x" ]]; then
	WANT_AUTOCONF="latest"
fi

if [[ -x "/usr/bin/${AUTOCONF_PROGRAM}-${WANT_AUTOCONF}" ]]; then
	TARGET="/usr/bin/${AUTOCONF_PROGRAM}-${WANT_AUTOCONF}"
fi

if [[ "${WANT_AUTOCONF}" != "latest" ]]; then
	WANT_VERSION="${AUTOCONF_VERSIONS%%:${WANT_AUTOCONF}*}"
	if [[ "${WANT_VERSION}" != "${AUTOCONF_VERSIONS}" ]]; then
		WANT_VERSION="${WANT_VERSION##* }"
	fi
	if [[ "${WANT_VERSION}" != "${AUTOCONF_VERSIONS}" ]]; then
		TARGET="/usr/bin/${AUTOCONF_PROGRAM}-${WANT_VERSION}"
	fi
else
	# Handle "latest" version
	WANT_VERSION="$(ls /usr/bin/autoconf-* | grep -v wrapper | sort -n | tail -n 1)"
	WANT_VERSION="${WANT_VERSION##*autoconf-}"
	TARGET="/usr/bin/${AUTOCONF_PROGRAM}-${WANT_VERSION}"
fi

# Exit with error code 1 if TARGET is unset
if [[ "${TARGET}x" == "x" ]]; then
	exit 1
fi

# Execute program
${TARGET} $@
