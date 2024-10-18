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
OPTIONS_DEFINE=	AMR_NB AMR_WB ASM ASS BS2B CACA CDIO \
		DC1394 DEBUG DOCS FDK_AAC FLITE \
		FONTCONFIG FREETYPE FREI0R FRIBIDI GME GSM ICONV ILBC \
		KVAZAAR LADSPA LAME LIBBLURAY \
		LTO MODPLUG NETWORK NVENC OPENAL OPENCL OPENGL \
		OPENH264 OPENJPEG OPTIMIZED_CFLAGS OPUS \
		PULSEAUDIO RTCPU RUBBERBAND SMB SNAPPY \
		SOXR SPEEX SSH SVTHEVC SVTVP9 \
		TESSERACT THEORA TWOLAME V4L VAAPI VDPAU VIDSTAB \
		VO_AMRWBENC VORBIS VPX WEBP X264 X265 \
		XCB XVID XVIDEO ZIMG ZMQ ZVBI
# intel-media-sdk only for i386/amd64
OPTIONS_DEFINE_amd64=	MFX
OPTIONS_DEFINE_i386=	MFX

OPTIONS_DEFAULT=	ASM FREI0R GMP ICONV OPTIMIZED_CFLAGS \
			RTCPU VAAPI VDPAU X264

# i386 is too register-starved for LTO (PR257124)
OPTIONS_EXCLUDE_i386=	LTO

OPTIONS_RADIO=	RTMP SSL
OPTIONS_RADIO_RTMP=	GCRYPT GMP
OPTIONS_RADIO_SSL=	GNUTLS OPENSSL
OPTIONS_GROUP=	LICENSE
OPTIONS_GROUP_LICENSE=	GPL3 NONFREE

ASS_DESC=	Subtitles rendering via libass
BS2B_DESC=	Bauer Stereophonic-to-Binaural filter
CHROMAPRINT_DESC=	Audio fingerprinting with chromaprint
DC1394_DESC=	IIDC-1394 grabbing using libdc1394
FDK_AAC_DESC=	AAC audio encoding via Fraunhofer FDK
FLITE_DESC=	Voice synthesis support via libflite
GME_DESC=	Game Music Emu demuxer
GPL3_DESC=	Allow (L)GPL version 3 code(cs)
ILBC_DESC=	Internet Low Bit Rate codec
KVAZAAR_DESC=	H.265 video codec support via Kvazaar
LICENSE_DESC=	Licensing options
MFX_DESC=	Intel MediaSDK (aka Quick Sync Video)
NETWORK_DESC=	Networking support
NONFREE_DESC=	Allow use of nonfree code
NVENC_DESC=	NVIDIA decoder/encoder with CUDA support
OPENH264_DESC=	H.264 video codec support via OpenH264
RUBBERBAND_DESC=Time-stretching and pitch-shifting with librubberband
RTCPU_DESC=	Detect CPU capabilities at runtime
RTMP_DESC=	RTMP(T)E protocol support
SVTHEVC_DESC=	HEVC encoding via SVT-HEVC
SVTVP9_DESC=	VP9 encoding via SVT-VP9
TESSERACT_DESC=	Optical Character Recognition via Tesseract
THEORA_DESC=	Encoding support for theora via libtheora
VIDSTAB_DESC=	Video stabilization filter
XCB_DESC=	X11 grabbing using XCB
XVID_DESC=	Encoding support for MPEG-4 ASP via libxvid
ZIMG_DESC=	"z" library video scaling filter
ZMQ_DESC=	Message passing via libzmq${ZMQ_VERSION}
ZVBI_DESC=	Teletext support via libzvbi

OPTIONS_SUB=	yes

# Opencore AMR NB
AMR_NB_LIB_DEPENDS=	libopencore-amrnb.so:audio/opencore-amr
AMR_NB_CONFIGURE_ENABLE=	libopencore-amrnb
AMR_NB_IMPLIES=		GPL3

