//
// Implementation of key expansion.
//
// Started 2022-3-8 by yangx, Zhejiang University
	
.section .data
.section .text
.syntax unified
.thumb
.global key_expansion
		
	
	/********************************************/
	// Function of key expansion
	//
	// Parameters:
	//    r0 stores the address of keys 
key_expansion:
	PUSH {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
	
	MOV R12, #10 // counter
	MOV R11, #0xFF
	LDR R10, =tab_sbox
	LDR R9, =rcon
loop_key:
	LDR R2, [R0]
	LDR R3, [R0, #4]
	LDR R4, [R0, #8]
	LDR R5, [R0, #12]
	AND R6, R11, R5
	LDRB R6, [R10, R6]
	LSL R6, R6, #24
	AND R7, R11, R5, LSR #8
	LDRB R7, [R10, R7]
	LDRB R8, [R9]
	EOR R7, R8
	ORR R6, R6, R7
	AND R7, R11, R5, LSR #16
	LDRB R7, [R10, R7]
	ORR R6, R6, R7, LSL #8
	AND R7, R11, R5, LSR #24
	LDRB R7, [R10, R7]
	ORR R6, R6, R7, LSL #16
	EOR R2, R6
	ADD R0, #16
	STR R2, [R0]
	EOR R2, R3
	STR R2, [R0, #4]
	EOR R2, R4
	STR R2, [R0, #8]
	EOR R2, R5
	STR R2, [R0, #12]
	
	// loop block
	SUB R12, #1
	ADD R9, #1
	CMP R12, #0
	IT NE
	BNE loop_key
	
	NOP
	POP {R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,LR}
	BX LR
	
	.end
		