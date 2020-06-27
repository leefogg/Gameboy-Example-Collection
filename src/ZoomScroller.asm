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


LoadNextScanlineData: MACRO
    LD A, [HL+]
    LD D, A
    LD A, [HL+]
    LD E, A
ENDM

; Arguments:
; D = SCY
; E = SCX
; B = LYC
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

    ; Prepare next scanline's data
    LoadNextScanlineData
    LD A, D
    SUB A, B
    LD D, A

    ; Reset pointer
    LD C, LOW(rSCY)

    RETI

HandleVBlank:
    ; Fire LYC interrupt on scanline 0
    LD A, 0
    LDH [LOW(rLYC)], A

    ; Reset data pointer back to start
    LD HL, ScanlineData

    LoadNextScanlineData
    LD B, 0
    LD C, LOW(rSCY)

    RETI

SECTION "Data", ROM0
TileData:
INCBIN "res/ZoomScroller.2bbp"
TileData_End:
MapData:
INCBIN "res/ZoomScroller.tilemap"
MapData_End:
ScanlineData:
REPT 10
    DB 14, 0, 14, 0, 14, 0, 14, 0, 14, 0, 14, 0, 14, 0, 14, 0, 14, 0, 14, 0, 14, 0, 14, 0, 14, 0, 14, 0
    DB 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
ENDR
ScanlineData_End: