ORG 0x7C00 ; Starting address of the boot loader. BIOS expects it to be here.
BITS 16 ; Start program in 16 bit mode. This is the default mode when the CPU starts.

	MOV	BP, characters
	MOV	SI, encoded_text
	XOR	DX,DX
print_next_character:
	LODSB					; next encoded data
	MOV	DL,AL				; save the "address"
	AND	DL,0F0h			; remove the "count" part
	SHR	DL,4				; normalize it
	MOV	DI,DX				; it doesn't understand effective address with DX, so move to DI
	MOV	CL,AL				; save the "count" part
	AND	CL,0Fh				; remove the "address" part
	CMP	CL,0				; is it the end? when count==0 that mean the end
	JZ	end_of_print			; yes, this is the end of encoded data
	CMP	CL,0Fh				; is it special character? when count==15 that mean special non-compressed character
	JNZ	continue_to_compressed_text	; no, continue with compressed character
	LODSB					; yes, it not compressed, load next byte
	MOV	CL,1				; the count is always 1 for special characters
	JMP	print_again			; go to print
continue_to_compressed_text:
	MOV	AL,[BP+DI]			; load the "real" character
print_again:
	MOV	AH,0Eh				; teletype mode
	MOV	BX,7				; lightgray character on black background
	INT	10h				; call the print BIOS service
	DEC	CL				; calculate how many character remain
	JNZ	print_again			; if has more, then print it again
	JMP	print_next_character		; else print next character


end_of_print:
	XOR	AH,AH				; wait a keyboard press
	INT	16h				; call BIOS service

shutdown:
	MOV	AX,0x1000			; fallback segment
	MOV	SS,AX				; store into stacksegment
	MOV	SP,0f000h			; fallback offset
	MOV	AX,5307h			; call apm service: set power state
	MOV	BX,1				; to all device
	MOV	CX,3				; power off
	INT	15h				; call BIOS service (apm)
 	RET					; fallback when apm failed - direct jump into reboot address

characters:					; the real characters: "█k╚r╗s║╔═╝ ao--"
						; indexes               0123456789abcde
	DB	219,107,200,114,187,115,186,201,205,188,32,97,111,10,13

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
	
	DB 0aeh,0aeh,0a4h,0fh,6ah,0b1h,0fh,6eh,0c1h,51h,0fh,7ah,0fh,65h,0fh,6eh,0d1h,0e1h
	DB 0aeh,0aeh,0a3h,51h,0b1h,31h,11h,0fh,69h,31h,0c1h,11h,0b1h,0d1h,0e1h
	DB 0d1h,0e1h,0d1h,0e1h,0fh,07h

	DB 0fh,48h,0fh,65h,0fh,6ch,0fh,6ch,0c1h,0a1h,0fh,57h,0c1h,31h,0fh,6ch,0fh,64h,0a1h, 0fh,69h,51h,0a1h, 0c1h,11h,0fh,2eh,0fh,2eh,0fh,2eh,0d1h,0e1h
	
	DB 0					; end of encoded text

TIMES 510 - ($ - $$) DB 0 ; Fill up 510 bytes
DW 0xAA55 ; Write magic bytes for boot loader
