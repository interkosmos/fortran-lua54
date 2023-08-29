.POSIX:

CC      = gcc
FC      = gfortran
AR      = ar
DEBUG   = #-g -O0 -Wall -fmax-errors=1
CFLAGS  = $(DEBUG) `pkg-config --cflags lua-5.4`
FFLAGS  = $(DEBUG) -std=f2008 `pkg-config --cflags lua-5.4`
ARFLAGS = rcs
LDFLAGS = `pkg-config --libs-only-L lua-5.4`
LDLIBS  = `pkg-config --libs-only-l lua-5.4`
TARGET  = libfortran-lua54.a

.PHONY: all clean examples test

all: $(TARGET)

test: types

examples: fibonacci fortran.so string table

$(TARGET): src/lua.f90
	$(FC) $(FFLAGS) -fPIC -c src/lua.f90
	$(AR) $(ARFLAGS) $(TARGET) lua.o

types: test/types.c
	$(CC) $(CFLAGS) -o types test/types.c $(LDFLAGS)

fibonacci: $(TARGET) examples/fibonacci/fibonacci.f90
	$(FC) $(FFLAGS) $(LDFLAGS) -o fibonacci examples/fibonacci/fibonacci.f90 $(TARGET) $(LDLIBS)

fortran.so: $(TARGET) examples/library/fortran.f90
	$(FC) $(FFLAGS) $(LDFLAGS) -shared -fPIC -o fortran.so examples/library/fortran.f90 $(TARGET)

string: $(TARGET) examples/string/string.f90
	$(FC) $(FFLAGS) $(LDFLAGS) -o string examples/string/string.f90 $(TARGET) $(LDLIBS)

table: $(TARGET) examples/table/table.f90
	$(FC) $(FFLAGS) $(LDFLAGS) -o table examples/table/table.f90 $(TARGET) $(LDLIBS)

clean:
	if [ `ls -1 *.mod 2>/dev/null | wc -l` -gt 0 ]; then rm *.mod; fi
	if [ `ls -1 *.o 2>/dev/null | wc -l` -gt 0 ]; then rm *.o; fi
	if [ -e $(TARGET) ]; then rm $(TARGET); fi
	if [ -e types ]; then rm types; fi
	if [ -e fibonacci ]; then rm fibonacci; fi
	if [ -e fortran.so ]; then rm fortran.so; fi
	if [ -e string ]; then rm string; fi
	if [ -e table ]; then rm table; fi
