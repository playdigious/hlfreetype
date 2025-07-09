
LBITS := $(shell getconf LONG_BIT)
MARCH ?= $(LBITS)
PREFIX ?= /usr/local
INSTALL_DIR ?= $(PREFIX)
INSTALL_BIN_DIR ?= $(PREFIX)/bin
INSTALL_LIB_DIR ?= $(PREFIX)/lib
INSTALL_INCLUDE_DIR ?= $(PREFIX)/include

CFLAGS = -Wall -O3 -I src -std=c++11
LFLAGS = -L. -lhl
EXTRA_LFLAGS ?=
LIBEXT = so

UNAME := $(shell uname)

# Cygwin
ifeq ($(OS),Windows_NT)

#use provided vcxproj

else ifeq ($(UNAME),Darwin)

# Mac
LIBEXT=dylib

BPREFIX := $(shell brew --prefix)

BREW_FREETYPE := $(shell brew --prefix freetype)

CFLAGS += -m$(MARCH) -I include -I /usr/local/include -I $(BREW_FREETYPE)/include/freetype2 -I /usr/local/opt/freetype2/include/freetype2 -I /Users/fboeuf/Documents/hashlink/include
LFLAGS += -Wl,-export_dynamic -L/usr/local/lib -L/usr/local/opt/freetype2/lib -L$(BREW_FREETYPE)/lib -L/Users/fboeuf/Documents/hashlink/ -L/Users/fboeuf/Documents/hashlink/libs

ifdef OSX_SDK
ISYSROOT = $(shell xcrun --sdk macosx$(OSX_SDK) --show-sdk-path)
CFLAGS += -isysroot $(ISYSROOT)
LFLAGS += -isysroot $(ISYSROOT)
endif

else

# Linux
CFLAGS += -m$(MARCH) -fPIC -pthread -fno-omit-frame-pointer -I /usr/local/include
LFLAGS += -lm -Wl,-rpath,. -Wl,--export-dynamic -Wl,--no-undefined -L/usr/local/lib

ifeq ($(MARCH),32)
CFLAGS += -I /usr/include/i386-linux-gnu
endif

endif

install: hlfreetype
	cp freetype.hdll $(INSTALL_LIB_DIR)	

uninstall:
	rm -f $(INSTALL_LIB_DIR)/freetype.hdll

hlfreetype: freetype.o
	${CC} ${CFLAGS} -shared -o freetype.hdll freetype.o ${LFLAGS} -lfreetype

freetype.o :
	${CC} ${CFLAGS} -o $@ -c src/freetype.cpp 

clean:
	rm -f freetype.o 

.PHONY: hlfreetype install uninstall clean