# Opencore AMR WB
AMR_WB_LIB_DEPENDS=	libopencore-amrwb.so:audio/opencore-amr
AMR_WB_CONFIGURE_ENABLE=	libopencore-amrwb
AMR_WB_IMPLIES=		GPL3

# asm support
ASM_CONFIGURE_ENABLE=	asm

# ass
ASS_LIB_DEPENDS=	libass.so:multimedia/libass
ASS_CONFIGURE_ENABLE=	libass

# bs2b
BS2B_LIB_DEPENDS=	libbs2b.so:audio/libbs2b
BS2B_CONFIGURE_ENABLE=	libbs2b

# caca
CACA_LIB_DEPENDS=	libcaca.so:graphics/libcaca
CACA_CONFIGURE_ENABLE=	libcaca

# cdio
CDIO_LIB_DEPENDS=	libcdio_paranoia.so:sysutils/libcdio-paranoia
CDIO_CONFIGURE_ENABLE=	libcdio

# chromaprint
CHROMAPRINT_BROKEN=		Dependency loop
CHROMAPRINT_LIB_DEPENDS=	libchromaprint.so:audio/chromaprint
CHROMAPRINT_CONFIGURE_ENABLE=	chromaprint

# dc1394
DC1394_LIB_DEPENDS=	libdc1394.so:multimedia/libdc1394
DC1394_CONFIGURE_ENABLE=	libdc1394

# debugging
DEBUG_CONFIGURE_ON=	--disable-stripping
DEBUG_CONFIGURE_OFF=	--disable-debug

# docs
DOCS_BUILD_DEPENDS=	texi2html:textproc/texi2html
DOCS_CONFIGURE_ENABLE=	htmlpages
DOCS_BINARY_ALIAS=	makeinfo=${FALSE} # force texi2html

# fdk_aac
FDK_AAC_LIB_DEPENDS=	libfdk-aac.so:audio/fdk-aac
FDK_AAC_CONFIGURE_ENABLE=	libfdk-aac
FDK_AAC_IMPLIES=	NONFREE

# flite
FLITE_LIB_DEPENDS=	libflite.so:audio/flite
FLITE_CONFIGURE_ENABLE=	libflite

# fontconfig
FONTCONFIG_LIB_DEPENDS=	libfontconfig.so:x11-fonts/fontconfig
FONTCONFIG_CONFIGURE_ENABLE=	fontconfig

# freetype
FREETYPE_LIB_DEPENDS=	libfreetype.so:print/freetype2
FREETYPE_CONFIGURE_ENABLE=	libfreetype

# frei0r
FREI0R_BUILD_DEPENDS=	${LOCALBASE}/include/frei0r.h:graphics/frei0r
FREI0R_CONFIGURE_ENABLE=	frei0r

# fribidi
FRIBIDI_LIB_DEPENDS=	libfribidi.so:converters/fribidi
FRIBIDI_CONFIGURE_ENABLE=	libfribidi

# gcrypt
GCRYPT_LIB_DEPENDS=	libgcrypt.so:security/libgcrypt
GCRYPT_CONFIGURE_ENABLE=	gcrypt

# gnutls
GNUTLS_LIB_DEPENDS=	libgnutls.so:security/gnutls
GNUTLS_CONFIGURE_ENABLE=	gnutls

# gme
GME_LIB_DEPENDS=	libgme.so:audio/libgme
GME_CONFIGURE_ENABLE=	libgme

# gmp
GMP_LIB_DEPENDS=	libgmp.so:math/gmp
GMP_CONFIGURE_ENABLE=	gmp
GMP_IMPLIES=		GPL3

# gsm
GSM_LIB_DEPENDS=	libgsm.so:audio/gsm
GSM_CONFIGURE_ENABLE=	libgsm

# iconv
ICONV_USES=	iconv
ICONV_CONFIGURE_ENABLE=	iconv

