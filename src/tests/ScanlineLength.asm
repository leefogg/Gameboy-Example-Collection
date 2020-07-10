INCLUDE "include/hardware.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

SECTION "VBLANK INTERRUPT", ROM0[$40]
    LD BC, _RAM
    RETI
SECTION "HBLANK INTERRUPT", ROM0[$48]
    POP DE  ; Dont care about the stack. 3
    JP HandleHBlank ; 4

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    ; Turn off LCD
    LD HL, rLCDC
	RES 7, [HL]

    CALL EnableHBlank
    CALL EnableVBlank

    ; Turn on LCD
    LD HL, rLCDC
	SET 7, [HL]

    LD HL, _RAM
    LD C, 10
    EI
Sleep:
    HALT
    JR Sleep

HandleHBlank:
    ; This will fire every hblank. The value written into RAM is how long the previous hlank-hblank took in M-Cycles
    LD DE, 22 ; Add overhead of this. 3
    ADD HL, DE ; 2
    LD DE, 2 ; 3
    LD A, H ; 1
    LD [BC], A ; 2
    INC BC ; 2 
    LD A, L ; 1
    LD [BC], A ; 2
    INC BC ; 2
    LD HL, 0 ; 3
    EI ; 1
    
    REPT 2000
        ADD HL, DE
    ENDR

    BREAKPOINT