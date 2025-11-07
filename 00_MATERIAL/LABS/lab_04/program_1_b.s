#******** RISCV NEURAL NETWORK PROGRAM - LOOP UNROLLING ************
#-------------------------------------------
# program_1_b.s
# Versione con loop unrolling (fattore 2) di program_1_a.s
# Il loop viene srotolato 2 volte per ridurre overhead del branch
# e aumentare il parallelismo a livello di istruzioni
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
    # Interpolare load per ridurre stalli
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
    # Con unrolling di fattore 2, facciamo 16/2 = 8 iterazioni
    li x3, 8            # x3 = K/2 = numero iterazioni loop (16/2 = 8)
    la x5, i            # x5 = puntatore vettore i
    la x6, w            # x6 = puntatore vettore w
    li x4, 0            # x4 = j = contatore iterazioni
    
    # Pre-load dei primi 4 elementi (2 coppie per unrolling)
    # Usiamo più registri per eliminare dipendenze
    flw fs1, 0(x5)      # fs1 = i[0] - prima coppia
    flw fs2, 0(x6)      # fs2 = w[0] - prima coppia
    flw fs4, 4(x5)      # fs4 = i[1] - seconda coppia
    flw fs5, 4(x6)      # fs5 = w[1] - seconda coppia
    
    # Inizializza accumulatore
    fmv.w.x fs0, zero   # fs0 = 0.0 (accumulatore principale)
    
    # Pre-incrementa puntatori di 8 byte (2 elementi)
    # per prepararli alla prossima iterazione
    addi x5, x5, 8      # puntatore i += 8 (salta 2 float)
    addi x6, x6, 8      # puntatore w += 8 (salta 2 float)

sum_loop:
    # ===== PRIMA ITERAZIONE SROTOLATA (elementi j) =====
    # Moltiplica prima coppia i[j] * w[j]
    fmul.s fs3, fs1, fs2    # fs3 = i[j] * w[j]
    
    # Carica elementi per la PROSSIMA iterazione (j + 2) mentre processiamo j e j + 1
    # Questo nasconde la latenza dei load
    flw fs1, 0(x5)      # fs1 = i[j + 2] (pre-load per prossima iterazione)
    flw fs2, 0(x6)      # fs2 = w[j + 2] (pre-load per prossima iterazione)
    
    # ===== SECONDA ITERAZIONE SROTOLATA (elementi j+1) =====
    # Moltiplica seconda coppia i[j+1] * w[j+1]
    # Usa registri diversi (fs4, fs5, fs6) per evitare dipendenze con fs3
    fmul.s fs6, fs4, fs5    # fs6 = i[j + 1] * w[j + 1]
    
    # Carica elementi per la prossima iterazione (j + 3)
    flw fs4, 4(x5)      # fs4 = i[j + 3] (pre-load)
    flw fs5, 4(x6)      # fs5 = w[j + 3] (pre-load)
    
    # Aggiorna puntatori: avanza di 8 byte (2 float)
    addi x5, x5, 8      # puntatore i += 8
    addi x6, x6, 8      # puntatore w += 8
    
    # Somma i risultati delle due moltiplicazioni all'accumulatore
    # fs3 e fs6 sono pronti da cicli precedenti
    fadd.s fs0, fs0, fs3    # fs0 += i[j] * w[j]
    fadd.s fs0, fs0, fs6    # fs0 += i[j+1] * w[j+1]
    
    # Incrementa contatore: abbiamo processato 2 elementi, quindi +1 iterazione
    addi x4, x4, 1      # j++
    
    # Controlla se dobbiamo continuare: se j < K/2, continua
    blt x4, x3, sum_loop    # loop se j < 8

compute_activation:
    # Carica indirizzo bias e costante per check NaN
    la x7, b            # x7 = indirizzo bias
    li x10, 0xFF        # x10 = 0xFF (per check esponente NaN/Inf)
    flw fs4, 0(x7)      # fs4 = bias b
    
    # Somma bias al risultato accumulato
    fadd.s fs0, fs0, fs4    # fs0 = x = sum + b
    
    # Converti float in bit pattern intero per estrarre esponente
    fmv.x.w x8, fs0     # x8 = rappresentazione bit di x
    
    # Estrai esponente (bit 30-23 per single precision)
    srli x9, x8, 23     # shift right 23 bit
    la x11, y           # Pre-carica indirizzo output y
    andi x9, x9, 0xFF   # maschera per ottenere 8 bit esponente
    
    # Controlla se esponente == 0xFF (indica NaN o Infinito)
    # Se esponente != 0xFF, x è valido, imposta y = x
    bne x9, x10, set_value   # se exp != 0xFF, vai a set_value

set_zero:
    # Esponente == 0xFF: NaN o Inf rilevato
    # Imposta output y = 0.0 come funzione di attivazione
    fmv.w.x fs5, zero   # fs5 = 0.0
    j store_result      # salta a salvataggio

set_value:
    # Valore valido (non NaN): imposta y = x
    fmv.s fs5, fs0      # fs5 = x (copia il valore calcolato)

store_result:
    # Salva risultato finale in memoria
    # x11 contiene già l'indirizzo di y (pre-caricato sopra)
    fsw fs5, 0(x11)     # memorizza fs5 in y

End:
    # Syscall exit per terminare il programma
    li a0, 0            # codice ritorno 0
    li a7, 93           # syscall number per exit
    ecall