SRCS  = NetworkLinux.cpp
SRCS += ZeroconfAvahi.cpp
SRCS += ZeroconfBrowserAvahi.cpp

LIB   = network_linux.a

include ../../../Makefile.include
-include $(patsubst %.cpp,%.P,$(patsubst %.c,%.P,$(SRCS)))
