RM:=rm -f
EMCONFIGURE:=emconfigure

EMTI_TOP:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PATCH_DIR:=$(EMTI_TOP)/patch
PREFIX_DIR:=$(EMTI_TOP)/build
EMTI_BIN:=$(EMTI_TOP)/emti.js

GLIB_TOP:=external/glib
GLIB_LIB:=$(PREFIX_DIR)/lib/libglib-2.0.so
GMODULE_LIB:=$(PREFIX_DIR)/lib/libgmodule-2.0.so
GOBJECT_LIB:=$(PREFIX_DIR)/lib/libgobject-2.0.so
GTHREAD_LIB:=$(PREFIX_DIR)/lib/libgthread-2.0.so
GLIB_LIBS:=$(GLIB_LIB) $(GMODULE_LIB) $(GOBJECT_LIB) $(GTHREAD_LIB)

LIBARCHIVE_TOP:=external/libarchive
LIBARCHIVE_LIB:=$(PREFIX_DIR)/lib/libarchive.so

TICABLES_TOP:=external/tilibs/libticables/trunk
TICALCS_TOP:=external/tilibs/libticalcs/trunk
TICONV_TOP:=external/tilibs/libticonv/trunk
TIFILES_TOP:=external/tilibs/libtifiles/trunk
TICABLES_LIB:=$(PREFIX_DIR)/lib/libticables2.so
TICALCS_LIB:=$(PREFIX_DIR)/lib/libticalcs2.so
TICONV_LIB:=$(PREFIX_DIR)/lib/libticonv.so
TIFILES_LIB:=$(PREFIX_DIR)/lib/libtifiles2.so

TIEMU_TOP:=external/tiemu
TIEMU_LIB:=$(PREFIX_DIR)/lib/libtiemu.so

CACHE_FILE:=$(EMTI_TOP)/config.cache
CONFIGUREFLAGS:=--cache-file=$(CACHE_FILE) --prefix=$(PREFIX_DIR) --build=x86_64-pc-linux-gnu --host=x86-pc-gnu
export PKG_CONFIG=$(EMTI_TOP)/prefix-pkg-config

# GLib
$(GLIB_TOP)/gtk-doc.make:
	echo "EXTRA_DIST =" > $@
	echo "CLEANFILES =" >> $@
$(GLIB_TOP)/README $(GLIB_TOP)/INSTALL:
	touch $@
$(GLIB_TOP)/configure: $(GLIB_TOP)/gtk-doc.make $(GLIB_TOP)/README $(GLIB_TOP)/INSTALL
	cd $(GLIB_TOP); \
	$(EMCONFIGURE) autoreconf -i -s
$(GLIB_TOP)/libtool:
	echo "#!/bin/sh" > $@
	echo "libtool \$$@" >> $@
	chmod +x $@
$(GLIB_TOP)/mkinstalldirs: $(TIEMU_TOP)/mkinstalldirs
	cp $< $@
$(GLIB_TOP)/Makefile: $(GLIB_TOP)/configure $(GLIB_TOP)/libtool
	cd $(GLIB_TOP); \
	$(EMCONFIGURE) ./configure $(CONFIGUREFLAGS) \
		CFLAGS='-s USE_ZLIB=1' \
		glib_cv_long_long_format=ll glib_cv_stack_grows=yes \
		--disable-threads
$(GLIB_LIBS): $(GLIB_TOP)/Makefile $(GLIB_TOP)/mkinstalldirs
	make -C $(GLIB_TOP) all install
.PHONY: glib glib-clean
glib: $(GLIB_LIBS)
glib-clean: $(GLIB_TOP)/Makefile
	make -C $(GLIB_TOP) clean

# LibArchive
$(LIBARCHIVE_TOP)/configure:
	cd $(LIBARCHIVE_TOP); \
	$(EMCONFIGURE) autoreconf -i -s
$(LIBARCHIVE_TOP)/Makefile: $(LIBARCHIVE_TOP)/configure
	cd $(LIBARCHIVE_TOP); \
	$(EMCONFIGURE) ./configure $(CONFIGUREFLAGS) \
		--disable-bsdtar --disable-bsdcat --disable-bsdcpio \
		--without-bz2lib --without-iconv --without-lz4 --without-zstd --without-lzma \
		--without-lzo2 --without-cng --without-nettle --without-openssl --without-xml2 \
		--without-expat
$(LIBARCHIVE_LIB): $(LIBARCHIVE_TOP)/Makefile
	make -C $(LIBARCHIVE_TOP) all install
