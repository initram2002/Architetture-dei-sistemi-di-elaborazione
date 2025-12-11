;/**************************************************************************//**
; * @file     startup_LPC17xx.s
; * @brief    CMSIS Cortex-M3 Core Device Startup File for
; *           NXP LPC17xx Device Series
; * @version  V1.10
; * @date     06. April 2011
; *
; * @note
; * Copyright (C) 2009-2011 ARM Limited. All rights reserved.
; *
; * @par
; * ARM Limited (ARM) is supplying this software for use with Cortex-M
; * processor based microcontrollers.  This file can be freely distributed
; * within development tools that are supporting such ARM based processors.
; *
; * @par
; * THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
; * OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
; * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
; * ARM SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR
; * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
; *
; ******************************************************************************/

; *------- <<< Use Configuration Wizard in Context Menu >>> ------------------

; <h> Stack Configuration
;   <o> Stack Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Stack_Size      EQU     0x00000200

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp


; <h> Heap Configuration
;   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Heap_Size       EQU     0x00000200

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3	; 2*3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors

__Vectors       DCD     __initial_sp              ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
                DCD     NMI_Handler               ; NMI Handler
                DCD     HardFault_Handler         ; Hard Fault Handler
                DCD     MemManage_Handler         ; MPU Fault Handler
                DCD     BusFault_Handler          ; Bus Fault Handler
                DCD     UsageFault_Handler        ; Usage Fault Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     SVC_Handler               ; SVCall Handler
                DCD     DebugMon_Handler          ; Debug Monitor Handler
                DCD     0                         ; Reserved
                DCD     PendSV_Handler            ; PendSV Handler
                DCD     SysTick_Handler           ; SysTick Handler

                ; External Interrupts
                DCD     WDT_IRQHandler            ; 16: Watchdog Timer
                DCD     TIMER0_IRQHandler         ; 17: Timer0
                DCD     TIMER1_IRQHandler         ; 18: Timer1
                DCD     TIMER2_IRQHandler         ; 19: Timer2
                DCD     TIMER3_IRQHandler         ; 20: Timer3
                DCD     UART0_IRQHandler          ; 21: UART0
                DCD     UART1_IRQHandler          ; 22: UART1
                DCD     UART2_IRQHandler          ; 23: UART2
                DCD     UART3_IRQHandler          ; 24: UART3
                DCD     PWM1_IRQHandler           ; 25: PWM1
                DCD     I2C0_IRQHandler           ; 26: I2C0
                DCD     I2C1_IRQHandler           ; 27: I2C1
                DCD     I2C2_IRQHandler           ; 28: I2C2
                DCD     SPI_IRQHandler            ; 29: SPI
                DCD     SSP0_IRQHandler           ; 30: SSP0
                DCD     SSP1_IRQHandler           ; 31: SSP1
                DCD     PLL0_IRQHandler           ; 32: PLL0 Lock (Main PLL)
                DCD     RTC_IRQHandler            ; 33: Real Time Clock
                DCD     EINT0_IRQHandler          ; 34: External Interrupt 0
                DCD     EINT1_IRQHandler          ; 35: External Interrupt 1
                DCD     EINT2_IRQHandler          ; 36: External Interrupt 2
                DCD     EINT3_IRQHandler          ; 37: External Interrupt 3
                DCD     ADC_IRQHandler            ; 38: A/D Converter
                DCD     BOD_IRQHandler            ; 39: Brown-Out Detect
                DCD     USB_IRQHandler            ; 40: USB
                DCD     CAN_IRQHandler            ; 41: CAN
                DCD     DMA_IRQHandler            ; 42: General Purpose DMA
                DCD     I2S_IRQHandler            ; 43: I2S
                DCD     ENET_IRQHandler           ; 44: Ethernet
                DCD     RIT_IRQHandler            ; 45: Repetitive Interrupt Timer
                DCD     MCPWM_IRQHandler          ; 46: Motor Control PWM
                DCD     QEI_IRQHandler            ; 47: Quadrature Encoder Interface
                DCD     PLL1_IRQHandler           ; 48: PLL1 Lock (USB PLL)
                DCD     USBActivity_IRQHandler    ; 49: USB Activity interrupt to wakeup
                DCD     CANActivity_IRQHandler    ; 50: CAN Activity interrupt to wakeup


                IF      :LNOT::DEF:NO_CRP
                AREA    |.ARM.__at_0x02FC|, CODE, READONLY
CRP_Key         DCD     0xFFFFFFFF
                ENDIF


var				RN 		2

                AREA    |.text|, CODE, READONLY
;===========================================================
; Reset Handler - Exercise 1 (Magic the Gathering)
;===========================================================

Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]                                            
                
