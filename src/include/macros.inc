BREAKPOINT: MACRO
    LD B, B
ENDM

NOPS: MACRO
    REPT \1
        NOP
    ENDR
ENDM

; DE - Origin
; HL - Destination
; C - Length / 16 (0-127 = 0-2032) & Mode
STARTDMA: MACRO
	LD A, D
	LDH [LOW(rHDMA1)], A
	LD A, E
	LDH [LOW(rHDMA2)], A
	LD A, H
	LDH [LOW(rHDMA3)], A
	LD A, L
	LDH [LOW(rHDMA4)], A
	LD A, C
	LDH [LOW(rHDMA5)], A
ENDM

SwitchMode: MACRO
	LD A, 1
	LDH [$FF00+LOW(rKEY1)], A
	STOP
ENDM

WaitVBlank: MACRO
	LD C, LOW(rSTAT)
	LD D, 1
.Loop:
	LD A, [$FF00+C]
	AND %00000011
	CP D
	JR NZ, .Loop
ENDM

TurnLCDOff: MACRO
	WaitVBlank

	LD HL, rLCDC
	RES 7, [HL]
ENDM

DelayMStates: MACRO
	LD BC, \1 / 8  ; 3
.Loop:
    DEC BC      ; 2
    LD A, B     ; 1
    OR C        ; 1
    JP NZ, .Loop; 3/4

    NOPS \1 % 8
ENDM
