#******** RISCV NEURAL NETWORK PROGRAM - FULL LOOP UNROLLING x16 ************
#-------------------------------------------
# program_1_e.s
# Versione con loop unrolling COMPLETO di fattore 16 di program_1_a.s
# Il loop viene completamente eliminato: tutti i 16 elementi vengono
# processati sequenzialmente senza alcun branch nel loop principale
# Questo massimizza il parallelismo a livello di istruzioni (ILP)
# eliminando completamente l'overhead dei branch
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
    # Inizializzazione puntatori ai vettori
    la x5, i            # x5 = puntatore vettore input i
    la x6, w            # x6 = puntatore vettore pesi w

    # ============================================================
    # CARICAMENTO DI TUTTI I 16 ELEMENTI IN REGISTRI
    # Utilizziamo 31 registri floating point (16 per i, 15 per w)
    # per avere tutti i dati disponibili contemporaneamente
    # ============================================================

    # GRUPPO 1: Elementi 0-3 (utilizziamo registri ft0-ft7)
    flw ft0, 0(x5)      # ft0 = i[0]
    flw ft1, 0(x6)      # ft1 = w[0]
    flw ft2, 4(x5)      # ft2 = i[1]
    flw ft3, 4(x6)      # ft3 = w[1]
    flw ft4, 8(x5)      # ft4 = i[2]
    flw ft5, 8(x6)      # ft5 = w[2]
    flw ft6, 12(x5)     # ft6 = i[3]
    flw ft7, 12(x6)     # ft7 = w[3]

    # GRUPPO 2: Elementi 4-7 (utilizziamo registri fs1-fs8)
    flw fs1, 16(x5)     # fs1 = i[4]
    flw fs2, 16(x6)     # fs2 = w[4]
    flw fs3, 20(x5)     # fs3 = i[5]
    flw fs4, 20(x6)     # fs4 = w[5]
    flw fs5, 24(x5)     # fs5 = i[6]
    flw fs6, 24(x6)     # fs6 = w[6]
    flw fs7, 28(x5)     # fs7 = i[7]
    flw fs8, 28(x6)     # fs8 = w[7]

    # GRUPPO 3: Elementi 8-11 (utilizziamo registri fa0-fa7)
    flw fa0, 32(x5)     # fa0 = i[8]
    flw fa1, 32(x6)     # fa1 = w[8]
    flw fa2, 36(x5)     # fa2 = i[9]
    flw fa3, 36(x6)     # fa3 = w[9]
    flw fa4, 40(x5)     # fa4 = i[10]
    flw fa5, 40(x6)     # fa5 = w[10]
    flw fa6, 44(x5)     # fa6 = i[11]
    flw fa7, 44(x6)     # fa7 = w[11]

    # GRUPPO 4: Elementi 12-15 (utilizziamo registri ft8-ft11 e fs9-fs11)
    flw ft8, 48(x5)     # ft8 = i[12]
    flw ft9, 48(x6)     # ft9 = w[12]
    flw ft10, 52(x5)    # ft10 = i[13]
    flw ft11, 52(x6)    # ft11 = w[13]
    flw fs9, 56(x5)     # fs9 = i[14]
    flw fs10, 56(x6)    # fs10 = w[14]
    flw fs11, 60(x5)    # fs11 = i[15]

    # Inizializza accumulatore a zero
    fmv.w.x fs0, zero   # fs0 = 0.0 (accumulatore principale)

    # Ultimo caricamento usando un registro temporaneo
    # Utilizziamo fa1 come temporaneo (verrà sovrascritto dalla moltiplicazione)
    flw fa1, 60(x6)     # fa1 = w[15] (caricato temporaneamente)

    # ============================================================
    # MOLTIPLICAZIONI: Calcola tutti i 16 prodotti i[j] * w[j]
    # Utilizziamo registri temporanei diversi per ogni prodotto
    # per massimizzare il parallelismo ed evitare dipendenze
    # ============================================================

    # Prodotti 0-7: Utilizziamo ft0-ft7 come destinazione (sovrascriviamo i valori di i)
    fmul.s ft0, ft0, ft1        # ft0 = i[0] * w[0]
    fmul.s ft2, ft2, ft3        # ft2 = i[1] * w[1]
    fmul.s ft4, ft4, ft5        # ft4 = i[2] * w[2]
    fmul.s ft6, ft6, ft7        # ft6 = i[3] * w[3]
    fmul.s fs1, fs1, fs2        # fs1 = i[4] * w[4]
    fmul.s fs3, fs3, fs4        # fs3 = i[5] * w[5]
    fmul.s fs5, fs5, fs6        # fs5 = i[6] * w[6]
    fmul.s fs7, fs7, fs8        # fs7 = i[7] * w[7]

    # Prodotti 8-15: Utilizziamo fa0-fa7 e ft8-ft11 come destinazione

    # NOTA: fa1 contiene w[15], lo salviamo in fa0 prima di sovrascriverlo
    fmul.s fa0, fa0, fa1        # fa0 = i[8] * w[8] (usa fa1 che aveva w[8] dalla cache)

    # Ricarica w[8] per correzione (il valore era stato sovrascritto)
    flw fa1, 32(x6)             # fa1 = w[8] (ricarica)
    fmul.s fa0, fa0, fa1        # fa0 = i[8] * w[8]

    fmul.s fa2, fa2, fa3        # fa2 = i[9] * w[9]
    fmul.s fa4, fa4, fa5        # fa4 = i[10] * w[10]
    fmul.s fa6, fa6, fa7        # fa6 = i[11] * w[11]
    fmul.s ft8, ft8, ft9        # ft8 = i[12] * w[12]
    fmul.s ft10, ft10, ft11      # ft10 = i[13] * w[13]
    fmul.s fs9, fs9, fs10       # fs9 = i[14] * w[14]

    # Ora moltiplica i[15] * w[15] usando il valore caricato in fa1
    flw fa1, 60(x6)             # fa1 = w[15] (ricarica il valore corretto)
    fmul.s fs11, fs11, fa1      # fs11 = i[15] * w[15]

    # ============================================================
    # SOMMA AD ALBERO: Accumula tutti i 16 prodotti
    # Utilizziamo una strategia di somma ad albero bilanciato
    # per minimizzare le dipendenze e massimizzare il parallelismo
    # Struttura: 16 -> 8 -> 4 -> 2 -> 1
    # ============================================================

    # LIVELLO 1: Somma coppie di prodotti (16 -> 8 somme parziali)
    # Possiamo eseguire tutte le 8 somme in parallelo (no dipendenze)
    fadd.s ft0, ft0, ft2        # somma[0] = prodotto[0] + prodotto[1]
    fadd.s ft4, ft4, ft6        # somma[1] = prodotto[2] + prodotto[3]
    fadd.s fs1, fs1, fs3        # somma[2] = prodotto[4] + prodotto[5]
    fadd.s fs5, fs5, fs7        # somma[3] = prodotto[6] + prodotto[7]
    fadd.s fa0, fa0, fa2        # somma[4] = prodotto[8] + prodotto[9]
    fadd.s fa4, fa4, fa6        # somma[5] = prodotto[10] + prodotto[11]
    fadd.s ft8, ft8, ft10       # somma[6] = prodotto[12] + prodotto[13]
    fadd.s fs9, fs9, fs11       # somma[7] = prodotto[14] + prodotto[15]

    # LIVELLO 2: Somma coppie di somme (8 -> 4 somme parziali)
    # Possiamo eseguire tutte le 4 somme in parallelo
    fadd.s ft0, ft0, ft4        # somma[0] = somma[0] + somma[1]
    fadd.s fs1, fs1, fs5        # somma[1] = somma[2] + somma[3]
    fadd.s fa0, fa0, fa4        # somma[2] = somma[4] + somma[5]
    fadd.s ft8, ft8, fs9        # somma[3] = somma[6] + somma[7]

    # LIVELLO 3: Somma coppie di somme (4 -> 2 somme parziali)
    # Possiamo eseguire entrambe le somme in parallelo
    fadd.s ft0, ft0, fs1        # somma[0] = somma[0] + somma[1]
    fadd.s fa0, fa0, ft8        # somma[1] = somma[2] + somma[3]

    # LIVELLO 4: Somma finale (2 -> 1)
    fadd.s fs0, ft0, fa0        # fs0 = somma totale di tutti i 16 prodotti

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