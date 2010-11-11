#!/bin/bash

valid_opts=( '--prefix' '--exec-prefix' '--includes' '--libs' '--cflags' '--ldflags' '--help' )

exit_with_usage() {
	printf "Usage: %s [%s]\n" $0 "$(output_opts)"
	exit ${1:-1}
}

output_opts() {
	IFS="|"
	local opts_output="${valid_opts[*]}"
	unset IFS
	echo -n "${opts_output}"
}

output_pkgconfig_cmd() {
	echo "$(PKG_CONFIG_PATH=@@PKG_CONFIG_PATH@@ pkg-config $@ python-@@SLOT@@)"
}

if [[ $# == 0 ]]; then
	exit_with_usage
else
	case "$1" in
		'--help'       ) exit_with_usage 0 ;;
		'--prefix'     ) output_pkgconfig_cmd '--variable=prefix' ;;
		'--exec-prefix') output_pkgconfig_cmd '--variable=exec-prefix' ;;
		'--includes'   ) output_pkgconfig_cmd '--cflags-only-I' ;;
		'--cflags'     ) output_pkgconfig_cmd '--cflags' ;;
		'--libs'       ) output_pkgconfig_cmd '--libs-only-l' ;;
		'--ldflags'    ) output_pkgconfig_cmd '--libs' ;;
	esac
	exit 0
fi

