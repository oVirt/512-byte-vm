ORG 0x7C00 ; Starting address of the boot loader. BIOS expects it to be here.
BITS 16 ; Start program in 16 bit mode. This is the default mode when the CPU starts.

    MOV     BP, print_mode
    MOV     SI, encoded_text
    XOR     DX,DX
    MOV     [BP],DX
print_next_character:
    MOV     AX,[BP]                     ; get the saved print mode
    TEST    AX,AX                       ; test it for non-zero value
    JNZ     normal_text                 ; jump to normal text print when mode is non-zero
    LODSB                               ; continue in compressed mode, get next encoded byte
    MOV     DL,AL                       ; save the "address"
    AND     DL,0F0h                     ; remove the "count" part
    SHR     DL,4                        ; normalize it
    MOV     DI,DX                       ; it doesn't understand effective address with DX, so move to DI
    MOV     CL,AL                       ; save the "count" part
    AND     CL,0Fh                      ; remove the "address" part
    CMP     CL,0                        ; is it the end? when count==0 that mean the end
    JZ      end_of_print                ; yes, this is the end of encoded data
    CMP     CL,0Fh                      ; is it special character? when count==15 that mean special non-compressed character
    JNZ     continue_to_compressed_text ; no, continue with compressed character
normal_text:
    LODSB                               ; yes, it not compressed, load next byte
    TEST    AL,AL                       ; check for end of text marker
    JZ      end_of_print                ; if it is end, then go out from print loop
    MOV     CL,1                        ; the count is always 1 for special characters
    JMP     print_again                 ; go to print
continue_to_compressed_text:
    MOV     AL,[BP+DI+2]                ; load the "real" character, which is two bytes after the print_mode start
print_again:
    MOV     AH,0Eh                      ; teletype mode
    MOV     BX,7                        ; lightgray character on black background
    INT     10h                         ; call the print BIOS service
    CMP     AL,13                       ; test the printed character is a LF
    JNZ     next_print_loop             ; no, it another character, continue the print loop
    MOV     AX,[BP]                     ; get the saved print mode
    TEST    AX,AX                       ; is print mode normal text?
    JZ      next_print_loop             ; if no, then continue the print loop
    LODSB                               ; it is normal text mode, and reveived LF. so load next byte to know how many spaces required
    MOV     CL,AL                       ; save the loaded byte into counter reg
    MOV     AL,' '                      ; set the printed character to ' ' (space)
next_print_loop:
    LOOP    print_again                 ; while has a remain count print it again
    JMP     print_next_character        ; else print next character


end_of_print:
    MOV     AX,[BP]                     ; get the saved print mode
    TEST    AX,AX                       ; test for non-zero value
    MOV     AL,1                        ; always set to 1 to sign the last iteration
    MOV     [BP],AX                     ; get the saved print mode
    JZ      print_next_character        ; at the end of the compressed loop, go back and print normal text

    CALL    serial_port_count           ; get the number of the serial ports
    CMP     AH, 1                       ; check to see if have at least one serial port
    JL      no_serial_ports             ; if we don't have any serial ports, then simply jump over
    CALL    serial_port_init            ; initialize the first serial port to 9600,8,n,1
    MOV     BX, serial_console_message  ; select the message to be sent over the serial port
    CALL    serial_send_str             ; send the message to the serial port

no_serial_ports:
    XOR     AH,AH                       ; wait a keyboard press
    INT     16h                         ; call BIOS service

shutdown:
    MOV     AX,0x1000                   ; fallback segment
    MOV     SS,AX                       ; store into stacksegment
    MOV     SP,0f000h                   ; fallback offset
    MOV     AX,5307h                    ; call apm service: set power state
    MOV     BX,1                        ; to all device
    MOV     CX,3                        ; power off
    INT     15h                         ; call BIOS service (apm)
    MOV     DX,4004h                    ; target port is PM1a_CNT
    MOV     AX,3400h                    ; magic value for virtualbox
    OUT     DX,AX                       ; try to shutdown with acpi
    RET                                 ; fallback when apm/acpi failed - direct jump into reboot address

print_mode:
    DW      9090h
characters:                             ; the real characters: "█k╚r╗s║╔═╝ ao--"
                                        ; indexes               0123456789abcde
    DB    219,107,200,114,187,115,186,201,205,188,32,97,111,10,13

encoded_text:
    DB 0d1h,0e1h
    ;  o                      V                                       i            r                                 t
    DB 0a9h,                  02h,41h,0a5h,02h,41h,                   02h,41h,     0aah,                             02h,41h,0d1h,0e1h
    DB 0a9h,                  02h,61h,0a5h,02h,61h,                   21h,81h,91h, 0a8h,                             07h,41h,0d1h,0e1h
    DB 0a1h,06h,41h,0a1h,     02h,61h,0a5h,02h,61h,                   02h,41h,     02h,41h,04h,41h,                  0a2h,02h,71h,82h,91h,0d1h,0e1h
    DB 02h,71h,83h,02h,41h,   21h,02h,41h,0a3h,02h,71h,91h,           02h,61h,     04h,71h,81h,02h,41h,              0a1h,02h,61h,0d1h,0e1h
    DB 02h,61h,0a3h,02h,61h,  0a1h,21h,02h,41h,0a1h,02h,71h,91h,0a1h, 02h,61h,     02h,71h,81h,91h,0a1h,21h,81h,91h, 0a1h,02h,61h,0a1h,02h,41h,0d1h,0e1h
    DB 21h,06h,71h,91h,       0a2h,21h,04h,71h,91h,0a2h,              02h,61h,     02h,61h,0a7h,                     21h,04h,71h,91h,0d1h,0e1h
    DB 0a1h,21h,85h,91h,0a4h, 21h,83h,91h,0a3h,                       21h,81h,91h, 21h,81h,91h,0a8h,                 21h,83h,91h,0d1h,0e1h

    DB 0                                ; end of compressed text section, start of contributors section
; each line ends with 13 (LF). after that the next byte means "how many space printed to the next line"
    DB 13                               ; new line after the ascii art


; contributors section

    DB 31,'janoscodes',10,13            ; 33 spaces to align right, and a name, and cr, lf
    DB 32,'sarkiroka',10,13             ; same structure as before
    DB 33,'bencurio',10,13              ; same structure as before
    DB 35,'lveyde',10,13                ; same structure as before

; end of contributors section


    DB 1,10,13                          ; empty line after contributors
    DB 1,'Hello World is ok...',10,13   ; the indispensable hello world text
    DB 1,0                              ; end of normal texts

serial_console_message:
    DB 'Hello World!', 0

%include "serial.asm"

TIMES 510 - ($ - $$) DB 0   ; Fill up 510 bytes
DW 0xAA55                   ; Write magic bytes for boot loader
