INCLUDE "include/hardware.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"
INCLUDE "include/console.asm"

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    PUSH HL
    PUSH DE
    PUSH BC
    PUSH AF
        CALL LCDOff

        CALL ClearNintendoLogo
        CALL Console_Init
        CALL Console_LoadFont

    LD BC, A_TEXT
    CALL Console_WriteString
    POP AF
    LD B, A
    CALL Console_WriteRegister
    CALL Console_Newline

    LD BC, B_TEXT
    CALL Console_WriteString
    POP BC
    CALL Console_WriteRegister
    CALL Console_Newline
    PUSH BC
        LD BC, C_TEXT
        CALL Console_WriteString
    POP BC
    LD B, C
    CALL Console_WriteRegister
    CALL Console_Newline

    LD BC, D_TEXT
    CALL Console_WriteString
    POP DE
    LD B, D
    CALL Console_WriteRegister
    CALL Console_Newline
    LD BC, E_TEXT
    CALL Console_WriteString
    LD B, E
    CALL Console_WriteRegister
    CALL Console_Newline

    LD BC, H_TEXT
    CALL Console_WriteString
    POP HL
    LD B, H
    CALL Console_WriteRegister
    CALL Console_Newline
    LD BC, L_TEXT
    CALL Console_WriteString
    LD B, L
    CALL Console_WriteRegister
    CALL Console_Newline


    
    CALL LCDOn
    JP Sleep


SECTION "REGISTER LABELS", ROM0[$2000]
A_TEXT:
DB "A: ", 0
B_TEXT:
DB "B: ", 0
C_TEXT:
DB "C: ", 0
D_TEXT:
DB "D: ", 0
E_TEXT:
DB "E: ", 0
H_TEXT:
DB "H: ", 0
L_TEXT:
DB "L: ", 0