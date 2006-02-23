# Makefile for Optware packages
#
# Copyright (C) 2004 by Rod Whitby <unslung@gmail.com>
# Copyright (C) 2004 by Oleg I. Vdovikin <oleg@cs.msu.su>
# Copyright (C) 2001-2004 Erik Andersen <andersen@codepoet.org>
# Copyright (C) 2002 by Tim Riker <Tim@Rikers.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

# Options are "nslu2", "wl500g", "ds101", "ds101g", "mss"  and "nas100d"
OPTWARE_TARGET ?= nslu2

HOST_MACHINE:=$(shell uname -m | sed -e 's/i[3-9]86/i386/' )

# Add new packages here - make sure you have tested cross compilation.
# When they have been tested, they will be promoted and uploaded.
#
CROSS_PACKAGES_READY_FOR_TESTING = \
	ruby \
	librsync \
	py-curl \
	py-rdiff-backup \
	py-setuptools \
	py-formencode \
	py-json \
	py-simplejson \
	py-testgears \
	py-turbogears \
	py-docutils \
	py-scgi \

# No provision is made in the cdrtools build for cross-compilation.  It
# always uses shell calls to uname to determine the target arch.
# A web search shows some interest (and effort) in making cdrtools 
# cross-compile, but no apparent success.
NATIVE_PACKAGES_READY_FOR_TESTING = cdrtools

COMMON_CROSS_PACKAGES = \
	abook adns alac-decoder adduser antinat appweb asterisk asterisk-sounds \
	apache apr apr-util atftp atk audiofile autoconf automake \
	bash bc bzip2 bind bip bitchx bitlbee busybox byrequest bzflag \
	bluez-libs bluez-utils bluez-hcidump \
	ccxstream chillispot coreutils cpio cron cdargs cherokee chrpath classpath clamav clips \
	ctorrent cups ctags cyrus-sasl \
	denyhosts dev-pts dict digitemp distcc dokuwiki dhcp diffutils dnsmasq dovecot dropbear \
	e2fsprogs e2tools eaccelerator ed esmtp erlang esound eggdrop expat \
	fetchmail file findutils flex ftpd-topfield ffmpeg ficy fixesext flac \
	fontconfig freeradius freetds freetype \
	gconv-modules getmail gdchart ghostscript gdb gdbm grep groff gzip \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	git-core gnutls gtk \
	hdparm hexcurse hnb hpijs \
	ice imagemagick imap inetutils iperf ipkg-web ipython ircd-hybrid ivorbis-tools \
	jabber jamvm jikes jove joe \
	knock \
	lame less libcurl libdb libftdi libnsl libol libpcap libstdc++ libxml2 logrotate lynx lzo \
	ldconfig libart libbt libdvb libdvdread libesmtp libevent \
	libgc libgcrypt libgd libghttp libgpg-error libid3tag libjpeg libmad libogg libosip2 \
	libpng libtasn1 libtiff libtool libusb libvorbis libvorbisidec libxslt lua \
	m4 make mc miau minicom mktemp modutils monit mt-daapd mysql \
	madplay man man-pages mdadm mediawiki metalog microperl monotone mod-fastcgi mod-python mrtg \
	nagios-plugins neon net-snmp nano ncftp ncurses noip net-tools netio nfs-server nfs-utils \
	nget nload nrpe ntop ntpclient nylon \
	opencdk oww openssh openssl openvpn \
	pango patch php php-thttpd procps proftpd psutils puppy python py-bittorrent \
	php-apache phpmyadmin pkgconfig popt poptop portmap postgresql procmail pwgen \
	py-bluez py-cheetah py-cherrypy py-clips \
	py-celementtree py-cherrytemplate \
	py-elementtree py-kid py-sqlobject \
	py-gdchart2 py-gd py-pil py-mssql \
	py-roundup py-serial py-simpy py-soappy \
	py-sqlite py-mercurial py-moin py-mx-base py-mysql py-psycopg py-xml \
	qemu qemu-libc-i386 quagga  \
	rcs recordext renderext rrdtool \
	rdate readline rsync \
	samba sdl ser siproxd sm snownews \
	screen sed smartmontools sqlite sqlite2 strace syslog-ng \
	sqsh stunnel streamripper sudo svn \
	sysstat \
	taged tcl tcpwrappers tftp-hpa \
	tar tcpdump termcap textutils thttpd \
	tin torrent transcode tsocks \
	ttf-bitstream-vera \
	ufsd unfs3 units \
	unzip usbutils \
	vblade vdr-mediamvp vsftpd vte vorbis-tools \
	vim \
	w3cam webalizer wget-ssl wizd \
	wakelan which whois wpa-supplicant \
	x11 xau xauth xaw xchat xcursor xdmcp xdpyinfo xext xextensions xfixes xft xinetd \
	xmail xmu xpdf xpm xproto xrender xt xterm xtrans xtst xvid \
	zip zlib \

