#******** RISCV UNROLLED OPTIMIZED PROGRAM ************
# -------------------------------------------
# program_1_b.s
# Versione con loop unrolling 2x di program_1_a.s
# Ottimizzazioni applicate:
# 1. Loop unrolling con fattore 2 (elabora 2 iterazioni per volta)
# 2. Rescheduling delle istruzioni per ridurre hazard tra iterazioni
# 3. Aumento registri utilizzati per eliminare dipendenze
# 4. Interleaving operazioni di iter[i] e iter[i - 1]
# -------------------------------------------
    .section .data
# Input vectors - 32 single precision floating point values each
v1: .float 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0, 20.0, 21.0, 22.0, 23.0, 24.0, 25.0, 26.0, 27.0, 28.0, 29.0, 30.0, 31.0, 32.0
v2: .float 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5, 12.5, 13.5, 14.5, 15.5, 16.5, 17.5, 18.5, 19.5, 20.5, 21.5, 22.5, 23.5, 24.5, 25.5, 26.5, 27.5, 28.5, 29.5, 30.5, 31.5
v3: .float 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0

# Output vectors - 32 empty slots for results
v4: .float 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
v5: .float 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
v6: .float 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

T0: .word 0x0BADC0DE

    .section .text
    .globl _start
_start:
    # Prefetch dei primi elementi per warm-up della cache
    la x1, v1
    flw fs0, 0(x1)
    la x1, v2
    flw fs0, 0(x1)
    la x1, v3
    flw fs0, 0(x1)
    la x1, v4
    flw fs0, 0(x1)
    la x1, v5
    flw fs0, 0(x1)
    la x1, v6
    flw fs0, 0(x1)
    la x1, T0
    lw x2, 0(x1)

Main:
    # Inizializzazione registri
    li x10, 31              # x10 = i (loop counter principale, parte da 31)
    li x25, 1               # x25 = m (variabile intera m)
    li x26, 3               # x26 = 3 (costante per modulo)

    # Caricamento base addresses
    la x12, v1              # x12 = base address di v1
    la x13, v2              # x13 = base address di v2
    la x14, v3              # x14 = base address di v3
    la x15, v4              # x15 = base address di v4
    la x16, v5              # x16 = base address di v5
    la x17, v6              # x17 = base address di v6

    # Controlla se il numero di iterazioni è dispari
    # Se i è pari, procedi con loop unrolled
    # Se i è dispari (31 è dispari), esegui prima una singola iterazione
    andi x28, x10, 1        # x28 = i & 1 (bit meno significativo)
    beqz x28, loop_unrolled # Se i è pari, vai direttamente al loop unrolled

    # ===== SINGOLA ITERAZIONE INIZIALE (per i dispari) =====
    # Esegui una iterazione standard per allineare il loop
    j single_iteration

loop_unrolled:
    # Controllo loop: esci se i < 1 (serve almeno i = 0 e i = 1 per 2 iterazioni)
    li x28, 0
    ble x10, x28, End       # if i <= 0, exit

    # =================================================================
    # ITERAZIONE 1: Elabora elemento i (corrente)
    # =================================================================

    # FASE 1A: Calcolo indirizzi per iterazione i
    slli x18, x10, 2        # x18 = i * 4 (offset per iter i)

    # Calcolo indirizzi per iter i
    add x19, x12, x18       # x19 = &v1[i]
    add x20, x13, x18       # x20 = &v2[i]
    add x21, x14, x18       # x21 = &v3[i]
    add x22, x15, x18       # x22 = &v4[i]
    add x23, x16, x18       # x23 = &v5[i]
    add x24, x17, x18       # x24 = &v6[i]

    # Caricamento valori iter i
    flw fs1, 0(x19)         # fs1 = v1[i]
    flw fs2, 0(x20)         # fs2 = v2[i]
    flw fs3, 0(x21)         # fs3 = v3[i]

    # Calcolo modulo iter i
    rem x27, x10, x26       # x27 = i % 3

    # Prepara iter i - 1 mentre attendiamo completamento load iter i
    addi x11, x10, -1       # x11 = i - 1 (indice per seconda iterazione)
    slli x9, x11, 2         # x9 = (i - 1) * 4 (offset per iter i - 1)

    # =================================================================
    # ITERAZIONE 2: Prepara indirizzi per elemento i - 1
    # =================================================================

    # Calcolo indirizzi iter i - 1 (usa registri diversi per evitare conflitti)
    add x5, x12, x9         # x5 = &v1[i - 1]
    add x6, x13, x9         # x6 = &v2[i - 1]
    add x7, x14, x9         # x7 = &v3[i - 1]
    add x8, x15, x9         # x8 = &v4[i - 1]
    add x28, x16, x9        # x28 = &v5[i - 1]
    add x29, x17, x9        # x29 = &v6[i - 1]

    # Branch per iter i
    bnez x27, else_branch_i # if i % 3 != 0, vai a else_branch_i

    # -----------------------------------------------------------------
    # IF BRANCH per iterazione i (i multiplo di 3)
    # -----------------------------------------------------------------
