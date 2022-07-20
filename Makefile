#!/usr/bin/make

ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif

.PHONY: install uninstall

all:

install:
	install -d $(DESTDIR)$(PREFIX)/lib/cmake/CMakeUtils/Modules
	install -m 644 CMakeUtilsConfig.cmake $(DESTDIR)$(PREFIX)/lib/cmake/CMakeUtils
	install -m 644 CMakeUtilsConfigVersion.cmake $(DESTDIR)$(PREFIX)/lib/cmake/CMakeUtils
	install -m 644 Modules/* $(DESTDIR)$(PREFIX)/lib/cmake/CMakeUtils/Modules

uninstall:
	rm -rf $(DESTDIR)$(PREFIX)/lib/cmake/CMakeUtils
