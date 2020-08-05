INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"
INCLUDE "include/constants.inc"

SECTION "VBlank Interrupt", ROM0[$40]
HandleVBlank:
    EI ; 1
    POP HL ; 3
    JP WaitToStartEffect ; 4

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    SwitchSpeedMode

    CALL LCDOff

    CALL SetupPalettes

    CALL MakeMap

    CALL PrepareVariables

    CALL EnableVBlank

    CALL LCDOn
    EI
    JP Sleep

PrepareVariables:
    ; Start at the top so the current RAM value doesn't imact where we start
    LD HL, CurrentFrame
    XOR A
    LD [HL], A

    ; Clear some of WRAM to make it clear which ones we're using
    LD HL, _RAM
    LD C, 128
.Loop:
    LD [HL+], A
    DEC C
    JR NZ, .Loop

    RET

SetupPalettes:
    LD C, LOW(rBCPS)
    LD A, %10000000
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    LD A, $16
    LD [$FF00+C], A
    LD A, $00
    LD [$FF00+C], A

    LD C, LOW(rBCPS)
    LD A, %10000000 | 8
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    LD A, $1F
    LD [$FF00+C], A
    LD A, $18
    LD [$FF00+C], A


    LD C, LOW(rBCPS)
    LD A, %10000000 | 16
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    LD A, $1F
    LD [$FF00+C], A
    LD A, $1A
    LD [$FF00+C], A


    LD C, LOW(rBCPS)
    LD A, %10000000 | 24 
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    LD A, $FF
    LD [$FF00+C], A
    LD A, $1B
    LD [$FF00+C], A


    LD C, LOW(rBCPS)
    LD A, %10000000 | 32
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    LD A, $FF
    LD [$FF00+C], A
    LD A, $43
    LD [$FF00+C], A

    RET


MakeMap:
    CALL SwitchToBank1
    LD DE, 0
    LD HL, _SCRN0
    LD BC, 1024
.loop:
    LD A, [DE]
    INC DE
    LD [HL+], A

    DEC BC
    LD A, B
    OR C
    JR NZ, .loop

    CALL SwitchToBank0
    RET

WaitToStartEffect:
    ; Wait for one frame to elapse, then 1 frame - 1 scanline  - the overhead of calling this function - the startup of the effect
    DelayMStates ((_VBLANKCYCLES / 4 * 2) - (_SCANLINECYCLES / 4) - 13 - 8)
    

StartEffect:
    ; 13
    ; Increment CurrentFrame
    LD C, LOW(CurrentFrame)    ; 2
    LD A, [$FF00+C]            ; 2
    INC A                      ; 1
    LD [$FF00+C], A            ; 2
    LD B, A                    ; 1

    ; Prepare for effect
    LD DE, AllScanlineData     ; 3
    LD C, LOW(rSCY)            ; 2


.Loop:
    NOP
    NOP
    NOP
    ; Mode 0 (HBlank) starts here
    INC A ; This is pointless at runtime. Its just here as a marker for easier debugging.

    ; Copy next scanline's data
    LD HL, CurrentScanlineData
    ; Demotronic's table has a stride of 11 but it only uses 10, no idea why yet
    REPT 10         ; 7 * 10
        LD A, [DE]  ; 2
        ADD A, B    ; 1
        INC DE      ; 2
        LD [HL+], A ; 2
    ENDR

    ; This takes up the remaing time between HBlank and Mode3
    REPT 64
        NOP 
    ENDR

    ; Change SCY each tile according to LUT
    LD HL, CurrentScanlineData ; 3
    ; Mode 3 starts here
    REPT 9
        LD A, [HL+]     ; 2
        LD [$FF00+C], A ; 2
    ENDR
    LD   A,[HL]         ; 2
    LD   [$FF00+C],A    ; 2
    REPT 10
        LD A, [HL-]     ; 2
        LD [$FF00+C], A ; 2
    ENDR
    JP .Loop ; 4

