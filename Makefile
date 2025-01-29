LIBS = -lraylib -lm -lc 
LD = /lib64/ld-linux-x86-64.so.2

all: physics

main: main.o
	ld $^ $(LIBS) -dynamic-linker $(LD)
	rm $^

main.o: main.asm
	fasm main.asm

physics.o: physics.asm raylib.inc
	fasm physics.asm

physics: physics.o
	ld $^ $(LIBS) -dynamic-linker $(LD)
	rm $^

test:
	gcc test.c -S -masm=intel
	gcc test.c -lraylib -lm

run: all
	./a.out

