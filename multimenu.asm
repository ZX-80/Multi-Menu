    PROCESSOR F8
    INCLUDE "ves.h"
    ORG $0800

CartridgeStart: 
	; valid cart indicator
	db	$55, $00

CartridgeEntry:
	; Initialize hardware
	lis		$0
	outs	1
	outs	4
	outs	5
	outs	0

	; Clear screen
	li  $D6  ; grey $D6, green $C0, blue $93,  b/w $21
    lr  3, A
    pi  BIOS_CLEAR_SCREEN

main:
	li  COLOR_BLUE  ; colour = blue
    lr  1, A
	li	40          ; X = 20
	lr	2, A
	li	40          ; Y = 20
	lr	3, A
	pi drawchar

    jmp main


;---------------;
; Char Function ;
;---------------;
; draw a single char on the screen
; r1 = set color
; r2 = x coordinate (4-105)
; r3 = y coordinate (4-61)
; r7 = ascii char
;------------------------
; r4 = temp
; r5 = line counter
; r6 = row counter
;------------------------
charHeight: equ 8
charWidth: equ 8
colour_r: equ 1
coordX_r: equ 2
coordY_r: equ 3
columnCounter_r: equ 5
rowCounter_r: equ 6
temp_r: equ 4
drawchar: SUBROUTINE
	li  charHeight
	lr  rowCounter_r, A

	DCI charSet

.drawRow:
		li charWidth
		lr columnCounter_r, A
		LM ; A = [DC0++]
		LR temp_r, A

.checkBit
		CI $FF ; Check MSB set
		BM .skipDraw
			; PLOT PIXEL
			lr	A, colour_r
			outs	1
			lr	A, coordX_r
			com
			outs	4
			lr	A, coordY_r
			com
			outs	5
			li		$60
			outs	0
			li		$50
			outs	0

			lis	6
.plotDelay2:
			ai	$ff
			bnz	.plotDelay2

.skipDraw:
		LR A, temp_r
		SL 1
		LR temp_r, A

		DS coordX_r
		DS columnCounter_r
		BNZ .checkBit
	
	li 8       ; R2 += 8
	as coordX_r
	lr coordX_r, A

	DS coordY_r
	DS rowCounter_r
	BNZ .drawRow
	
	; Return from the subroutine
	pop

asciiTooAddress:
	; K = ascii * 8
		; KL = ascii
		; K << 3
			; KL << 1
			; KU += carry
	; DC0 -> Q
	; QL = KL + QL
	; QU = KU + QU + carry
	; DC0 <- Q


; DC0 = charSet = 0xUU00
; ascii = 0 to 127
	; 011 11111 00000000
	; 0AA BBBBB 00000000
	; DC0 += BBBBB000
	

    ; assume A is the ascii char
	; DC0 = charSet[8 * ascii]
	; DCI charSet
	; ADC
	; ADC
	; ADC
	; ADC
	; ADC
	; ADC
	; ADC
	; ADC


	ALIGN 256
charSet: ; 0x??00
	; Percentage
    db %00000001
    db %01100000
    db %10010100
    db %01101000
    db %00010110
    db %00101001
    db %00000110
    db %10000000

	; Sum
    db %00000000
    db %00111110
    db %00100010
    db %00010000
    db %00001100
    db %00010000
    db %00100010
    db %00111110
