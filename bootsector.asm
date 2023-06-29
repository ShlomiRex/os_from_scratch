[global start]
[BITS 16]                               ;Tells the assembler that its a 16 bit code
[ORG 0x7C00]                    ;Origin, tell the assembler that where the code will
                                                ;be in memory after it is been loaded

start:
    mov SI, String                  ;Store string pointer to SI
    call PrintString                ;Call print string procedure
    JMP $                                   ;Infinite loop, hang it here.


PrintCharacter:                 ;Procedure to print character on screen
                                        ;Assume that ASCII value is in register AL
    mov AH, 0x0E                    ;Tell BIOS that we need to print one charater on screen.
    mov BH, 0x00                    ;Page no.
    mov BL, 0x07                    ;Text attribute 0x07 is lightgrey font on black background

    INT 0x10                                ;Call video interrupt
    RET                                             ;Return to calling procedure



PrintString:                    ;Procedure to print string on screen
                                                ;Assume that string starting pointer is in register SI

    next_character:                 ;Lable to fetch next character from string
        mov AL, [SI]                    ;Get a byte from string and store in AL register
        inc SI                                  ;Increment SI pointer
        or AL, AL                               ;Check if value in AL is zero (end of string)
        jz exit_function                ;If end then return
        call PrintCharacter     ;Else print the character which is in AL register
        JMP next_character              ;Fetch next character from string
        exit_function:                  ;End label
        ret                                             ;Return from procedure


String db 'Hello World', 0              ;HelloWorld string ending with 0

times 510 - ($ - $$) db 0               ;Fill the rest of sector with 0
dw 0xAA55                                               ;Add boot signature at the end of bootloader
