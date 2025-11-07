#******** RISCV NEURAL NETWORK PROGRAM - OPTIMIZED ************
#-------------------------------------------
# program_1_a.s
# Versione ottimizzata di program_1.s con rescheduling
# per eliminare gli hazard di pipeline
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
    # Load first elements of each data area into cache
    # OTTIMIZZAZIONE: Interpolare load di interi e float per ridurre stalli
    la x1, i
    la x5, w            # Pre-carichiamo anche l'indirizzo di w
    flw fs1, 0(x1)      # Cache i[0]
    la x6, b            # Pre-carichiamo indirizzo di b
    flw fs2, 0(x5)      # Cache w[0]
    la x7, y            # Pre-carichiamo indirizzo di y
    flw fs3, 0(x6)      # Cache b
    la x1, T0
    flw fs4, 0(x7)      # Cache y
    lw x2, 0(x1)        # Cache T0

Main:
    # OTTIMIZZAZIONE: Preparare tutte le variabili prima del loop
    # per evitare dipendenze all'inizio del loop
    li x3, 16           # x3 = K = numero di elementi
    la x5, i            # x5 = indirizzo del vettore i
    la x6, w            # x6 = indirizzo del vettore w
    li x4, 0            # x4 = j = contatore loop
    
    # OTTIMIZZAZIONE: Pre-load dei primi due elementi per nascondere latenza
    flw fs1, 0(x5)      # fs1 = i[0]
    flw fs2, 0(x6)      # fs2 = w[0]
    
    # Inizializza accumulatore mentre si attendono i load
    fmv.w.x fs0, zero   # fs0 = 0.0 (accumulatore)
    
    # Pre-incrementa i puntatori per la prossima iterazione
    addi x5, x5, 4      # puntatore i già pronto per i[1]
    addi x6, x6, 4      # puntatore w già pronto per w[1]

sum_loop:
    # OTTIMIZZAZIONE: Moltiplicazione può iniziare subito (i dati sono già caricati)
    fmul.s fs3, fs1, fs2    # fs3 = i[j] * w[j]
    
    # OTTIMIZZAZIONE: Mentre avviene la moltiplicazione, carichiamo i prossimi valori
    # per nascondere la latenza dei load nella prossima iterazione
    flw fs1, 0(x5)      # fs1 = i[j+1] (load anticipato)
    flw fs2, 0(x6)      # fs2 = w[j+1] (load anticipato)
    
    # OTTIMIZZAZIONE: Incremento contatore e puntatori mentre fs3 viene calcolato
    addi x4, x4, 1      # j++ (eseguito prima del branch per ridurre hazard)
    addi x5, x5, 4      # puntatore i += 4
    addi x6, x6, 4      # puntatore w += 4
    
    # Somma al totale (ora fs3 è pronto)
    fadd.s fs0, fs0, fs3    # fs0 += (i[j] * w[j])
    
    # OTTIMIZZAZIONE: Branch ritardato - il confronto avviene mentre fadd completa
    blt x4, x3, sum_loop    # continua se j < K

compute_activation:
    # OTTIMIZZAZIONE: Carica bias e prepara calcoli seguenti
    la x7, b            # indirizzo bias
    li x10, 0xFF        # Pre-carica costante 0xFF per check NaN successivo
    flw fs4, 0(x7)      # fs4 = b
    
    # Somma bias (dopo 1 ciclo di latenza dal load)
    fadd.s fs0, fs0, fs4    # fs0 = x = sum + b
    
    # OTTIMIZZAZIONE: Mentre fadd.s completa, prepariamo altre operazioni
    # Sposta fs0 in registro intero per check NaN
    fmv.x.w x8, fs0     # x8 = bit pattern di x
    
    # OTTIMIZZAZIONE: Operazioni shift e mask sono indipendenti
    srli x9, x8, 23     # shift right 23 bit per estrarre esponente
    la x11, y           # Pre-carica indirizzo y per store finale
    andi x9, x9, 0xFF   # maschera per ottenere esponente 8-bit
    
    # Check se esponente == 0xFF (NaN o Inf)
    # OTTIMIZZAZIONE: x10 già contiene 0xFF (pre-caricato sopra)
    bne x9, x10, set_value   # se exp != 0xFF, y = x

set_zero:
    # OTTIMIZZAZIONE: Imposta y = 0.0
    fmv.w.x fs5, zero   # fs5 = 0.0
    j store_result      # salta a store

set_value:
    # OTTIMIZZAZIONE: y = x (semplice move, 0 latenza aggiuntiva)
    fmv.s fs5, fs0      # fs5 = x

store_result:
    # OTTIMIZZAZIONE: x11 già contiene indirizzo y (caricato prima)
    fsw fs5, 0(x11)     # salva y in memoria

End:
    # exit() syscall
    li a0, 0
    li a7, 93
    ecall