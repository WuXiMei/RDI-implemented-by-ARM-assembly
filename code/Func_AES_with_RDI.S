//
// Implementation of AES with random delays.
// Note that the key expansion is seperated and implemented in another file
// Random delays generation methods are:
// - no delays (ND)
// - plain uniform delays (PU)
// - Benoit-Tunstall table method (BT)
// - floating mean (FM)
// - improved floating mean (IFM)
//
// Started 2022-12-6 by yangx, Zhejiang University
	
.section .data
.section .text
.syntax unified
.thumb
.global AES_with_randomDelays
		
	// define the method of random delays
	// you should fix here if you wa na specify a method
	// ND  - remove all codes embedded in MACRO
	// PU  - remove codes of FlipRandomDelays and change the suffix to pu
	// BT  - remove codes of InitRandomDelays & FlipRandomDelays and change the suffix to bt
	// FM  - change the suffix to fm
	// IFM - change the suffix to ifm
	.macro RandomDelay
	BL randomdelay_ifm // pu bt fm ifm
	.endm
	
	.macro InitRandomDelays
	BL init_ifm // pu fm ifm
	.endm
	
	.macro FlipRandomDelay
	BL flip_ifm // fm ifm
	.endm
	
	/******************************************/
	// the AES body
AES_with_randomDelays:
	
	PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
	
	// r0 stores the address of random pool
	LDR R12, =randompool
	
	InitRandomDelays
	
	LDR R0, =dummypt
	LDR R1, =dummykey
	BL encryptround // dummy round
	BL encryptround // dummy round
	BL encryptround // dummy round
	
	LDR R0, =plaintext
	LDR R1, =keys
	BL encryptround
	ADD R1, #16 // the next round key
	//BL encryptround
	BL lastencryptround
	//ADD R1, #16 // the next round key
	//BL encryptround
	//ADD R1, #16 // the next round key
	//BL encryptround
	//ADD R1, #16 // the next round key
	//BL encryptround
	
	//FlipRandomDelay
	
	//ADD R1, #16 // the next round key
	//BL encryptround
	//ADD R1, #16 // the next round key
	//BL encryptround
	//ADD R1, #16 // the next round key
	//BL encryptround
	//ADD R1, #16 // the next round key
	//BL encryptround
	//ADD R1, #16 // the next round key
	//BL lastencryptround
	
	//LDR R0, =dummypt
	//LDR R1, =dummykey
	//BL encryptround // dummy round
	//BL encryptround // dummy round
	//BL encryptround // dummy round
	
	//NOP
	POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
	BX LR
	
	//LTORG
	
//DATA1 SPACE 4096
	
	//ENDFUNC

