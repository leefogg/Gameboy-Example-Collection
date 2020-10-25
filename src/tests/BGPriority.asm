INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

SECTION "VBLANK INTERRUPT", ROM0[$40]
VBlank:
    JP HandleVBlank

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    CALL LCDOff

    CALL SetupTiles
    CALL SetupPalette
    CALL CreateSprite
    CALL CreateBackground

    CALL EnableSprites
    CALL EnableVBlank

    CALL LCDOn
    EI
    JP Sleep

SetupTiles:
    LD HL, _VRAM + $10
    LD DE, SpriteGraphic
    LD BC, 16
    CALL MEMCOPY

    RET

SetupPalette:
    LD A, 1 << 7
    LD C, LOW(rBCPS)
    LD [$FF00+C], A
    LD C, LOW(rBCPD)

    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A

    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD A, $10
    LD [$FF00+C], A
    LD A, $42
    LD [$FF00+C], A
    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A

    LD A, 1 << 7
    LD C, LOW(rOCPS)
    LD [$FF00+C], A
    LD C, LOW(rOCPD)

    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD A, $1F
    LD [$FF00+C], A
    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A

    RET

CreateBackground:
    ; Set 2 BG tiles to use palette 1 and to be above the sprite
    CALL SwitchToBank1
        LD HL, _SCRN0 + $E5
        LD A, 1 | OAMF_PRI
        LD [HL], A
        INC HL
        LD [HL], A
    CALL SwitchToBank0

    ; Set 2 BG tiles to use tile 1
    LD HL, _SCRN0 + $E5
    LD [HL], 1
    INC HL
    LD [HL], 1
    RET

CreateSprite:
    ; Set sprite's Y and tile index
    LD HL, _OAMRAM
    LD [HL], 70
    INC HL
    INC HL
    LD [HL], 1

    RET

HandleVBlank:
    ; Move sprite's X
    LD HL, _OAMRAM + 1
    LD A, [HL]
    INC A
    AND %01111111
    LD [HL], A

    RETI

SECTION "SPRTEGRAPHIC", ROM0
SpriteGraphic:
DB $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00