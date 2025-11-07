#******** RISCV NEURAL NETWORK PROGRAM - LOOP UNROLLING x8 ************
#-------------------------------------------
# program_1_d.s
# Versione con loop unrolling di fattore 8 di program_1_a.s
# Il loop viene srotolato 8 volte per massimizzare il parallelismo
# a livello di istruzioni e ridurre al minimo l'overhead del branch
# Con 16 elementi, avremo 16/8 = 2 iterazioni totali
#-------------------------------------------
    .section .data
# Input vector i: 16 single precision floating point values
i: .float 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0
   .float 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0

# Weight vector w: 16 single precision floating point values
w: .float 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5
   .float 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5

# Bias value b = 0xab (171 in decimal as float)
b: .float 171.0

# Output value y
y: .float 0.0

# Temporary storage
T0: .word 0x0BADC0DE

    .section .text
    .globl _start
_start:
    # Caricamento iniziale in cache di tutti i data segment
    # Interpolare load per ridurre stalli della pipeline
    la x1, i
    la x5, w
    flw fs1, 0(x1)      # Cache i[0]
    la x6, b
    flw fs2, 0(x5)      # Cache w[0]
    la x7, y
    flw fs3, 0(x6)      # Cache b
    la x1, T0
    flw fs4, 0(x7)      # Cache y
    lw x2, 0(x1)        # Cache T0

Main:
    # Inizializzazione variabili
    # Con unrolling di fattore 8, facciamo 16/8 = 2 iterazioni
    li x3, 2            # x3 = K/8 = numero iterazioni loop (16/8 = 2)
    la x5, i            # x5 = puntatore vettore input i
    la x6, w            # x6 = puntatore vettore pesi w
    li x4, 0            # x4 = j = contatore iterazioni

    # Pre-load dei primi 16 elementi (8 coppie per unrolling x8)
    # Utilizziamo 16 registri floating point per le 8 coppie
    # Questo permette di avere tutti i dati pronti per il calcolo
    # minimizzando gli stalli di pipeline

    # COPPIA 0: i[0], w[0]
    flw ft0, 0(x5)      # ft0 = i[0]
    flw ft1, 0(x6)      # ft1 = w[0]

    # COPPIA 1: i[1], w[1]
    flw ft2, 4(x5)      # ft2 = i[1]
    flw ft3, 4(x6)      # ft3 = w[1]

    # COPPIA 2: i[2], w[2]
    flw ft4, 8(x5)      # ft4 = i[2]
    flw ft5, 8(x6)      # ft5 = w[2]

    # COPPIA 3: i[3], w[3]
    flw ft6, 12(x5)     # ft6 = i[3]
    flw ft7, 12(x6)     # ft7 = w[3]

    # COPPIA 4: i[4], w[4]
    flw fs1, 16(x5)     # fs1 = i[4]
    flw fs2, 16(x6)     # fs2 = w[4]

    # COPPIA 5: i[5], w[5]
    flw fs3, 20(x5)     # fs3 = i[5]
    flw fs4, 20(x6)     # fs4 = w[5]

    # COPPIA 6: i[6], w[6]
    flw fs5, 24(x5)     # fs5 = i[6]
    flw fs6, 24(x6)     # fs6 = w[6]

    # COPPIA 7: i[7], w[7]
    flw fs7, 28(x5)     # fs7 = i[7]
    flw fs8, 28(x6)     # fs8 = w[7]

    # Inizializza accumulatore a zero
    fmv.w.x fs0, zero   # fs0 = 0.0 (accumulatore principale)

    # Pre-incrementa puntatori di 32 byte (8 elementi float)
    # per prepararli alla prossima iterazione
    addi x5, x5, 32     # puntatore i += 32 (salta 8 float)
    addi x6, x6, 32     # puntatore w += 32 (salta 8 float)

