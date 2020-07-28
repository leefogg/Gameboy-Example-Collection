INCLUDE "include/hardware.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

SECTION "VBLANK INTERRUPT", ROM0[$40]
VBlank::
    JP HandleVBlank

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    CALL EnableVBlank
    CALL InitializeVariables
    EI
Sleep:
    HALT
    JR Sleep

InitializeVariables:
    LD HL, WhiteOrBlack
    LD A, 0
    LD [HL], A
    RET

HandleVBlank:
    ; Toggle WhiteOrBlack
    LD A, [HL]
    XOR $FF
    LD [HL], A

    OR A
    JP Z, SetBlackPalette
    JP SetWhitePalette

SetWhitePalette:
    LD C, LOW(rBCPS)
    LD A, 1 << 7
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    LD A, 0
    LD [$FF00+C], A
    LD [$FF00+C], A
    RETI

SetBlackPalette:
    LD C, LOW(rBCPS)
    LD A, 1 << 7
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    LD A, $FF
    LD [$FF00+C], A
    LD [$FF00+C], A
    RETI

SECTION "Variables", WRAM0
WhiteOrBlack: ds 1