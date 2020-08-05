INCLUDE "include/hardware.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"
INCLUDE "include/console.asm"

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    CALL LCDOff

    CALL Console_Init
    CALL Console_LoadFont

    LD BC, RomBank1
    CALL Console_WriteString

    LD A, 2
    CALL SwitchRomBank
    CALL Console_Newline
    LD BC, RomBank1
    CALL Console_WriteString

    LD A, 3
    CALL SwitchRomBank
    CALL Console_Newline
    LD BC, RomBank1
    CALL Console_WriteString

    LD A, 4
    CALL SwitchRomBank
    CALL Console_Newline
    LD BC, RomBank1
    CALL Console_WriteString

    CALL LCDOn
    JP Sleep

SECTION "Bank 1", ROMX, BANK[1]
DB "From ROM Bank 1", 0
SECTION "Bank 2", ROMX, BANK[2]
DB "From ROM Bank 2", 0
SECTION "Bank 3", ROMX, BANK[3]
DB "From ROM Bank 3", 0
SECTION "Bank 4", ROMX, BANK[4]
DB "From ROM Bank 4", 0