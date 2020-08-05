INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

SECTION "VBLANK INTERRUPT", ROM0[$40]
VBlank::
    JP HandleVBlank

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    CALL LCDOff

    CALL SetupPalette
    CALL MakeTiles
    CALL CreateSprite
    CALL CreateBackground

    CALL EnableSprites
    CALL EnableVBlank

    CALL LCDOn
    EI
    JP Sleep

MakeTiles:
    LD DE, IndexedTileData_Start
    LD HL, _VRAM
    LD BC, IndexedTileData_End - IndexedTileData_Start
    CALL MEMCOPY
    RET

SetupPalette:
    LD HL, RandomData_Start ; Copy code as palette data
    LD C, LOW(rBCPS)
    LD A, %10000000
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    REPT 4 * 2
        LD A, [HL+]
        LD [$FF00+C], A
    ENDR

    ; Black sprite
    LD C, LOW(rOCPS)
    LD A, %10000000
    LD [$FF00+C], A
    LD C, LOW(rOCPD)
    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A

    RET

CreateSprite:
    ; Clear variables' state
    LD A, 0
    LD HL, SpritePosY
    LD [HL+], A
    LD [HL+], A
    LD A, 1
    LD [HL+], A
    LD [HL+], A
    RET

CreateBackground:
    LD DE, RandomData_Start
    LD HL, _SCRN0
    LD BC, RandomData_End - RandomData_Start
.Loop
    LD A, [DE]
    AND %00000011
	LD [HL+], A
	INC DE
	DEC BC
    
	LD A, B
	CP 0
	JR NZ, .Loop
	LD A, C
	CP 0
	JR NZ, .Loop
    RET

HandleVBlank:
    CALL RenderSrite
    CALL UpdateSprite
    CALL ToggleSpritesEnabled
    RETI

UpdateSprite:
    LD DE, $0000 - 2
    LD HL, SpriteDirY
    LD A, [HL]
    ADD HL, DE
    ADD [HL]
    LD [HL], A
    LD HL, SpriteDirX
    LD A, [HL]
    ADD HL, DE
    ADD [HL]
    LD [HL], A
    RET

RenderSrite:
    LD HL, _OAMRAM
    LD DE, SpritePosY
    LD A, [DE]
    INC DE
    ADD A, 16
    LD [HL+], A ; SpritePosY
    LD A, [DE]
    INC DE
    ADD A, 8
    LD [HL+], A ; SpritePosX
    LD A, 3
    LD [HL+], A
    LD A, 0
    LD [HL+], A
    RET

IndexedTileData_Start:
DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
DB $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF
DB $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
DB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
IndexedTileData_End:

RandomData_Start:
INCBIN "res/font.png"
RandomData_End:

SECTION "Variables", WRAM0
SpritePosY: ds 1
SpritePosX: ds 1
SpriteDirY: ds 1
SpriteDirX: ds 1
