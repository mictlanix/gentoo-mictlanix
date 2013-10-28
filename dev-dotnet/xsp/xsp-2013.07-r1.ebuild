# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
inherit eutils mono user autotools autotools-utils

DESCRIPTION="XSP is a small web server that can host ASP.NET pages"
HOMEPAGE="http://www.mono-project.com/ASP.NET"

SRC_URI="http://dev.gentoo.org/~kensington/distfiles/xsp-20130730.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc test"

RDEPEND="dev-db/sqlite:3"
DEPEND="${RDEPEND}"

S=${WORKDIR}/xsp-20130730

src_prepare() {
	epatch "${FILESDIR}/aclocal-fix.patch"

	if [ -z "$LIBTOOL" ]; then
		LIBTOOL=`which glibtool 2>/dev/null`
		if [ ! -x "$LIBTOOL" ]; then
			LIBTOOL=`which libtool`
		fi
	fi
	eaclocal -I build/m4/shamrock -I build/m4/shave $ACLOCAL_FLAGS
	if test -z "$NO_LIBTOOLIZE"; then
		${LIBTOOL}ize --force --copy
	fi
	eautoconf
}

src_configure() {
	myeconfargs=("--enable-maintainer-mode")
	use test && myeconfargs+=("--with_unit_tests")
	use doc || myeconfargs+=("--disable-docs")
	eautomake --gnu --add-missing --force --copy #nowarn
	autotools-utils_src_configure
}

src_compile() {
	autotools-utils_src_compile
}

pkg_preinst() {
	enewgroup aspnet
	enewgroup www-data 33
	enewuser aspnet -1 -1 /tmp "aspnet,www-data"
}

src_install() {
	mv_command="cp -ar" autotools-utils_src_install
	newinitd "${FILESDIR}"/xsp.initd xsp
	newinitd "${FILESDIR}"/mod-mono-server-r1.initd mod-mono-server
	newinitd "${FILESDIR}"/mono-fcgi.initd mono-fcgi
	newconfd "${FILESDIR}"/xsp.confd xsp
	newconfd "${FILESDIR}"/mod-mono-server.confd mod-mono-server
	newconfd "${FILESDIR}"/mono-fcgi.confd mono-fcgi

	keepdir /var/run/aspnet
}

pkg_postinst() {
	chown aspnet:www-data /var/run/aspnet
}