# Packages that *only* work for nslu2 - do not just put new packages here.
NSLU2_SPECIFIC_PACKAGES = upslug2 unslung-feeds unslung-devel crosstool-native

# Packages that do not work for nslu2.
NSLU2_BROKEN_PACKAGES = 

# autoconf compiles in a path to m4, and also wants to run it at that path.
# bison cross-compiles, but can't build flex.  native-compiled bison is fine.
# bogofilter's configure wants to run some small executables
# cyrus-imapd fails with "impossible constraint in `asm'" when cross-compiled
# emacs and xemacs needs to run themselves to dump an image, so they probably will never cross-compile.
# ocaml does not use gnu configure, cross build may work by some more tweaking, build native first
# openldap runs its own binaries at compile-time and expects them to have same byte-order as target
# perl's Configure is not cross-compile "friendly"
# perl modules depend on perl
# rsnapshot depends on perl
# squid probably will build cross - may just need some configure work
# stow depends on perl
NSLU2_NATIVE_PACKAGES = \
	autoconf \
	bison \
	bogofilter \
	cyrus-imapd \
	emacs \
	xemacs \
	hugs \
	mzscheme \
        ocaml \
	openldap \
	perl perl-db-file perl-dbi perl-digest-hmac perl-digest-sha1 \
	perl-date-manip \
	perl-appconfig perl-cgi-application \
	perl-html-parser perl-html-tagset perl-html-template \
	perl-mime-base64 perl-net-dns perl-net-ident \
	perl-spamassassin perl-storable perl-time-hires \
	perl-template-toolkit \
	perl-term-readkey \
	postfix \
	rsnapshot \
	squid \
	stow \
	w3m \
        xmail \

# Packages that *only* work for wl500g - do not just put new packages here.
WL500G_SPECIFIC_PACKAGES = wiley-feeds

# Packages that do not work for wl500g.
WL500G_BROKEN_PACKAGES = \
	appweb asterisk atk \
	bitlbee bzflag \
	cdargs cherokee cogito ctorrent cvs \
	dict \
	elinks erlang \
	ficy freetds \
	gawk gettext giftcurs git-core glib gnupg gtk \
	hnb \
	ice iperf iptables ivorbis-tools \
	jabber jamvm jikes \
	ldconfig libdvb libgc libstdc++ libsigc++ libtiff libtorrent libvorbisidec lsof \
	mdadm metalog mod-fastcgi mod-python monotone mtr mutt \
	nagios-plugins nail nfs-server nfs-utils nget nload nmap nrpe ntp \
	pango pcre py-bluez py-cheetah py-clips py-celementtree py-gdchart2 py-gd py-pil \
	py-mercurial py-mssql py-sqlite py-mx-base py-mysql py-psycopg py-xml \
	qemu qemu-libc-i386 \
	rtorrent \
	sdl ser sm snownews sqsh sudo \
	transcode \
	unrar \
	vte \
	wget-ssl \
	x11 xauth xaw xchat xcursor xdpyinfo xext xfixes xft xmu xpdf xpm xrender xt xterm xtst \

# Packages that *only* work for mss - do not just put new packages here.
MSS_SPECIFIC_PACKAGES = 

# Packages that do not work for mss.
MSS_BROKEN_PACKAGES = \
	apache apr-util asterisk \
	bitlbee \
	clamav \
	erlang \
	ivorbis-tools \
	jamvm \
	ldconfig libvorbisidec \
	mod-fastcgi mod-python monotone \
	php-apache \
	qemu qemu-libc-i386 \
	svn \
	transcode \

# Packages that *only* work for ds101 - do not just put new packages here.
DS101_SPECIFIC_PACKAGES = 