/* *************************************************************************** */
//
// ENCRYPTROUND
//
// 1 round only, with random delays incorporated; 128 bit plaintext block
// Parameters: r0 stores the address of state
//             r1 stores the address od key
// Output: r0 stores the address of state result
encryptround:
	
	PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,LR}
	
	RandomDelay
	
	// AddRoundKey
	LDR R2, [R0]
	LDR R3, [R1]
	EOR R4, R2, R3
	LDR R2, [R0, #4]
	LDR R3, [R1, #4]
	EOR R5, R2, R3
	LDR R2, [R0, #8]
	LDR R3, [R1, #8]
	EOR R6, R2, R3
	LDR R2, [R0, #12]
	LDR R3, [R1, #12]
	EOR R7, R2, R3
	
	RandomDelay
	
	// Sbox + ShiftRows
	LDR R2, =tab_sbox
	// row 1
	MOV R8, #0xFF
	AND R3, R4, R8
	LDRB R3, [R2, R3]
	STRB R3, [R0]
	AND R3, R5, R8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #4]
	AND R3, R6, R8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #8]
	AND R3, R7, R8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #12]
	
	RandomDelay
	
	// row 2
	AND R3, R8, R4, LSR #8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #13]
	AND R3, R8, R5, LSR #8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #1]
	AND R3, R8, R6, LSR #8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #5]
	AND R3, R8, R7, LSR #8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #9]
	
	RandomDelay
	
	// row 3
	AND R3, R8, R4, LSR #16
	LDRB R3, [R2, R3]
	STRB R3, [R0, #10]
	AND R3, R8, R5, LSR #16
	LDRB R3, [R2, R3]
	STRB R3, [R0, #14]
	AND R3, R8, R6, LSR #16
	LDRB R3, [R2, R3]
	STRB R3, [R0, #2]
	AND R3, R8, R7, LSR #16
	LDRB R3, [R2, R3]
	STRB R3, [R0, #6]
	
	RandomDelay
	
	// row 4
	AND R3, R8, R4, LSR #24
	LDRB R3, [R2, R3]
	STRB R3, [R0, #7]
	AND R3, R8, R5, LSR #24
	LDRB R3, [R2, R3]
	STRB R3, [R0, #11]
	AND R3, R8, R6, LSR #24
	LDRB R3, [R2, R3]
	STRB R3, [R0, #15]
	AND R3, R8, R7, LSR #24
	LDRB R3, [R2, R3]
	STRB R3, [R0, #3]
	
	RandomDelay
	
	// MixColumn
	LDR R9, =tab2
	LDR R10, =tab3
	// column 1 
	LDR R1, [R0]
	AND R2, R8, R1
	AND R3, R8, R1, LSR #8
	EOR R6, R2, R3
	LDRB R11, [R10, R2]
	EOR R7, R11, R3
	LDRB R11, [R9, R3]
	EOR R5, R2, R11
	LDRB R2, [R9, R2]
	LDRB R3, [R10, R3]
	EOR R4, R2, R3
	AND R2, R8, R1, LSR #16
	EOR R4, R2
	EOR R7, R2
	LDRB R3, [R10, R2]
	EOR R5, R3
	LDRB R2, [R9, R2]
	EOR R6, R2
	AND R2, R8, R1, LSR #24
	EOR R4, R2
	EOR R5, R2
	LDRB R3, [R10, R2]
	EOR R6, R3
	LDRB R2, [R9, R2]
	EOR R7, R2
	STRB R4, [R0]
	STRB R5, [R0, #1]
	STRB R6, [R0, #2]
	STRB R7, [R0, #3]
	
	RandomDelay
	
	// column 2 
	LDR R1, [R0, #4]
	AND R2, R8, R1
	AND R3, R8, R1, LSR #8
	EOR R6, R2, R3
	LDRB R11, [R10, R2]
	EOR R7, R11, R3
	LDRB R11, [R9, R3]
	EOR R5, R2, R11
	LDRB R2, [R9, R2]
	LDRB R3, [R10, R3]
	EOR R4, R2, R3
	AND R2, R8, R1, LSR #16
	EOR R4, R2
	EOR R7, R2
	LDRB R3, [R10, R2]
	EOR R5, R3
	LDRB R2, [R9, R2]
	EOR R6, R2
	AND R2, R8, R1, LSR #24
	EOR R4, R2
	EOR R5, R2
	LDRB R3, [R10, R2]
	EOR R6, R3
	LDRB R2, [R9, R2]
	EOR R7, R2
	STRB R4, [R0, #4]
	STRB R5, [R0, #5]
	STRB R6, [R0, #6]
	STRB R7, [R0, #7]
	
	RandomDelay
	
	// column 3 
	LDR R1, [R0, #8]
	AND R2, R8, R1
	AND R3, R8, R1, LSR #8
	EOR R6, R2, R3
	LDRB R11, [R10, R2]
	EOR R7, R11, R3
	LDRB R11, [R9, R3]
	EOR R5, R2, R11
	LDRB R2, [R9, R2]
	LDRB R3, [R10, R3]
	EOR R4, R2, R3
	AND R2, R8, R1, LSR #16
	EOR R4, R2
	EOR R7, R2
	LDRB R3, [R10, R2]
	EOR R5, R3
	LDRB R2, [R9, R2]
	EOR R6, R2
	AND R2, R8, R1, LSR #24
	EOR R4, R2
	EOR R5, R2
	LDRB R3, [R10, R2]
	EOR R6, R3
	LDRB R2, [R9, R2]
	EOR R7, R2
	STRB R4, [R0, #8]
	STRB R5, [R0, #9]
	STRB R6, [R0, #10]
	STRB R7, [R0, #11]
	
	RandomDelay
	
	// column 4 
	LDR R1, [R0, #12]
	AND R2, R8, R1
	AND R3, R8, R1, LSR #8
	EOR R6, R2, R3
	LDRB R11, [R10, R2]
	EOR R7, R11, R3
	LDRB R11, [R9, R3]
	EOR R5, R2, R11
	LDRB R2, [R9, R2]
	LDRB R3, [R10, R3]
	EOR R4, R2, R3
	AND R2, R8, R1, LSR #16
	EOR R4, R2
	EOR R7, R2
	LDRB R3, [R10, R2]
	EOR R5, R3
	LDRB R2, [R9, R2]
	EOR R6, R2
	AND R2, R8, R1, LSR #24
	EOR R4, R2
	EOR R5, R2
	LDRB R3, [R10, R2]
	EOR R6, R3
	LDRB R2, [R9, R2]
	EOR R7, R2
	STRB R4, [R0, #12]
	STRB R5, [R0, #13]
	STRB R6, [R0, #14]
	STRB R7, [R0, #15]
	
	RandomDelay
/*
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	*/
	POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,LR}
	BX LR
	
	//LTORG
	
//DATA2 SPACE 4096
	
	//ENDFUNC
	
	
// ***************************************************************************
//
// LASTENCRYPTROUND
//
// the last AES round with random delays incorporated; 128 bit plaintext block
// Parameters: r0 stores the address of state
//             r1 stores the address od key
// Output: r8 stores the address of state result
lastencryptround:
	
	PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,LR}
	
	RandomDelay
	
	// AddRoundKey
	LDR R2, [R0]
	LDR R3, [R1]
	EOR R4, R2, R3
	LDR R2, [R0, #4]
	LDR R3, [R1, #4]
	EOR R5, R2, R3
	LDR R2, [R0, #8]
	LDR R3, [R1, #8]
	EOR R6, R2, R3
	LDR R2, [R0, #12]
	LDR R3, [R1, #12]
	EOR R7, R2, R3
	
	RandomDelay
	
	// Sbox + ShiftRows
	LDR R2, =tab_sbox
	// row 1
	MOV R8, #0xFF
	AND R3, R4, R8
	LDRB R3, [R2, R3]
	STRB R3, [R0]
	AND R3, R5, R8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #4]
	AND R3, R6, R8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #8]
	AND R3, R7, R8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #12]
	
	RandomDelay
	
	// row 2
	AND R3, R8, R4, LSR #8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #13]
	AND R3, R8, R5, LSR #8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #1]
	AND R3, R8, R6, LSR #8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #5]
	AND R3, R8, R7, LSR #8
	LDRB R3, [R2, R3]
	STRB R3, [R0, #9]
	
	RandomDelay
	
	// row 3
	AND R3, R8, R4, LSR #16
	LDRB R3, [R2, R3]
	STRB R3, [R0, #10]
	AND R3, R8, R5, LSR #16
	LDRB R3, [R2, R3]
	STRB R3, [R0, #14]
	AND R3, R8, R6, LSR #16
	LDRB R3, [R2, R3]
	STRB R3, [R0, #2]
	AND R3, R8, R7, LSR #16
	LDRB R3, [R2, R3]
	STRB R3, [R0, #6]
	
	RandomDelay
	
	// row 4
	AND R3, R8, R4, LSR #24
	LDRB R3, [R2, R3]
	STRB R3, [R0, #7]
	AND R3, R8, R5, LSR #24
	LDRB R3, [R2, R3]
	STRB R3, [R0, #11]
	AND R3, R8, R6, LSR #24
	LDRB R3, [R2, R3]
	STRB R3, [R0, #15]
	AND R3, R8, R7, LSR #24
	LDRB R3, [R2, R3]
	STRB R3, [R0, #3]
	
	RandomDelay
	
	// AddRoundKey
	ADD R1, #16 // fix the key address
	LDR R2, [R0]
	LDR R3, [R1]
	EOR R4, R2, R3
	LDR R2, [R0, #4]
	LDR R3, [R1, #4]
	EOR R5, R2, R3
	LDR R2, [R0, #8]
	LDR R3, [R1, #8]
	EOR R6, R2, R3
	LDR R2, [R0, #12]
	LDR R3, [R1, #12]
	EOR R7, R2, R3
	
	// store the ciphertext
	LDR R8, =ct
	STR R4, [R8]
	STR R5, [R8, #4]
	STR R6, [R8, #8]
	STR R7, [R8, #12]
	
	RandomDelay
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	NOP
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP 
	NOP
	
	POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,LR}
	BX LR
	
	//ENDFUNC
	
/* *************************************************************************** */
// *** Plain uniform delays
/* *************************************************************************** */
// 
// RANDOMDELAY_PU
// This routine produces delay by dummy cycling for a random number of rounds
//  The method is plain uniform.
//
// Parameters:
//     MASK should contain the mask for truncating the delay (i.e. parameter b)
// R0 -- RND
// R1 -- MASK
// R12 -- X
randomdelay_pu:
	PUSH {R0,R1,LR}
	
	LDR R1, =mask
	LDRB R1, [R1]
	
	LDRB R0, [R12]
	ADD R12, #1
	AND R0, R1
	CMP R0, #0
	IT EQ
	BEQ zero_pu
	NOP
	NOP
dummyloop_pu:
	SUB R0, #1
	CMP R0, #0
	IT NE
	BNE dummyloop_pu
zero_pu:
	POP {R0,R1,LR}
	BX LR
	
	//ENDFUNC
	
	
/* *************************************************************************** */
// 
// INIT_PU
// This routine initializes the stuff required for the floating mean method
//
// Parameters:
//     X is the exlusive pointer-counter for this routine
// Touched registers:
//     R1 -- MASK
init_pu:
	PUSH {R0,R1,LR}
	
	LDR R1, =mask
	MOV R0, #0x0F
	STRB R0, [R1]
	POP {R0,R1,LR}
	BX LR
	
	//ENDFUNC


/* *************************************************************************** */
// *** Floating mean
/* *************************************************************************** */
// 
// RANDOMDELAY_FM
// This routine produces delay by dummy cycling for a random number of rounds
//  The method is 'Floating mean'
//
// Parameters:
//     MASK should contain the mask for truncating the delay (i.e. parameter b)
// Touched registers:
//     R2 -- MEAN
// 	R0 -- RND
// 	R1 -- MASK
// 	R12 -- X
randomdelay_fm:
	PUSH {R0,R1,R2,LR}
	
	LDR R1, =mask
	LDRB R1, [R1]
	LDR R2, =mean
	LDRB R2, [R2]
	
	LDRB R0, [R12]
	ADD R12, #1
	AND R0, R1
	ADD R0, R2
	CMP R0, #0
	IT EQ
	BEQ zero_fm
	NOP
	NOP
dummyloop_fm:
	SUB R0, #1
	CMP R0, #0
	IT NE
	BNE dummyloop_fm
zero_fm:
	POP {R0,R1,R2,LR}
	BX LR
	
	//ENDFUNC
	
	
/* *************************************************************************** */
//
// INIT_FM
// This routine initializes the stuff required for the floating mean method
//
// Parameters:
//     X is the exlusive pointer-counter for this routine
// Touched registers:
//     R2 -- MEAN
// 	R0 -- RND
// 	R1 -- MASK
// 	R12 -- X
init_fm:
	PUSH {R0,R1,R2,LR}
	
	LDR R1, =mask
	LDR R2, =mean
	LDRB R0, [R12]
	ADD R12, #1
	AND R0, R0, #0x0F
	STRB R0, [R2]
	MOV R0, #0x0F
	STRB R0, [R1]
	POP {R0,R1,R2,LR}
	BX LR
	
	//ENDFUNC
	

/* *************************************************************************** */
// 
// FLIP_FM
// 'Flips' the floating mean. To be called in the middle of the execution
//     R7 -- COUNTER
//     R8 -- MEAN
flip_fm:
	PUSH {R0,R1,R2,LR}
	
	LDR R2, =mean
	LDRB R0, [R2]
	MOV R1, #0x0F
	SUB R1, R0
	STRB R1, [R2]
	POP {R0,R1,R2,LR}
	BX LR
	
	//ENDFUNC
	

/* *************************************************************************** */
// *** Improved floating mean
/* *************************************************************************** */
//
// RANDOMDELAY_IFM
// This routine produces delay by dummy cycling for a random number of rounds
//  The method is 'Improved floating mean'
//
// Parameters:
//     MASK should contain the mask for truncating the delay (i.e. parameter b)
// Touched registers:
//     R2 -- MEAN
// 	R0 -- RND
// 	R1 -- MASK
// 	R12 -- X
randomdelay_ifm:
	PUSH {R0,R1,R2,LR}
	
	LDR R1, =mask
	LDRB R1, [R1]
	LDR R2, =mean
	LDRB R2, [R2]
	
	LDRB R0, [R12]
	ADD R12, #1
	AND R0, R1
	ADD R0, R2
	LSR R0, R0, #3 // k = 3
	CMP R0, #0
	IT EQ
	BEQ zero_ifm
	NOP
	NOP
dummyloop_ifm:
	SUB R0, #1
	CMP R0, #0
	IT NE
	BNE dummyloop_ifm
zero_ifm:
	POP {R0,R1,R2,LR}
	BX LR
	
	//ENDFUNC
	
/* *************************************************************************** */
// 
// INIT_IFM
// This routine initializes the stuff required for the improved floating mean
//  method
//
// Parameters:
//     X is the exlusive pointer-counter for this routine
// Touched registers:
//     R2 -- MEAN
// 	R0 -- RND
// 	R1 -- MASK
// 	R12 -- X
init_ifm:
	PUSH {R0,R1,R2,LR}
	
	LDR R1, =mask
	LDR R2, =mean
	LDRB R0, [R12]
	ADD R12, #1
	AND R0, #0x7F // the mask for truncating the mean (k = 3)
	STRB R0, [R2]
	MOV R0, #0x1F // set up mask for future use in the floating mean (k = 3)
	STRB R0, [R1]
	POP {R0,R1,R2,LR}
	BX LR
	
	//ENDFUNC
	

/* *************************************************************************** */
// 
// FLIP_IFM
// 'Flips' the floating mean. To be called in the middle of the execution
//
// Touched registers:
//    COUNTER is used a s a temporary helper register here
//    R7 -- COUNTER
//    R8 -- MEAN
flip_ifm:
	PUSH {R0,R1,R2,LR}
	
	LDR R2, =mean
	LDRB R0, [R2]
	MOV R1, #0x7F
	SUB R1, R0
	STRB R1, [R2]
	POP {R0,R1,R2,LR}
	BX LR
	
	//ENDFUNC
	
	
/* *************************************************************************** */
// *** Benoit-Tunstall
/* *************************************************************************** */
// 
// RANDOMDELAY_BT
// This routine produces delay by dummy cycling for a random number of rounds
//  The method is 'Benoit-Tunstall'
//
// Parameters:
//     MASK should contain the mask for truncating the delay (i.e. parameter b)
// Touched registers:
// 	R0 -- RND
// 	R12 -- X
randomdelay_bt:
	PUSH {R0,R1,LR}
	
	LDRB R0, [R12]
	ADD R12, #1
	LDR R1, =bttable
	LDRB R0, [R1, R0]
	CMP R0, #0
	IT EQ
	BEQ zero_bt
	NOP
	NOP
dummyloop_bt:
	SUB R0, #1
	CMP R0, #0
	IT NE
	BNE dummyloop_bt
zero_bt:
	POP {R0,R1,LR}
	BX LR
	NOP
	
	//ENDFUNC

.end
		