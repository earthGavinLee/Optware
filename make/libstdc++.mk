###########################################################
#
# libstdc++
#
###########################################################

LIBSTDC++_VERSION=5.0.7
LIBSTDC++_DIR=libstdc++-$(LIBSTDC++_VERSION)
LIBSTDC++_LIBNAME=libstdc++.so

LIBSTDC++_IPK_VERSION=1

LIBSTDC++_BUILD_DIR=$(BUILD_DIR)/libstdc++
LIBSTDC++_SOURCE_DIR=$(SOURCE_DIR)/libstdc++
LIBSTDC++_IPK_DIR=$(BUILD_DIR)/libstdc++-$(LIBSTDC++_VERSION)-ipk
LIBSTDC++_IPK=$(BUILD_DIR)/libstdc++_$(LIBSTDC++_VERSION)-$(LIBSTDC++_IPK_VERSION)_armeb.ipk

$(LIBSTDC++_BUILD_DIR)/.configured: $(LIBSTDC++_PATCHES)
	rm -rf $(BUILD_DIR)/$(LIBSTDC++_DIR) $(LIBSTDC++_BUILD_DIR)
	mkdir -p $(LIBSTDC++_BUILD_DIR)
	touch $(LIBSTDC++_BUILD_DIR)/.configured

libstdc++-unpack: $(LIBSTDC++_BUILD_DIR)/.configured

$(LIBSTDC++_BUILD_DIR)/.built: $(LIBSTDC++_BUILD_DIR)/.configured
	rm -f $(LIBSTDC++_BUILD_DIR)/.built
	cp $(TARGET_LIBDIR)/$(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) $(LIBSTDC++_BUILD_DIR)/
	touch $(LIBSTDC++_BUILD_DIR)/.built

libstdc++: $(LIBSTDC++_BUILD_DIR)/.built

$(LIBSTDC++_BUILD_DIR)/.staged: $(LIBSTDC++_BUILD_DIR)/.built
	rm -f $(LIBSTDC++_BUILD_DIR)/.staged
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBSTDC++_BUILD_DIR)/$(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) $(STAGING_DIR)/opt/lib
	(cd $(STAGING_DIR)/opt/lib; \
	 ln -s $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
               $(LIBSTDC++_LIBNAME); \
	 ln -s $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
               $(LIBSTDC++_LIBNAME).5 \
	)
	touch $(LIBSTDC++_BUILD_DIR)/.staged

libstdc++-stage: $(LIBSTDC++_BUILD_DIR)/.staged

$(LIBSTDC++_IPK): $(LIBSTDC++_BUILD_DIR)/.built
	rm -rf $(LIBSTDC++_IPK_DIR) $(BUILD_DIR)/libstdc++_*_armeb.ipk
	install -d $(LIBSTDC++_IPK_DIR)/opt/lib
	install -m 644 $(LIBSTDC++_BUILD_DIR)/$(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) $(LIBSTDC++_IPK_DIR)/opt/lib
	(cd $(LIBSTDC++_IPK_DIR)/opt/lib; \
	 ln -s $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
               $(LIBSTDC++_LIBNAME); \
	 ln -s $(LIBSTDC++_LIBNAME).$(LIBSTDC++_VERSION) \
               $(LIBSTDC++_LIBNAME).5 \
	)
	install -d $(LIBSTDC++_IPK_DIR)/CONTROL
	install -m 644 $(LIBSTDC++_SOURCE_DIR)/control $(LIBSTDC++_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSTDC++_IPK_DIR)

libstdc++-ipk: $(LIBSTDC++_IPK)

libstdc++-clean:
	rm -rf $(LIBSTDC++_BUILD_DIR)/*

libstdc++-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSTDC++_DIR) $(LIBSTDC++_BUILD_DIR) $(LIBSTDC++_IPK_DIR) $(LIBSTDC++_IPK)