# ilbc
ILBC_LIB_DEPENDS=	libilbc.so:net/libilbc
ILBC_CONFIGURE_ENABLE=	libilbc

# kvazaar
KVAZAAR_LIB_DEPENDS=	libkvazaar.so:multimedia/kvazaar
KVAZAAR_CONFIGURE_ENABLE=	libkvazaar

# ladspa
LADSPA_BUILD_DEPENDS=	${LOCALBASE}/include/ladspa.h:audio/ladspa
LADSPA_RUN_DEPENDS=	${LOCALBASE}/lib/ladspa/amp.so:audio/ladspa
LADSPA_CONFIGURE_ENABLE=	ladspa

# lame
LAME_LIB_DEPENDS=	libmp3lame.so:audio/lame
LAME_CONFIGURE_ENABLE=	libmp3lame

# libbluray
LIBBLURAY_LIB_DEPENDS=	libbluray.so:multimedia/libbluray
LIBBLURAY_CONFIGURE_ENABLE=	libbluray

# lto
LTO_CONFIGURE_ENABLE=	lto

# libv4l
V4L_BUILD_DEPENDS=	v4l_compat>0:multimedia/v4l_compat
V4L_LIB_DEPENDS=	libv4l2.so:multimedia/libv4l
V4L_CONFIGURE_ENABLE=	libv4l2
V4L_CONFIGURE_OFF=		--disable-indev=v4l2 \
				--disable-outdev=v4l2

# mfx
MFX_LIB_DEPENDS=	libmfx.so:multimedia/intel-media-sdk
MFX_CONFIGURE_ENABLE=	libmfx

# modplug
MODPLUG_LIB_DEPENDS=	libmodplug.so:audio/libmodplug
MODPLUG_CONFIGURE_ENABLE=	libmodplug

# network
NETWORK_CONFIGURE_ENABLE=	network

# nvenc
NVENC_BUILD_DEPENDS=	${LOCALBASE}/include/ffnvcodec/nvEncodeAPI.h:multimedia/ffnvcodec-headers
NVENC_CONFIGURE_ENABLE=	nvenc

# OpenAL
OPENAL_LIB_DEPENDS=	libopenal.so:audio/openal-soft
OPENAL_CONFIGURE_ENABLE=	openal

# opencl
OPENCL_BUILD_DEPENDS=	${LOCALBASE}/include/CL/opencl.h:devel/opencl
OPENCL_LIB_DEPENDS=	libOpenCL.so:devel/ocl-icd
OPENCL_CONFIGURE_ENABLE=	opencl

# opengl
OPENGL_USES=		gl
OPENGL_USE=		GL=gl
OPENGL_CONFIGURE_ENABLE=	opengl

# openh264
OPENH264_LIB_DEPENDS=	libopenh264.so:multimedia/openh264
OPENH264_CONFIGURE_ENABLE=	libopenh264

# openjpeg
OPENJPEG_LIB_DEPENDS=	libopenjp2.so:graphics/openjpeg
OPENJPEG_CONFIGURE_ENABLE=	libopenjpeg

# openssl/libtls
OPENSSL_USES=		ssl
OPENSSL_CONFIGURE_ENABLE=	${"${SSL_DEFAULT:Mlibressl*}"!="":?libtls:openssl}
OPENSSL_IMPLIES=	NONFREE

# optimizations
OPTIMIZED_CFLAGS_CONFIGURE_ENABLE=	optimizations

# opus
OPUS_LIB_DEPENDS=	libopus.so:audio/opus
OPUS_CONFIGURE_ENABLE=	libopus

# pulseaudio
PULSEAUDIO_LIB_DEPENDS=	libpulse.so:audio/pulseaudio
PULSEAUDIO_CONFIGURE_ENABLE=	libpulse

