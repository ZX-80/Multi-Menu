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

    MAC status
        w
    ENDM
    MAC flag
        w
    ENDM

; ------------------------------------------------------------------------------
; DELAY_S -- a short delay for ((time + 1) * 2.5 + (time - 1) * 3.5 + 3) cycles
; IN: time
; OUT: None
; DESTROYS: A
    MAC DELAY_S
        li {1}         ; 2.5 cycle
.plotDelay:
        ai	$ff        ; 2.5 cycles
        bnz	.plotDelay ; 3/3.5 cycles
    ENDM

; ------------------------------------------------------------------------------
; NOP -- do nothing for 1 cycle
; IN: None
; OUT: None
; DESTROYS: None
    MAC NOP
        db $2B
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
        lr A, {1}
        ai {2}
        lr {1}, A
    ENDM

; ------------------------------------------------------------------------------
; SET_REG -- set register to value
; IN: register, value
; OUT: None
; DESTROYS: A
    MAC SET_REG
        li  {2}
        lr  {1}, A
    ENDM