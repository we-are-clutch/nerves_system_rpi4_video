################################################################################
#
# rpicam-apps
#
################################################################################

RPICAM_APPS_VERSION = 1.4.1
RPICAM_APPS_SITE = $(call github,raspberrypi,rpicam-apps,v$(RPICAM_APPS_VERSION))
RPICAM_APPS_LICENSE = BSD-2-Clause
RPICAM_APPS_LICENSE_FILES = license.txt
RPICAM_APPS_DEPENDENCIES = \
	host-pkgconf \
	boost \
	jpeg \
	libcamera \
	libexif \
	libpng \
	tiff

RPICAM_APPS_CONF_OPTS = \
	-DENABLE_COMPILE_FLAGS_FOR_TARGET=disabled \
	-DENABLE_OPENCV=0 \
	-DENABLE_TFLITE=0

ifeq ($(BR2_PACKAGE_LIBDRM),y)
RPICAM_APPS_DEPENDENCIES += libdrm
RPICAM_APPS_CONF_OPTS += -DENABLE_DRM=1
else
RPICAM_APPS_CONF_OPTS += -DENABLE_DRM=0
endif

ifeq ($(BR2_PACKAGE_FFMPEG)$(BR2_PACKAGE_LIBDRM),yy)
RPICAM_APPS_DEPENDENCIES += ffmpeg libdrm
RPICAM_APPS_CONF_OPTS += -DENABLE_LIBAV=1
else
RPICAM_APPS_CONF_OPTS += -DENABLE_LIBAV=0
endif

ifeq ($(BR2_PACKAGE_XORG7),y)
RPICAM_APPS_DEPENDENCIES += \
	$(if $(BR2_PACKAGE_LIBEPOXY),libepoxy) \
	$(if $(BR2_PACKAGE_XLIB_LIBX11),xlib_libX11)
RPICAM_APPS_CONF_OPTS += -DENABLE_X11=1
else
RPICAM_APPS_CONF_OPTS += -DENABLE_X11=0
endif

ifeq ($(BR2_PACKAGE_QT5),y)
RPICAM_APPS_DEPENDENCIES += qt5base
RPICAM_APPS_CONF_OPTS += -DENABLE_QT=1
else
RPICAM_APPS_CONF_OPTS += -DENABLE_QT=0
endif

ifeq ($(BR2_TOOLCHAIN_HAS_LIBATOMIC),y)
RPICAM_APPS_CONF_OPTS += -DCMAKE_EXE_LINKER_FLAGS=-latomic
endif

$(eval $(cmake-package))
