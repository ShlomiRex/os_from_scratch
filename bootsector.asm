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

    ; Enter protected mode
    cli
    lgdt [GDT_Descriptor] ; Load GDT
    mov eax, cr0
    or eax, 0x1 ; Set protected mode bit
    mov cr0, eax
    jmp CODE_SEG:StartProtectedMode ; Jump to code segment in protected mode

GDT_Start:          ; Create a global descriptor table
    null_descriptor:
        dd 0x0 ; 8 bits of zeros
        dd 0x0
    code_descriptor:
        dw 0xFFFF ; Limit (16 bits)
        dw 0x0 ; Base (24 bits in total) (16 bits)
        db 0x0 ; Base (8 bits)
        db 10011010b ; First 4 bits: present, priviledge, type. Last 4 bits: Type flags
        db 11001111b ; Other flags (4 bits) + Limit (4 bits)
        db 0x0 ; Base (8 bits)
    data_descriptor:
        dw 0xFFFF ; Limit (16 bits)
        dw 0x0 ; Base (24 bits in total) (16 bits)
        db 0x0 ; Base (8 bits)
        db 10010010b ; First 4 bits: present, priviledge, type. Last 4 bits: Type flags
        db 11001111b ; Other flags (4 bits) + Limit (4 bits)
        db 0x0 ; Base (8 bits)
GDT_End:
GDT_Descriptor:
    dw GDT_End - GDT_Start - 1 ; Size of GDT
    dd GDT_Start ; Start address of GDT

CODE_SEG equ code_descriptor - GDT_Start
DATA_SEG equ data_descriptor - GDT_Start
BOOT_DRIVE db 0

[BITS 32]
StartProtectedMode:
    ; Initialize segment registers immediately after entering protected mode
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Initialize the stack
    mov ebp, 0x90000
    mov esp, ebp

    ; Print 'A' on screen
    mov al, 'A'
    mov ah, 0x0f
    mov [0xb8000], ax

    ; Stop
    cli
    hlt
times 510 - ($ - $$) db 0
dw 0xAA55