SECTION "Scanline Data", ROM0, ALIGN[8]
; 144 * 10 bytes. Each byte is a SCY value to set each tile each scanline
AllScanlineData:
DB $24, $1E, $18, $15, $0F, $0B, $07, $06, $04, $02, $23, $1E, $18, $14, $0F, $0B, $07, $06, $04, $02, $23, $1D, $18, $14, $0F, $0B, $07, $05, $04, $02, $22, $1D, $17, $14, $0E, $0B, $07, $05, $04, $02, $22, $1C, $17, $13, $0E, $0B, $07, $05, $04, $02, $21, $1C, $17, $13, $0E, $0A, $07, $05, $03, $02, $21, $1B, $16, $13, $0E, $0A, $07, $05, $03, $02, $20, $1B, $16, $13, $0E, $0A, $07, $05, $03, $02, $20, $1B, $16, $12, $0D, $0A, $07, $05, $03, $02, $1F, $1A, $15, $12, $0D, $0A, $07, $05, $03, $02, $1F, $1A, $15, $12, $0D, $0A, $06, $05, $03, $02, $1E, $19, $15, $11, $0D, $0A, $06, $05, $03, $02, $1E, $19, $14, $11, $0C, $09, $06, $05, $03, $02, $1D, $19, $14, $11, $0C, $09, $06, $05, $03, $02, $1D, $18, $14, $11, $0C, $09, $06, $05, $03, $02, $1C, $18, $13, $10, $0C, $09, $06, $04, $03, $01, $1C, $17, $13, $10, $0C, $09, $06, $04, $03, $01, $1B, $17, $13, $10, $0B, $09, $06, $04, $03, $01, $1B, $16, $12, $0F, $0B, $08, $06, $04, $03, $01, $1A, $16, $12, $0F, $0B, $08, $06, $04, $03, $01, $1A, $16, $12, $0F, $0B, $08, $05, $04, $03, $01, $19, $15, $11, $0F, $0B, $08, $05, $04, $03, $01, $19, $15, $11, $0E, $0A, $08, $05, $04, $03, $01, $18, $14, $11, $0E, $0A, $08, $05, $04, $03, $01, $18, $14, $10, $0E, $0A, $07, $05, $04, $02, $01, $17, $14, $10, $0D, $0A, $07, $05, $04, $02, $01, $17, $13, $10, $0D, $0A, $07, $05, $04, $02, $01, $16, $13, $0F, $0D, $09, $07, $05, $04, $02, $01, $16, $12, $0F, $0D, $09, $07, $05, $03, $02, $01, $15, $12, $0F, $0C, $09, $07, $04, $03, $02, $01, $15, $11, $0E, $0C, $09, $07, $04, $03, $02, $01, $14, $11, $0E, $0C, $09, $06, $04, $03, $02, $01, $14, $11, $0E, $0B, $08, $06, $04, $03, $02, $01, $13, $10, $0D, $0B, $08, $06, $04, $03, $02, $01, $13, $10, $0D, $0B, $08, $06, $04, $03, $02, $01, $12, $0F, $0D, $0B, $08, $06, $04, $03, $02, $01, $12, $0F, $0C, $0A, $07, $06, $04, $03, $02, $01, $11, $0F, $0C, $0A, $07, $05, $04, $03, $02, $01, $11, $0E, $0B, $0A, $07, $05, $04, $03, $02, $01, $10, $0E, $0B, $09, $07, $05, $03, $03, $02, $01, $10, $0D, $0B, $09, $07, $05, $03, $02, $02, $01, $0F, $0D, $0A, $09, $06, $05, $03, $02, $02, $01, $0F, $0C, $0A, $09, $06, $05, $03, $02, $02, $01, $0E, $0C, $0A, $08, $06, $05, $03, $02, $02, $01, $0E, $0C, $09, $08, $06, $04, $03, $02, $01, $01, $0D, $0B, $09, $08, $06, $04, $03, $02, $01, $01, $0D, $0B, $09, $07, $05, $04, $03, $02, $01, $01, $0C, $0A, $08, $07, $05, $04, $03, $02, $01, $01, $0C, $0A, $08, $07, $05, $04, $02, $02, $01, $01, $0B, $0A, $08, $07, $05, $04, $02, $02, $01, $01, $0B, $09, $07, $06, $05, $03, $02, $02, $01, $01, $0A, $09, $07, $06, $04, $03, $02, $02, $01, $01, $0A, $08, $07, $06, $04, $03, $02, $02, $01, $01, $09, $08, $06, $05, $04, $03, $02, $01, $01, $00, $09, $07, $06, $05, $04, $03, $02, $01, $01, $00, $08, $07, $06, $05, $04, $03, $02, $01, $01, $00, $08, $07, $05, $05, $03, $02, $02, $01, $01, $00, $07, $06, $05, $04, $03, $02, $02, $01, $01, $00, $07, $06, $05, $04, $03, $02, $01, $01, $01, $00, $06, $05, $04, $04, $03, $02, $01, $01, $01, $00, $06, $05, $04, $03, $02, $02, $01, $01, $01, $00, $05, $05, $04, $03, $02, $02, $01, $01, $01, $00, $05, $04, $03, $03, $02, $02, $01, $01, $01, $00, $04, $04, $03, $03, $02, $01, $01, $01, $00, $00, $04, $03, $03, $02, $02, $01, $01, $01, $00, $00, $03, $03, $02, $02, $01, $01, $01, $01, $00, $00, $03, $02, $02, $02, $01, $01, $01, $00, $00, $00, $02, $02, $02, $01, $01, $01, $01, $00, $00, $00, $02, $02, $01, $01, $01, $01, $00, $00, $00, $00, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $FE, $FE, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $FE, $FE, $FE, $FF, $FF, $FF, $FF, $00, $00, $00, $FD, $FE, $FE, $FE, $FF, $FF, $FF, $00, $00, $00, $FD, $FD, $FE, $FE, $FF, $FF, $FF, $FF, $00, $00, $FC, $FD, $FD, $FE, $FE, $FF, $FF, $FF, $00, $00, $FC, $FC, $FD, $FD, $FE, $FF, $FF, $FF, $00, $00, $FB, $FC, $FD, $FD, $FE, $FE, $FF, $FF, $FF, $00, $FB, $FB, $FC, $FD, $FE, $FE, $FF, $FF, $FF, $00, $FA, $FB, $FC, $FD, $FE, $FE, $FF, $FF, $FF, $00, $FA, $FB, $FC, $FC, $FD, $FE, $FF, $FF, $FF, $00, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $FF, $FF, $00, $F9, $FA, $FB, $FC, $FD, $FE, $FE, $FF, $FF, $00, $F8, $F9, $FB, $FB, $FD, $FE, $FE, $FF, $FF, $00, $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $FF, $00, $F7, $F9, $FA, $FB, $FC, $FD, $FE, $FF, $FF, $00, $F7, $F8, $FA, $FB, $FC, $FD, $FE, $FF, $FF, $00, $F6, $F8, $F9, $FA, $FC, $FD, $FE, $FE, $FF, $FF, $F6, $F7, $F9, $FA, $FC, $FD, $FE, $FE, $FF, $FF, $F5, $F7, $F9, $FA, $FB, $FD, $FE, $FE, $FF, $FF, $F5, $F6, $F8, $F9, $FB, $FC, $FE, $FE, $FF, $FF, $F4, $F6, $F8, $F9, $FB, $FC, $FE, $FE, $FF, $FF, $F4, $F6, $F8, $F9, $FB, $FC, $FD, $FE, $FF, $FF, $F3, $F5, $F7, $F9, $FB, $FC, $FD, $FE, $FF, $FF, $F3, $F5, $F7, $F8, $FA, $FC, $FD, $FE, $FF, $FF, $F2, $F4, $F7, $F8, $FA, $FC, $FD, $FE, $FF, $FF, $F2, $F4, $F6, $F8, $FA, $FB, $FD, $FE, $FE, $FF, $F1, $F4, $F6, $F7, $FA, $FB, $FD, $FE, $FE, $FF, $F1, $F3, $F6, $F7, $FA, $FB, $FD, $FE, $FE, $FF, $F0, $F3, $F5, $F7, $F9, $FB, $FD, $FE, $FE, $FF, $F0, $F2, $F5, $F7, $F9, $FB, $FD, $FD, $FE, $FF, $EF, $F2, $F5, $F6, $F9, $FB, $FC, $FD, $FE, $FF, $EF, $F1, $F4, $F6, $F9, $FB, $FC, $FD, $FE, $FF, $EE, $F1, $F4, $F6, $F9, $FA, $FC, $FD, $FE, $FF, $EE, $F1, $F3, $F5, $F8, $FA, $FC, $FD, $FE, $FF, $ED, $F0, $F3, $F5, $F8, $FA, $FC, $FD, $FE, $FF, $ED, $F0, $F3, $F5, $F8, $FA, $FC, $FD, $FE, $FF, $EC, $EF, $F2, $F5, $F8, $FA, $FC, $FD, $FE, $FF, $EC, $EF, $F2, $F4, $F7, $FA, $FC, $FD, $FE, $FF, $EB, $EF, $F2, $F4, $F7, $F9, $FC, $FD, $FE, $FF, $EB, $EE, $F1, $F4, $F7, $F9, $FC, $FD, $FE, $FF, $EA, $EE, $F1, $F3, $F7, $F9, $FB, $FD, $FE, $FF, $EA, $ED, $F1, $F3, $F7, $F9, $FB, $FC, $FE, $FF, $E9, $ED, $F0, $F3, $F6, $F9, $FB, $FC, $FE, $FF, $E9, $EC, $F0, $F3, $F6, $F9, $FB, $FC, $FE, $FF, $E8, $EC, $F0, $F2, $F6, $F9, $FB, $FC, $FE, $FF, $E8, $EC, $EF, $F2, $F6, $F8, $FB, $FC, $FD, $FF, $E7, $EB, $EF, $F2, $F6, $F8, $FB, $FC, $FD, $FF, $E7, $EB, $EF, $F1, $F5, $F8, $FB, $FC, $FD, $FF, $E6, $EA, $EE, $F1, $F5, $F8, $FB, $FC, $FD, $FF, $E6, $EA, $EE, $F1, $F5, $F8, $FA, $FC, $FD, $FF, $E5, $EA, $EE, $F1, $F5, $F8, $FA, $FC, $FD, $FF, $E5, $E9, $ED, $F0, $F5, $F7, $FA, $FC, $FD, $FF, $E4, $E9, $ED, $F0, $F4, $F7, $FA, $FC, $FD, $FF, $E4, $E8, $ED, $F0, $F4, $F7, $FA, $FC, $FD, $FF, $E3, $E8, $EC, $EF, $F4, $F7, $FA, $FB, $FD, $FE, $E3, $E7, $EC, $EF, $F4, $F7, $FA, $FB, $FD, $FE, $E2, $E7, $EC, $EF, $F4, $F7, $FA, $FB, $FD, $FE, $E2, $E7, $EB, $EF, $F3, $F6, $FA, $FB, $FD, $FE, $E1, $E6, $EB, $EE, $F3, $F6, $FA, $FB, $FD, $FE, $E1, $E6, $EB, $EE, $F3, $F6, $F9, $FB, $FD, $FE, $E0, $E5, $EA, $EE, $F3, $F6, $F9, $FB, $FD, $FE, $E0, $E5, $EA, $ED, $F2, $F6, $F9, $FB, $FD, $FE, $DF, $E5, $EA, $ED, $F2, $F6, $F9, $FB, $FD, $FE, $DF, $E4, $E9, $ED, $F2, $F6, $F9, $FB, $FD, $FE, $DE, $E4, $E9, $ED, $F2, $F5, $F9, $FB, $FC, $FE, $DE, $E3, $E9, $EC, $F2, $F5, $F9, $FB, $FC, $FE, $DD, $E3, $E8, $EC, $F1, $F5, $F9, $FB, $FC, $FE, $DD, $E2, $E8, $EC, $F1, $F5, $F9, $FA, $FC, $FE, $DC

SECTION "Variables", WRAM0
CurrentScanlineData: ds 1
SECTION "HRAM Variables", HRAM
; Current frame counter, offsets CurrentScanlineData to make the screen go down
CurrentFrame: ds 1