# Packages that do not work for ds101.
DS101_BROKEN_PACKAGES = \
	apache apr-util \
	cyrus-sasl \
	imagemagick \
	mod-fastcgi mod-python monotone \
	php-apache \
	qemu qemu-libc-i386 \
	svn \

# Packages that *only* work for ds101g+ - do not just put new packages here.
DS101G_SPECIFIC_PACKAGES = 

# Packages that do not work for ds101g+.
DS101G_BROKEN_PACKAGES = \
	apache apr-util appweb asterisk \
	bitlbee \
	cherokee clamav \
	eaccelerator \
	flac \
	gnutls \
	ivorbis-tools \
	ldconfig libgcrypt libvorbisidec \
	ntop \
	opencdk \
	php php-apache portmap \
	qemu qemu-libc-i386 \
	rsync \
	ser \

# Packages that *only* work for nas100d - do not just put new packages here.
NAS100D_SPECIFIC_PACKAGES = ipkg

# Packages that do not work for nas100d.
NAS100D_BROKEN_PACKAGES = 

# dump: is broken in several ways. It is using the host's e2fsprogs
# includes.  It is also misconfigured: --includedir and --libdir as
# arguments to configure affect installation directories, not where
# things get searched for.  I think it would be best to rewrite this
# .mk from scratch, following template.mk.
# 
# libao - has runtime trouble
# parted - does not work on the slug, even when compiled natively
# lumikki - does not install to /opt
# mini_httpd - Underscores shouldn't appear in package names: please rename
#              this package to "minihttpd", or to "mini-httpd". In the latter
#              case the .mk file and the variables in it must also be renamed.
PACKAGES_THAT_NEED_TO_BE_FIXED = dump libao nethack scponly gkrellm parted lumikki mini_httpd


# libiconv - has been made obsolete by gconv-modules
# git - has been made obsolete by git-core
# Metalog - has been made obsolete by syslog-ng
PACKAGES_OBSOLETED = libiconv git metalog

