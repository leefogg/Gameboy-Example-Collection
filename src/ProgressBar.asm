INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

Bar_X EQU 6
Bar_Y EQU 12
Bar_Index EQU Bar_Y * 32 + Bar_X

SECTION "VBlank Interrupt", ROM0[$40]
VBLankInterrupt::
    JP HandleVBlank

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    ; Turn off LCD
    LD HL, rLCDC
	RES 7, [HL]

    CALL SetupProgressBar
    CALL EnableVBlank

    ; Turn on LCD
    LD HL, rLCDC
	SET 7, [HL]
    EI
Sleep:
    HALT
    JR Sleep

SetupPalette:
    LD A, 1 << 7
    LD C, LOW(rBCPS)
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    LD A, $FF
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
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
    LD A, $FF
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD [$FF00+C], A
    RET

SetupProgressBar::
    CALL SetupPalette
    
    ; Put a white tile right before the progress bar
    ; with rendering priority.
    ; This is useful as we can then use just one 8x8 sprite
    ; and and it will extend from under the BG tile.
    LD HL, _SCRN0 + Bar_Index - 1
    LD A, 0
    LD [HL], A
    CALL SwitchToBank1
    SET 7, [HL]
    CALL SwitchToBank0

    ; Copy two tiles into VRAM:
    ; 1. A tile that is just palette color 1 (2) (white)
    ; 2. A tile that is just palette color 3 (4) (black)
    LD DE, WhiteTile
    LD HL, _VRAM
    LD BC, SineTable - WhiteTile
    CALL MEMCOPY

    CALL EnableSprites

    ; Create a sprite that uses the black tile
    LD HL, _OAMRAM + 2
    LD A, 1
    LD [HL], A
    RET

HandleVBlank:
    ; For a progress bar that can go down we cant take
    ; any assumptions of its current position. 
    ; So clear and draw it completely again.
.ClearPrevious::
    LD A, 0
    LD C, 16
    LD HL, _SCRN0 + Bar_Index
    CALL MEM_FILL

    ; Increment Framecounter
    LD HL, FrameCounter
    LD A, [HL]
    INC A
    LD [HL+], A
    ; Look up the sine value for this frame
    LD HL, SineTable
    LD B, 0
    LD C, A
    ADD HL, BC
    LD A, [HL]
    LD B, A ; Make a backup in B
    ; Calulate how many 8x8 tiles to render by dividing by 32
    SRL A
    SRL A
    SRL A
    SRL A
    SRL A
    LD C, A
    ; Get remainder by dividing by 4
    SRL B
    SRL B

.DrawBar::
    ; If theres no tiles to draw, skip to just the sprite (remainder)
    LD A, C
    CP 0
    ; Draw C tiles
    JR Z, .CopySprite
    LD A, 1
    LD HL, _SCRN0 + Bar_Index
    CALL MEM_FILL

.CopySprite::
    LD HL, _OAMRAM
    LD A, Bar_Y * 8 + 16 ; Y
    LD [HL+], A
    LD A, Bar_X * 8 ; Start X
    ADD B ; Add remainder offset
    LD [HL+], A

    RETI

SECTION "VARIABLES", WRAM0
FrameCounter: ds 1

SECTION "DATA", ROM0
WhiteTile::
DB $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00, $FF, $00
BlackTile::
DB $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
SineTable::
DB $00, $03, $06, $09, $0C, $0F, $12, $15, $19, $1C, $1F, $22, $25, $28, $2B, $2E, $31, $35, $38, $3B, $3E, $41, $44, $47, $4A, $4D, $50, $53, $56, $59, $5C, $5F, $61, $64, $67, $6A, $6D, $70, $73, $75, $78, $7B, $7E, $80, $83, $86, $88, $8B, $8E, $90, $93, $95, $98, $9B, $9D, $9F, $A2, $A4, $A7, $A9, $AB, $AE, $B0, $B2, $B5, $B7, $B9, $BB, $BD, $BF, $C1, $C3, $C5, $C7, $C9, $CB, $CD, $CF, $D1, $D3, $D4, $D6, $D8, $D9, $DB, $DD, $DE, $E0, $E1, $E3, $E4, $E6, $E7, $E8, $EA, $EB, $EC, $ED, $EE, $EF, $F1, $F2, $F3, $F4, $F4, $F5, $F6, $F7, $F8, $F9, $F9, $FA, $FB, $FB, $FC, $FC, $FD, $FD, $FE, $FE, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FE, $FE, $FD, $FD, $FC, $FC, $FB, $FB, $FA, $F9, $F9, $F8, $F7, $F6, $F5, $F4, $F4, $F3, $F2, $F1, $EF, $EE, $ED, $EC, $EB, $EA, $E8, $E7, $E6, $E4, $E3, $E1, $E0, $DE, $DD, $DB, $D9, $D8, $D6, $D4, $D3, $D1, $CF, $CD, $CB, $C9, $C7, $C5, $C3, $C1, $BF, $BD, $BB, $B9, $B7, $B5, $B2, $B0, $AE, $AB, $A9, $A7, $A4, $A2, $9F, $9D, $9B, $98, $95, $93, $90, $8E, $8B, $88, $86, $83, $80, $7E, $7B, $78, $75, $73, $70, $6D, $6A, $67, $64, $61, $5F, $5C, $59, $56, $53, $50, $4D, $4A, $47, $44, $41, $3E, $3B, $38, $35, $31, $2E, $2B, $28, $25, $22, $1F, $1C, $19, $15, $12, $0F, $0C, $09, $06, $03