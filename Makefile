PORTNAME=	ffmpeg
PORTVERSION=	3.0.2
CATEGORIES=	multimedia audio net
MASTER_SITES=	https://ffmpeg.org/releases/
PKGNAMESUFFIX=	3

MAINTAINER=	kreinholz@gmail.com
COMMENT=	Realtime audio/video encoder/converter and streaming server (legacy 3.* series)
WWW=		https://ffmpeg.org/

LICENSE=	GPLv2+ LGPL21+
LICENSE_COMB=	multi

BUILD_DEPENDS=	${BUILD_DEPENDS_${ARCH}}
BUILD_DEPENDS_aarch64=	as:devel/binutils
BUILD_DEPENDS_amd64=	nasm:devel/nasm
BUILD_DEPENDS_armv6=	as:devel/binutils
BUILD_DEPENDS_armv7=	as:devel/binutils
BUILD_DEPENDS_i386=	nasm:devel/nasm

HAS_CONFIGURE=	yes
CONFIGURE_LOG=	ffbuild/config.log
USES=		compiler:c11 cpe gmake localbase:ldflags perl5 \
		pkgconfig shebangfix tar:xz
USE_LDCONFIG=	yes
USE_PERL5=	build
SHEBANG_FILES=	doc/texi2pod.pl
NOPRECIOUSMAKEVARS=	yes # ARCH

.ifdef PKGNAMESUFFIX
PORTSCOUT=	limit:^3\.
PREFIX=		${LOCALBASE}/${PKGBASE} # avoid conflict with the default
.endif

# Option CHROMAPRINT disabled, it cannot work and people are baffled.
OPTIONS_DEFINE=	ASM OPTIMIZED_CFLAGS RTCPU VAAPI VDPAU X264

OPTIONS_DEFAULT=	OPTIMIZED_CFLAGS RTCPU

OPTIONS_DEFAULT_amd64=	LTO

# i386 is too register-starved for LTO (PR257124)
OPTIONS_EXCLUDE_i386=	LTO

RTCPU_DESC=	Detect CPU capabilities at runtime

OPTIONS_SUB=	yes

# asm support
ASM_CONFIGURE_ENABLE=	asm

# debugging
DEBUG_CONFIGURE_ON=	--disable-stripping
DEBUG_CONFIGURE_OFF=	--disable-debug

# docs
DOCS_BUILD_DEPENDS=	texi2html:textproc/texi2html
DOCS_CONFIGURE_ENABLE=	htmlpages
DOCS_BINARY_ALIAS=	makeinfo=${FALSE} # force texi2html

# lto
LTO_CONFIGURE_ENABLE=	lto

# optimizations
OPTIMIZED_CFLAGS_CONFIGURE_ENABLE=	optimizations

# rtcpu
RTCPU_CONFIGURE_ENABLE=	runtime-cpudetect

# vaapi
VAAPI_LIB_DEPENDS=	libva.so:multimedia/libva
VAAPI_CONFIGURE_ENABLE=	vaapi

# vdpau
VDPAU_USES=		xorg
VDPAU_USE=		XORG=x11
VDPAU_LIB_DEPENDS=	libvdpau.so:multimedia/libvdpau
VDPAU_CONFIGURE_ENABLE=	vdpau

# x264
X264_LIB_DEPENDS=	libx264.so:multimedia/libx264
X264_CONFIGURE_ENABLE=	libx264

INSTALL_TARGET=	install-data install-libs install-headers

DATADIR=	${PREFIX}/share/${PORTNAME}${PKGNAMESUFFIX}
DOCSDIR=	${PREFIX}/share/doc/${PORTNAME}${PKGNAMESUFFIX}
MAKE_ENV+=	V=1
LDFLAGS_aarch64=-Wl,-z,notext
LDFLAGS_armv6=	-Wl,-z,notext
LDFLAGS_armv7=	-Wl,-z,notext
LDFLAGS_i386=	-Wl,-z,notext
LDFLAGS+=	-Wl,--undefined-version

CONFIGURE_ARGS+=--prefix="${PREFIX}" \
		--mandir="${PREFIX}/share/man" \
		--datadir="${DATADIR}" \
		--docdir="${DOCSDIR}" \
		--pkgconfigdir="${PREFIX}/libdata/pkgconfig" \
		--disable-static \
		--disable-libcelt \
		--enable-shared \
		--enable-pic \
		--enable-gpl \
		--disable-avresample \
		--cc="${CC}" \
		--cxx="${CXX}" \
		--disable-avdevice \
		--disable-filters \
		--disable-programs \
		--disable-network \
		--disable-avfilter \
		--disable-postproc \
		--disable-doc \
		--disable-ffplay \
		--disable-ffprobe \
		--disable-ffserver \
		--disable-sdl

DOC_FILES=	Changelog CREDITS INSTALL.md LICENSE.md MAINTAINERS \
		README.md RELEASE_NOTES
# under doc subdirectory
DOC_DOCFILES=	APIchanges *.txt
PORTDOCS=	*

.include <bsd.port.options.mk>

post-install:
	(cd ${WRKSRC} && ${COPYTREE_SHARE} \
		"${DOC_FILES}" ${STAGEDIR}${DOCSDIR})
	(cd ${WRKSRC}/doc && ${COPYTREE_SHARE} \
		"${DOC_DOCFILES}" ${STAGEDIR}${DOCSDIR})

.include <bsd.port.mk>