;----------------------------------------------------------
; Design registri
; R0 = &Cards
; R1 = &PurchasePrice
; R2 = &CurrentPrice
; (R3 usato come registro temporaneo)
;
; R4 = i			; indice delle carte [0, ..., NumCards - 1]
; R5 = NumCards		; numero di carte (#Cards)
; R6 = offset/puntatore temporaneo
; R7 = cardID corrente
; R8 = purchase price della carta corrente
; R9 = current price della carta corrente
;
; R10 = somma dei (current - purchase) per carte con guadagno
; R11 = numero di carte con current price > purchase
; R12 = indice interno per la scansione delle tabelle (j)
;----------------------------------------------------------

; Base address delle tabelle
				LDR		R0, =Cards					; &Cards
				LDR		R1, =PurchasePrice			; &PurchasePrice
				LDR		R2, =CurrentPrice			; &CurrentPrice
				; LDR	R3, =Condition				; non usato in questa fase
				
; Carica #Cards (byte) in R5
				LDR		R6, =NumCards
				LDRB	R5, [R6]					; R5 = numero di carte
				
; Inizializza contatori/accumulatori
				MOV		R4, #0						; i = 0
				MOV		R10, #0						; somma guadagni
				MOV		R11, #0						; conteggio carte in guadagno
				
;----------------------------------------------------------
; Loop principale sulle carte
;----------------------------------------------------------
main_loop
				CMP		R4, R5						; i >= NumCards ?
				BGE		done						; sì -> fine
				
; R7 = Cards[i]
				MOV		R6, R4
				LSL		R6, R6, #2					; offset i * 4 (word)
				LDR		R7, [R0, R6]				; cardID corrente
				
;==========================================================
; 1) Cerca il purchase price della carta in PurchasePrice
;	(tabella di coppie (ID, prezzo) -> 8 byte per entry)
;==========================================================
				MOV		R8, #0						; default se non trovata
				MOV		R12, #0						; j = 0
				
