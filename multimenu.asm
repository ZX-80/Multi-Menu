    PROCESSOR F8
    SEG main
    INCLUDE "header.asm"
    INCLUDE "IO.asm"
    INCLUDE "egg.asm"
    ORG $0800

cartridge_start: 
	DB $55, $2B   ; Valid cart indicator

cartridge_entry:
	LIS  0        ; Initialize hardware
	OUTS 1
	OUTS 4
	OUTS 5
	OUTS 0
	
	LI  $D6       ; Clear screen; Grey $D6, Green $C0, Blue $93, B/W $21
    LR  R3, A
    PI  BIOS_CLEAR_SCREEN 

    EI            ; Enable interrupts

; ==================================================================
; Main Program Loop
; ==================================================================
    SET_REG R9, egg_x_coord
    PRINT_C banner, COLOUR_BLUE, 14, 14
main:
    SECRET_BANNER_CHECK
    PRINT_CL game_title, COLOUR_RED, 9, 37, 20
    CHECK_INPUTS
    jmp main

; ==================================================================
; Subroutines
; ==================================================================

    drawchar_func

; ==================================================================
; Constants
; ==================================================================

banner: db 17, " MultiMenu 0.2.2", 16, 0
egg_text: db "<:3)", $1D, $1D, " ", 0
; egg_text: db "<<By 3DMAZE>> ", 0
    INCLUDE "fonts/font.asm"

; ==================================================================
; SRAM
; ==================================================================

    SEG.U sram
	ORG $2800
buttons_ctrl: res 2 ; Used for debugging in MESS/MAME (1 = next, 2 = select, 4 = previous, 8 = none)
game_title: res 1   ; The beginning of the filename C-string
