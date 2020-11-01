INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

SECTION "VBlank Interrupt", ROM0[$40]
HandleVBlank:
    JP VBlank

SECTION "HBLANK INTERRUPT", ROM0[$48]
HandleHBlank:
    JP HBlank

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    CALL LCDOff

    CALL CopyPalette
    CALL CopyTiles
    CALL CopyMap

    CALL InitVars
    CALL EnableVBlank
    CALL EnableHBlank
    CALL LCDOn

    EI
    JP Sleep

CopyTiles:
    LD DE, TileData
    LD HL, _VRAM
    LD BC, TileData_End - TileData
    CALL MEMCOPY
    RET

CopyMap:
    LD DE, MapData
    CALL CopyImage
    RET

CopyPalette:
    LD C, LOW(rBCPS)
    LD A, %10000000
    LD [$FF00+C], A
    
    LD HL, PaletteData
    LD C, LOW(rBCPD)
    REPT 8
        LD A, [HL+]
        LD [$FF00+C], A
    ENDR
    RET

;DE - Origin
CopyImage:
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

InitVars:
    LD HL, ScanlineIndicies
    LD A, 0
    LD C, 144
    CALL MEM_FILL

    RET

VBlank:
    LD A, 0
    LDH [$FF00+LOW(rSCY)], A

    LD HL, SineStartIndex
    LD A, [HL]
    LD H, HIGH(SINETABLE)           ; HL = Sine index
    LD L, A
    LD D, HIGH(ScanlineIndicies)    ; DE = Scanline
    LD B, 0                         ; B = Index

    REPT 144
        LD A, [HL+]
        LD E, A
        LD A, B
        LD [DE], A
        INC E
        LD [DE], A
        INC B
    ENDR

    
    LD HL, SineStartIndex
    INC [HL]
    INC [HL]

    LD HL, ScanlineIndicies
    LD C, LOW(rSCY)
    RETI 

HBlank:
    LD A, [HL+]
    SUB L
    LD [$FF00+C], A

    RETI 

SECTION "Data", ROM0, ALIGN[8]
SINETABLE:
DB $6E, $6D, $6D, $6D, $6D, $6D, $6D, $6D, $6D, $6D, $6C, $6C, $6C, $6B, $6B, $6B, $6A, $6A, $6A, $69, $69, $68, $68, $67, $67, $66, $66, $65, $64, $64, $63, $62, $62, $61, $60, $60, $5F, $5E, $5D, $5D, $5C, $5B, $5A, $59, $58, $57, $57, $56, $55, $54, $53, $52, $51, $50, $4F, $4E, $4D, $4C, $4B, $4A, $49, $48, $47, $46, $46, $45, $44, $43, $42, $41, $40, $3F, $3E, $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $34, $33, $32, $31, $30, $2F, $2E, $2E, $2D, $2C, $2B, $2B, $2A, $29, $29, $28, $27, $27, $26, $25, $25, $24, $24, $23, $23, $22, $22, $21, $21, $21, $20, $20, $20, $1F, $1F, $1F, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1F, $1F, $1F, $20, $20, $20, $21, $21, $21, $22, $22, $23, $23, $24, $24, $25, $25, $26, $27, $27, $28, $29, $29, $2A, $2B, $2B, $2C, $2D, $2E, $2E, $2F, $30, $31, $32, $33, $34, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41, $42, $43, $44, $45, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $57, $57, $58, $59, $5A, $5B, $5C, $5D, $5D, $5E, $5F, $60, $60, $61, $62, $62, $63, $64, $64, $65, $66, $66, $67, $67, $68, $68, $69, $69, $6A, $6A, $6A, $6B, $6B, $6B, $6C, $6C, $6C, $6D, $6D, $6D, $6D, $6D, $6D, $6D, $6D, $6D
DB $6E, $6D, $6D, $6D, $6D, $6D, $6D, $6D, $6D, $6D, $6C, $6C, $6C, $6B, $6B, $6B, $6A, $6A, $6A, $69, $69, $68, $68, $67, $67, $66, $66, $65, $64, $64, $63, $62, $62, $61, $60, $60, $5F, $5E, $5D, $5D, $5C, $5B, $5A, $59, $58, $57, $57, $56, $55, $54, $53, $52, $51, $50, $4F, $4E, $4D, $4C, $4B, $4A, $49, $48, $47, $46, $46, $45, $44, $43, $42, $41, $40, $3F, $3E, $3D, $3C, $3B, $3A, $39, $38, $37, $36, $35, $34, $34, $33, $32, $31, $30, $2F, $2E, $2E, $2D, $2C, $2B, $2B, $2A, $29, $29, $28, $27, $27, $26, $25, $25, $24, $24, $23, $23, $22, $22, $21, $21, $21, $20, $20, $20, $1F, $1F, $1F, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1E, $1F, $1F, $1F, $20, $20, $20, $21, $21, $21, $22, $22, $23, $23, $24, $24, $25, $25, $26, $27, $27, $28, $29, $29, $2A, $2B, $2B, $2C, $2D, $2E, $2E, $2F, $30, $31, $32, $33, $34, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41, $42, $43, $44, $45, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $53, $54, $55, $56, $57, $57, $58, $59, $5A, $5B, $5C, $5D, $5D, $5E, $5F, $60, $60, $61, $62, $62, $63, $64, $64, $65, $66, $66, $67, $67, $68, $68, $69, $69, $6A, $6A, $6A, $6B, $6B, $6B, $6C, $6C, $6C, $6D, $6D, $6D, $6D, $6D, $6D, $6D, $6D, $6D
TileData:
INCBIN "res/blooper.2bpp"
TileData_End:
MapData:
INCBIN "res/blooper.tilemap"
MapData_End:
PaletteData:
INCBIN "res/blooper.pal"
PaletteData_End:


SECTION "Variables", WRAM0
ScanlineIndicies: ds 144
SineStartIndex: ds 1