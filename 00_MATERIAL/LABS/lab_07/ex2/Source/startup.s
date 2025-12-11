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
					
				AREA	MYDATA, DATA, READWRITE
POOR			SPACE 	7 * 4					; al massimo 7 ID (7 carte) -> 28 byte
GOOD			SPACE	7 * 4
MINT 			SPACE 	7 * 4

var				RN 		2

                AREA    |.text|, CODE, READONLY
; Reset Handler

Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]                                            
                
			    ; -------------------------------------------------
				; FASE 1: costruzione vettori POOR/GOOD/MINT
				; -------------------------------------------------
				
				LDR		R2, =Condition			; R2 = ptr corrente Condition
				LDR		R0, =NumCards
				LDRB	R1, [R0]				; R1 = N (#Cards)
				
				LDR		R4, =POOR				; base vettori
				LDR		R5, =GOOD
				LDR		R6, =MINT
				
				MOVS	R7, #0					; poorCount
				MOVS	R8, #0					; goodCount
				MOVS	R9, #0					; mintCount
			
ClassLoop
				CMP		R1, #0
				BEQ		ClassDone
				
				LDR		R3, [R2]				; R3 = ID
				LDR		R0, [R2, #4]			; R0 = cond
				ADD		R2, R2, #8				; entry successiva
				SUBS	R1, R1, #1
				
				CMP		R0, #0
				BEQ		ClassPoor
				CMP		R0, #1
				BEQ		ClassGood
				; altrimenti cond = 2 (MINT)
	
ClassMint		
				MOV		R10, R9
				LSL		R10, R10, #2
				ADD		R10, R6, R10
				STR		R3, [R10]				; scrivi ID in MINT[mintCount]
				ADDS	R9, R9, #1
				B 		ClassLoop
				
ClassPoor
				MOV		R10, R7
				LSL		R10, R10, #2
				ADD		R10, R4, R10
				STR		R3, [R10]				; scrivi ID in POOR[poorCount]
				ADDS	R7, R7, #1
				B		ClassLoop
				
ClassGood
				MOV 	R10, R8
				LSL		R10, R10, #2
				ADD		R10, R5, R10
				STR		R3, [R10]				; scrivi ID in GOOD[goodCount]
				ADDS	R8, R8, #1
				B		ClassLoop
				
ClassDone
				
                ; -------------------------------------------------
				; FASE 2: ordinamento per differenza di prezzo
                ; -------------------------------------------------
				
				; ordina vettore POOR
				MOV		R0, R4					; base POOR
				MOV		R1, R7					; len = poorCount
				BL		SortVector
				
				; ordina vettore GOOD
				MOV		R0, R5
				MOV		R1, R8
				BL		SortVector
				
				; ordina vettore MINT
				MOV		R0, R6
				MOV		R1, R9
				BL		SortVector
				
                ; -------------------------------------------------
				; FASE 3: carta con perdita massima
				;			loss = purchasePrice - currentPrice
				; -------------------------------------------------

				LDR		R2, =PurchasePrice		; iteriamo PurchasePrice
				LDR		R0, =NumCards
				LDRB	R1, [R0]				; R1 = N
				
				MOVS	R10, #0					; maxLoss finora
				MOVS	R11, #0					; bestID
				MOVS	R12, #0					; bestCond
				
LossLoop
				CMP		R1, #0
				BEQ		AllDone
				
				LDR		R0, [R2]				; R0 = ID
				ADD		R2, R2, #8
				SUBS	R1, R1, #1
				
				; diff = current - purchase
				MOV		R3, R0					; salva ID corrente in R14
				BL		GetDiff					; R0 = diff
				
				CMP		R0, #0
				BGE		NoLoss					; diff >= 0 => nessuna perdita
				
				; loss = -diff = purchase - current
				RSBS	R0, R0, #0				; R0 = loss (positivo)
				
				CMP		R0, R10
				BLS		NoLoss					; loss <= maxLoss -> ignora
				
				; nuovo massimo
				MOV		R10, R0					; aggiornato maxLoss
				MOV		R11, R3					; bestID = ID corrente
				
				; bestCond = cond(ID)
				MOV		R0, R3
				BL		GetCondition			; R0 = cond
				MOV		R12, R0
				
NoLoss
				B 		LossLoop
				
AllDone
				; A questo punto:
				; R11 = ID della carta con perdita massima
				; R12 = condizione corrispondente (0/1/2)
								
				LDR     R0, =stop
				
stop            BX      R0
				
                ENDP
					
;-----------------------------------------------------------------
; R0 = Card ID
; R0 (ritorno) = currentPrice - purchasePrice (può essere negativo)
; Usa: tabelle PurchasePrice, CurrentPrice, NumCards
;-----------------------------------------------------------------
GetDiff			PROC
				PUSH	{R1-R7, LR}
				
				; carica #Cards
				LDR		R1, =NumCards
				LDRB	R1, [R1]				; R1 = N
				
				
                ; ---------- cerca purchase price ----------
				LDR		R2, =PurchasePrice		; base Purchase
				MOVS	R3, #0					; i = 0
				
GD_findP_loop
				CMP		R3, R1
				BCS		GD_findP_done			; safety
				
				ADD		R4, R2, R3, LSL #3		; &entry[i] (8 byte per entry)
				LDR		R5, [R4]				; id_i
				LDR		R6, [R4, #4]			; purchase_i
				CMP		R5, R0
				BEQ		GD_foundP
				ADDS	R3, R3, #1
				B		GD_findP_loop
				
GD_foundP		
				MOV		R7, R6					; purchase -> R7
				
GD_findP_done

				; ---------- cerca current price ----------
				LDR		R2, =CurrentPrice
				MOVS	R3, #0					; i = 0
				
GD_findC_loop
				CMP		R3, R1
				BCS		GD_findC_done			; safety
				
				ADD		R4, R2, R3, LSL #3
				LDR 	R5, [R4]				; id_i
				LDR		R6, [R4, #4]			; current_i
				CMP		R5, R0
				BEQ		GD_foundC
				ADDS	R3, R3, #1
				B		GD_findC_loop
				
GD_foundC
				MOV		R1, R6					; current -> R1
				
GD_findC_done
				; diff = current - purchase
				SUB		R0, R1, R7
				
				POP		{R1-R7, PC}
				ENDP
					
;-----------------------------------------------------------------
; R0 = Card ID
; R0 (ritorno) = condition (0 = POOR, 1 = GOOD, 2 = MINT)
;-----------------------------------------------------------------
GetCondition	PROC
				PUSH	{R1-R4, LR}
				
				LDR		R1, =NumCards
				LDRB	R1, [R1]				; R1 = N
				LDR		R2, =Condition			; base Condition
				MOVS	R3, #0					; i = 0
				
GC_loop			
				CMP		R3, R1
				BCS		GC_notFound				; safety, default 0
				
				ADD		R4, R2, R3, LSL #3		; &entry[i]
				LDR		R1, [R4]				; id_i
				LDR		R4, [R4, #4]			; cond_i
				CMP		R1, R0
				BEQ		GC_found
				ADDS	R3, R3, #1
				B		GC_loop
				
GC_found
				MOV		R0, R4					; cond -> R0
				POP		{R1-R4, PC}
			
GC_notFound
				MOVS 	R0, #0
				POP		{R1-R4, PC}
				ENDP
					
;-----------------------------------------------------------------
; R0 = base address del vettore (POOR/GOOD/MINT)
; R1 = length (numero di elementi effettivi)
; Ordina in-place per differenza crescente (current - purchase)
;-----------------------------------------------------------------
SortVector		PROC
				PUSH	{R2-R7, LR}
				
				CMP 	R1, #1
				BLE		SV_return				; 0 o 1 elemento: già ordinato
				
				MOV		R2, R0					; R2 = base del vettore
				SUBS	R1, R1, #1				; outer loop: n - 1 ripetizioni
				
SV_outer
				MOVS	R2, #0					; j = 0
				MOV		R4, R1					; limite corrente (n - 1 - u)
				
SV_inner		
				CMP		R3, R4
				BCS		SV_inner_done
				
				; calcola indirizzo elemento j
				MOV		R4, R3
				LSL		R5, R5, #2				; offset = j * 4
				ADD		R5, R2, R5				; R5 = &v[j]
				
				LDR		R6, [R5]				; id_j
				LDR		R7, [R5, #4]			; id_{j + 1}
				
				; diff_j
				MOV		R0, R6
				BL		GetDiff
				MOV		R12, R0					; diff_j in R12
				
				; diff_{j + 1}
				MOV		R0, R7
				BL		GetDiff					; diff_{j + 1} in R0
				
				; se diff_j > diff{j + 1} -> swap
				CMP		R12, R0
				BLE		SV_no_swap
				
				STR		R7, [R5]
				STR		R6, [R5, #4]
				
SV_no_swap
				ADDS	R3, R3, #1
				B		SV_inner
				
SV_inner_done
				SUBS 	R1, R1, #1
				BNE		SV_outer
				
SV_return		
				POP		{R2-R7, PC}
				ENDP
					
				LTORG
				
				ALIGN 	2						; allineamento a 2 byte
ConstBefore		SPACE 	4096					; 4 KB di zeri prima dei dati
	
Cards			DCD		0x134, 3, 275, 0x2B9, 0xDC, 151, 2087
	
Condition		DCD		2087, 2, 275, 0x0, 308, 0x1, 0xDC, 2, 151, 2, 0x3, 0, 697, 2
	
PurchasePrice	DCD		0x3, 2000, 0x113, 2, 151, 9, 0x134, 45, 2087, 17, 220, 5, 697, 350
	
CurrentPrice	DCD		0xDC, 3, 151, 16, 3, 3300, 697, 420, 308, 63, 275, 1, 0x827, 3
	
NumCards		DCB		7						; #Cards
		
				ALIGN	2
ConstAfter		SPACE	4096					; 4 KB di zeri dopo i dati

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


                ALIGN


; User Initial Stack & Heap

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit                

                END
