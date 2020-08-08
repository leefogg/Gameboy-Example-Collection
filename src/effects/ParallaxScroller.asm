INCLUDE "include/hardware.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

SECTION "VBlank Interrupt", ROM0[$40]
HandleVBlank:
    JP VBlank

SECTION "Boot Vector", ROM0[$100]
    JR Main

; Based on https://youtu.be/C9A6K5RQ2JQ?t=77
SECTION "Main", ROM0[$150]
Main:
    CALL LCDOff

    CALL WriteTile
    CALL SetupMap
    CALL SetupVariables

    CALL EnableVBlank
    
    CALL LCDOn
    EI
    LD B, 0
    JP Sleep

; Copies the tile data to the first tile slot
; So that all tiles in BGMap use it
WriteTile:
    LD DE, TileData
    LD HL, _VRAM
    LD BC, 16
    CALL MEMCOPY
    RET

; A key part of the effect is the use of multiple palletes.
; Instead of having all tiles point to one palette
; resulting in only 4 possible positions for the columns,
; set each 8 tiles to that palette 
; (tile 2 = palette 2. Tile 9 = palette 1)
SetupMap:
    CALL SwitchToBank1

    LD C, 0
    LD DE, _SCRN_Size
    LD HL, _SCRN0
.Loop:
    LD A, C
    LD [HL+], A
    INC A
    AND %00000111
    LD C, A

    DEC DE
    LD A, 0
    OR D
    OR E
    CP 0
    JR NZ, .Loop

    CALL SwitchToBank0
    RET

; As we dont know which colours in what palette will be set,
; Clear everything back to white
; This is by far the slowest part of the effect.
; Could speed it up by clearing last frames set colours only instead
ClearPalettes:
    LD C, LOW(rBCPS)
    LD A, rBCPS_Flag_AutoIncrement
    LD [$FF00+C], A

    LD A, $FF
    LD C, LOW(rBCPD)
    REPT _BCP_Size
        LD [$FF00+C], A
    ENDR
    RET

; Writes a red colour to palette memory + RedPosition
; and a blue colour to palette memory + GreenPosition
WritePalettes:
    LD HL, RedPosition
    LD C, LOW(rBCPS)
    LD A, [HL+]
    OR rBCPS_Flag_AutoIncrement
    LD [$FF00+C], A

    LD C, LOW(rBCPD)
    LD A, $1F
    LD [$FF00+C], A
    LD A, $00
    LD [$FF00+C], A

    ; GreenPosition
    LD C, LOW(rBCPS)
    LD A, [HL]
    OR rBCPS_Flag_AutoIncrement
    LD [$FF00+C], A

    LD C, LOW(rBCPD)
    LD A, $00
    LD [$FF00+C], A
    LD A, $1F << 2
    LD [$FF00+C], A
    RET

; Sets RedPosition & RedPosition variables to their starting values
SetupVariables:
    LD HL, RedPosition
    LD A, 0
    LD [HL+], A
    LD A, 4
    LD [HL], A
    RET

; RedPosition += 2
; GreenPosition -= 4
; (Each colour takes 2 bytes)
UpdateLinePositions:
    LD HL, RedPosition
    LD A, [HL]
    INC A
    INC A
    AND _BCP_Size - 1 ; Limit to the size of the palette (64 bytes)
    LD [HL+], A
    ; GreenPosition
    LD A, [HL]
    DEC A
    DEC A
    DEC A
    DEC A
    AND _BCP_Size - 1 ; Limit to the size of the palette (64 bytes)
    LD [HL], A
    RET

; Update the position of the lines and update each frame
VBlank:
    CALL UpdateLinePositions    
    CALL ClearPalettes
    CALL WritePalettes
    RETI

; A tile where each two columns are the next shade
SECTION "Tile", ROM0
TileData:
REPT 8
; 11223344
DB %00110011, %00001111
ENDR

SECTION "Variables", WRAM0
; Two variables that act as offsets in where to write 
; their colours to in palette memory
RedPosition: DS 1
GreenPosition: DS 1