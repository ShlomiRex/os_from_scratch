[global Start]
[BITS 16]
[ORG 0x7C00]

section .text
Start:
    mov si, String
    call PrintString

    mov ax, 0x0012
    call PrintHex

    ; End
    cli                                 ;Clear all interrupts, so we don't need to handle them in halt state
    hlt                                 ;Halt the system - wait for next interrupt - but we disabled so its very efficient and not using much CPU%

; Input: AL register, AH register (optional)
; Output: None
; Print the hex value of AL register. Example: AL=0x12 will print: 0x12
; If you want to print prefix '0x' then set AH=0, else set AH=1. Example: AL=0x12, AH=1 will print: 12
PrintHex:
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
    add al, 0x30 ; Convert to ASCII. Since nibble is 0-15, we can just add 0x30 to get the ASCII value
    call PrintCharacter

    ; Print low nibble
    pop ax
    add al, 0x30
    call PrintCharacter

    ret

; Input: AL register
; Output: AX register
; Convert a number in AL to hex nibbles. Example: 256 -> 0xAB. The high nibble (0xA) is stored in AH and the low nibble (0xB) in AL
ALToHex:
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
    next_character:                     ;Lable to fetch next character from string
        mov al, [SI]                    ;Get a byte from string and store in AL register
        inc SI                          ;Increment SI pointer
        or AL, AL                       ;Check if value in AL is zero (end of string)
        jz exit_function                ;If end then return
        call PrintCharacter             ;Else print the character which is in AL register
        jmp next_character              ;Fetch next character from string
        exit_function:                  ;End label
        ret                             ;Return from procedure
String db 'Hello World', 0              ;HelloWorld string ending with 0

times 510 - ($ - $$) db 0               ;Fill the rest of sector with 0
dw 0xAA55                               ;Add boot signature at the end of bootloader