if_branch_i:
    # Calcolo: a_i = v1[i] / ((float) (m << 1))
    slli x30, x25, 1        # x30 = m << 1
    fcvt.s.w fs7, x30       # fs7 = (float) (m << 1)

    # Intanto carica dati per iter i - 1
    flw ft1, 0(x5)          # ft1 = v1[i - 1]
    flw ft2, 0(x6)          # ft2 = v2[i - 1]
    flw ft3, 0(x7)          # ft3 = v3[i - 1]

    # Divisione per iter i (12 cicli)
    fdiv.s fs8, fs1, fs7    # fs8 = a_i = v1[i] / ((float) (m << 1))
    
    # Durante fdiv, calcola modulo per iter i - 1
    rem x31, x11, x26       # x31 = (i - 1) % 3

    # Conversione risultato iter i
    fcvt.w.s x25, fs8, rtz  # m = (int) a_i

    j after_if_i

    # -----------------------------------------------------------------
    # ELSE BRANCH per iterazione i (i NON multiplo di 3)
    # -----------------------------------------------------------------
else_branch_i:
    # Calcolo: a_i = v1[i] * ((float) m * i)
    fcvt.s.w fs7, x25       # fs7 = (float) m
    fcvt.s.w fs9, x10       # fs9 = (float) i

    # Durante conversioni, carica dati per iter i - 1
    flw ft1, 0(x5)          # ft1 = v1[i - 1]
    flw ft2, 0(x6)          # ft2 = v2[i - 1]

    # Prima moltiplicazione (6 cicli)
    fmul.s fs10, fs7, fs9   # fs10 = (float) m * i

    # Carica ultimo dato iter i - 1
    flw ft3, 0(x7)          # ft3 = v3[i - 1]

    # Calcola modulo per iter i - 1
    rem x31, x11, x26       # x31 = (i - 1) % 3

    # Seconda moltiplicazione (6 cicli)
    fmul.s fs8, fs1, fs10   # fs8 = a_i = v1[i] * ((float) m * i)

    # Conversione risultato
    fcvt.w.s x25, fs8, rtz  # m = (int) a_i

after_if_i:
    # -----------------------------------------------------------------
    # Calcolo output per iterazione i
    # -----------------------------------------------------------------

    # v4[i] = a_i * v1[i] - v2[i]
    fmul.s fs4, fs8, fs1    # fs4 = a_i * v1[i] (6 cicli)

    # Intanto processa branch per iter i - 1
    bnez x31, else_branch_i1 # if (i - 1) % 3 != 0, vai a else_branch_i1

    # -----------------------------------------------------------------
    # IF BRANCH per iterazione i - 1
    # -----------------------------------------------------------------
if_branch_i1:
    # Calcolo: a_(i - 1) = v1[i - 1] / ((float) (m << 1))
    slli x30, x25, 1        # x30 = m << 1
    fcvt.s.w ft7, x30       # ft7 = (float) (m << 1)

    # Completa calcolo v4[i]
    fsub.s fs4, fs4, fs2    # fs4 = v4[i] = a_i * v1[i] - v2[i] (4 cicli)
    fsw fs4, 0(x22)         # Salva v4[i]

    # Divisione per iter i - 1 (12 cicli)
    fdiv.s ft8, ft1, ft7    # ft8 = a_(i - 1) = v1[i - 1] / ((float) (m << 1))

    # Durante fdiv, inizia calcolo v5[i]
    fdiv.s fs5, fs4, fs3    # fs5 = v4[i] / v3[i] (12 cicli)

    # Conversione risultato per iter i - 1
    fcvt.w.s x25, ft8, rtz  # m = (int) a_(i - 1)

    j after_if_i1

    # -----------------------------------------------------------------
    # ELSE BRANCH per iterazione i - 1
    # -----------------------------------------------------------------
else_branch_i1:
    # Calcolo: a_(i - 1) = v1[i - 1] * ((float) m * (i - 1))
    fcvt.s.w ft7, x25       # ft7 = (float) m
    fcvt.s.w ft9, x11       # ft9 = (float) (i - 1)

    # Completa calcolo v4[i]
    fsub.s fs4, fs4, fs2    # fs4 = v4[i]
    fsw fs4, 0(x22)         # Salva v4[i]

    # Prima moltiplicazione per iter i - 1 (6 cicli)
    fmul.s ft10, ft7, ft9   # ft10 = (float) m * (i - 1)

    # Inizia calcolo v5[i]
    fdiv.s fs5, fs4, fs3    # fs5 = v4[i] / v3[i] (12 cicli)

    # Seconda moltiplicazione iter i - 1 (6 cicli)
    fmul.s ft8, ft1, ft10   # ft8 = a_(i - 1) = v1[i - 1] * ((float) m * (i - 1))

    # Conversione risultato
    fcvt.w.s x25, ft8, rtz  # m = (int) a_(i - 1)

