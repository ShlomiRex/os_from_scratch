all:
	nasm bootsector.asm -f bin -o boot.img
	qemu-system-x86_64 boot.img

test:
	nasm -f bin bootsector.asm -o boot.bin
	nasm -f elf32 test.asm -o test.o
	ld -Ttext 0x7C00 -m elf_i386 --oformat binary -o final.bin boot.bin test.o
	qemu-system-x86_64 final.img
