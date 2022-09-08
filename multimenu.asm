    processor F8

    INCLUDE "ves.h"

    org $0800
CartridgeStart: db	$55	                ; valid cart indicator
                NOP                      ; unused byte

;Before drawing, use the screen clearing subroutine in the machine ROM ( ; means comments):
; Set Accumulator to color value
CartridgeEntry: LI  $D6  ; grey, green $C0, blue $93,  b/w $21
    ; Load register 3 with value from Accumulator
    LR  3, A
    ; Subroutine call to built-in screen clear
    PI  $00D0
    ; Routine clears with color set in r3
    ; You'll end up here after return. 

;You then load registers with:
plot_start:
    LI  $40      ;  colour
    LR  1, A
    LI  70       ; x coordinate (4-105)
    LR  2, A
    LI  30       ; y coordinate (4-61)
    LR  3, A
    PI  plot  ; Call the above plot routine

	li	20	; x
	lr	1,a
	li	20			; y
	lr	2,a
	li	$89
	lr	0,a			; combined color + char index -> r0
	pi	BIOS_DRAW_CHARACTER   

	pi drawchar

; repeat
    jmp plot_start


; save a counter by using LISL/LISU/ISAR++/ISAR--/ISAR/BR7
; load 7 lines into R7 to R13
; use br7 as row counter
; 7x7 char set, with spacing for 8x8

;r1 = colour
;r2 = x
;r3 = y
;r4 = temp
;r5 = line counter
;r6 = row counter
drawchar:
    ; Colour = red
	LI  $80
    LR  1, A

    ; Y = 20
	li	40
	lr	3,a

	; row count = 8
	li 8
	lr 6, A

	;load bytes in and plot pixels
	DCI char
.get_byte:
       
	
		; X = 20
		li	40
		lr	2,a

        ; line count = 8
		li 8
		lr 5, A

        ; A = [DC0]
		LM
		LR 4, A ; temp = A


		; check 8 bits
.check_bit
		CI $FF
		BM .blank_pixel
			; PLOT PIXEL
			; set the color using r1
			lr	A, 1
			outs	1
			; set the column using r2
			lr	A, 2
			com
			outs	4
			; set the row using r3
			lr	A, 3
			com
			outs	5
			;LR 4, A ; temp = A
			li	$60
			outs	0
			li	$50
			outs	0
			lis	6
.plotDelay2:
			ai	$ff
			bnz	.plotDelay2
.blank_pixel:

		LR A, 4 ; A = temp
		SL 1    ; A << 1
		LR 4, A ; temp = A

		DS 2
		DS 5
		BNZ .check_bit
	DS 3
	DS 6
	BNZ .get_byte
	
	; Return from the subroutine
	pop


char:
    db %00000001
    db %01100000
    db %10010100
    db %01101000
    db %00010110
    db %00101001
    db %00000110
    db %10000000


;---------------;
; Plot Function ;
;---------------;
; plot out a single point on the screen
; uses three registers as "arguments"
; r1 = set color
; r2 = x coordinate (4-105)
; r3 = y coordinate (4-61)
;------------------------
; Valid colors
;------------------------
; green	= $00 (%00000000)
; red	= $40 (%01000000)
; blue	= $80 (%10000000)
; bkg	= $C0 (%11000000)
;------------------------
plot:
	; set the color using r1
	lr	A, 1
	outs	1
	; set the column using r2
	lr	A, 2
	com
	outs	4
	; set the row using r3
	lr	A, 3
	com
	outs	5
	; transfer data to the screen memory
	li	$60
	outs	0
	li	$50
	outs	0
	; delay until it's fully updated
	lis	6					; Value here is 4 in Videocart 21, Bowling
.plotDelay:	
	ai	$ff
	bnz	.plotDelay
	pop							; return from the subroutine