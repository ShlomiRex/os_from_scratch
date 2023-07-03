gnu_gcc := "/home/shlomi/my_tools/bin/i686-elf-gcc"
gnu_ld := "/home/shlomi/my_tools/bin/i686-elf-ld"

all: compile run

compile:
# kernel.o
	$(gnu_gcc) -ffreestanding -m32 -g -c "kernel.cpp" -o "kernel.o"
# kernel_entry.o
	nasm "kernel_entry.asm" -f elf -o "kernel_entry.o"
# kernel.bin - link kernel_entry.o and kernel.o
	$(gnu_ld) -o "full_kernel.bin" -Ttext 0x1000 "kernel_entry.o" "kernel.o" --oformat binary
# boot.bin - bootloader
	nasm "bootsector.asm" -f bin -o "boot.bin"
# everything.bin - bootloader + kernel
	cat "boot.bin" "full_kernel.bin" > "everything.bin"
# zeroes.bin - zeroes
	nasm "zeroes.asm" -f bin -o "zeroes.bin"
# os.bin - everything + zeroes
	cat "everything.bin" "zeroes.bin" > "os.bin"
# run

run:
	qemu-system-x86_64 -drive format=raw,file="os.bin",index=0,if=floppy -m 128M
