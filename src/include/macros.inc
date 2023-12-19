MACRO BREAKPOINT
    LD B, B
ENDM

MACRO NOPS
    REPT \1
        NOP
    ENDR
ENDM

; DE - Origin
; HL - Destination
; C - Length / 16 (0-127 = 0-2032) & Mode
MACRO STARTDMA
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

MACRO SwitchSpeedMode
	LD A, 1
	LDH [$FF00+LOW(rKEY1)], A
	STOP
ENDM

MACRO WaitVBlank
	LD C, LOW(rSTAT)
	LD D, 1
.Loop:
	LD A, [$FF00+C]
	AND %00000011
	CP D
	JR NZ, .Loop
ENDM

MACRO DelayMStates
	LD BC, \1 / 8  ; 3
.Loop:
    DEC BC      ; 2
    LD A, B     ; 1
    OR C        ; 1
    JP NZ, .Loop; 3/4

    NOPS \1 % 8
ENDM
