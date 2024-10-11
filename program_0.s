;------------------------------------------------------------
; Program: program_0.s
; Check if any element of v1 is included in v2 at least once.
; -----------------------------------------------------------

        .data
v1:     .byte   2, 6, -3, 11, 9, 18, -13, 16, 5, 1
v2:     .byte   4, 2, -13, 3, 9, 9, 7, 16, 4, 7
v3:     .space  10
flag1:  .space  1
flag2:  .space  1
flag3:  .space  1

        .text
MAIN:       dadd    r1, r0, r0          ; pointer register for v1
            dadd    r2, r0, r0          ; pointer register for v2
            dadd    r3, r0, r0          ; pointer register for v3
            daddi   r4, r0, 10          ; default length for v1 and v2

LOOP1:      lb      r5, v1(r1)          ; get a value from v1 at index r1
LOOP2:      lb      r6, v2(r2)          ; get a value from v2 at index r2
            beq     r5, r6, LOAD        ; if r7 and r8 are equal, load the value in v3     
CONTINUE:   daddi   r2, r2, 1           ; update pointer register for v2
            beq     r2, r4, CONTINUE2   ; if counter of elements in v2 is 10, v2 is terminated, so we have to update v1       
            j       LOOP2               ; jump to LOOP2 if v2 is not finished yet
CONTINUE2:  daddi   r1, r1, 1           ; update counter for elements in v1
            dadd    r2, r0, r0          ; reset r2 value
            beq     r1, r4, ENDLOOP     ; if counter of elements in v1 is 10, exit loops
            j       LOOP1               ; jump to LOOP1 label
LOAD:       sb      r5, v3(r3)          ; store the value in v3 at index r3
            daddi   r3, r3, 1           ; update pointer of v3
            j       CONTINUE2
ENDLOOP:
            slti    r1, r3, 1           ; if r3 is 0, v3 is empty, so flag 1 is true
            sb      r1, flag1(r0)

            dadd    r1, r0, r0          ; initialising index for v3
            dadd    r5, r0, r0          ; default value for flag2

START:      beq     r1, r3, END         ; if index equals the dimension of v3, then there is no i+1 element
            lb      r2, v3(r1)          ; load i value from v3
            daddi   r1, r1, 1           ; increment v3 index
            lb      r4, v3(r1)          ; load i + 1 value from v3
            slt     r5, r2, r4          ; set r5 to 1 if r2 < r4 (v3[i] < v3[i + 1])
            beq     r5, r0, END         ; if r5 is set to 0, then the sequence is not increasing, go to end
            j       START
END:        sb      r5, flag2(r0)       ; store value of flag2

            bne     r5, r0, SET0        ; if flag2 is 1, then flag3 is automatically 0
            dadd    r1, r0, r0          ; reset v3 index value

START2:     beq     r1, r3, END2        ; if index equals the dimension of v3, then there is no i + 1 element
            lb      r2, v3(r1)          ; load i value from v3
            daddi   r1, r1, 1           ; increment v3 index
            lb      r4, v3(r1)          ; load i + 1 value from v3
            slt     r5, r4, r2          ; set r5 to 1 if r4 < r2 (v3[i + 1] < v3[i])
            beq     r5, r0, END2        ; if r5 is set to 0, then the sequence is not in decreasing, go to end
            j       START2

SET0:       sb      r0, flag3(r0)

END2:       sb      r5, flag3(r0)

            
            HALT                        ; the end
    