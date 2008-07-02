LIBC_STYLE=uclibc
TARGET_ARCH=armeb
TARGET_OS=linux-uclibc

LIBSTDC++_VERSION=6.0.8
LIBNSL_VERSION=0.9.28

GETTEXT_NLS=enable
NO_BUILTIN_MATH=true

GNU_TARGET_NAME=$(TARGET_ARCH)-linux

CROSS_CONFIGURATION_GCC_VERSION=4.1.2
CROSS_CONFIGURATION_UCLIBC_VERSION=0.9.28.2
BUILDROOT_GCC=$(CROSS_CONFIGURATION_GCC_VERSION)
UCLIBC-OPT_VERSION=$(CROSS_CONFIGURATION_UCLIBC_VERSION)

ifeq ($(HOST_MACHINE),armv5teb)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(GNU_TARGET_NAME)
TARGET_CROSS=/opt/bin/
TARGET_LIBDIR=/opt/lib
TARGET_INCDIR=/opt/include
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS=-I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
else
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_UCLIBC=uclibc-$(CROSS_CONFIGURATION_UCLIBC_VERSION)
CROSS_CONFIGURATION=$(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_UCLIBC)
#TARGET_CROSS_TOP = $(shell cd $(BASE_DIR)/../..; pwd)/openwrt/staging_dir/toolchain-armeb_gcc4.1.2
TARGET_CROSS_TOP = $(shell cd $(BASE_DIR)/../..; pwd)/releases/openwrt-kamikaze_7.09/staging_dir_armeb
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(TARGET_ARCH)-$(TARGET_OS)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/lib
TARGET_INCDIR = $(TARGET_CROSS_TOP)/include
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
endif
