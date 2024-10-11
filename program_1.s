;------------------------------------------------------------
; Program: program_1.s
; Implement the following high-level code:
; for(i = 31; i >= 0; i--){
;   v4[i] = v1[i] * v1[i] - v2[i];
;   v5[i] = v4[i]/v3[i] - v2[i];
;   v6[i] = (v4[i] - v1[i]) * v5[i];
; }
; -----------------------------------------------------------

        .data
v1:     .double 3.14, 6.28, 9.42, 12.56
        .double 3.14, 6.28, 9.42, 12.56
        .double 3.14, 6.28, 9.42, 12.56
        .double 3.14, 6.28, 9.42, 12.56
        .double 3.14, 6.28, 9.42, 12.56
        .double 3.14, 6.28, 9.42, 12.56
        .double 3.14, 6.28, 9.42, 12.56
        .double 3.14, 6.28, 9.42, 12.56
v2:     .double 1.23, 4.56, 7.89, 10.12
        .double 1.23, 4.56, 7.89, 10.12
        .double 1.23, 4.56, 7.89, 10.12
        .double 1.23, 4.56, 7.89, 10.12
        .double 1.23, 4.56, 7.89, 10.12
        .double 1.23, 4.56, 7.89, 10.12
        .double 1.23, 4.56, 7.89, 10.12
        .double 1.23, 4.56, 7.89, 10.12
v3:     .double 0.01, 2.34, 5.67, 8.90
        .double 0.01, 2.34, 5.67, 8.90
        .double 0.01, 2.34, 5.67, 8.90
        .double 0.01, 2.34, 5.67, 8.90
        .double 0.01, 2.34, 5.67, 8.90
        .double 0.01, 2.34, 5.67, 8.90
        .double 0.01, 2.34, 5.67, 8.90
        .double 0.01, 2.34, 5.67, 8.90
v4:     .space 256
v5:     .space 256
v6:     .space 256

        .text
MAIN:   daddi   r1, r0, 248     ; initialising a register to 31, which is the index of the vectors
LOOP:   l.d     f1, v1(r1)      ; loading v1 value
        l.d     f2, v2(r1)      ; loading v2 value
        l.d     f3, v3(r1)      ; loading v3 value

        mul.d   f0, f1, f1      ; intermediate operation for v4[i]
        sub.d   f4, f0, f2      ; v4[i]
        s.d     f4, v4(r1)      ; storing v4[i] value

        div.d   f0, f4, f3      ; intermediate operation for v5[i]
        sub.d   f5, f0, f2      ; v5[i]
        s.d     f5, v5(r1)      ; storing v5[i] value

        sub.d   f0, f4, f1      ; intermediate operation for v6[i]
        mul.d   f6, f0, f5      ; v6[i]
        s.d     f6, v6(r1)      ; storing v6[i] value

        daddi   r1, r1, -8      ; decrementing the index value
        slt     r2, r1, r0      ; if r1 < 0, we have finished
        beq     r2, r0, LOOP    ; if r2 == 0, we have to continue the cycle
        nop

        HALT                    ; the end