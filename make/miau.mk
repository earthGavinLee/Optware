###########################################################
#
# miau
#
###########################################################

MIAU_DIR=$(BUILD_DIR)/miau
MIAU_VERSION=0.5.3
MIAU=miau-$(MIAU_VERSION)
MIAU_SITE=http://aleron.dl.sourceforge.net/sourceforge/miau
MIAU_SOURCE_ARCHIVE=$(MIAU).tar.gz
MIAU_UNZIP=zcat

MIAU_IPK=$(BUILD_DIR)/miau_$(MIAU_VERSION)-1_armeb.ipk
MIAU_IPK_DIR=$(BUILD_DIR)/miau-$(MIAU_VERSION)-ipk

#
# Setting these up because Flex includes and libraries get put in these
# locations and IRCD Hybrid needs them.
#
MY_STAGING_CPPFLAGS="$(STAGING_CPPFLAGS) -I$(STAGING_DIR)/include/include"
MY_STAGING_LDFLAGS="$(STAGING_LDFLAGS) -L$(STAGING_DIR)/lib/lib"

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MIAU_SOURCE_ARCHIVE):
	$(WGET) -P $(DL_DIR) $(MIAU_SITE)/$(MIAU_SOURCE_ARCHIVE)

#
# The IRCD Hybrid source code depends on it existing within the
# download directory.  This target will be called by the top level
# Makefile to download the source code's archive (.tar.gz, .bz2, etc.)
#
miau-source: $(DL_DIR)/$(MIAU_SOURCE_ARCHIVE)

#
# This target unpacks the source code into the build directory.
#
$(MIAU_DIR)/.source: $(DL_DIR)/$(MIAU_SOURCE_ARCHIVE)
	$(MIAU_UNZIP) $(DL_DIR)/$(MIAU_SOURCE_ARCHIVE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/miau-$(MIAU_VERSION) $(MIAU_DIR)
	touch $(MIAU_DIR)/.source

#
# This target configures the build within the build directory.
# This is a fairly important note (cuz I wasted about 5 hours on it).
# Flags usch as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
$(MIAU_DIR)/.configured: $(MIAU_DIR)/.source
	(cd $(MIAU_DIR); \
	export LDFLAGS=$(MY_STAGING_LDFLAGS); \
	export CPPFLAGS=$(MY_STAGING_CPPFLAGS); \
	./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/opt	\
	);
	touch $(MIAU_DIR)/.configured

#
# This builds the actual binary (ircd).  IRCD Hybrid drops the final binary
# in the src directory once built.
#
$(MIAU_DIR)/src/miau: $(MIAU_DIR)/.configured
	$(MAKE) -C $(MIAU_DIR)	\
	RANLIB=$(TARGET_RANLIB)

#
# These are the dependencies for the binary.  IRCD Hybrid requires Zlib,
# Flex, and the actual binary to exist before we're done.
#
miau: zlib flex $(MIAU_DIR)/src/miau

#
# This builds the IPK file.
#
$(MIAU_IPK): $(MIAU_DIR)/src/miau
	mkdir -p $(MIAU_IPK_DIR)/CONTROL
	mkdir -p $(MIAU_IPK_DIR)/opt
	mkdir -p $(MIAU_IPK_DIR)/opt/bin
	$(STRIP) $(MIAU_DIR)/src/miau -o $(MIAU_IPK_DIR)/opt/bin/miau
	cp $(SOURCE_DIR)/miau.control $(MIAU_IPK_DIR)/CONTROL/control
	mkdir -p $(MIAU_IPK_DIR)/opt/etc
	cp $(MIAU_DIR)/misc/miaurc $(MIAU_IPK_DIR)/opt/etc/miaurc
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MIAU_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
miau-ipk: $(MIAU_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
miau-clean:
	-$(MAKE) -C $(MIAU_DIR) uninstall
	-$(MAKE) -C $(MIAU_DIR) clean

#
# This is called from the top level makefile to clean ALL files, including
# downloaded source.
#
miau-distclean:
	-rm $(MIAU_DIR)/.configured
	-$(MAKE) -C $(MIAU_DIR) distclean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
miau-dirclean:
	rm -rf $(MIAU_DIR) $(MIAU_IPK_DIR) $(MIAU_IPK)
