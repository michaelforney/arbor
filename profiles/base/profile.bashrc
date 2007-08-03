# Copyright 2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/profiles/base/profile.bashrc,v 1.2 2006/07/06 21:35:00 genone Exp $

if [[ $(type -t elog) != "function" ]]; then
	elog() {
		einfo "$@"
	}
fi
