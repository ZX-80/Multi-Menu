    PROCESSOR F8
    INCLUDE "ves.h"
    INCLUDE "header.asm"
    ORG $0800

CartridgeStart: 
	; valid cart indicator
	db	$55, $2B

CartridgeEntry:
	; Initialize hardware
	lis		0
	outs	1
	outs	4
	outs	5
	outs	0

	; Clear screen
	li  $D6  ; grey $D6, green $C0, blue $93,  b/w $21
    lr  R3, A
    pi  BIOS_CLEAR_SCREEN

; ==================================================================
; MAIN PROGRAM LOOP
; ==================================================================
banner: db 17, " MultiMenu Madness", 16, 0
main:
    DCI banner
    SET_REG R1, COLOR_BLUE
    SET_REG R2, 9  ; X coord (4+font_width)
    SET_REG R3, 12 ; Y coord (4+font_height)
.print_loop
    LM
    CMP
    bz .end_of_print

    LR R7, A
    XDC
    pi drawchar
    XDC

    ADD_REG R2, font_width
    jmp .print_loop
.end_of_print


    SET_REG R7, $7a

    SET_REG R9, 112  ; X coord
loop9:

    LR A, R10 ; check egg
    CI $FF
    BZ .skip_E_12
    jmp .skip_E_11
.skip_E_12
    
    SET_REG R1, COLOR_RED
    SET_REG R3, 61 ; Y coord
    DS R9

    LR A, R9
    LR R2, A
    CI 3
    BC .skip_E_0
    CI 110
    BNC .skip_E_0
    SET_REG R7, '< ; ascii
    pi drawchar
.skip_E_0:

    LR A, R2
    ai 5
    LR R2, A
    CI 3
    BC .skip_E_1
    CI 110
    BNC .skip_E_1
    SET_REG R7, ': ; ascii
    pi drawchar
.skip_E_1

    LR A, R2
    ai 5
    LR R2, A
    CI 3
    BC .skip_E_2
    CI 110
    BNC .skip_E_2
    SET_REG R7, '3 ; ascii
    pi drawchar
.skip_E_2

    LR A, R2
    ai 5
    LR R2, A
    CI 3
    BC .skip_E_3
    CI 110
    BNC .skip_E_3
    SET_REG R7, ') ; ascii
    pi drawchar
.skip_E_3

    LR A, R2
    ai 5
    LR R2, A
    CI 3
    BC .skip_E_4
    CI 110
    BNC .skip_E_4
    SET_REG R7, $1D ; ascii
    pi drawchar
.skip_E_4

    LR A, R2
    ai 5
    LR R2, A
    CI 3
    BC .skip_E_5
    CI 110
    BNC .skip_E_5
    SET_REG R7, $1D ; ascii
    pi drawchar