sum_loop:
    # ===== ITERAZIONE UNROLLED 0: elabora elemento j =====
    # Moltiplica i[j] * w[j]
    fmul.s ft8, ft0, ft1    # ft8 = i[j] * w[j]

    # Pre-load elementi per la PROSSIMA iterazione (j + 8)
    flw ft0, 0(x5)          # ft0 = i[j + 8] (pre-load)
    flw ft1, 0(x6)          # ft1 = w[j + 8] (pre-load)

    # ===== ITERAZIONE UNROLLED 1: elabora elemento j + 1 =====
    fmul.s ft9, ft2, ft3    # ft9 = i[j + 1] * w[j + 1]

    # Pre-load per prossima iterazione (j + 9)
    flw ft2, 4(x5)          # ft2 = i[j + 9] (pre-load)
    flw ft3, 4(x6)          # ft3 = w[j + 9] (pre-load)

    # ===== ITERAZIONE UNROLLED 2: elabora elemento j + 2 =====
    fmul.s ft10, ft4, ft5   # ft10 = i[j + 2] * w[j + 2]

    # Pre-load per prossima iterazione (j + 10)
    flw ft4, 8(x5)          # ft4 = i[j + 10] (pre-load)
    flw ft5, 8(x6)          # ft5 = w[j + 10] (pre-load)

    # ===== ITERAZIONE UNROLLED 3: elabora elemento j + 3 =====
    fmul.s ft11, ft6, ft7   # ft11 = i[j + 3] * w[j + 3]

    # Pre-load per prossima iterazione (j + 11)
    flw ft6, 12(x5)         # ft6 = i[j + 11] (pre-load)
    flw ft7, 12(x6)         # ft7 = w[j + 11] (pre-load) 

    # ===== ITERAZIONE UNROLLED 4: elabora elemento j + 4 =====
    fmul.s fa0, fs1, fs2    # fa0 = i[j + 4] * w[j + 4]

    # Pre-load per prossima iterazione (j + 12)
    flw fs1, 16(x5)         # fs1 = i[j + 12] (pre-load)
    flw fs2, 16(x6)         # fs2 = w[j + 12] (pre-load)

    # ===== ITERAZIONE UNROLLED 5: elabora elemento j + 5
    fmul.s fa1, fs3, fs4    # fa1 = i[j + 5] * w[j + 5]

    # Pre-load per prossima iterazione (j + 13)
    flw fs3, 20(x5)         # fs3 = i[j + 13] (pre-load)
    flw fs4, 20(x6)         # fs4 = w[j + 13] (pre-load)

    # ===== ITERAZIONE UNROLLED 6: elabora elemento j + 6 =====
    fmul.s fa2, fs5, fs6    # fa2 = i[j + 6] * w[j + 6]

    # Pre-load per prossima iterazione (j + 14)
    flw fs5, 24(x5)         # fs5 = i[j + 14] (pre-load)
    flw fs6, 24(x6)         # fs6 = w[j + 14] (pre-load)

    # ===== ITERAZIONE UNROLLED 7: elabora elemento j + 7 =====
    fmul.s fa3, fs7, fs8    # fa3 = i[j + 7] * w[j + 7]

    # Pre-load per prossima iterazione (j + 15)
    flw fs7, 28(x5)         # fs7 = i[j + 15] (pre-load)
    flw fs8, 28(x6)         # fs8 = w[j + 15] (pre-load)

    # Aggiorna puntatori: avanza di 32 byte (8 float)
    addi x5, x5, 32         # puntatore i += 32
    addi x6, x6, 32         # puntatore w += 32

    # Accumula tutti gli 8 prodotti parziali
    # Utilizziamo una strategia di somma ad albero per ridurre dipendenze:
    # Invece di sommare sequenzialmente (fs0 += ft8; fs0 += ft9; ...),
    # sommiamo a coppie per massimizzare il parallelismo

    # Livello 1: somme delle prime 4 coppie
    fadd.s fa4, ft8, ft9    # fa4 = prodotto[0] + prodotto[1]
    fadd.s fa5, ft10, ft11  # fa5 = prodotto[2] + prodotto[3]
    fadd.s fa6, fa0, fa1    # fa6 = prodotto[4] + prodotto[5]
    fadd.s fa7, fa2, fa3    # fa7 = prodotto[6] + prodotto[7]

    # Livello 2: somme delle coppie precedenti
    fadd.s fa4, fa4, fa5    # fa4 = somma(prodotti 0-3)
    fadd.s fa6, fa6, fa7    # fa6 = somma(prodotti 4-7)

    # Livello 3: somma finale dei due gruppi
    fadd.s fa4, fa4, fa6    # fa4 = somma(tutti i prodotti 0-7)

    # Aggiungi al totale accumulato
    fadd.s fs0, fs0, fa4    # fs0 += somma di questa iterazione

    # Incrementa contatore: abbiamo processato 8 elementi, quindi +1 iterazione
    addi x4, x4, 1          # j++

    # Controlla se dobbiamo continuare: se j < K/8, continua
    blt x4, x3, sum_loop    # loop se j < 2

compute_activation:
    # Carica indirizzo bias e costante per check NaN
    la x7, b                # x7 = indirizzo bias
    li x10, 0xFF            # x10 = 0xFF (per check esponente NaN/Inf)
    flw fs4, 0(x7)          # fs4 = bias b

    # Somma bias al risultato accumulato
    fadd.s fs0, fs0, fs4    # fs0 = x = sum + b

    # Converti float in bit pattern intero per estrarre esponente
    fmv.x.w x8, fs0         # x8 = rappresentazione bit di x

    # Estrai esponente (bit 30-23 per single precision)
    srli x9, x8, 23         # shift right 23 bit
    la x11, y               # Pre-carica indirizzo output y
    andi x9, x9, 0xFF       # maschera per ottenere 8 bit esponente

    # Controlla se esponente == 0xFF (indica NaN o Infinito)
    # Se esponente != 0xFF, x è valido, imposta y = x
    bne x9, x10, set_value  # se exp != 0xFF, vai a set_value

set_zero:
    # Esponente == 0xFF: NaN o Inf rilevato
    # Imposta output y = 0.0 come funzione di attivazione
    fmv.w.x fs5, zero       # fs5 = 0.0
    j store_result          # salta a salvataggio

set_value:
    # Valore valido (non NaN): imposta y = x
    fmv.s fs5, fs0          # fs5 = x (copia il valore calcolato)

store_result:
    # Salva risultato finale in memoria
    # x11 contiene già l'indirizzo di y (pre-caricato sopra)
    fsw fs5, 0(x11)         # memorizza fs5 in y

End:
    # Syscall exit per terminare il programma
    li a0, 0                # codice ritorno 0
    li a7, 93               # syscall number per exit
    ecall