find_purchase
				CMP		R12, R5						; j >= NumCards ?
				BGE		purchase_done				; sì -> esci (R8 resta com'è)
				
				MOV 	R6, R12
				LSL		R6, R6, #3					; offset = j * 8
				ADD		R6, R1, R6					; R6 = &PurchasePrice[j * 2]
				
				LDR		R3, [R6]					; ID_j
				CMP		R3, R7						; ID_j == cardID ?
				BNE		next_purchase
				
				LDR		R8, [R6, #4]				; purchase price trovato
				B 		purchase_done
				
next_purchase
				ADD		R12, R12, #1				; j++
				B		find_purchase
				
purchase_done
; ora R8 contiene il prezzo d'acquisto (0 se non trovato)

;==========================================================
; 2) Cerca il current price della carta in CurrentPrice
;==========================================================
				MOV		R9, #0						; default se non trovata
				MOV 	R12, #0						; j = 0
				
find_current
				CMP		R12, R5						; j >= NumCards ?
				BGE		current_done				; sì -> esci (R9 resta com'è)
				
				MOV 	R6, R12
				LSL		R6, R6, #3					; offset = j * 8
				ADD		R6, R2, R6					; R6 = &CurrentPrice[j * 2]
				
				LDR		R3, [R6]					; ID_j
				CMP		R3, R7						; ID_j == cardID ?
				BNE		next_current
				
				LDR		R9, [R6, #4]				; current price trovato
				B		current_done
				
next_current
				ADD		R12, R12, #1				; j++
				B		find_current
				
current_done
; ora R8 = purchase, R9 = current per la carta corrente
; (oppure 0 se non trovati)

;==========================================================
; 3) Se current > purchase:
; 		- incrementa R11 (conteggio)
;		- somma (current - purchase) in R10
;==========================================================
				CMP		R9, R8
				BLE		no_gain						; se current <= purchase -> niente
				
				SUB		R6, R9, R8					; R6 = current - purchase
				ADD		R10, R10, R6				; accumula nella somma
				ADD		R11, R11, #1				; una carta in guadagno
				
no_gain
; prossima carta (i++)
				ADD		R4, R4, #1	
				B		main_loop
				
;==========================================================
; Fine: risultati in R10 (somma) e R11 (conteggio)
;==========================================================
done				
				LDR     R0, =stop
								
stop            BX      R0

				LTORG		; il literal pool viene emesso qui

                ENDP


; Dummy Exception Handlers (infinite loops which can be modified)

NMI_Handler     PROC
                EXPORT  NMI_Handler               [WEAK]

                B       .
				
                ENDP
HardFault_Handler\
                PROC
                EXPORT  HardFault_Handler         [WEAK]
                ; your code
				orr r0,r0,#1
				mov r1, r2
				BX	r0
                ENDP
MemManage_Handler\
                PROC
                EXPORT  MemManage_Handler         [WEAK]
                B       .
                ENDP
BusFault_Handler\
                PROC
                EXPORT  BusFault_Handler          [WEAK]
                B       .
                ENDP
UsageFault_Handler\
                PROC
                EXPORT  UsageFault_Handler        [WEAK]
                B       .
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler               [WEAK]
                B       .
                ENDP
DebugMon_Handler\
                PROC
                EXPORT  DebugMon_Handler          [WEAK]
                B       .
                ENDP
PendSV_Handler  PROC
                EXPORT  PendSV_Handler            [WEAK]
                B       .
                ENDP
SysTick_Handler PROC
                EXPORT  SysTick_Handler           [WEAK]
                B       .
                ENDP

Default_Handler PROC

                EXPORT  WDT_IRQHandler            [WEAK]
                EXPORT  TIMER0_IRQHandler         [WEAK]
                EXPORT  TIMER1_IRQHandler         [WEAK]
                EXPORT  TIMER2_IRQHandler         [WEAK]
                EXPORT  TIMER3_IRQHandler         [WEAK]
                EXPORT  UART0_IRQHandler          [WEAK]
                EXPORT  UART1_IRQHandler          [WEAK]
                EXPORT  UART2_IRQHandler          [WEAK]
                EXPORT  UART3_IRQHandler          [WEAK]
                EXPORT  PWM1_IRQHandler           [WEAK]
                EXPORT  I2C0_IRQHandler           [WEAK]
                EXPORT  I2C1_IRQHandler           [WEAK]
                EXPORT  I2C2_IRQHandler           [WEAK]
                EXPORT  SPI_IRQHandler            [WEAK]
                EXPORT  SSP0_IRQHandler           [WEAK]
                EXPORT  SSP1_IRQHandler           [WEAK]
                EXPORT  PLL0_IRQHandler           [WEAK]
                EXPORT  RTC_IRQHandler            [WEAK]
                EXPORT  EINT0_IRQHandler          [WEAK]
                EXPORT  EINT1_IRQHandler          [WEAK]
                EXPORT  EINT2_IRQHandler          [WEAK]
                EXPORT  EINT3_IRQHandler          [WEAK]
                EXPORT  ADC_IRQHandler            [WEAK]
                EXPORT  BOD_IRQHandler            [WEAK]
                EXPORT  USB_IRQHandler            [WEAK]
                EXPORT  CAN_IRQHandler            [WEAK]
                EXPORT  DMA_IRQHandler            [WEAK]
                EXPORT  I2S_IRQHandler            [WEAK]
                EXPORT  ENET_IRQHandler           [WEAK]
                EXPORT  RIT_IRQHandler            [WEAK]
                EXPORT  MCPWM_IRQHandler          [WEAK]
                EXPORT  QEI_IRQHandler            [WEAK]
                EXPORT  PLL1_IRQHandler           [WEAK]
                EXPORT  USBActivity_IRQHandler    [WEAK]
                EXPORT  CANActivity_IRQHandler    [WEAK]

WDT_IRQHandler
TIMER0_IRQHandler
TIMER1_IRQHandler
TIMER2_IRQHandler
TIMER3_IRQHandler
UART0_IRQHandler
UART1_IRQHandler
UART2_IRQHandler
UART3_IRQHandler
PWM1_IRQHandler
I2C0_IRQHandler
I2C1_IRQHandler
I2C2_IRQHandler
SPI_IRQHandler
SSP0_IRQHandler
SSP1_IRQHandler
PLL0_IRQHandler
RTC_IRQHandler
EINT0_IRQHandler
EINT1_IRQHandler
EINT2_IRQHandler
EINT3_IRQHandler
ADC_IRQHandler
BOD_IRQHandler
USB_IRQHandler
CAN_IRQHandler
DMA_IRQHandler
I2S_IRQHandler
ENET_IRQHandler
RIT_IRQHandler
MCPWM_IRQHandler
QEI_IRQHandler
PLL1_IRQHandler
USBActivity_IRQHandler
CANActivity_IRQHandler

                B       .

                ENDP
					
;===========================================================
; Constant data section
; - in CODE section
; - 2-byte alignment
; - 4096 zero bytes as boundary before and after
;===========================================================

				ALIGN	2				; allineamento a multiplo di 2 byte
					
ConstLowBound	SPACE	4096			; 4KB di zeri prima delle tabelle
	
				EXPORT 	Cards
				EXPORT 	Condition
				EXPORT	PurchasePrice
				EXPORT 	CurrentPrice
				EXPORT 	NumCards
				EXPORT 	ConstLowBound
				EXPORT 	ConstHighBound
	
; Cards: solo gli ID delle carte (7 carte)	
Cards			DCD		0x134, 3, 275, 0x2B9, 0xDC, 151, 2087
	
; Condition: coppie (ID, condition)
; 0 = POOR, 1 = GOOD, 2 = MINT
Condition		DCD		2087, 2, 275, 0x0, 308, 0x1, 0xDC, 2, 151, 2, 0x3, 0, 697, 2
	
; Purchase price: coppie (ID, prezzo d'acquisto)
PurchasePrice	DCD		0x3, 2000, 0x113, 2, 151, 9, 0x134, 45, 2087, 17, 220, 5, 697, 350

; Current price: coppie (ID, prezzo corrente)
CurrentPrice	DCD		0xDC, 3, 151, 16, 3, 3300, 697, 420, 308, 63, 275, 1, 0x827, 3

; #Cards: numero di carte nella collezione
NumCards		DCB		7

ConstHighBound	SPACE 4096				; 4KB di zeri dopo le tabelle

; User Initial Stack & Heap

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit                

                END