.skip_E_5:

    LR A, R2
    ai 5
    LR R2, A
    CI 3  ; if (A <= 3) {don't draw}
    BC .skip_E_10
    CI 110  ; if (A > 110) {don't draw}
    BNC .skip_E_11
    SET_REG R7, '  ; ascii
    pi drawchar

    jmp .skip_E_11
.skip_E_10:
    SET_REG R9, 112
    SET_REG R10, $00
.skip_E_11:
    


    DCI game_title
    SET_REG R1, COLOR_RED
    SET_REG R2, 9  ; X coord
    SET_REG R3, 37 ; Y coord
    SET_REG R8, 21 ; Max string length (102 / font_width) + 1
.print_loop2
    LM                ; While [DC0] != 0 && R8 != 0 
    CMP
    bz .end_of_print2
    DS R8
    bz .end_of_print2

    LR R7, A          ; Draw ascii char in [DC0], preserving DC0
    XDC
    pi drawchar
    XDC

    ADD_REG R2, font_width     ; X coord += font_width 
    jmp .print_loop2
.end_of_print2
    LR A, R8
    CMP
    bnz .kip
    ; set game_title + 19 to $10
    LI $FE
    ADC
    LI $10
    ST
    jmp .kip_end
.kip
    ; draw 20 - R8 spaces
    SET_REG R7, $20
    pi drawchar
    ADD_REG R2, font_width     ; X coord += font_width 
    DS R8
    bnz .kip
.kip_end

    ; INPUT
    CLR
    OUTS 0  ; enable button input
    OUTS 1  ; clear latch
    OUTS 4  ; clear latch
    DCI $2800
    ;INS 0  ; buttons (xxxx4321)
    INS 1  ; right (push, pull, clockwise, counter-clockwise, forward, back, left, right)
    LR R4, A ; R4 = right
    INS 4    ; left  (push, pull, clockwise, counter-clockwise, forward, back, left, right)
    NS R4    ; left & right
    COM
    LR R4, A ; R4 = left & right

readbuts:       ins  0                    ; $00C1 - read buttons
                com                       ; Invert port data, 1 now means pushed
                ni   $0F                  ; Just keep button data
                lr   R6, A                ; Button indata now in R6

                NI 1
                bz .check_button_2
                    LR A, R4
                    OI prev_mask
                    LR R4, A
.check_button_2
                LR A, R6
                NI 2
                bz .check_button_3
                    LR A, R4
                    OI next_mask
                    LR R4, A
.check_button_3
                LR A, R6
                NI 4
                bz .check_button_4
                    LR A, R4
                    OI select_mask
                    LR R4, A
.check_button_4
                LR A, R6
                NI 8
                bz .check_button_end
                    LR A, R4
                    OI select_mask
                    LR R4, A
.check_button_end

                SET_REG R5, $FF
debounce:       ds   R5
                bnz  debounce

    ; next = 11011010 = clockwise, back, right, 2
    ; prev = 11100101 = counter-clockwise, forward, left, 1
    ; select = 00111111 = push, pull, 3, 4

; 11011011 n
; 00100101 m
; 00000001

    LR A, R4
    XI $03
    BNZ .skip_E_99
    SET_REG R10, $FF
.skip_E_99

next_mask = %00100101
prev_mask = %00011010
select_mask = %11000000

    LR A, R4
    NI next_mask
    bz .check_prev
        LI 2
        ST ; OUT $FF
        jmp .check_end
.check_prev:
    LR A, R4
    NI prev_mask
    bz .check_select
        LI 4
        ST ; OUT $FF
        jmp .check_end
.check_select:
    LR A, R4
    NI select_mask
    bz .key_up
        LI 1
        ST ; OUT $FF
        jmp .check_end
.key_up:
    LI 3
    ST   ; OUT $FF
    
.check_end:
    LI $55  ; IN $FF 
    CM      ; CI $55
    BNZ .no_jump
    jmp $0000
.no_jump:

;     SET_REG R1, COLOR_RED
;     SET_REG R2, 58
;     SET_REG R3, 28
	
;     ADD_REG R7, 1

;     pi  drawchar

;     li 255
; 	lr 8, A
; .plotDelay323:
; 	li	255
; .plotDelay32:
; 	ai	$ff
; 	bnz	.plotDelay32
; 	DS 8
; 	bnz	.plotDelay323

	jmp loop9

    jmp main
    
; ------------------------------------------------------------------------------
; drawchar -- draw an ascii character to the screen
; IN: r1 = set color
;     r2 = x coordinate (4-105)
;     r3 = y coordinate (4-61)
;     r7 = ascii char
; OUT: None
; DESTROYS: A, DC0, r4, r5, r6
drawchar: SUBROUTINE

drawchar.colour_r = 1 ; Cannot use local labels, as they don't work in macros
drawchar.coordX_r = 2
drawchar.coordY_r = 3
drawchar.temp_r = 4
drawchar.columnCounter_r = 5
drawchar.rowCounter_r = 6
drawchar.ascii_r = 7

    SET_REG drawchar.rowCounter_r, font_height
     
	; DC0 = bitmapFont[8 * .ascii_r]
	lr A, drawchar.ascii_r
	dci bitmapFont
	adc  ; add (signed) .ascii_r
	adc
	adc
	adc
	adc
	adc
	adc
	adc

.drawRow:
		SET_REG drawchar.columnCounter_r, font_width
		LM ; A = [DC0++]
		LR drawchar.temp_r, A

.checkBit
		CMP ; Check MSB set
		BP .blank_pixel
			; PLOT PIXEL
			lr	A, drawchar.colour_r
			outs	1
			lr	A, drawchar.coordX_r
			com
			outs	4
			lr	A, drawchar.coordY_r
			com
			outs	5
			li		$60
			outs	0
			li		$50
			outs	0

            DELAY_S 6

			jmp .pixel_draw_done

.blank_pixel:
			; PLOT PIXEL
			li	COLOR_BACKGROUND
			outs	1
			lr	A, drawchar.coordX_r
			com
			outs	4
			lr	A, drawchar.coordY_r
			com
			outs	5
			li		$60
			outs	0
			li		$50
			outs	0

            DELAY_S 6

.pixel_draw_done:
		LR A, drawchar.temp_r
		SL 1
		LR drawchar.temp_r, A

		DS drawchar.coordX_r
		DS drawchar.columnCounter_r
		BNZ .checkBit
        ADD_REG drawchar.coordX_r, font_width

	DS drawchar.coordY_r
	DS drawchar.rowCounter_r
	BNZ .drawRow
    ADD_REG drawchar.coordY_r, font_height
	
	pop

; ==================================================================
; SRAM
; ==================================================================

	ORG $2800
buttons_ctrl: db 0
response: db 0
game_title: db 0

; ==================================================================
; Font data
; ==================================================================

	ORG $3000
	INCLUDE "fonts/font.asm"

; DONE: display string at $2801
; DONE: write 0 to port/memory when user moves left
; DONE: write 1 to port/memory when user pushes
; TODO: Then transition into another ROM safely
;       1. Pico changes $800 to $00
;     √ 2  menu waits until port/memory is 3 (READY)
;     √ 3. menu jumps to $0000
;     √ 4. channel F will stay in check loop becaues there is no $55 at $800
;       5. During this time, we're free to rewrite all memory (except $800)
;       6. When we're done, we write $55 to $800, and the channel F does the rest
; DONE: write 2 to port/memory when user moves right