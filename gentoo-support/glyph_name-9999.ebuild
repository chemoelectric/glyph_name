# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"
SUPPORT_PYTHON_ABIS="1"

inherit distutils git

IUSE="python nolib"

DESCRIPTION="A library for computing Unicode sequences from glyph names"
HOMEPAGE="http://github.com/chemoelectric/glyph_name"
SRC_URI=""
EGIT_REPO_URI="git://github.com/chemoelectric/glyph_name.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	python? ( >=dev-lang/python-2.6.4 )
	"
DEPEND="
        >=dev-lang/python-2.6.4
	!nolib? ( >=dev-util/scons-1.2.0-r1
	          sys-devel/m4 )
	${RDEPEND}
	"

S="${WORKDIR}/${PN}"

src_compile() {
	cd "${S}"
	if ! use nolib; then
	   scons --include_soname || die "scons compile failed"
	fi
	if use python; then
	   cp setup-no_cython.py setup.py
	   distutils_src_compile || die "distutils_src_compile failed"
	fi
}

src_install() {
	cd "${S}"
	if ! use nolib; then
	   scons --prefix="${D}/usr" --libdir="${D}/usr/$(get_libdir)" --include_soname install ||
	   	 die "scons install failed"
	fi
	if use python; then
	   python_need_rebuild
	   distutils_src_install || die "distutils_src_install failed"
	fi
}
