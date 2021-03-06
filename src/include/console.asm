SECTION "Console", ROM0
Console_Init::
    XOR A
    LD HL, CursorY
    LD [HL+], A
    LD [HL], A
    RET

Console_LoadFont::
    LD DE, FontStart
    LD HL, _VRAM
    LD BC, FontEnd - FontStart
    CALL MEMCOPY

    ; Set palette
    LD C, LOW(rBCPS)
    LD A, 1 << 7
    LD [$FF00+C], A
    LD C, LOW(rBCPD)
    LD A, 0
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD A, 4
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD A, 8
    LD [$FF00+C], A
    LD [$FF00+C], A
    LD A, 15
    LD [$FF00+C], A
    LD [$FF00+C], A
    RET

; B - Char
Console_WriteChar::
    PUSH HL
        CALL GetCursorPosition

        LD A, B
        SUB A, $20
        LD [HL+], A

        CALL SaveCursorPosition
    POP HL
    RET

; B - Value
Console_WriteRegister::
    PUSH HL
        CALL GetCursorPosition

        LD A, B
        SWAP A
        AND $0F
        CALL _GetNibbleChar
        LD [HL+], A
        LD A, B
        AND $0F
        CALL _GetNibbleChar
        LD [HL+], A

        CALL SaveCursorPosition
    POP HL
    RET

; BC - String src
Console_WriteString::
    PUSH HL
        CALL GetCursorPosition
.Loop:
        LD A, [BC]
        OR A
        JR Z, .Break
        INC BC
        SUB A, $20
        LD [HL+], A
        JR .Loop
.Break:
        CALL SaveCursorPosition
    POP HL
    RET

Console_Newline::
    PUSH HL
        LD HL, CursorY
        INC [HL]
        INC HL
        XOR A
        LD [HL], A
    POP HL
    RET

; Returns:
; HL - _SCRN0 + Position
GetCursorPosition:
    PUSH BC
        LD HL, CursorY
        LD A, [HL+]
        RLA 
        RLA 
        RLA 
        RLA 
        RLA
        LD C, A
        LD A, [HL]
        OR C

        LD L, A
        LD H, 0
        LD BC, _SCRN0
        ADD HL, BC
    POP BC
    RET

SaveCursorPosition:
    PUSH BC
        LD BC, 0 - _SCRN0
        ADD HL, BC

        LD A, L
        AND A, 31
        LD B, A

        RL L
        RL H
        RL L
        RL H
        RL L
        RL H
        LD A, H
        AND A, 31

        LD HL, CursorY
        LD [HL+], A
        LD A, B
        LD [HL], A
    POP BC
    RET


_GetNibbleChar:
    CP 10
    JR NC, .IsLetter
    ADD A, 16 ; '0'
    RET
.IsLetter:
    ADD A, 33 - 10 ; 'A'
    RET

SECTION "FONT", ROM0[$1000]
FontStart:
    INCBIN "res/font.2bpp"
FontEnd:

SECTION "Console Variables", WRAM0
CursorY: ds 1
CursorX: ds 1