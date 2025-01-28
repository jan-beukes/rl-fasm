LIBS = -lraylib -lm -lc 
LD = /lib64/ld-linux-x86-64.so.2

all: main

main: main.o
	ld main.o -o main $(LIBS) -dynamic-linker $(LD)

main.o: main.asm
	fasm main.asm

run: main
	./main

