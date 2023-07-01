[global Start]
[BITS 16]
[ORG 0x7C00]

section .text

Start:
    ; DL stores the current drive number, save in variable
    mov [BOOT_DRIVE], dl

    ; Initialize the stack
    mov bp, 0x7C00
    mov sp, bp

    ; ; Read the kernel
    ; xor ax, ax
    ; mov es, ax ; ES:BX is the address where the data will be stored. We don't want to jump in 16 bytes blocks.

    ; mov ah, 2
    ; mov al, 2 ; number of sectors to read (kernel = 2 sectors = 1024 bytes). We must change that if kernel is bigger.
    ; mov bx, KERNEL_ADDRESS
    ; mov ch, 0 ; Cylinder number
    ; mov cl, 2 ; Sector number
    ; mov dh, 2 ; Head number TODO: WHY IS IT 2?
    ; mov dl, [BOOT_DRIVE]
    ; int 0x13 ; BIOS interrupt call
    ; jc DiskError ; Jump if carry flag is set (error)

    ; DiskError:
    ;     mov si, DiskErrorMessage
    ;     call PrintString
    ;     cli
    ;     hlt
    jmp EnterProtectedMode

%include "pm.asm"
%include "gdt.asm"
%include "bios.asm"


BOOT_DRIVE db 0
KERNEL_ADDRESS equ 0x1000 ; Don't start at 0 to avoid overwriting interrupt vector table of the BIOS


times 510 - ($ - $$) db 0
dw 0xAA55
