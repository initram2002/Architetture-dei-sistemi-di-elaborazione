#******** RISCV OPTIMIZED PROGRAM ************
# -------------------------------------------
# program_1_a.s
# Versione ottimizzata di program_1.s con riduzione degli hazard
# Ottimizzazioni applicate:
# 1. Riordinamento istruzioni per evitare stalli RAW
# 2. Interleaving di operazioni integer e FP
# 3. Precalcolo di indirizzi e valori
# 4. Software pipelining per sfruttare latenze FP
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
    # Riduce miss penalty per le prime iterazioni
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
    li x10, 31              # x10 = i (loop counter, parte da 31)
    li x25, 1               # x25 = m (variabile intera m)
    li x26, 3               # x26 = 3 (costante per modulo, precalcolata)

    # Caricamento base addresses - fatto una sola volta
    la x12, v1              # x12 = base address di v1
    la x13, v2              # x13 = base address di v2
    la x14, v3              # x14 = base address di v3
    la x15, v4              # x15 = base address di v4
    la x16, v5              # x16 = base address di v5
    la x17, v6              # x17 = base address di v6

loop:
    # Branch prediction: controllo loop all'inizio
    blt x10, x0, End        # if i < 0, exit loop

    # PHASE 1: Calcolo indirizzi e caricamento dati
    # Operazioni integer non dipendenti da FP precedenti
    slli x18, x10, 2        # x18 = i * 4 (offset)

    # Calcolo tutti gli indirizzi in parallelo (no dependencies)
    add x19, x12, x18       # x19 = &v1[i]
    add x20, x13, x18       # x20 = &v2[i]
    add x21, x14, x18       # x21 = &v3[i]
    add x22, x15, x18       # x22 = &v4[i]
    add x23, x16, x18       # x23 = &v5[i]
    add x24, x17, x18       # x24 = &v6[i]

    # Caricamento valori da memoria (latenza: 2-3 cicli)
    flw fs1, 0(x19)         # fs1 = v1[i]
    flw fs2, 0(x20)         # fs2 = v2[i]
    flw fs3, 0(x21)         # fs3 = v3[i]

    # PHASE 2: Calcolo modulo mentre le load completano
    # Evita lo stallo inserendo operazioni integer tra load e uso FP
    rem x27, x10, x26       # x27 = i % 3 (remainder)

    # Precalcolo per iterazione successiva (riduce latenza nel loop)
    addi x29, x10, -1       # x29 = i - 1 (prossima iterazione)

    # Branch: determina il percorso di calcolo
    bnez x27, else_branch   # if i % 3 != 0, vai a else_branch

    # ===== IF BRANCH: i multiplo di 3 =====
    # Calcolo: a = v1[i] / ((float)(m << 1))

    # Operazioni integer per preparare divisore
    slli x28, x25, 1        # x28 = m << 1
    fcvt.s.w fs7, x28       # fs7 = (float)(m << 1) [Latency: 3 cicli]

    # Durante la conversione, precalcola offset prossima iterazione
    slli x30, x29, 2        # x30 = (i - 1) * 4
    add x31, x12, x30       # x31 = &v[i - 1] per prefetch

    # Divisione FP (latenza: 12 cicli) - operazione più costosa
    fdiv.s fs8, fs1, fs7    # fs8 = a = v1[i] / ((float)(m << 1))

    # OTTIMIZZAZIONE: Durante i 12 cicli di fdiv, esegui operazioni utili
    # Prefetch dato per prossima iterazione
    blt x29, x0, skip_pf1   # Salta prefetch se i - 1 < 0
    flw fs0, 0(x31)         # Carica v1[i - 1] in cache
skip_pf1:
    # Prepara registri per fase successiva
    # (nessuna dipendenza da fs8 ancora)

    # Conversione risultato a intero (dipende da fdiv: attendi completamento)
    fcvt.w.s x25, fs8, rtz  # m = (int) a [Latency: 3 cicli]

    j after_if              # Salta al codice comune

