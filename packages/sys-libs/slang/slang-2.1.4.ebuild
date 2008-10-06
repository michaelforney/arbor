# Copyright 2008 Wulf C. Krueger
# Distributed under the terms of the GNU General Public License v2
# Based in part upon 'slang-2.1.3-r1.ebuild' from Gentoo, which is:
#       Copyright 1999-2008 Gentoo Foundation

SUMMARY="A portable library designed to allow a developer to create robust portable software"
DESCRIPTION="
S-Lang is a multi-platform programmer's library designed to allow a developer to
create robust multi-platform software. It provides facilities required by
interactive applications such as display/screen management, keyboard input,
keymaps, and so on. It a features an easily embeddable slang interpreter and a
stand-alone mode by means of slsh.
" 
HOMEPAGE="http://www.s-lang.org"
DOWNLOADS="ftp://ftp.fu-berlin.de/pub/unix/misc/slang/v${PV%.*}/${PNV}.tar.bz2"

BUGS_TO="philantrop@exherbo.org"
REMOTE_IDS="freshmeat:${PN}"
UPSTREAM_DOCUMENTATION="http://www.s-lang.org/docs.html"

LICENCES="GPL-2"
SLOT="0"
PLATFORMS="~amd64 ~x86"
MYOPTIONS="pcre png"

DEPENDENCIES="
    build+run:
        >=sys-libs/ncurses-5.6
        >=sys-libs/readline-5.1
        pcre? ( >=dev-libs/pcre-7.8 )
        png? ( >=media-libs/libpng-1.2.31 )
"

DEFAULT_SRC_PREPARE_PATCHES=(
    -p0 "${FILES}"/${PNV}-slsh-ncurses.patch
    -p1 "${FILES}"/${PNV}-slsh-libs.patch
    -p1 "${FILES}"/${PNV}-uclibc.patch
)

DEFAULT_SRC_CONFIGURE_PARAMS=(
    --with-readline=gnu
    --without-onig
)

DEFAULT_SRC_CONFIGURE_OPTION_WITHS=(
    pcre
    png
)

DEFAULT_SRC_COMPILE_PARAMS=(
    -j1
    elf
    static
)

DEFAULT_SRC_INSTALL_PARAMS=(
    install-static
)

src_compile() {
    default
    
    pushd slsh >/dev/null 2>&1
    emake -j1 slsh || die "emake slsh failed."
    popd >/dev/null 2>&1
}

src_install() {
    default

    rm -rf "${IMAGE}"/usr/share/doc/{slang,slsh}
    dodoc *.txt doc/{,internal,text}/*.txt doc/slangdoc.html slsh/doc/html/*.html
    keepdir /usr/share/slsh/local-packages
}
