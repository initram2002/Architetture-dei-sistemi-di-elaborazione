#******** RISCV NEURAL NETWORK PROGRAM - LOOP UNROLLING x4 ************
#-------------------------------------------
# program_1_c.s
# Versione con loop unrolling di fattore 4 di program_1_a.s
# Il loop viene srotolato 4 volte per massimizzare il parallelismo
# a livello di istruzioni e ridurre ulteriormente l'overhead del branch
# Con 16 elementi, avremo 16/4 = 4 iterazioni totali
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
    # Con unrolling di fattore 4, facciamo 16/4 = 4 iterazioni
    li x3, 4            # x3 = K/4 = numero iterazioni loop (16/4 = 4)
    la x5, i            # x5 = puntatore vettore input i
    la x6, w            # x6 = puntatore vettore pesi w
    li x4, 0            # x4 = j = contatore iterazioni

    # Pre-load dei primi 8 elementi (4 coppie per unrolling x4)
    # Utilizziamo 8 registri floating point per le 4 coppie
    # COPPIA 0: i[0], w[0]
    flw fs1, 0(x5)      # fs1 = i[0]
    flw fs2, 0(x6)      # fs2 = w[0]
    # COPPIA 1: i[1], w[1]
    flw ft0, 4(x5)      # ft0 = i[1]
    flw ft1, 4(x6)      # ft1 = w[1]
    # COPPIA 2: i[2], w[2] 
    flw ft2, 8(x5)      # ft2 = i[2]
    flw ft3, 8(x6)      # ft3 = w[2]
    # COPPIA 3: i[3], w[3]
    flw ft4, 12(x5)     # ft4 = i[3]
    flw ft5, 12(x6)     # ft5 = w[3]

    # Inizializza accumulatore a zero
    fmv.w.x fs0, zero   # fs0 = 0.0 (accumulatore principale)

    # Pre-incrementa puntatori di 16 byte (4 elementi float)
    # per prepararli alla prossima iterazione
    addi x5, x5, 16     # puntatore i += 16 (salta 4 float)
    addi x6, x6, 16     # puntatore w += 16 (salta 4 float)

sum_loop:
    # ===== PRIMA ITERAZIONE UNROLLED: elabora elementi j =====
    # Moltiplica i[j] * w[j]
    fmul.s fs3, fs1, fs2    # fs3 = i[j] * w[j]

    # Pre-load elementi per la PROSSIMA iterazione (j + 4)
    # mentre processiamo gli elementi correnti
    flw fs1, 0(x5)          # fs1 = i[j + 4] (pre-load)
    flw fs2, 0(x6)          # fs2 = w[j + 4] (pre-load)

    # ===== SECONDA ITERAZIONE UNROLLED: elabora elementi j + 1 =====
    # Moltiplica i[j + 1] * w[j + 1]
    fmul.s ft6, ft0, ft1    # ft6 = i[j + 1] * w[j + 1]

    # Pre-load elementi per la prossima iterazione (j + 5)
    flw ft0, 4(x5)          # ft0 = i[j + 5] (pre-load)
    flw ft1, 4(x6)          # ft1 = w[j + 5] (pre-load)

    # ===== TERZA ITERAZIONE UNROLLED: elabora elementi j + 2 =====
    # Moltiplica i[j + 2] * w[j + 2]
    fmul.s ft7, ft2, ft3    # ft7 = i[j + 2] * w[j + 2]
    
    # Pre-load elementi per la prossima iterazione (j + 6)
    flw ft2, 8(x5)          # ft2 = i[j + 6] (pre-load)
    flw ft3, 8(x6)          # ft3 = w[j + 6] (pre-load)

    # ===== QUARTA ITERAZIONE UNROLLED: elabora elementi j + 3 =====
    # Moltiplica i[j + 3] * w[j + 3]
    fmul.s ft8, ft4, ft5    # ft8 = i[j + 3] * w[j + 3]

    # Pre-load elementi per la prossima iterazione (j + 7)
    flw ft4, 12(x5)         # ft4 = i[j + 7] (pre-load)
    flw ft5, 12(x6)         # ft5 = w[j + 7] (pre-load)

    # Aggiorna puntatori: avanza di 16 byte (4 float)
    addi x5, x5, 16         # puntatore i += 16
    addi x6, x6, 16         # puntatore w += 16

    # Accumula tutti e 4 i prodotti parziali
    # Sommiamo in ordine per ridurre dipendenze
    fadd.s fs0, fs0, fs3    # fs0 += i[j] * w[j]
    fadd.s fs0, fs0, ft6    # fs0 += i[j + 1] * w[j + 1]
    fadd.s fs0, fs0, ft7    # fs0 += i[j + 2] * w[j + 2]
    fadd.s fs0, fs0, ft8    # fs0 += i[j + 3] * w[j + 3]

    # Incrementa contatore: abbiamo processato 4 elementi, quindi +1 iterazione
    addi x4, x4, 1          # j++

    # Controlla se dobbiamo continuare: se j < K/4, continua
    blt x4, x3, sum_loop    # loop se j < 4

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
    bne x9, x10, set_value   # se exp != 0xFF, vai a set_value

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