all:
	nasm bootsector.asm -f bin -o boot.img
	qemu-system-x86_64 boot.img
