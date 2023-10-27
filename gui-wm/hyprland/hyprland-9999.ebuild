# Copyright 2023 Gentoo Authors
# Copyright 2023 Avishek Sen
# Distributed under the terms of the GNU General Public License v3

EAPI=8

inherit meson toolchain-funcs

DESCRIPTION="A dynamic tiling Wayland compositor that doesn't sacrifice on its looks"
HOMEPAGE="https://github.com/hyprwm/Hyprland/releases"

inherit git-r3
EGIT_REPO_URI="https://github.com/hyprwm/${PN^}.git"

KEYWORDS="~amd64"
LICENSE="BSD"
SLOT="0"
IUSE="X legacy-renderer systemd contrib"

RDEPEND="
	app-misc/jq
	dev-libs/libevdev
	dev-libs/libinput
	dev-libs/wayland
	>=dev-libs/wayland-protocols-1.31
	dev-util/glslang
	dev-util/vulkan-headers
	gui-libs/gtk-layer-shell
	media-libs/libdisplay-info
	media-libs/libglvnd[X?]
	media-libs/mesa[gles2,wayland,X?]
	media-libs/vulkan-loader
	x11-base/xcb-proto
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libxkbcommon
	x11-libs/pixman
	x11-misc/xkeyboard-config
	virtual/libudev
	X? (
	   gui-libs/wlroots[x11-backend]
	   x11-base/xwayland
	   x11-libs/libxcb
	   x11-libs/xcb-util-image
	   x11-libs/xcb-util-renderutil
	   x11-libs/xcb-util-wm
	)
	contrib? ( gui-apps/hyprland-contrib )
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-libs/hyprland-protocols
	dev-libs/libliftoff
	dev-vcs/git
	>=gui-libs/wlroots-0.16.0[X?]
"

PATCHES=("${FILESDIR}/hyprland-wezterm-revert.patch")

src_prepare() {
	STDLIBVER=$(echo '#include <string>' | $(tc-getCXX) -x c++ -dM -E - | \
					grep GLIBCXX_RELEASE | sed 's/.*\([1-9][0-9]\)/\1/')
	if ! [[ ${STDLIBVER} -ge 12 ]]; then
		die "Hyprland requires >=sys-devel/gcc-12.1.0 to build"
	fi
	eapply hyprland-wezterm-revert.patch

	default
}

src_configure() {
	local emesonargs=(
		$(meson_feature legacy-renderer legacy_renderer)
		$(meson_feature X xwayland)
		$(meson_feature systemd)
	)

	meson_src_configure
}

src_install() {
	meson_src_install --skip-subprojects wlroots
}
