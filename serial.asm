; Really simple serial communication library for "512 bytes boot sector VM"
; Using BIOS 11h and 14h ISRs
;
; Copyright (C) 2021
; Author:  Lev Veyde <lveyde@redhat.com>
; License: GNU GPLv3


;
; Returns the number of serial ports detected by BIOS
;
serial_port_count:
    int 0x11                            ; Return system information
    and ah, 0x0e                        ; Bitmask relevant bits that contain the number of the serial ports
    shr ah, 1                           ; Shift right by 1 bit to return a proper number
    ret                                 ; Number of serial ports returned in ah register

;
; Initializes the first serial port to 9600,8,n,1
;
serial_port_init:
    push ax                             ; Save the AX register since we modify it
    push dx                             ; Save the DX register since we modify it
    mov ah, 0                           ; Init comm. port function
    mov al, 11100011b                   ; 9600 baud, 8 bits of data, no parity, 1 stop bit
    mov dx, 0                           ; First serial port
    int 0x14                            ; Call the ISR
    pop dx                              ; Restore the DX register
    pop ax                              ; Restore the AX register
    ret

;
; Sends to first serial port a null terminated string
; pointed to by BX register
;
; Note that we don't save/restore BX register value
;
serial_send_str:
    push ax                             ; Save the AX register since we modify it
    push dx                             ; Save the DX register since we modify it
    mov dx, 0                           ; First serial port
serial_send_str_send_char:
    mov ah, 1                           ; Send function
    mov al, [bx]                        ; Read byte pointed by address in BX
    cmp al, 0                           ; Check if we reached the end of the string
    je serial_send_str_end              ; If so, then we can clean the stack and return
    int 0x14                            ; Call the ISR
    inc bx                              ; Increment the pointer
    jmp serial_send_str_send_char       ; Jump to process next byte
serial_send_str_end:
    pop dx                              ; Restore the DX register
    pop ax                              ; Restore the AX register
    ret
