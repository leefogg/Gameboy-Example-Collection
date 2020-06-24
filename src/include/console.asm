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
    LD C, (FontEnd - FontStart) / 16
    STARTDMA

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
    CALL GetCursorPosition
    LD A, B
    SUB A, $20
    LD [HL+], A
    CALL SaveCursorPosition
    RET

GetCursorPosition:
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
    PUSH BC
        LD BC, _SCRN0
        ADD HL, BC
    POP BC

    RET

SaveCursorPosition:
    LD BC, 0 - _SCRN0
    ADD HL, BC

    LD A, L
    AND A, 31
    LD B, A

    SLA H
    SLA L
    SLA H
    SLA L
    LD A, H
    AND A, 31

    LD HL, CursorY
    LD [HL+], A
    LD A, B
    LD [HL], A

    RET


SECTION "Console Variables", WRAM0
CursorY: ds 1
CursorX: ds 1
