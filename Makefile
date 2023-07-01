all:
	nasm bootsector.asm -f bin -o boot.img
	gcc -arch x86_64 -ffreestanding -c kernel.c -o kernel.o
	ld -arch x86_64 -o kernel.bin -Ttext 0x1000 kernel.o --oformat binary
	qemu-system-x86_64 boot.img
