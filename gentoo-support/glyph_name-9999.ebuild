# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils git

IUSE="python"

DESCRIPTION="A library for computing Unicode sequences from glyph names"
HOMEPAGE="http://github.com/chemoelectric/glyph_name"
SRC_URI=""
EGIT_REPO_URI="git://github.com/chemoelectric/glyph_name.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="python? ( >=dev-lang/python-2.6.4
		           >=dev-lang/swig-1.3.40 )"
DEPEND=">=dev-util/scons-1.2.0-r1
        python? ( >=dev-lang/swig-1.3.40 )
	    ${RDEPEND}"

S="${WORKDIR}/${PN}"

src_compile() {
	cd "${S}"
	scons --include_soname || die "scons compile failed"
	if use python; then
	   swig -python glyph_name.i || die "swig failed"
	   LDFLAGS="-L. ${LDFLAGS}" distutils_src_compile || die "distutils_src_compile failed"
	fi
}

src_install() {
	python_need_rebuild
	cd "${S}"
	scons --prefix="${D}/usr" --libdir="${D}/usr/$(get_libdir)" --include_soname install ||
	      die "scons install failed"
	if use python; then
	   distutils_src_install || die "distutils_src_install failed"
	fi
}
