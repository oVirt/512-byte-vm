ORG 0x7C00 ; Starting address of the boot loader. BIOS expects it to be here.
BITS 16 ; Start program in 16 bit mode. This is the default mode when the CPU starts.

main:
    MOV SI, text_hello_world ; Move pointer to the text label into the SI register
    CALL printText
    JMP halt

; printText prints a null-terminated string from the address passed in SI using the BIOS facility
printText:
    MOV AH, 0x0E ; Set BIOS / INT 10 printing facility to text output
.printChar:
    LODSB ; Load byte from the address in SI into AL and advance SI by one
    OR AL, AL ; Equal to CMP AL, 0, but shorter in byte code
    JE .printReturn ; If yes, jump to the return
    INT 0x10 ; Trigger BIOS print method
    JMP .printChar ; Repeat for next byte
.printReturn:
    RET ; Return from the printText function

halt:
    HLT ; Halt CPU if the APM shutdown failed.

text_hello_world:
    DB "Hello World!", 13, 0 ; Embed data into binary, zero-terminated.

TIMES 510 - ($ - $$) DB 0 ; Fill up 510 bytes
DW 0xAA55 ; Write magic bytes for boot loader