else_branch:
    # ===== ELSE BRANCH: i NON multiplo di 3 =====
    # Calcolo: a = v1[i] * ((float) m * i)

    # Conversioni float (latenza: 3 cicli ciascuna)
    fcvt.s.w fs7, x25       # fs7 = (float) m
    fcvt.s.w fs9, x10       # fs9 = (float) i

    # OTTIMIZZAZIONE: Le due fcvt sono indipendenti, possono sovrapporsi
    # Durante le conversioni, prepara dati per iterazione successiva
    slli x30, x29, 2        # x30 = (i - 1) * 4

    # Prima moltiplicazione (latenza: 6 cicli)
    fmul.s fs10, fs7, fs9   # fs10 = (float) m * i

    # Durante fmul, calcola indirizzo prefetch
    add x31, x12, x30       # x31 = &v1[i - 1]

    # Seconda moltiplicazione (dipende da fs10, latenza: 6 cicli)
    fmul.s fs8, fs1, fs10   # fs8 = a = v1[i] * ((float) m * i)

    # Durante questa fmul, fai prefetch se possibile
    blt x29, x0, skip_pf2
    flw fs0, 0(x31)         # Prefetch v1[i - 1]
skip_pf2:

    # Conversione risultato a intero
    fcvt.w.s x25, fs8, rtz  # m = (int) a

after_if:
    # ===== CODICE COMUNE: Calcolo output vectors =====

    # v4[i] = a * v1[i] - v2[i]
    # fs8 contiene 'a', fs1 contiene v1[i], fs2 contiene v2[i]

    # Moltiplicazione (latenza: 6 cicli)
    fmul.s fs4, fs8, fs1    # fs4 = a * v1[i]

    # OTTIMIZZAZIONE: Durante fmul, prepara calcoli per v6
    # Precalcola (v4[i] - v1[i]) = (a * v1[i] - v2[i] - v1[i])
    # Ma fs4 non è ancora pronto, quindi prepariamo altre cose

    # Sottrazione (dipende da fmul, latenza: 4 cicli)
    fsub.s fs4, fs4, fs2    # fs4 = v4[i] = a * v1[i] - v2[i]

    # Store v4[i] (può avvenire appena fs4 è pronto)
    fsw fs4, 0(x22)         # Salva v4[i]

    # v5[i] = v4[i]/v3[i] - v2[i]
    # Divisione (latenza: 12 cicli) - inizia appena fs4 è pronto
    fdiv.s fs5, fs4, fs3    # fs5 = v4[i]/v3[i]

    # OTTIMIZZAZIONE CRITICA: Durante i 12 cicli di fdiv:
    # Calcola (v4[i] - v1[i]) per v6, che dipende da fs4 già disponibile
    fsub.s fs11, fs4, fs1   # fs11 = v4[i] - v1[i] [Latency: 4 cicli]

    # Ancora 8 cicli disponibili durante fdiv: prepara prossima iterazione
    # Decrementa contatore (può essere fatto ora per branch prediction)
    addi x10, x10, -1       # i-- (prepara per prossima iterazione)

    # Calcola offset prossima iterazione
    slli x18, x10, 2        # x18 = nuovo i * 4

    # Completa v5: sottrazione (dipende da fdiv)
    fsub.s fs5, fs5, fs2    # fs5 = v5[i] = v4[i]/v3[i] - v2[i]

    # Store v5[i]
    fsw fs5, 0(x23)         # Salva v5[i]

    # v6[i] = (v4[i] - v1[i]) * v5[i]
    # fs11 già contiene (v4[i] - v1[i]), fs5 contiene v5[i]
    # Moltiplicazione (latenza: 6 cicli)
    fmul.s fs6, fs11, fs5   # fs6 = v6[i] = (v4[i] - v1[i]) * v5[i]

    # Durante fmul, prepara indirizzi per prossima iterazione (già fatto x18)
    # Calcola primo indirizzo che servirà
    add x19, x12, x18       # x19 = &v1[i] per prossima iterazione

    # Store v6[i] (quando fmul completa)
    fsw fs6, 0(x24)         # Salva v6[i]
    
    # Torna all'inizio del loop
    # Branch prediction: likely taken fino a fine loop
    j loop

End:
    # Terminazione con syscall exit
    li a0, 0                # Codice di uscita 0
    li a7, 93               # Numero syscall exit
    ecall                   # Esegui syscall