# rubberband
RUBBERBAND_LIB_DEPENDS=	librubberband.so:audio/rubberband
RUBBERBAND_CONFIGURE_ENABLE=	librubberband

# rtcpu
RTCPU_CONFIGURE_ENABLE=	runtime-cpudetect

# smbclient
SMB_USES=		samba:lib
SMB_CONFIGURE_ENABLE=	libsmbclient
SMB_IMPLIES=		GPL3

# snappy
SNAPPY_LIB_DEPENDS=	libsnappy.so:archivers/snappy
SNAPPY_CONFIGURE_ENABLE=	libsnappy

# soxr
SOXR_LIB_DEPENDS=	libsoxr.so:audio/libsoxr
SOXR_CONFIGURE_ENABLE=	libsoxr

# speex
SPEEX_LIB_DEPENDS=	libspeex.so:audio/speex
SPEEX_CONFIGURE_ENABLE=	libspeex

# ssh
SSH_LIB_DEPENDS=	libssh.so:security/libssh
SSH_CONFIGURE_ENABLE=	libssh

# svt-hevc
SVTHEVC_LIB_DEPENDS=	libSvtHevcEnc.so:multimedia/svt-hevc
SVTHEVC_CONFIGURE_ON=	--enable-libsvthevc
SVTHEVC_PATCH_SITES=	https://github.com/OpenVisualCloud/SVT-HEVC/raw/v1.5.0-3-g86b58f77/ffmpeg_plugin/:svthevc
SVTHEVC_PATCHFILES=	0001-lavc-svt_hevc-add-libsvt-hevc-encoder-wrapper.patch:-p1:svthevc \
			0002-doc-Add-libsvt_hevc-encoder-docs.patch:-p1:svthevc
.if make(makesum)
.MAKEFLAGS:		WITH+=SVTHEVC
.endif

# svt-vp9
SVTVP9_LIB_DEPENDS=	libSvtVp9Enc.so:multimedia/svt-vp9
SVTVP9_CONFIGURE_ON=	--enable-libsvtvp9
SVTVP9_PATCH_SITES=	https://github.com/OpenVisualCloud/SVT-VP9/raw/v0.3.0-4-gabd5c59/ffmpeg_plugin/:svtvp9
SVTVP9_PATCHFILES=	master-0001-Add-ability-for-ffmpeg-to-run-svt-vp9.patch:-p1:svtvp9
.if make(makesum)
.MAKEFLAGS:		WITH+=SVTVP9
.endif

# tesseract
TESSERACT_LIB_DEPENDS=	libtesseract.so:graphics/tesseract
TESSERACT_CONFIGURE_ENABLE=	libtesseract

# theora
THEORA_LIB_DEPENDS=	libtheora.so:multimedia/libtheora
THEORA_CONFIGURE_ENABLE=	libtheora

# twolame
TWOLAME_LIB_DEPENDS=	libtwolame.so:audio/twolame
TWOLAME_CONFIGURE_ENABLE=	libtwolame

# vaapi
VAAPI_LIB_DEPENDS=	libva.so:multimedia/libva
VAAPI_CONFIGURE_ENABLE=	vaapi

# vdpau
VDPAU_USES=		xorg
VDPAU_USE=		XORG=x11
VDPAU_LIB_DEPENDS=	libvdpau.so:multimedia/libvdpau
VDPAU_CONFIGURE_ENABLE=	vdpau

# vo-amrwbenc
VO_AMRWBENC_LIB_DEPENDS=	libvo-amrwbenc.so:audio/vo-amrwbenc
VO_AMRWBENC_CONFIGURE_ENABLE=	libvo-amrwbenc
VO_AMRWBENC_IMPLIES=	GPL3

# vid.stab
VIDSTAB_LIB_DEPENDS=	libvidstab.so:multimedia/vid.stab
VIDSTAB_CONFIGURE_ENABLE=	libvidstab

