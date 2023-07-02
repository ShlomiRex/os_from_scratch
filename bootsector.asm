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

    call ClearScreen

    mov SI, hello_msg
    call PrintString
    call PrintNewLine
    
    ; Read kernel
    xor ax, ax
    mov es, ax
    mov ds, ax
    
    mov bx, KERNEL_ADDRESS
    mov dh, 20
    mov ah, 2
    mov al, dh
    mov ch, 0
    mov dh, 0
    mov cl, 2
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc DiskError
    jmp NoDiskError

    DiskError:
        mov SI, disk_error_msg
        call PrintString

        ; Error code
        mov al, ah
        mov ah, 0
        call Print2Hex

        cli
        hlt
    NoDiskError:
        jmp EnterProtectedMode

%include "pm.asm"
%include "gdt.asm"
%include "bios.asm"


BOOT_DRIVE db 0
KERNEL_ADDRESS equ 0x1000 ; Don't start at 0 to avoid overwriting interrupt vector table of the BIOS
hello_msg db "Running in 16-bit real mode...", 0
disk_error_msg db "Error reading disk, error code: ", 0

times 510 - ($ - $$) db 0
dw 0xAA55
