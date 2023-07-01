EnterProtectedMode:
    ; Enter protected mode
    mov si, enter_pm_msg
    call PrintString
    call PrintNewLine

    cli
    lgdt [GDT_Descriptor] ; Load GDT
    mov eax, cr0
    or eax, 0x1 ; Set protected mode bit
    mov cr0, eax
    jmp CODE_SEG:StartProtectedMode ; Jump to code segment in protected mode
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

    ; Print 'OK' on top-left corner of the screen
    mov al, 'O'
    mov ah, 0x0f
    mov [0xb8000], ax
    mov al, 'K'
    mov [0xb8002], ax

    ; Stop
    cli
    hlt

enter_pm_msg db "Entering protected mode...", 0