.PHONY: libarchive libarchive-clean
libarchive: $(LIBARCHIVE_LIB)
libarchive-clean: $(LIBARCHIVE_TOP)/Makefile
	make -C $(LIBARCHIVE_TOP) clean

# TiCables
$(TICABLES_TOP)/configure:
	cd $(TICABLES_TOP); \
	$(EMCONFIGURE) autoreconf -i -s
$(TICABLES_TOP)/Makefile: $(TICABLES_TOP)/configure glib
	cd $(TICABLES_TOP); \
	$(EMCONFIGURE) ./configure $(CONFIGUREFLAGS) \
		--disable-libusb
$(TICABLES_LIB): $(TICABLES_TOP)/Makefile
	make -C $(TICABLES_TOP) all install
.PHONY: ticables ticables-clean
ticables: $(TICABLES_LIB)
ticables-clean: $(TICABLES_TOP)/Makefile
	make -C $(TICABLES_TOP) clean

# TiCalcs
$(TICALCS_TOP)/configure:
	cd $(TICALCS_TOP); \
	$(EMCONFIGURE) autoreconf -i -s
$(TICALCS_TOP)/Makefile: $(TICALCS_TOP)/configure glib ticables ticonv tifiles
	cd $(TICALCS_TOP); \
	$(EMCONFIGURE) ./configure $(CONFIGUREFLAGS)
$(TICALCS_LIB): $(TICALCS_TOP)/Makefile
	make -C $(TICALCS_TOP) all install
.PHONY: ticalcs ticalcs-clean
ticalcs: $(TICALCS_LIB)
ticalcs-clean: $(TICALCS_TOP)/Makefile
	make -C $(TICALCS_TOP) clean

# TiConv
$(TICONV_TOP)/configure:
	cd $(TICONV_TOP); \
	$(EMCONFIGURE) autoreconf -i -s
$(TICONV_TOP)/Makefile: $(TICONV_TOP)/configure glib
	cd $(TICONV_TOP); \
	$(EMCONFIGURE) ./configure $(CONFIGUREFLAGS)
$(TICONV_LIB): $(TICONV_TOP)/Makefile
	make -C $(TICONV_TOP) all install
.PHONY: ticonv ticonv-clean
ticonv: $(TICONV_LIB)
ticonv-clean: $(TICONV_TOP)/Makefile
	make -C $(TICONV_TOP) clean

# TiFiles
$(TIFILES_TOP)/configure:
	cd $(TIFILES_TOP); \
	$(EMCONFIGURE) autoreconf -i -s
$(TIFILES_TOP)/Makefile: $(TIFILES_TOP)/configure glib ticonv libarchive
	cd $(TIFILES_TOP); \
	$(EMCONFIGURE) ./configure $(CONFIGUREFLAGS)
$(TIFILES_LIB): $(TIFILES_TOP)/Makefile
	make -C $(TIFILES_TOP) all install
.PHONY: tifiles tifiles-clean
tifiles: $(TIFILES_LIB)
tifiles-clean: $(TIFILES_TOP)/Makefile
	make -C $(TIFILES_TOP) clean

# TiEmu
$(TIEMU_TOP)/configure:
	cd $(TIEMU_TOP); \
	$(EMCONFIGURE) autoreconf -i -s
$(TIEMU_TOP)/Makefile: $(TIEMU_TOP)/configure ticables ticalcs tifiles ticonv glib
	cd $(TIEMU_TOP); \
	$(EMCONFIGURE) ./configure $(CONFIGUREFLAGS) \
		--disable-sound --disable-debugger --disable-gdb \
		--without-dbus --without-kde
$(TIEMU_LIB): $(TIEMU_TOP)/Makefile
	make -C $(TIEMU_TOP) all install
.PHONY: tiemu tiemu-clean
tiemu: $(TIEMU_LIB)
tiemu-clean: $(TIEMU_TOP)/Makefile
	make -C $(TIEMU_TOP) clean

# Emti
emti: tiemu

.PHONY: patch
patch:
	git submodule foreach --recursive \
		'git --no-pager diff HEAD -D --no-color --ignore-submodules > $(PATCH_DIR)/$$name.patch'

.PHONY: apply
apply:
	git submodule foreach --recursive \
		'test -f $(PATCH_DIR)/$$name.patch && git --no-pager apply $(PATCH_DIR)/$$name.patch || true'

.PHONY: all clean
all: emti
clean: glib-clean libarchive-clean ticables-clean ticonv-clean tifiles-clean ticalcs-clean tiemu-clean emti-clean