after_if_i1:
    # -----------------------------------------------------------------
    # Completa calcoli output per iterazione i
    # -----------------------------------------------------------------

    # Calcola (v4[i] - v1[i]) per v6[i]
    fsub.s fs11, fs4, fs1   # fs11 = v4[i] - v1[i] (4 cicli)
    fsw fs5, 0(x23)         # Salva v5[i]

    # -----------------------------------------------------------------
    # Calcolo output per iterazione i - 1
    # -----------------------------------------------------------------

    # v4[i - 1] = a_(i - 1) * v1[i - 1] - v2[i - 1]
    fmul.s ft4, ft8, ft1    # ft4 = a_(i - 1) * v1[i - 1] (6 cicli)

    # Calcola v6[i]
    fmul.s fs6, fs11, fs5   # fs6 = v6[i] = (v4[i] - v1[i]) * v5[i] (6 cicli)
    fsw fs6, 0(x24)         # Salva v6[i]

    # Completa v4[i - 1]
    fsub.s ft4, ft4, ft2    # ft4 = v4[i - 1] (4 cicli)
    fsw ft4, 0(x8)          # Salva v4[i - 1]

    # v5[i - 1] = v4[i - 1] / v3[i - 1] - v2[i - 1]
    fdiv.s ft5, ft4, ft3    # ft5 = v4[i - 1] / v3[i - 1] (12 cicli)

    # Durante fdiv, calcola (v4[i - 1] - v1[i - 1]) per v6[i - 1]
    fsub.s ft11, ft4, ft1   # ft11 = v4[i - 1] - v1[i - 1] (4 cicli)
    
    # Decrementa contatore per prossima coppia di iterazioni
    addi x10, x10, -2       # i = i - 2 (processa 2 iter per volta)
    
    # Completa v5[i - 1]
    fsub.s ft5, ft5, ft2    # ft5 = v5[i - 1] (4 cicli)
    fsw ft5, 0(x28)         # Salva v5[i - 1]
    
    # v6[i - 1] = (v4[i - 1] - v1[i - 1]) * v5[i - 1]
    fmul.s ft6, ft11, ft5   # ft6 = v6[i - 1] (6 cicli)
    fsw ft6, 0(x29)         # Salva v6[i - 1]
    
    # Ritorna al loop
    j loop_unrolled

# =================================================================
# SINGOLA ITERAZIONE per cleanup o inizio con i dispari
# =================================================================
single_iteration:
    # Controlla se siamo alla fine
    blt x10, x0, End        # if i < 0, exit
    
    # Calcolo indirizzi
    slli x18, x10, 2        # x18 = i * 4
    add x19, x12, x18       # x19 = &v1[i]
    add x20, x13, x18       # x20 = &v2[i]
    add x21, x14, x18       # x21 = &v3[i]
    add x22, x15, x18       # x22 = &v4[i]
    add x23, x16, x18       # x23 = &v5[i]
    add x24, x17, x18       # x24 = &v6[i]
    
    # Caricamento valori
    flw fs1, 0(x19)         # fs1 = v1[i]
    flw fs2, 0(x20)         # fs2 = v2[i]
    flw fs3, 0(x21)         # fs3 = v3[i]
    
    # Calcolo modulo
    rem x27, x10, x26       # x27 = i % 3
    bnez x27, else_single   # if i % 3 != 0, vai a else_single

if_single:
    # i multiplo di 3
    slli x28, x25, 1        # x28 = m << 1
    fcvt.s.w fs7, x28       # fs7 = (float) (m << 1)
    fdiv.s fs8, fs1, fs7    # fs8 = a = v1[i] / ((float) (m << 1))
    fcvt.w.s x25, fs8, rtz  # m = (int) a
    j after_single

else_single:
    # i NON multiplo di 3
    fcvt.s.w fs7, x25       # fs7 = (float) m
    fcvt.s.w fs9, x10       # fs9 = (float) i
    fmul.s fs10, fs7, fs9   # fs10 = (float) m * i
    fmul.s fs8, fs1, fs10   # fs8 = a = v1[i] * ((float) m * i)
    fcvt.w.s x25, fs8, rtz  # m = (int) a

after_single:
    # Calcolo output
    fmul.s fs4, fs8, fs1    # fs4 = a * v1[i]
    fsub.s fs4, fs4, fs2    # fs4 = v4[i]
    fsw fs4, 0(x22)         # Salva v4[i]
    
    fdiv.s fs5, fs4, fs3    # fs5 = v4[i] / v3[i]
    fsub.s fs11, fs4, fs1   # fs11 = v4[i] - v1[i]
    fsub.s fs5, fs5, fs2    # fs5 = v5[i]
    fsw fs5, 0(x23)         # Salva v5[i]
    
    fmul.s fs6, fs11, fs5   # fs6 = v6[i]
    fsw fs6, 0(x24)         # Salva v6[i]
    
    # Decrementa e vai al loop unrolled
    addi x10, x10, -1       # i--
    j loop_unrolled

End:
    # Terminazione
    li a0, 0
    li a7, 93
    ecall