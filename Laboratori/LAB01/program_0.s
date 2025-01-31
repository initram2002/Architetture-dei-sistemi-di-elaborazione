; Architetture dei Sistemi di Elaborazione - 02GOLOV     ;
; author:       Michela MARTINI - Politecnico di Torino  ;
; creation:     31 January 2025                          ;
; last update:  31 January 2025                          ;

    .data
v1:     .byte   2, 6, -3, 11, 9, 18, -13, 16, 5, 1
v2:     .byte   4, 2, -13, 3, 9, 9, 7, 16, 4, 7
v3:     .space  10
flag1:  .space 1
flag2:  .space 1
flag3:  .space 1

    .text
main:  
    dadd    r1, r0, r0
    dadd    r2, r0, r0
    dadd    r3, r0, r0

    daddi   r10, r0, 10

; request 1
extLoop:
    lb      r4, v1(r1)

intLoop:
    lb      r5, v2(r2)
    dsub    r6, r4, r5
    bnez    r6, continue
    
    dadd    r7, r0, r0
checkDuplicates:    
    lb      r8, v3(r7)
    dsub    r9, r4, r8
    beqz    r9, continue
    dsub    r8, r3, r7
    daddi   r7, r7, 1
    bnez    r8, checkDuplicates
    sb      r4, v3(r3)
    daddi   r3, r3, 1

continue:
    daddi   r2, r2, 1
    bne     r2, r10, intLoop
    dadd    r2, r0, r0
    daddi   r1, r1, 1
    bne     r1, r10, extLoop

; request 2
    bnez    r3, flag2
    daddi   r9, r0, 1
    sb      r9, flag1(r0)
    sb      r0, flag2(r0)
    sb      r0, flag3(r0)
    j       end

    dadd    r1, r0, r0
    daddi   r2, r0, 1
flag2:
    sb      r0, flag1(r0)
    lb      r4, v3(r1)
    lb      r5, v3(r2)
    slt     r6, r3, r4 ; must give 1
    beqz    r6, breakFlag2
    daddi   r1, r1, 1
    daddi   r2, r2, 1
    bne     r2, r3, flag2
    sb      r9, flag2(r0)
    j       flag3

breakFlag2:
    sb      r0, flag2(r0)

    dadd    r1, r0, r0
    daddi   r2, r0, 1
flag3:
    lb      r4, v3(r1)
    lb      r5, v3(r2)
    slt     r6, r3, r4 ; must give 0
    bnez    r6, breakFlag3
    daddi   r1, r1, 1
    daddi   r2, r2, 1
    bne     r2, r3, flag3
    sb      r9, flag3(r0)
    j       end

breakFlag3:
    sb      r0, flag3(r0)

end:
    halt
