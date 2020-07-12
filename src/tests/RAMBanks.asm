INCLUDE "include/hardware.inc"
INCLUDE "include/constants.inc"
INCLUDE "include/macros.inc"
INCLUDE "include/utils.asm"

SECTION "Boot Vector", ROM0[$100]
    JR Main

SECTION "Main", ROM0[$150]
Main:
    CALL WriteIDsToBanks
    CALL VerifyIDsOfBanks
    ; If a is not 0 here, test failed
    BREAKPOINT
Sleep:
    HALT
    JR Sleep

WriteIDsToBanks:
    LD A, 4
    LD HL, rSVBK
    LD BC, RamBank1
.Loop
    LD [HL], A ; Switch to bank
    LD [BC], A ; Write bank number in bank

    DEC A
    RET Z
    JP .Loop

VerifyIDsOfBanks:
    LD D, 4
    LD HL, rSVBK
    LD BC, RamBank1
.Loop
    LD A, D
    LD [HL], A ; Switch to bank
    ; Verify bank number was written
    LD A, [BC]
    CP D
    JR NZ, .Fail

    DEC D
    JP NZ, .Loop
    LD A, 0
    RET

.Fail:
    LD A, $FF
    RET