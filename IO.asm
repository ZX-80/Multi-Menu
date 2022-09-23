; ===============================[IO macros]====================================

; ------------------------------------------------------------------------------
; PRINT_C -- print a C-string to the screen
; IN: string_address, colour, X, Y
; OUT: None
; CALLS: drawchar
; DESTROYS: A, R1, R2, R3, DC0
    MAC PRINT_C

    DCI {1}                 ; String address
    SET_REG R1, {2}         ; Colour
    SET_REG R2, {3}         ; X coord
    SET_REG R3, {4}         ; Y coord

.print_loop:
    LM                      ; Load char
    CMP
    BZ .end_of_print        ; End if char is null

    LR R7, A
    XDC                     ; Preserve DC0
    PI drawchar
    XDC                     ; Restore DC0

    ADD_REG R2, font_width  ; X += font width 
    BR .print_loop
.end_of_print:

    ENDM

; ------------------------------------------------------------------------------
; PRINT_CL -- print a C-string up to a fixed length to the screen
; IN: string_address, colour, X, Y, length
; OUT: None
; CALLS: drawchar
; DESTROYS: A
    MAC PRINT_CL

    DCI {1}                 ; String address
    SET_REG R1, {2}         ; Colour
    SET_REG R2, {3}         ; X coord
    SET_REG R3, {4}         ; Y coord
    SET_REG R8, {5}         ; Max string length

.print_loop:
    LM                      ; While [DC0] != 0 && R8 != 0 
    CMP
    BZ .end_of_print
    DS R8
    BZ .end_of_print

    LR R7, A                ; Draw ascii char in [DC0], preserving DC0
    XDC
    PI drawchar
    XDC

    ADD_REG R2, font_width  ; X coord += font_width 
    BR .print_loop
.end_of_print:

    LR A, R8                ; Draw an arrow to show the string was truncated
    CMP
    BNZ .skip_arrow
    LI $FE                  ; DC0 -= 2
    ADC
    LI $10                  ; [DC0] = "►"
    ST
    BR .skip_spaces
.skip_arrow:
    SET_REG R7, '           ; Pad with spaces
    PI drawchar
    ADD_REG R2, font_width  ; X coord += font_width 
    DS R8
    BNZ .skip_arrow
.skip_spaces:

    ENDM


; ------------------------------------------------------------------------------
; drawchar -- draw an ascii character to the screen
; IN: r1 = set colour
;     r2 = x coordinate (4-105)
;     r3 = y coordinate (4-61)
;     r7 = ascii char
; OUT: None
; DESTROYS: A, DC0, r4 (row data), r5 (column counter), r6 (row counter)
    MAC drawchar_func
drawchar: SUBROUTINE
	LR A, R7                   ; DC0 = &bitmapFont[8 * char]
	DCI bitmapFont
	ADC
	ADC
	ADC
	ADC
	ADC
	ADC
	ADC
	ADC

    SET_REG R6, font_height    ; Row counter = font_height
.draw_row:
    SET_REG R5, font_width     ; Column counter = font_width
    LM
    LR R4, A                   ; Row data = [DC0]

.check_bit:
        CMP                        ; Check MSB set
        LR	A, R1                  ; Colour
        BM .draw_pixel
        LI	COLOUR_BACKGROUND
.draw_pixel:
        OUTS 1                     ; Set pixel colour
        LR A, R2                   ; Set pixel X-coord
        COM
        OUTS 4
        LR A, R3                   ; Set pixel Y-coord
        COM
        OUTS 5
        LI $60                     ; Execute write to video RAM
        OUTS 0
        LI $50
        OUTS 0
        DELAY_S 6                  ; Delay until fully updated (4 in Videocart 21, Bowling)

        LR A, R4                   ; Row data << 1
        SL 1
        LR R4, A

        DS R2                      ; X-coord -= 1
        DS R5                      ; Column counter -= 1
        BNZ .check_bit             ; Repeat until column counter = 0
        ADD_REG R2, font_width     ; X-coord += 5

	DS R3                      ; Y-coord -= 1
	DS R6                      ; Row counter -= 1
	BNZ .draw_row              ; Repeat until row counter = 0
    ADD_REG R3, font_height    ; Y-coord += 5
	
	pop

    ENDM

; ------------------------------------------------------------------------------
; CHECK_INPUTS -- send Channel F inputs to Pico
; IN: None
; OUT: R10
; DESTROYS: A, DC0, R4 (controllers), R6 (buttons), R5 (debounce)
    MAC CHECK_INPUTS
    CLR
    OUTS 0                 ; Enable button input
    OUTS 1                 ; Clear latch
    OUTS 4                 ; Clear latch
    DCI buttons_ctrl
    
    INS 1                  ; Right (push, pull, clockwise, counter-clockwise, forward, back, left, right)
    LR R4, A               ; R4 = right
    INS 4                  ; Left  (push, pull, clockwise, counter-clockwise, forward, back, left, right)
    NS R4                  ; Left & right
    COM
    LR R4, A               ; R4 = !(left & right)

    INS  0                 ; Read buttons (xxxx4321)
    COM
    NI   $0F               ; R6 = button data
    LR   R6, A

    SL 4
    BM .select             ; Button 4
    SL 1
    BM .select             ; Button 3
    SL 1
    BM .next               ; Button 2
    SL 1
    BM .previous           ; Button 1

    LR A, R4
    CMP
    BM .select             ; Push
    SL 1
    BM .select             ; Pull
    SL 1
    BM .next               ; Clockwise
    SL 1
    BM .previous           ; Counter-clockwise
    SL 1
    BM .previous           ; Forward
    SL 1
    BM .next               ; Back
    SL 1
    BM .previous           ; Left
    SL 1
    BM .next               ; Right
    BR .none


.next:                     ; Next file
    LI 1
    BR .send_command
.select:                   ; Selection was made
    LI 2
    ST
    OUT $FF
    jmp $0000
    BR .skip_send_command  
.previous:                 ; Previous file
    LI 4
    BR .send_command
.none:                     ; No command
    LI 8
.send_command:
    ST
    OUT $FF
.skip_send_command:

    SET_REG R5, $FF        ; Debounce
.debounce:
    DS R5
    BNZ .debounce

    LR A, R4               ; Load left/right controller inputs
    XI $03                 ; R10 = $FF if the left/right controls are opposing
    BNZ .skip_egg
    SET_REG R10, $FF
.skip_egg

    ENDM