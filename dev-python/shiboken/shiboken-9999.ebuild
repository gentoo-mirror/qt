# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/shiboken/shiboken-1.2.2.ebuild,v 1.5 2014/09/20 23:58:11 pesa Exp $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )

inherit cmake-utils multilib python-r1 git-r3

DESCRIPTION="A tool for creating Python bindings for C++ libraries"
HOMEPAGE="https://wiki.qt.io/Pyside"
EGIT_REPO_URI=(
	"git://code.qt.io/pyside/${PN}.git"
	"https://code.qt.io/git/pyside/${PN}.git"
)

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""

IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-libs/libxml2
	dev-libs/libxslt
	dev-qt/qtcore:4
	dev-qt/qtxmlpatterns:4
"
DEPEND="${RDEPEND}
	test? (
		dev-qt/qtgui:4
		dev-qt/qttest:4
	)"

DOCS=( AUTHORS ChangeLog )

src_prepare() {
	# Fix inconsistent naming of libshiboken.so and ShibokenConfig.cmake,
	# caused by the usage of a different version suffix with python >= 3.2
	sed -i -e "/get_config_var('SOABI')/d" \
		cmake/Modules/FindPython3InterpWithDebug.cmake || die

	if use prefix; then
		cp "${FILESDIR}"/rpath.cmake . || die
		sed -i -e '1iinclude(rpath.cmake)' CMakeLists.txt || die
	fi

	cmake-utils_src_prepare
}

src_configure() {
	configuration() {
		local mycmakeargs=(
			$(cmake-utils_use_build test TESTS)
			-DPYTHON_EXECUTABLE="${PYTHON}"
			-DPYTHON_SITE_PACKAGES="$(python_get_sitedir)"
			-DPYTHON_SUFFIX="-${EPYTHON}"
		)

		if [[ ${EPYTHON} == python3* ]]; then
			mycmakeargs+=(
				-DUSE_PYTHON3=ON
				-DPYTHON3_EXECUTABLE="${PYTHON}"
				-DPYTHON3_INCLUDE_DIR="$(python_get_includedir)"
				-DPYTHON3_LIBRARY="$(python_get_library_path)"
			)
		fi

		cmake-utils_src_configure
	}
	python_foreach_impl configuration
}

src_compile() {
	python_foreach_impl cmake-utils_src_compile
}

src_test() {
	python_foreach_impl cmake-utils_src_test
}

src_install() {
	installation() {
		cmake-utils_src_install
		mv "${ED}"usr/$(get_libdir)/pkgconfig/${PN}{,-${EPYTHON}}.pc || die
	}
	python_foreach_impl installation
}
