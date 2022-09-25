; ===================[Various useful macros]========================


; ==================================================================
; Based on VES.H 1.01
; ==================================================================
INCLUDE_VESH = 0                   ; Remove if ves.h can be provided

    IFCONST INCLUDE_VESH

;-------------------------------------------------------------------------------
; BIOS Calls

BIOS_CLEAR_SCREEN   = $00d0        ; Uses r31
BIOS_DELAY          = $008f
BIOS_PUSH_K         = $0107        ; Used to allow more subroutine stack space
BIOS_POP_K          = $011e
BIOS_DRAW_CHARACTER = $0679

;-------------------------------------------------------------------------------
; Colors

COLOR_RED           = $40
COLOR_BLUE          = $80
COLOR_GREEN         = $00
COLOR_BACKGROUND    = $C0

; Alternate (European) spellings...

COLOUR_RED          = COLOR_RED
COLOUR_BLUE         = COLOR_BLUE
COLOUR_GREEN        = COLOR_GREEN
COLOUR_BACKGROUND   = COLOR_BACKGROUND

	ENDIF

; ==================================================================
; Register aliases
; ==================================================================
R0 = 0
R1 = 1
R2 = 2
R3 = 3
R4 = 4
R5 = 5
R6 = 6
R7 = 7
R8 = 8
R9 = 9
R10 = 10
R11 = 11

; ------------------------------------------------------------------------------
; JMP_{condition} -- jump to address if condition is true
; IN: address
; OUT: None
; DESTROYS: A
    MAC JMP_EQUAL         ; A == n (zero) [signed / unsigned]
        BNZ .no_jump
        JMP {1}
.no_jump:
    ENDM
    
    MAC JMP_NOT_EQUAL     ; A != n (!zero) [signed / unsigned]
        BZ .no_jump
        JMP {1}
.no_jump:
    ENDM

    MAC JMP_LESS          ; A < n (sign != overflow and !zero) [signed]
        BZ .no_jump
        JMP_LESS_EQUAL {1}
.no_jump:
    ENDM

    MAC JMP_LESS_EQUAL    ; A <= n (sign != overflow) [signed]
        BF SV .no_jump
        BNO .jump
        BP .no_jump
.jump:  JMP {1}
.no_jump:
    ENDM

    MAC JMP_GREATER       ; A > n (sign == overflow) [signed]
        BF SV .jump
        BNO .no_jump
        BM .no_jump
.jump:  JMP {1}
.no_jump:
    ENDM

    MAC JMP_GREATER_EQUAL ; A >= n (sign == overflow or zero) [signed]
            BNZ .no_jump
            JMP {1}
.no_jump:   JMP_GREATER {1}
    ENDM

    MAC JMP_ABOVE         ; A > n (!carry) [unsigned]
        BC .no_jump
        JMP {1}
.no_jump:
    ENDM

    MAC JMP_ABOVE_EQUAL   ; A >= n (!carry or zero) [unsigned]
        BNC .jump
        BNZ .no_jump
.jump:
        JMP {1}
.no_jump:
    ENDM

    MAC JMP_BELOW         ; A < n (carry and !zero) [unsigned]
        BNC .no_jump
        BZ .no_jump
        JMP {1}
.no_jump:
    ENDM

    MAC JMP_BELOW_EQUAL   ; A <= n (carry) [unsigned]
        BNC .no_jump
        JMP {1}
.no_jump:
    ENDM

; ------------------------------------------------------------------------------
; BR_{condition} -- branch to address if condition is true
; IN: address
; OUT: None
; DESTROYS: None
    MAC BR_EQUAL         ; A == n (zero) [signed / unsigned]
        BZ {1}
    ENDM

    MAC BR_NOT_EQUAL     ; A != n (!zero) [signed / unsigned]
        BNZ {1}
    ENDM

    MAC BR_LESS          ; A < n (sign != overflow and !zero) [signed]
        BZ .no_jump
        BF SV .no_jump
        BNO {1}
        BM {1}
.no_jump:
    ENDM

    MAC BR_LESS_EQUAL    ; A <= n (sign != overflow) [signed]
        BF SV .no_jump
        BNO {1}
        BM {1}
.no_jump:
    ENDM

    MAC BR_GREATER       ; A > n (sign == overflow) [signed]
        BF SV {1}
        BNO .no_jump
        BP {1}
.no_jump:
    ENDM

    MAC BR_GREATER_EQUAL ; A >= n (sign == overflow or zero) [signed]
        BZ {1}
        BF SV {1}
        BNO .no_jump
        BP {1}
.no_jump:
    ENDM

    MAC BR_ABOVE         ; A > n (!carry) [unsigned]
        BNC {1}
    ENDM

    MAC BR_ABOVE_EQUAL   ; A >= n (!carry or zero) [unsigned]
        BNC {1}
        BZ {1}
    ENDM

    MAC BR_BELOW         ; A < n (carry and !zero) [unsigned]
        BNC .no_jump
        BNZ {1}
.no_jump:
    ENDM

    MAC BR_BELOW_EQUAL   ; A <= n (carry) [unsigned]
        BC {1}
    ENDM

; ------------------------------------------------------------------------------
; DELAY_S -- a short delay for ((time + 1) * 2.5 + (time - 1) * 3.5 + 3) cycles
; IN: time
; OUT: None
; DESTROYS: A
    MAC DELAY_S
        LI {1}         ; 2.5 cycle
.plotDelay:
        AI	$ff        ; 2.5 cycles
        BNZ	.plotDelay ; 3/3.5 cycles
    ENDM

; ------------------------------------------------------------------------------
; NOP -- do nothing for 1 cycle
; IN: None
; OUT: None
; DESTROYS: None
    MAC NOP
        DB $2B
    ENDM

; ------------------------------------------------------------------------------
; CMP -- set zero/sign flags according to the value in the accumulator
; IN: A
; OUT: zero/sign flags
; DESTROYS: None
    MAC CMP
        NI $FF
    ENDM

; ------------------------------------------------------------------------------
; ADD_REG -- add value to register
; IN: register, value
; OUT: None
; DESTROYS: A
    MAC ADD_REG
        LR A, {1}
        AI {2}
        LR {1}, A
    ENDM

; ------------------------------------------------------------------------------
; SET_REG -- set register to value
; IN: register, value
; OUT: None
; DESTROYS: A
    MAC SET_REG
        LI  {2}
        LR  {1}, A
    ENDM
