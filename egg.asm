; ==================[Handles secret banner]=========================

egg_x_coord = 112
egg_y_coord = 59

    MAC SECRET_BANNER_CHECK

    LR A, R10                  ; Check flag
    CI $FF
    JMP_NOT_EQUAL EGG.skip_egg

    SET_REG R1, COLOUR_RED     ; Colour
    SET_REG R3, egg_y_coord    ; Y coord
    DS R9
    DS R9

    DCI egg_text               ; String address
    SET_REG R1, COLOUR_RED     ; Colour
    LR A, R9                   ; X coord
    LR R2, A
    SET_REG R3, egg_y_coord    ; Y coord

.print_loop:
    LM                         ; Load char
    LR R7, A
    CI 0
    BR_EQUAL EGG.end_of_print  ; End if char is null

    LR A, R2                   ; Print if 3 < X <= 110
    CI 3
    BR_BELOW_EQUAL EGG.next_char
    CI 110
    BR_ABOVE EGG.next_char

    XDC                        ; Preserve DC0
    PI drawchar
    XDC                        ; Restore DC0

EGG.next_char:
    ADD_REG R2, font_width     ; X += font width 
    JMP .print_loop
EGG.end_of_print:

    LR A, R2                   ; Deactivate if X <= font_width*2
    CI font_width*2
    BR_ABOVE EGG.skip_egg
    SET_REG R9, egg_x_coord
    SET_REG R10, 0

EGG.skip_egg:

    ENDM