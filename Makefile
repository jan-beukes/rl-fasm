LIBS = -lraylib -lm -lc 
LD = /lib64/ld-linux-x86-64.so.2

all: main

main: main.o
	ld $^ $(LIBS) -dynamic-linker $(LD)
	rm $^

main.o: main.asm raylib.inc
	fasm main.asm

hello.o: hello.asm raylib.inc
	fasm hello.asm

hello: hello.o
	ld $^ $(LIBS) -dynamic-linker $(LD)
	rm $^

test:
	gcc test.c -S -masm=intel
	gcc test.c -lraylib -lm

run: all
	./a.out

