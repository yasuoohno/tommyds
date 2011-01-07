#############################################################################
# Tommy Makefile

VERSION=0.1
CFLAGS=-O3 -Wall -g
UNAME=$(shell uname)

# Linux
ifeq ($(UNAME),Linux)
LIB=-lrt
EXE=
O=.o
endif

# Darwin
ifeq ($(UNAME),Darwin)
LIB=
EXE=
O=.o
endif

# Windows
ifeq ($(UNAME),)
LIB=benchmark/judy/src/judy.lib
EXE=.exe
O=.obj
endif

CHECK = ./tommybench -S 1000

DEP = \
	tommyalloc.c \
	tommyalloc.h \
	tommy.c \
	tommy.h \
	tommyhash.c \
	tommyhashdyn.c \
	tommyhashdyn.h \
	tommyhash.h \
	tommyhashlin.c \
	tommyhashlin.h \
	tommyhashtbl.c \
	tommyhashtbl.h \
	tommylist.c \
	tommylist.h \
	tommytrie.c \
	tommytrie.h \
	tommytrieinp.c \
	tommytrieinp.h \
	tommytypes.h \
	tommychain.h

all: tommycheck$(EXE) tommybench$(EXE)

tommy$(O): $(DEP)
	gcc $(CFLAGS) -c tommy.c -o tommy$(O)
	gcc $(CFLAGS) -S -fverbose-asm tommy.c -o tommy.s
	objdump -S tommy$(O) > tommy.S

tommycheck$(EXE): check.c tommy$(O)
	gcc $(CFLAGS) check.c tommy.o -o tommycheck$(EXE) $(LIB)

tommybench$(EXE): benchmark.cc $(DEP)
	g++ $(CFLAGS) benchmark.cc -o tommybench$(EXE) $(LIB)

check: tommycheck$(EXE) tommybench$(EXE)
	./tommycheck$(EXE)
	./tommybench$(EXE) -S 100000
	echo Check completed with success!

valgrind:
	valgrind \
		--tool=memcheck \
		--track-origins=yes \
		--read-var-info=yes \
		-v $(CHECK) \
		2> valgrind.log
		tail valgrind.log

callgrind:
	valgrind \
		--tool=callgrind \
		--dump-instr=yes \
		--trace-jump=yes \
		-v $(CHECK) \
		2> callgrind.log
		tail callgrind.log

cachegrind:
	valgrind \
		--tool=cachegrind \
		-v $(CHECK) \
		2> cachegrind.log
		tail cachegrind.log

phony:

doc: phony tommy.doxygen tommy.css $(DEP)
	rm -rf doc
	mkdir doc
	cp -a benchmark/data/* doc/
	rm -f doc/*/*.lst
	rm -f doc/*/*.gnu
	doxygen tommy.doxygen
	rm -f doc/doxygen.png
	rm -f doc/tab_*.png

clean:
	rm -f *.log *.s *.S *.lst *.o
	rm -f *.ncb *.suo *.obj
	rm -rf Debug Release x64
	rm -f callgrind.out.*
	rm -f cachegrind.out.*

distclean: clean
	rm -f tommybench$(EXE) tommycheck$(EXE)

maintainerclean: distclean
	rm -rf doc

DIST=tommyds-$(VERSION)

DISTFILES=\
	Makefile \
	README LICENSE AUTHORS INSTALL HISTORY \
	tommy.doxygen tommy.css tommy-header.html tommy-footer.html \
	benchmark.cc \
	benchmark.vcproj benchmark.sln \
	benchmark.geany \
	check.c

dist:
	mkdir $(DIST)
	cp $(DISTFILES) $(DIST)
	cp $(DEP) $(DIST)
	cp -R doc $(DIST)
	cp -R benchmark $(DIST)/benchmark
	rm -f $(DIST)/benchmark/data/*/*.png
	rm -f $(DIST).tar.gz
	tar cfzo $(DIST).tar.gz $(DIST)
	rm -r $(DIST)