# vorbis
VORBIS_LIB_DEPENDS=	libvorbisenc.so:audio/libvorbis
VORBIS_CONFIGURE_ENABLE=	libvorbis

# vp8
VPX_LIB_DEPENDS=	libvpx.so:multimedia/libvpx
VPX_CONFIGURE_ENABLE=	libvpx

# webp
WEBP_LIB_DEPENDS=	libwebp.so:graphics/webp
WEBP_CONFIGURE_ENABLE=	libwebp

# x264
X264_LIB_DEPENDS=	libx264.so:multimedia/libx264
X264_CONFIGURE_ENABLE=	libx264

# x265
X265_LIB_DEPENDS=	libx265.so:multimedia/x265
X265_CONFIGURE_ENABLE=	libx265

# xcb
XCB_USES=		xorg
XCB_USE=		XORG=xcb
XCB_CONFIGURE_ENABLE=	libxcb

# xvid
XVID_LIB_DEPENDS=	libxvidcore.so:multimedia/xvid
XVID_CONFIGURE_ENABLE=	libxvid

# xv
XVIDEO_USES=		xorg
XVIDEO_USE=		XORG=x11,xext,xv
XVIDEO_CONFIGURE_OFF=	--disable-outdev=xv

# zimg
ZIMG_LIB_DEPENDS=	libzimg.so:graphics/sekrit-twc-zimg
ZIMG_CONFIGURE_ENABLE=	libzimg

# zmq
ZMQ_LIB_DEPENDS=	libzmq.so:net/libzmq${ZMQ_VERSION}
ZMQ_CONFIGURE_ENABLE=	libzmq
ZMQ_VERSION?=		4

# zvbi
ZVBI_LIB_DEPENDS=	libzvbi.so:devel/libzvbi
ZVBI_CONFIGURE_ENABLE=	libzvbi

# License knobs
GPL3_CONFIGURE_ENABLE=	version3
GPL3_VARS=		LICENSE="GPLv3+ LGPL3+"
LICENSE_FILE_GPLv3+ =	${WRKSRC}/COPYING.GPLv3
LICENSE_FILE_LGPL3+ =	${WRKSRC}/COPYING.LGPLv3

NONFREE_CONFIGURE_ENABLE=nonfree

INSTALL_TARGET=	install-progs install-doc install-data \
		install-libs install-headers

DATADIR=	${PREFIX}/share/${PORTNAME}${PKGNAMESUFFIX}
DOCSDIR=	${PREFIX}/share/doc/${PORTNAME}${PKGNAMESUFFIX}
MAKE_ENV+=	V=1
LDFLAGS_aarch64=-Wl,-z,notext
LDFLAGS_armv6=	-Wl,-z,notext
LDFLAGS_armv7=	-Wl,-z,notext
LDFLAGS_i386=	-Wl,-z,notext

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
		--enable-avresample \
		--cc="${CC}" \
		--cxx="${CXX}"

DOC_FILES=	Changelog CREDITS INSTALL.md LICENSE.md MAINTAINERS \
		README.md RELEASE_NOTES
# under doc subdirectory
DOC_DOCFILES=	APIchanges *.txt
PORTDOCS=	*

.include <bsd.port.options.mk>

.if ${PORT_OPTIONS:MNONFREE}
LICENSE+=	NONFREE
LICENSE_COMB=	multi
LICENSE_NAME_NONFREE=	Non free code
LICENSE_TEXT_NONFREE=	enabling OPENSSL or FDK_AAC restricts redistribution
LICENSE_PERMS_NONFREE=	auto-accept
.endif

post-install:
	(cd ${WRKSRC} && ${COPYTREE_SHARE} \
		"${DOC_FILES}" ${STAGEDIR}${DOCSDIR})
	(cd ${WRKSRC}/doc && ${COPYTREE_SHARE} \
		"${DOC_DOCFILES}" ${STAGEDIR}${DOCSDIR})

.include <bsd.port.mk>
