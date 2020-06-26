INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

; DE - Origin
CopyImage::
    LD HL, _SCRN0 - 1
    LD B, 18
    LD C, 20

.Loop
    INC HL
    LD A, [DE]
    INC DE
    ;LD A, 29
    LD [HL], A

    DEC C
    JR NZ, .Loop
    LD C, 20

    DEC B
    RET Z

    PUSH BC
        LD BC, 32 - 20
        ADD HL, BC
    POP BC

    JR .Loop

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
     ; Turn off LCD
    LD HL, rLCDC
	RES 7, [HL]

    CALL CopyPalette
    CALL CopyTiles
    CALL CopyMap

    ; Turn on LCD
    LD HL, rLCDC
	SET 7, [HL]
Sleep:
    HALT
    JR Sleep

CopyTiles:
    LD DE, TileData
    LD HL, _VRAM
    LD BC, TileData_End - TileData
    CALL MEMCOPY
    RET

CopyMap:
    LD DE, MapData
    LD C, $FF
    CALL CopyImage
    RET

CopyPalette:
    LD C, rBCPS
    LD A, %10000000
    LD [$FF00+C], A
    
    LD HL, PaletteData
    LD C, rBCPD
    REPT 8
        LD A, [HL+]
        LD [$FF00+C], A
    ENDR
    RET

SECTION "Data", ROM0
TileData:
INCBIN "res/gameboy.2bbp"
TileData_End:
MapData:
INCBIN "res/gameboy.tilemap"
MapData_End:
PaletteData:
INCBIN "res/gameboy.pal"
PaletteData_End: