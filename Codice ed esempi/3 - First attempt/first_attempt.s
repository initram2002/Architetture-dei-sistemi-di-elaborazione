; Architetture dei Sistemi di Elaborazione - 02GOLOV     ;
; author:       Michela MARTINI - Politecnico di Torino  ;
; creation:     28 January 2025                          ;
; last update:  31 January 2025                          ;

    .data
v1: .byte       0x1, 0xea
v2: .word       0xc1a0c1a0bac1bac1
v3: .word32     0xdeadbeef, 0xc1a0bac1
v4: .word16     0xcafe, 0xda1e
v5: .double     3.14, 9.82
v6: .asciiz     "hello_world"
v7: .space      8

    .text
main:
    xor     r2, r2, r2
    lb      r15, v1(r0)     ; prende il valore contenuto in v1 con displacement r0 = 0. Quel valore e' un immediato
    daddui  r2, r2, 8
    lbu     r15, v1(r2)     ; il valore 'ea' deve essere caricato come unsigned, in quanto il bit più significativo e' 
                            ;impostato a 1 e se fosse caricato come signed corrisponderebbe a un numero negativo
    lb      r15, v1(r2)     ; il byte 01 invece rimane lo stesso sia se caricato come signed che come unsigned

    ld      r15, v2(r0)     ; carica c1a0c1a0bac1bac1
    andi    r15, r15, 0xcafe; manipola il valore di r15
    sd      r15, v2(r2)     
    sd      r15, v7(r0)

    xor     r2, r2, r2
    lw      r15, v3(r2)
    daddui  r2, r2, 4
    lwu     r15, v3(r2)

    lh      r15, v4(r0)
    daddi   r2, r2, -2      ; utilizzando un valore negativo, è necessario utilizzare l'istruzione signed
    lh      r15, v4(r2)

    l.d     f15, v5(r0)
    xor     r2, r2, r2
    ori     r2, r2, 8
    l.d     f15, v5(r2)

    ori     r2, r0, 0x0030  ; in r2 viene memorizzato 0x0030, ovvero l'indirizzo a cui è memorizzata la stringa "hello_world"

    xor     r3, r3, r3
loop:                       ; il loop serve per leggere "hello_world"
    lbu     r15, 0(r2)      ; gli indici della tabella ascii sono valori unsigned, non si spreca un bit per il segno (che sara' sempre 
                            ; positivo)
    daddi   r2, r2, 1
    bne     r15, r3, loop   ; confronta il byte estratto (carattere) con il valore memorizzato in r3 che è 0, ovvero il terminatore di 
                            ; stringa

    halt                    ; blocca l'esecuzione alla fine programma. Durante l'esecuzione del ciclo viene fetchata ma al momento della 
                            ; decodifica viene buttata via
