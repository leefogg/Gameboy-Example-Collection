INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

SECTION "VBlank Interrupt", ROM0[$40]
HandleVBlank:
    JP VBlank

SECTION "HBLANK INTERRUPT", ROM0[$48]
    JP HandleHBlank

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    CALL LCDOff

    CALL CopyPalette
    CALL CopyTiles
    CALL CopyMap

    CALL EnableVBlank
    CALL EnableHBlank
    CALL LCDOn

    LD E, LOW(SINETABLE)
    LD D, HIGH(SINETABLE)
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
    LD C, $FF

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

VBlank:
    ; Increment SineStartIndex
    LD HL, SineStartIndex
    LD A, [HL]
    INC A
    LD [HL], A

    ; DE = HIGH(SINETABLE) + SineStartIndex
    LD E, A
    LD D, HIGH(SINETABLE)

    ; HL = HIGH(SINETABLE) + (SineStartIndex + 128)
    ADD A, 128
    LD L, A
    LD H, D
    RETI

HandleHBlank:
    BIT 0, E
    JR Z, .odd
    JR .even
.odd
    LD A, [DE]
    JR .write
.even:
    LD A, [HL]

.write:
    SRL A
    SUB A, 144 / 4 ; Offset to align image to center
    LDH [$FF00+LOW(rSCX)], A

    INC E
    INC L
    RETI 

SECTION "Data", ROM0, ALIGN[8]
SINETABLE::
DB $48, $49, $4B, $4D, $4F, $50, $52, $54, $56, $57, $59, $5B, $5C, $5E, $60, $61, $63, $65, $66, $68, $69, $6B, $6D, $6E, $70, $71, $72, $74, $75, $77, $78, $79, $7A, $7C, $7D, $7E, $7F, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $89, $8A, $8B, $8B, $8C, $8C, $8D, $8D, $8E, $8E, $8E, $8F, $8F, $8F, $8F, $8F, $8F, $90, $8F, $8F, $8F, $8F, $8F, $8F, $8E, $8E, $8E, $8D, $8D, $8C, $8C, $8B, $8B, $8A, $89, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $7D, $7C, $7A, $79, $78, $77, $75, $74, $72, $71, $70, $6E, $6D, $6B, $69, $68, $66, $65, $63, $61, $60, $5E, $5C, $5B, $59, $57, $56, $54, $52, $50, $4F, $4D, $4B, $49, $48, $46, $44, $42, $40, $3F, $3D, $3B, $39, $38, $36, $34, $33, $31, $2F, $2E, $2C, $2A, $29, $27, $26, $24, $22, $21, $1F, $1E, $1D, $1B, $1A, $18, $17, $16, $15, $13, $12, $11, $10, $F, $E, $D, $C, $B, $A, $9, $8, $7, $6, $6, $5, $4, $4, $3, $3, $2, $2, $1, $1, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $1, $1, $2, $2, $3, $3, $4, $4, $5, $6, $6, $7, $8, $9, $A, $B, $C, $D, $E, $F, $10, $11, $12, $13, $15, $16, $17, $18, $1A, $1B, $1D, $1E, $1F, $21, $22, $24, $26, $27, $29, $2A, $2C, $2E, $2F, $31, $33, $34, $36, $38, $39, $3B, $3D, $3F, $40, $42, $44, $46
DB $48, $49, $4B, $4D, $4F, $50, $52, $54, $56, $57, $59, $5B, $5C, $5E, $60, $61, $63, $65, $66, $68, $69, $6B, $6D, $6E, $70, $71, $72, $74, $75, $77, $78, $79, $7A, $7C, $7D, $7E, $7F, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $89, $8A, $8B, $8B, $8C, $8C, $8D, $8D, $8E, $8E, $8E, $8F, $8F, $8F, $8F, $8F, $8F, $90, $8F, $8F, $8F, $8F, $8F, $8F, $8E, $8E, $8E, $8D, $8D, $8C, $8C, $8B, $8B, $8A, $89, $89, $88, $87, $86, $85, $84, $83, $82, $81, $80, $7F, $7E, $7D, $7C, $7A, $79, $78, $77, $75, $74, $72, $71, $70, $6E, $6D, $6B, $69, $68, $66, $65, $63, $61, $60, $5E, $5C, $5B, $59, $57, $56, $54, $52, $50, $4F, $4D, $4B, $49, $48, $46, $44, $42, $40, $3F, $3D, $3B, $39, $38, $36, $34, $33, $31, $2F, $2E, $2C, $2A, $29, $27, $26, $24, $22, $21, $1F, $1E, $1D, $1B, $1A, $18, $17, $16, $15, $13, $12, $11, $10, $F, $E, $D, $C, $B, $A, $9, $8, $7, $6, $6, $5, $4, $4, $3, $3, $2, $2, $1, $1, $1, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $0, $1, $1, $1, $2, $2, $3, $3, $4, $4, $5, $6, $6, $7, $8, $9, $A, $B, $C, $D, $E, $F, $10, $11, $12, $13, $15, $16, $17, $18, $1A, $1B, $1D, $1E, $1F, $21, $22, $24, $26, $27, $29, $2A, $2C, $2E, $2F, $31, $33, $34, $36, $38, $39, $3B, $3D, $3F, $40, $42, $44, $46
TileData:
; Ghost image made by https://www.flaticon.com/authors/freepik
INCBIN "res/ghost.2bpp"
TileData_End:
MapData:
INCBIN "res/ghost.tilemap"
MapData_End:
PaletteData:
INCBIN "res/ghost.pal"
PaletteData_End:


SECTION "Variables", WRAM0
SineStartIndex: ds 1