ifeq ($(OPTWARE_TARGET),nslu2)
ifeq ($(HOST_MACHINE),armv5b)
PACKAGES = $(NSLU2_NATIVE_PACKAGES)
PACKAGES_READY_FOR_TESTING = $(NATIVE_PACKAGES_READY_FOR_TESTING)
# when native building on unslung, it's important to have a working awk 
# in the path ahead of busybox's broken one.
PATH=/opt/bin:/usr/bin:/bin
else
PACKAGES = $(filter-out $(NSLU2_NATIVE_PACKAGES) $(NSLU2_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(NSLU2_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
endif
TARGET_ARCH=armeb
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),wl500g)
PACKAGES = $(filter-out $(WL500G_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(WL500G_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=mipsel
TARGET_OS=linux-uclibc
endif

ifeq ($(OPTWARE_TARGET),mss)
PACKAGES = $(filter-out $(MSS_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(MSS_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=mipsel
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),ds101)
PACKAGES = $(filter-out $(DS101_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(DS101_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=armeb
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),ds101g)
PACKAGES = $(filter-out $(DS101G_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(DS101G_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=powerpc
TARGET_OS=linux
endif

ifeq ($(OPTWARE_TARGET),nas100d)
PACKAGES = $(filter-out $(NAS100D_BROKEN_PACKAGES), $(COMMON_CROSS_PACKAGES) $(NAS100D_SPECIFIC_PACKAGES))
PACKAGES_READY_FOR_TESTING = $(CROSS_PACKAGES_READY_FOR_TESTING)
TARGET_ARCH=armeb
TARGET_OS=linux
endif

all: directories toolchain packages

testing:
	$(MAKE) PACKAGES="$(PACKAGES_READY_FOR_TESTING)" all
	$(PERL) -w scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) --objdump-path=$(TARGET_CROSS)objdump --base-dir=$(BASE_DIR) $(patsubst %,$(BUILD_DIR)/%*.ipk,$(PACKAGES_READY_FOR_TESTING))

# Common tools which may need overriding
CVS=cvs
SUDO=sudo
WGET=wget --passive-ftp
PERL=perl

# Directory location definitions
BASE_DIR:=$(shell pwd)
SOURCE_DIR=$(BASE_DIR)/sources
DL_DIR=$(BASE_DIR)/downloads
BUILD_DIR=$(BASE_DIR)/builds
STAGING_DIR=$(BASE_DIR)/staging
STAGING_PREFIX=$(STAGING_DIR)/opt
TOOL_BUILD_DIR=$(BASE_DIR)/toolchain
PACKAGE_DIR=$(BASE_DIR)/packages
export TMPDIR=$(BASE_DIR)/tmp

TARGET_OPTIMIZATION=-O2 #-mtune=xscale -march=armv4 -Wa,-mcpu=xscale
TARGET_DEBUGGING= #-g

ifeq ($(OPTWARE_TARGET),nslu2)
CROSS_CONFIGURATION_GCC_VERSION=3.3.5
CROSS_CONFIGURATION_GLIBC_VERSION=2.2.5
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
ifeq ($(HOST_MACHINE),armv5b)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = armv5b-softfloat-linux
GNU_TARGET_NAME = armv5b-softfloat-linux
TARGET_CROSS = /opt/$(TARGET_ARCH)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = /opt/$(TARGET_ARCH)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS=-I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
else
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = armv5b-softfloat-linux
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: crosstool
endif
endif

ifeq ($(OPTWARE_TARGET),wl500g)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = mipsel-linux
CROSS_CONFIGURATION = hndtools-mipsel-uclibc
TARGET_CROSS = /opt/brcm/$(CROSS_CONFIGURATION)/bin/mipsel-uclibc-
TARGET_LIBDIR = /opt/brcm/$(CROSS_CONFIGURATION)/lib
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
endif

ifeq ($(OPTWARE_TARGET),mss)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = mipsel-linux
CROSS_CONFIGURATION = hndtools-mipsel-linux
TARGET_CROSS = /opt/brcm/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = /opt/brcm/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe 
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
endif

ifeq ($(OPTWARE_TARGET),ds101)
CROSS_CONFIGURATION_GCC_VERSION=3.3.5
CROSS_CONFIGURATION_GLIBC_VERSION=2.2.5
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = armv5b-softfloat-linux
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: crosstool
endif

ifeq ($(OPTWARE_TARGET),ds101g)
CROSS_CONFIGURATION_GCC_VERSION=3.3.4
CROSS_CONFIGURATION_GLIBC_VERSION=2.3.3
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = powerpc-603e-linux
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: crosstool
endif

ifeq ($(OPTWARE_TARGET),nas100d)
CROSS_CONFIGURATION_GCC_VERSION=3.3.5
CROSS_CONFIGURATION_GLIBC_VERSION=2.2.5
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_GLIBC=glibc-$(CROSS_CONFIGURATION_GLIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_GLIBC)
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = armv5b-softfloat-linux
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: crosstool
endif


TARGET_CXX=$(TARGET_CROSS)g++
TARGET_CC=$(TARGET_CROSS)gcc
TARGET_CPP="$(TARGET_CC) -E"
TARGET_LD=$(TARGET_CROSS)ld
TARGET_AR=$(TARGET_CROSS)ar
TARGET_AS=$(TARGET_CROSS)as
TARGET_NM=$(TARGET_CROSS)nm
TARGET_RANLIB=$(TARGET_CROSS)ranlib
TARGET_STRIP=$(TARGET_CROSS)strip
TARGET_CONFIGURE_OPTS= \
	AR=$(TARGET_AR) \
	AS=$(TARGET_AS) \
	LD=$(TARGET_LD) \
	NM=$(TARGET_NM) \
	CC=$(TARGET_CC) \
	CPP=$(TARGET_CPP) \
	GCC=$(TARGET_CC) \
	CXX=$(TARGET_CXX) \
	RANLIB=$(TARGET_RANLIB) \
	STRIP=$(TARGET_STRIP)
TARGET_PATH=$(STAGING_PREFIX)/bin:$(STAGING_DIR)/bin:/opt/bin:/opt/sbin:/bin:/sbin:/usr/bin:/usr/sbin

STRIP_COMMAND=$(TARGET_STRIP) --remove-section=.comment --remove-section=.note --strip-unneeded

PATCH_LIBTOOL=sed -i \
	-e 's|^sys_lib_search_path_spec=.*|sys_lib_search_path_spec="$(TARGET_LIBDIR) $(STAGING_LIB_DIR)"|' \
	-e 's|^sys_lib_dlsearch_path_spec=.*|sys_lib_dlsearch_path_spec=""|'

STAGING_INCLUDE_DIR=$(STAGING_PREFIX)/include
STAGING_LIB_DIR=$(STAGING_PREFIX)/lib

STAGING_CPPFLAGS=$(TARGET_CFLAGS) -I$(STAGING_INCLUDE_DIR)
STAGING_LDFLAGS=$(TARGET_LDFLAGS) -L$(STAGING_LIB_DIR) -Wl,-rpath,/opt/lib -Wl,-rpath-link,$(STAGING_LIB_DIR)

# Clear these variables to remove assumptions
AR=
AS=
LD=
NM=
CC=
GCC=
CXX=
RANLIB=
STRIP=
LD_LIBRARY_PATH=

PACKAGES_CLEAN:=$(patsubst %,%-clean,$(PACKAGES))
PACKAGES_SOURCE:=$(patsubst %,%-source,$(PACKAGES))
PACKAGES_DIRCLEAN:=$(patsubst %,%-dirclean,$(PACKAGES))
PACKAGES_STAGE:=$(patsubst %,%-stage,$(PACKAGES))
PACKAGES_IPKG:=$(patsubst %,%-ipk,$(PACKAGES))

$(PACKAGES) : directories toolchain
$(PACKAGES_STAGE) %-stage : directories toolchain
$(PACKAGES_IPKG) %-ipk : directories toolchain ipkg-utils

.PHONY: index
index: $(PACKAGE_DIR)/Packages

$(PACKAGE_DIR)/Packages: $(BUILD_DIR)/*.ipk
	rsync -avr --delete $(BUILD_DIR)/*_$(TARGET_ARCH).ipk $(PACKAGE_DIR)/
	{ \
		cd $(PACKAGE_DIR); \
		$(IPKG_MAKE_INDEX) . > Packages; \
		gzip -c Packages > Packages.gz; \
	}
	@echo "ALL DONE."

packages: $(PACKAGES_IPKG)
	$(MAKE) index

.PHONY: all clean dirclean distclean directories packages source toolchain \
	autoclean \
	$(PACKAGES) $(PACKAGES_SOURCE) $(PACKAGES_DIRCLEAN) \
	$(PACKAGES_STAGE) $(PACKAGES_IPKG) \
	query-%

query-%:
	@echo $($(*))

include make/*.mk

directories: $(DL_DIR) $(BUILD_DIR) $(STAGING_DIR) $(STAGING_PREFIX) \
	$(STAGING_LIB_DIR) $(STAGING_INCLUDE_DIR) $(TOOL_BUILD_DIR) \
	$(PACKAGE_DIR) $(TMPDIR)

$(DL_DIR):
	mkdir $(DL_DIR)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(STAGING_DIR):
	mkdir $(STAGING_DIR)

$(STAGING_PREFIX):
	mkdir $(STAGING_PREFIX)

$(STAGING_LIB_DIR):
	mkdir $(STAGING_LIB_DIR)

$(STAGING_INCLUDE_DIR):
	mkdir $(STAGING_INCLUDE_DIR)

$(TOOL_BUILD_DIR):
	mkdir $(TOOL_BUILD_DIR)

$(PACKAGE_DIR):
	mkdir $(PACKAGE_DIR)

$(TMPDIR):
	mkdir $(TMPDIR)

source: $(PACKAGES_SOURCE)

check-packages:
	@$(PERL) -w scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) --objdump-path=$(TARGET_CROSS)objdump --base-dir=$(BASE_DIR) $(filter-out $(BUILD_DIR)/crosstool-native-%,$(wildcard $(BUILD_DIR)/*.ipk))

autoclean:
	$(PERL) -w scripts/optware-autoclean.pl -v -C $(BASE_DIR)

clean: $(TARGETS_CLEAN) $(PACKAGES_CLEAN)
	find . -name '*~' -print | xargs /bin/rm -f
	find . -name '.*~' -print | xargs /bin/rm -f
	find . -name '.#*' -print | xargs /bin/rm -f

dirclean: $(PACKAGES_DIRCLEAN)

distclean:
	rm -rf $(BUILD_DIR) $(STAGING_DIR) $(PACKAGE_DIR) nslu2 wl500g mss

toolclean:
	rm -rf $(TOOL_BUILD_DIR)

make/%.mk:
	PKG_UP=$$(echo $* | tr [a-z\-] [A-Z_]);			\
	sed -e "s/<foo>/$*/g" -e "s/<FOO>/$${PKG_UP}/g"		\
		 -e '6,11d' make/template.mk > $@
