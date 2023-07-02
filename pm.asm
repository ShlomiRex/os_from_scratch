EnterProtectedMode:
    mov si, enter_pm_msg
    call PrintString
    call PrintNewLine

    ; Enter protected mode
    cli
    lgdt [GDT_Descriptor] ; Load GDT
    mov eax, cr0
    or eax, 0x1 ; Set protected mode bit
    mov cr0, eax
    jmp CODE_SEG:StartProtectedMode ; Far jump to code segment in protected mode, force CPU to flush pipeline
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

    ; TODO: Remove this 'OK' we do this in kernel in C++ instead
    ; Print 'OK' on second line (VGA memory starts at 0xB8000)
    ; mov al, 'O'
    ; mov ah, 0x0f
    ; mov [0xb80A0], ax
    ; mov al, 'K'
    ; mov [0xb80A2], ax

    ; cli
    ; hlt
    jmp KERNEL_ADDRESS

enter_pm_msg db "Entering protected mode...", 0
