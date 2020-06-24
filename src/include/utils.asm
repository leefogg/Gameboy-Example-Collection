SECTION "Utility Methods", ROM0
WaitNewScanline:
    LD A, [$FF00+LOW(rLY)]
    LD B, A
.LOOP:
    LD A, [$FF00+LOW(rLY)]
    CP B
    JR Z, .LOOP
    RET

EnableHBlank:
    LD HL, rSTAT
    SET 3, [HL]
    LD HL, rIE
    SET 1, [HL]
    LD HL, rIF
    RES 1, [HL]
    RET

EnableVBlank:
    LD HL, rSTAT
    SET 4, [HL]
    LD HL, rIE
    SET 0, [HL]
    LD HL, rIF
    RES 1, [HL]
    RET

DisableHBlank:   ; 18
    LD HL, rSTAT ; 3
    RES 3, [HL]  ; 4
    LD HL, rIE   ; 3
    RES 1, [HL]  ; 4
    RET          ; 4

DisableVBlank:
    LD HL, rSTAT
    RES 4, [HL]
    LD HL, rIE
    RES 0, [HL]
    RET

SwitchToBank0:
    XOR A
    LD [rVBK], A
	RET
	
SwitchToBank1:
    LD A, 1
    LD [rVBK], A
	RET

; HL - Destination
; DE - Origin
; BC - Length
; Does BC / 1024 DMAs of 1024 bytes then remainder / 16
; DMA copies in blocks of 16
DMA_LARGE::
	DEC BC ; Blocks = Length / 16 - 1
	; Calculate remainder
	; C = BC / 16, Maximum 63
	PUSH HL
		LD A, B
		LD H, A	
		LD A, C
		LD L, A
		RR H
		RR L
		RR H
		RR L
		RR H
		RR L
		RR H
		RR L
		LD A, L
		AND %00111111
		LD C, A
	POP HL
	; Calculate how many DMAs of 64
	; B = BC / 1024, Maximum 63
	SRL B
	SRL B
	JR Z, .REMAINDER
.LOOP:
	PUSH BC
		LD C, %01000000
		STARTDMA
	POP BC
	
	PUSH BC
		LD BC, 1024
		; Origin += 1024
		PUSH HL
			LD A, D
			LD H, A
			LD A, E
			LD L, A
			ADD HL, BC
			LD A, L
			LD E, A
			LD A, H
			LD D, A
		POP HL
		
		
		; Destination += 1024
		ADD HL, BC
	POP BC
	
	DEC B
	JR NZ, .LOOP
.REMAINDER:
	CALL STARTDMA
	RET

; DE - Origin
; HL - Destination
; BC - Size
MEMCOPY::
	LD A, [DE]
	LD [HL], A
	INC HL
	INC DE
	DEC BC
	LD A, B
	CP 0
	JR NZ, MEMCOPY
	LD A, C
	CP 0
	JR NZ, MEMCOPY
	RET

; A - Fill value
; C - Length
; HL - Destination
MEM_FILL:
	LD [HL+], A
	DEC C
	JR NZ, MEM_FILL
	RET

EnableSprites:
	LD HL, rLCDC
	SET 1, [HL]
	RET