INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

SECTION "VBlank Interrupt", ROM0[$40]
VBlank:
    JP HandleVBlank

SECTION "HBLANK INTERRUPT", ROM0[$48]
HBlank:
    JP HandleHBlank

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    CALL LCDOff
    CALL CopySprite
    CALL SetupPalette
    
    CALL CreateSprites
    CALL CreatePositions

    CALL EnableVBlank
    CALL EnableHBlank
    CALL EnableSprites
    CALL LCDOn
    EI
    JP Sleep

CopySprite:
    LD DE, StarSprite
    LD HL, _VRAM
    LD BC, 16
    CALL MEMCOPY
    RET

CreateSprites:
    LD DE, OAMData
    LD HL, _OAMRAM
    LD BC, 4
    CALL MEMCOPY
    RET

SetupPalette:
    LD A, 1 << 7
    LD C, LOW(rOCPS)
    LD [$FF00+C], A
    LD C, LOW(rOCPD)

    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
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
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD A, $08
    LD [$FF00+C], A
    LD A, $21
    LD [$FF00+C], A

    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A

    RET

CreatePositions:
    LD DE, RandomData
    LD HL, XPositions
    LD BC, 144
    CALL MEMCOPY
    RET

HandleVBlank:
    LD L, 0
    LD B, HIGH(RandomSpeeds)
    LD C, HIGH(XPositions)
    REPT 144
        LD H, B
        LD A, [HL]
        LD H, C
        ADD [HL]
        LD [HL], A

        INC L
    ENDR

    LD L, 0
    LD B, 16 ; Sprite height + 1 for next scanline
    LD C, LOW(rLY)


    RETI
HandleHBlank:

    LD DE, _OAMRAM

    ; Set sprite y to next scanline
    LD A, [C]
    ADD B
    LD [DE], A

    ; Set sprite x to its position
    INC E
    LD H, HIGH(XPositions)
    LD A, [HL]
    LD [DE], A

    ; Set Palette from speed
    INC E
    INC E
    LD H, HIGH(RandomSpeeds)
    LD A, [HL]
    DEC A
    LD [DE], A


    INC L
    RETI

SECTION "RandomData", ROM0, ALIGN[8]
RandomData:
DB $5F, $26, $77, $C, $FE, $66, $63, $40, $F6, $54, $BA, $CD, $C6, $D0, $B7, $D1, $C5, $23, $E1, $4, $1F, $8B, $4E, $EB, $B0, $60, $A6, $90, $B8, $3E, $97, $14, $18, $44, $4B, $F, $AA, $6A, $BF, $17, $AD, $3C, $29, $F5, $B, $59, $5B, $C7, $3B, $22, $D5, $A4, $75, $F3, $19, $78, $20, $D8, $15, $4C, $86, $64, $B9, $16, $B6, $A, $1, $2C, $41, $E8, $A3, $DA, $8D, $8E, $21, $AF, $58, $3D, $E3, $D9, $76, $CF, $70, $80, $25, $FA, $DC, $D6, $CC, $D4, $12, $E0, $A0, $1C, $A5, $9D, $6E, $E9, $82, $2E, $F0, $85, $2B, $32, $74, $96, $39, $D3, $7E, $9E, $B1, $F8, $F7, $43, $A2, $7B, $2, $4A, $E7, $9A, $C9, $E2, $D2, $10, $AC, $73, $1B, $AE, $95, $27, $F1, $13, $F2, $71, $EE, $C8, $79, $31, $B3, $98, $92, $B5, $61, $72, $1D, $3, $83, $56, $A9, $EF, $24, $CE, $C4, $2D, $50, $49, $4F, $6C, $87, $93, $7A, $6F, $69, $94, $5D, $1A, $30, $7C, $81, $E, $42, $D, $8F, $9, $C2, $A1, $A8, $47, $3F, $28, $7D, $E5, $2F, $6, $BC, $5, $0, $EA, $DB, $9F, $11, $65, $EC, $53, $1E, $51, $3A, $A7, $DF, $C3, $34, $62, $8A, $52, $B4, $ED, $F9, $88, $35, $AB, $CB, $68, $5E, $C0, $4D, $38, $55, $8C, $2A, $48, $46, $B2, $F4, $89, $99, $37, $8, $FD, $9C, $E6, $9B, $DD, $5C, $84, $57, $36, $BD, $FC, $E4, $BE, $FB, $33, $D7, $5A, $45, $7, $6B, $CA, $C1, $91, $BB, $7F, $6D, $DE, $67
SECTION "RandomSpeeds", ROM0, ALIGN[8]
RandomSpeeds:
DB 2, 1, 1, 2, 3, 2, 2, 1, 2, 1, 3, 3, 3, 3, 1, 1, 2, 3, 2, 3, 3, 1, 1, 2, 3, 3, 1, 3, 1, 1, 1, 1, 1, 2, 1, 2, 2, 1, 3, 1, 3, 2, 1, 3, 1, 3, 1, 3, 1, 3, 1, 2, 3, 2, 2, 2, 3, 3, 3, 1, 1, 2, 3, 1, 1, 2, 3, 1, 3, 2, 2, 2, 3, 2, 3, 1, 1, 1, 1, 3, 3, 1, 3, 1, 1, 2, 1, 3, 1, 3, 3, 2, 2, 3, 1, 1, 3, 3, 3, 2, 1, 3, 1, 2, 1, 3, 3, 2, 2, 1, 2, 3, 3, 3, 2, 3, 2, 2, 1, 3, 2, 3, 1, 3, 3, 3, 3, 3, 2, 3, 2, 1, 2, 2, 2, 3, 1, 2, 1, 1, 2, 3, 1, 3, 2, 3, 3, 2, 2, 2, 2, 1, 3, 3, 1, 2, 3, 1, 3, 2, 3, 3, 1, 3, 3, 1, 1, 1, 2, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 2, 3, 1, 2, 2, 2, 2, 1, 3, 3, 3, 3, 2, 3, 2, 1, 1, 1, 3, 3, 1, 3, 3, 2, 2, 3, 3, 2, 2, 3, 3, 3, 1, 2, 2, 1, 3, 2, 3, 3, 3, 2, 3, 3, 2, 3, 2, 2, 1, 2, 1, 1, 1, 1, 1, 2, 1, 2, 3, 3, 3, 3, 2, 1, 1, 3, 2, 3, 1, 2, 2, 2, 2, 3
SECTION "GeneralData", ROM0, ALIGN[8]
StarSprite:
DB $00, $00, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
OAMData:
DB 0, 0, 0, 0


SECTION "Variables", WRAM0
XPositions: ds 144