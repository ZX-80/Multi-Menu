    PROCESSOR F8
    INCLUDE "ves.h"
    ORG $0800

CartridgeStart: 
	; valid cart indicator
	db	$55, $00

CartridgeEntry:
	; Initialize hardware
	lis		0
	outs	1
	outs	4
	outs	5
	outs	0

	; Clear screen
	li  $D6  ; grey $D6, green $C0, blue $93,  b/w $21
    lr  3, A
    pi  BIOS_CLEAR_SCREEN

main:
	drawchar_func COLOR_BLUE, 40, 40, 1
	drawchar_func COLOR_RED, 48, 40, 0
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
ascii_r: equ 7
columnCounter_r: equ 5
rowCounter_r: equ 6
temp_r: equ 4
	MAC drawchar_func
		li  {1}  ; colour = blue
		lr  1, A
		li	{2}  ; X = 20
		lr	2, A
		li	{3}  ; Y = 20
		lr	3, A
		li	{4}  ; char = sigma
		lr	7, A
		pi drawchar
	ENDM
drawchar: SUBROUTINE
	li  charHeight
	lr  rowCounter_r, A
     
	; DC0 = charSet[8 * ascii_r]
	lr A, ascii_r
	dci charSet
	adc
	adc
	adc
	adc
	adc
	adc
	adc
	adc

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



charSet:
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

	ORG $2800
testString: db "Tic Tac Toe", 0

; special port to signal next/select/prev