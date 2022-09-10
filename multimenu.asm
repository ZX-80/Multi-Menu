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
		drawchar_func COLOR_BLUE, 11, 12, 17
		drawchar_func COLOR_BLUE, 17, 12, 'M
		drawchar_func COLOR_BLUE, 22, 12, 'u
		drawchar_func COLOR_BLUE, 27, 12, 'l
		drawchar_func COLOR_BLUE, 32, 12, 't
		drawchar_func COLOR_BLUE, 37, 12, 'i
		drawchar_func COLOR_BLUE, 42, 12, 'M
		drawchar_func COLOR_BLUE, 47, 12, 'e
		drawchar_func COLOR_BLUE, 52, 12, 'n
		drawchar_func COLOR_BLUE, 57, 12, 'u
		drawchar_func COLOR_BLUE, 61, 12, ' 
		drawchar_func COLOR_BLUE, 66, 12, 'M
		drawchar_func COLOR_BLUE, 71, 12, 'a
		drawchar_func COLOR_BLUE, 76, 12, 'd
		drawchar_func COLOR_BLUE, 81, 12, 'n
		drawchar_func COLOR_BLUE, 86, 12, 'e
		drawchar_func COLOR_BLUE, 91, 12, 's
		drawchar_func COLOR_BLUE, 96, 12, 's
		drawchar_func COLOR_BLUE, 101, 12, 16
	;  drawchar_func COLOR_BLUE, 12, 12, 17
	;  drawchar_func COLOR_BLUE, 19, 12, 'H
	;  drawchar_func COLOR_BLUE, 26, 12, 'E
	;  drawchar_func COLOR_BLUE, 33, 12, 'L
	;  drawchar_func COLOR_BLUE, 40, 12, 'l
	;  drawchar_func COLOR_BLUE, 47, 12, 'O 
	;  drawchar_func COLOR_BLUE, 54, 12, ' 
	;  drawchar_func COLOR_BLUE, 61, 12, ' 
	;  drawchar_func COLOR_BLUE, 68, 12, 't
	;  drawchar_func COLOR_BLUE, 75, 12, 'H
	;  drawchar_func COLOR_BLUE, 82, 12, 'e
	;  drawchar_func COLOR_BLUE, 89, 12, 'R
	;  drawchar_func COLOR_BLUE, 96, 12, 'E
	;  drawchar_func COLOR_BLUE, 103, 12, 16
	; drawchar_func COLOR_RED, 48, 40, $45
	; drawchar_func COLOR_RED, 48, 30, $23 ;b1

	li  $7a
    lr  7, A

loop9:
	li  COLOR_RED
    lr  1, A
	li  58
    lr  2, A
	li  28
    lr  3, A
	; DS 7
	
	lr A, 7
	ai 1
	lr 7, A

    pi  drawchar

    li 255
	lr 8, A
.plotDelay323:
	li	255
.plotDelay32:
	ai	$ff
	bnz	.plotDelay32
	DS 8
	bnz	.plotDelay323

	jmp loop9

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
charWidth: equ 5
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
     
	; DC0 = bitmapFont[8 * ascii_r]
	lr A, ascii_r
	dci bitmapFont
	adc  ; add (signed) ascii_r
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
		BM .blank_pixel
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

			jmp .pixel_draw_done

.blank_pixel:
			; PLOT PIXEL
			li	COLOR_BACKGROUND
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
.plotDelay222:
			ai	$ff
			bnz	.plotDelay222

.pixel_draw_done:
		LR A, temp_r
		SL 1
		LR temp_r, A

		DS coordX_r
		DS columnCounter_r
		BNZ .checkBit
	
	li charWidth       ; R2 += charWidth
	; inc
	as coordX_r
	lr coordX_r, A

	DS coordY_r
	DS rowCounter_r
	BNZ .drawRow
	
	; Return from the subroutine
	pop


	ORG $2800
testString: db 3, "Tic Tac Toe", 3, 0

	ORG $3000
	INCLUDE "font.h"

; special port to signal next/select/prev