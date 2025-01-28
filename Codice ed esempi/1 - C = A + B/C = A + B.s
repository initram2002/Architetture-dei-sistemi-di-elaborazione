	.data
Val_A:  .word 10
Val_B:  .word 20
Val_C:  .word 0

	.text 
Main:
	ld      R1, Val_A(R0)
	ld      R2, Val_B(R0)
	dadd    R3, R2, R1
	sd      R3, Val_C(R0)