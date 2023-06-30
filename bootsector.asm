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

    ; Read second sector (512 bytes)
    xor ax, ax ; Indirectly set ES to 0
    mov es, ax

    mov ah, 2 ; Read from disk function
    mov al, 1 ; Number of sectors to be read 
    mov ch, 0 ; Cylinder number (we in the sane platter)
    mov cl, 2 ; Sector number (1-63)
    mov dh, 0 ; Disk side (top, bottom) / Header
    mov dl, [BOOT_DRIVE] ; Drive number (floppy)

    ; Drive number = es offset by bx = 0x7e00
    ; es * 16 + bx = 0 + bx = 0x7e00
    mov bx, 0x7e00 ; Offset address of buffer
    
    int 0x13 ; Call BIOS interrupt
    jc .error ; If carry flag is set, then there was an error
    jmp .success ; Else, continue

    .error:
        push ax ; Save error code in AH
        mov si, error_msg ; Set SI to point to error_msg
        call PrintString ; Print error_msg

        ; Print error code
        pop ax ; Get error code
        mov al, ah
        call Print2Hex

        jmp .halt ; Halt the system

    .success:
        mov si, success_msg ; Set SI to point to success_msg
        call PrintString ; Print success_msg

        call PrintNewLine

        ; Print the second sector
        mov si, 0x7e00 ; Set SI to point to buffer
        call PrintString ; Print buffer

    .halt:
        ; End
        cli                                 ;Clear all interrupts, so we don't need to handle them in halt state
        hlt                                 ;Halt the system - wait for next interrupt - but we disabled so its very efficient and not using much CPU%

EnterProtectedMode:       ; Enter protected mode
    cli
    lgdt [GDT_Descriptor] ; Load GDT
    mov eax, cr0
    or eax, 0x1 ; Set protected mode bit
    mov cr0, eax
    jmp CODE_SEG:init_pm ; Jump to code segment in protected mode

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
Print4Hex:
    ; Input AX register, BL register (optional)
    ; Output: None
    ; Prints the hex value of AX register (4 nibbles). Example: AX=0x1234 will print: 0x1234
    ; If you want to print prefix '0x' then set BL=0, else set BL=1. Example: AX=0x1234, BL=1 will print: 1234
    push ax

    shr ax, 8
    mov ah, bl ; Print prefix according to BL input for first byte
    call Print2Hex

    ; Print low byte
    pop ax
    mov ah, 1 ; Here we don't need to print prefix
    call Print2Hex

    ret

Print2Hex:
    ; Input: AL register, AH register (optional)
    ; Output: None
    ; Print the hex value of AL register (2 nibbles). Example: AL=0x12 will print: 0x12
    ; If you want to print prefix '0x' then set AH=0, else set AH=1. Example: AL=0x12, AH=1 will print: 12
    cmp ah, 1
    je .no_prefix
    ; Print hex prefix
    push ax
    mov al, '0'
    call PrintCharacter
    mov al, 'x'
    call PrintCharacter
    pop ax ; Get the argument
    .no_prefix:

    ; Print high nibble
    call ALToHex
    push ax ; Store for low nibble printing later on
    mov al, ah ; Move high nibble to AL, since the PrintCharacter procedure expects the character in AL
    ; Check if nibble is greater than 0x9. If it does, then we need offset of 0x41 to get 'A' in ASCII. Else, we need offset of 0x30 to get '0' in ASCII.
    cmp al, 0xA
    jl .finish
    add al, 0x7
    .finish:
    add al, 0x30
    call PrintCharacter

    ; Print low nibble
    pop ax
    cmp al, 0xA
    jl .finish2
    add al, 0x7
    .finish2:
    add al, 0x30
    call PrintCharacter

    ret

ALToHex:
    ; Input: AL register
    ; Output: AX register
    ; Convert a number in AL to hex nibbles. Example: 256 -> 0xAB. The high nibble (0xA) is stored in AH and the low nibble (0xB) in AL
    push ax ; Save AL
    ; Get high nibble of AL, store in DH for later retrieval
    and al, 0xF0
    shr al, 4
    mov dh, al
    
    pop ax
    ; Get low nibble of AL, store in AL
    and al, 0x0F
    
    mov ah, dh ; Retrieve high nibble from DH to AH
    ret



PrintCharacter:                         ;Procedure to print character on screen
                                        ;Assume that ASCII value is in register AL
    mov ah, 0x0E                        ;Tell BIOS that we need to print one charater on screen.
    mov bh, 0x00                        ;Page no.
    mov bl, 0x07                        ;Text attribute 0x07 is lightgrey font on black background
    int 0x10                            ;Call video interrupt
    ret                                 ;Return to calling procedure
PrintString:                            ;Procedure to print string on screen
                                        ;Assume that string starting pointer is in register SI
    .next_character:                     ;Lable to fetch next character from string
        mov al, [SI]                    ;Get a byte from string and store in AL register
        inc SI                          ;Increment SI pointer
        or AL, AL                       ;Check if value in AL is zero (end of string)
        jz .exit_function                ;If end then return
        call PrintCharacter             ;Else print the character which is in AL register
        jmp .next_character              ;Fetch next character from string
        .exit_function:                  ;End label
        ret                             ;Return from procedure
PrintNewLine:
    ; Print new line
    mov al, 0x0D
    call PrintCharacter
    mov al, 0x0A
    call PrintCharacter
    ret

CODE_SEG equ code_descriptor - GDT_Start
DATA_SEG equ data_descriptor - GDT_Start
BOOT_DRIVE db 0
error_msg db 'Error reading from disk, error code: ', 0
success_msg db 'Successfully read from disk', 0

times 510 - ($ - $$) db 0               ;Fill the rest of sector with 0
dw 0xAA55                               ;Add boot signature at the end of bootloader

times 512 db 'A'