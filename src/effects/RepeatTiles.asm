INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"
INCLUDE "include/console.asm"

SECTION "HBLANK INTERRUPT", ROM0[$48]
    JP HandleHBlank

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    ; Turn off LCD
    LD HL, rLCDC
	RES 7, [HL]

    CALL Console_LoadFont

    LD HL, _SCRN0
    LD BC, 31
    LD D, $11

    ; Write 12 on every row
    REPT SCRN_Y_B
        LD A, D
        LD [HL+], A
        INC A
        LD [HL], A
        ADD HL, BC
    ENDR

    CALL EnableHBlank

    ; Turn on LCD
    LD HL, rLCDC
	SET 7, [HL]
    EI
Sleep:
    HALT
    JR Sleep

HandleHBlank:
    LD C, LOW(rSCX)
    LD A, 0
    LD B, 16

    NOPS 54

    ; Mode 3 starts here
    ; Every 16 cycles, move the screen 16 pixels to the left so the same 16 pixels are drawn
    ; This should result in the screen being full of 12
    REPT 10
        LD [$FF00+C], A ; 2
        NOP             ; 1
        SUB A, B        ; 1 
        ; Total: 4 (16)
    ENDR

    RETI

SECTION "FONT", ROM0[$1000]
FontStart:
    INCBIN "res/font.2bpp"
FontEnd: