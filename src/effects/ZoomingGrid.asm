INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

SECTION "VBLANK INTERRUPT", ROM0[$40]
VBlank::
    JP HandleVBlank
SECTION "LCDC INTERRUPT", ROM0[$48]
LCDC::
    JP HandleLCDCInterrupt

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    ; Turn off LCD
    LD HL, rLCDC
	RES 7, [HL]

    CALL LoadPalette

    LD DE, TileData
    LD HL, _VRAM
    LD BC, TileData_End - TileData
    CALL MEMCOPY

    LD DE, MapData
    LD HL, _SCRN0
    LD BC, MapData_End - MapData
    CALL MEMCOPY

    CALL EnableVBlank
    ; Enable LYC interrupt
    LD HL, rSTAT
    SET 6, [HL]
    LD HL, rIE
    SET 1, [HL]

    LD C, LOW(ScanlineCount)
    XOR A
    LD [$FF00+C], A
    INC C
    LD [$FF00+C], A

    ; Turn on LCD
    LD HL, rLCDC
	SET 7, [HL]

    EI
Sleep:
    HALT
    JR Sleep

LoadPalette:
    LD A, 1 << 7
    LD C, LOW(rBCPS)
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    LD A, $FF
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD A, $00
    LD [$FF00+C], A
    LD [$FF00+C], A
    RET

; Arguments:
; D = SCY
; E = SCX
; B = LYC
; C = $42
; H = Width
HandleLCDCInterrupt:
    ; TIMING CRITICAL
    ; We need to update SCX and SCY before mode 3
    ; In single speed mode, we only have 10 cycles
    LD A, D             ; 1
    LD [$FF00+C], A     ; 2
    INC C               ; 1
    LD A, E             ; 1
    LD [$FF00+C], A     ; 2
    ; End of timing critical code

    ; Update LYC to fire on the next scanline
    INC B
    LD A, B
    LD C, LOW(rLYC)
    LD [$FF00+C], A

    CALL PrepareScanlineData

    RETI

HandleVBlank:
    ; Fire LYC interrupt on scanline 0
    XOR A
    LDH [LOW(rLYC)], A
    LDH [$FF00+LOW(ScanlineCount)], A
    LDH [$FF00+LOW(IsOffset)], A

    ; Load the current Width
    LD C, LOW(CurrentWidth)
    LD A, [$FF00+C]
    LD B, A

    INC C
    LD A, [$FF00+C]
    INC A
    CP B
    JR NC, .DontIncrement

    ; Reset FrameTimer
    XOR A
    LD [$FF00+C], A

    ; Increment FrameCount
    INC C
    LD A, [$FF00+C]
    INC A
    LD [$FF00+C], A
    JR .LoadWidth
.DontIncrement:
    LD [$FF00+C], A

.LoadWidth:
    LD C, LOW(FrameCount)
    LD A, [$FF00+C]
    LD H, HIGH(ScanlineData)
    LD L, A
    LD A, [HL]
    LD H, A

    LD C, LOW(CurrentWidth)
    LD [$FF00+C], A

    LD B, 0
    CALL PrepareScanlineData

    RETI

; Arguments:
; H = Width
; Returns:
; D = SCY
; E = SCX
; C = $42
; H = Width
PrepareScanlineData:
    ; Set SXY
    LD A, H
    SUB A, B
    LD D, A

    ; Increment ScanlineCount
    LD C, LOW(ScanlineCount)
    LD A, [$FF00+C]
    INC A
    LD [$FF00+C], A
    ; If its Width, reset it, toggle IsOffset and set SCX to width, otherwise set SCX to 0
    CP H
    JR NZ, .DontFlip

    XOR A
    LD [$FF00+C], A

    INC C
    LD A, [$FF00+C]
    XOR $FF
    LD [$FF00+C], A
    LD C, LOW(rSCY)
.SetX:
    OR A
    JR Z, .IsOffset
    LD E, H
    RETI
.IsOffset:
    LD E, 0
    RETI
.DontFlip:
    INC C
    LD A, [$FF00+C]
    LD C, LOW(rSCY)
    JR .SetX

SECTION "Data", ROM0, ALIGN[8]
ScanlineData:
DB 118, 117, 117, 117, 117, 117, 117, 117, 116, 116, 116, 115, 115, 115, 114, 114, 113, 113, 112, 111, 111, 110, 109, 109, 108, 107, 106, 105, 104, 103, 102, 102, 101, 99, 98, 97, 96, 95, 94, 93, 92, 91, 89, 88, 87, 86, 84, 83, 82, 80, 79, 78, 76, 75, 74, 72, 71, 69, 68, 67, 65, 64, 62, 61, 60, 58, 57, 55, 54, 52, 51, 50, 48, 47, 45, 44, 43, 41, 40, 39, 37, 36, 35, 33, 32, 31, 30, 28, 27, 26, 25, 24, 23, 22, 21, 20, 18, 17, 17, 16, 15, 14, 13, 12, 11, 10, 10, 9, 8, 8, 7, 6, 6, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7, 8, 8, 9, 10, 10, 11, 12, 13, 14, 15, 16, 17, 17, 18, 20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 31, 32, 33, 35, 36, 37, 39, 40, 41, 43, 44, 45, 47, 48, 50, 51, 52, 54, 55, 57, 58, 59, 61, 62, 64, 65, 67, 68, 69, 71, 72, 74, 75, 76, 78, 79, 80, 82, 83, 84, 86, 87, 88, 89, 91, 92, 93, 94, 95, 96, 97, 98, 99, 101, 102, 102, 103, 104, 105, 106, 107, 108, 109, 109, 110, 111, 111, 112, 113, 113, 114, 114, 115, 115, 115, 116, 116, 116, 117, 117, 117, 117, 117, 117, 117
ScanlineData_End:
TileData:
INCBIN "res/zoominggrid.2bpp"
TileData_End:
MapData:
INCBIN "res/zoominggrid.tilemap"
MapData_End:

SECTION "Variables", HRAM
ScanlineCount: DS 1
IsOffset: DS 1
CurrentWidth: DS 1
FrameTimer: DS 1
FrameCount: DS 1