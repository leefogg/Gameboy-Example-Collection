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

    CALL Console_Init
    CALL Console_LoadFont

    LD BC, RomBank1
    CALL Console_WriteString

    LD HL, rROMB0
    LD A, 1
    LD [HL], A
    CALL Console_Newline
    LD BC, RomBank1
    CALL Console_WriteString

    LD HL, rROMB0
    LD A, 2
    LD [HL], A
    CALL Console_Newline
    LD BC, RomBank1
    CALL Console_WriteString

    LD HL, rROMB0
    LD A, 3
    LD [HL], A
    CALL Console_Newline
    LD BC, RomBank1
    CALL Console_WriteString

    
    ; Turn on LCD
    LD HL, rLCDC
	SET 7, [HL]
Sleep:
    HALT
    JR Sleep

SECTION "FONT", ROM0[$1000]
FontStart:
    INCBIN "res/font.2bbp"
FontEnd:

SECTION "Bank 1", ROMX, BANK[1]
DB "From ROM Bank 1", 0
SECTION "Bank 2", ROMX, BANK[2]
DB "From ROM Bank 2", 0
SECTION "Bank 3", ROMX, BANK[3]
DB "From ROM Bank 3", 0
SECTION "Bank 4", ROMX, BANK[4]
DB "From ROM Bank 4", 0