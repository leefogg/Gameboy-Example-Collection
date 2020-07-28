INCLUDE "include/hardware.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"
INCLUDE "include/console.asm"

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    ; Turn off LCD
    LD HL, rLCDC
	RES 7, [HL]

    CALL DetermineConsole

    PUSH BC
        CALL ClearNintendoLogo
        CALL Console_Init
        CALL Console_LoadFont
    POP BC

    CALL Console_WriteString
    
    ; Turn on LCD
    LD HL, rLCDC
	SET 7, [HL]
Sleep:
    HALT
    JR Sleep

DetermineConsole:
    BIT 5, A
    JR NZ, .IsGB
    BIT 0, B
    JR Z, .IsGBC
    LD BC, GBA
    RET
.IsGBC:
    LD BC, GBC
    RET
.IsGB:
    LD BC, GB
    RET

SECTION "FONT", ROM0[$1000]
FontStart:
    INCBIN "res/font.2bbp"
FontEnd:

SECTION "Console Names", ROM0
GB:
DB "Gameboy", 0
GBC:
DB "Gameboy Color", 0
GBA:
DB "Gameboy Advance", 0