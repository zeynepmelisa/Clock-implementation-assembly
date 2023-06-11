;Sa se scrie un program cu ajutorul caruia sa se implementeze un ceas.

;Adresele alocate in zona MDX pentru circuitul 8255_0(U4):
Adr_8255_0_PA	EQU		8000h ;secunde
Adr_8255_0_PB	EQU		8001h ;secunde
Adr_8255_0_PC	EQU		8002h ;minute
Adr_8255_0_CC	EQU		8003h
;Adresele alocate in zona MDX pentru circuitul 8255_1(U5):
Adr_8255_1_PA	EQU		8004h ;minute
Adr_8255_1_PB	EQU		8005h ;ora
Adr_8255_1_PC	EQU		8006h ;ora
Adr_8255_1_CC	EQU		8007h

CC_8255_0		EQU		80h
CC_8255_1		EQU		80h

ORG 0h
	LJMP PP
				
ORG 0Bh
	LJMP intrerupere
			
ORG 100h
	PP:	CLR IE.7				;dezactivare globala a sistemului de intreruperi
		MOV TMOD,#01h 			;programarea modului de lucru
		MOV TH0,#0F9h 			;incarcare OMS al constantei de timp in TH0
		MOV TL0,#07Dh 			;incarcare OMPS al constantei de timp in TL0
		SETB IE.1 				;validarea intreruperilor de la timerul T0			
		ACALL initializari		;salt la sectiunea de initializari
		SETB TCON.4 			;pornire software a timerului T0
		SETB IE.7 				;activare globala a sistemului de intreruperi
		SJMP $					;bucla infinita
				
ORG 200h
	initializari:	MOV R0,#00h				;initializare contor
					MOV DPTR,#Adr_8255_0_CC	;initializare 8255_0
					MOV A,#CC_8255_0
					MOVX @DPTR,A
					MOV DPTR,#Adr_8255_1_CC	;initializare 8255_1
					MOV A,#CC_8255_1
					MOVX @DPTR,A
					RET
			
ORG 300h
intrerupere:	INC R6						;incrementare contor
				CJNE R6,#0FFh,continue
	continue:	JC afisare
				MOV R6,#00h
				
				INC R0						;incrementare secunde 
				CJNE R0,#0Ah,next0	
	   next0:	JC afisare
				MOV R0,#00h				
				
				MOV A,R1					;incrementare secunde partea zecimala
				ADD A,#10h
				MOV R1,A
				CJNE R1,#60h,next1
	   next1:	JC afisare
				MOV R1,#00h
				
				INC R2						;incrementare minute
				CJNE R2,#0Ah,next2
		next2:	JC afisare
				MOV R2,#00h	
				
				MOV A,R3					;incrementare minute partea zecimala 
				ADD A,#10h
				MOV R3,A
				CJNE R3,#60h,next3
	   next3:	JC afisare
				MOV R3,#00h
				
				INC R4						;incrementare ora
				CJNE R4,#0Ah,next4
		next4:	JC afisare
				MOV R4,#00h	
				
				MOV A,R5					;incrementare ora partea zecimala 
				ADD A,#10h
				MOV R5,A
				CJNE R5,#60h,next5
	   next5:	JC afisare
				MOV R5,#00h
				
				RETI
			
ORG 380h
	afisare:	MOV A,R0
				MOV DPTR,#Adr_8255_0_PA
				MOVX @DPTR,A
				
				MOV A,R1
				MOV DPTR,#Adr_8255_0_PB
				MOVX @DPTR,A
				
				MOV A,R2
				MOV DPTR,#Adr_8255_0_PC
				MOVX @DPTR,A
				
				MOV A,R3
				MOV DPTR,#Adr_8255_1_PA
				MOVX @DPTR,A
				
				MOV A,R4
				MOV DPTR,#Adr_8255_1_PB
				MOVX @DPTR,A
				
				MOV A,R5
				MOV DPTR,#Adr_8255_1_PC
				MOVX @DPTR,A
				
				RETI

			ORG 600h
conversie:	ANL A,#0Fh
			MOV R7,#00h 
			CJNE A,#09h,next 
	 next: 	JNC exit 
			MOV DPTR,#SSEG 
			MOVC A,@A+DPTR 
			MOV R7,A 
	 exit: 	MOV A,R7  
			RET
 
				ORG 700h
SSEG:		DB 3Fh	;0
			DB 06h	;1
			DB 5Bh	;2
			DB 4Fh	;3
			DB 66h	;4
			DB 6Dh	;5
			DB 7Dh	;6
			DB 07h	;7
			DB 7Fh	;8
			DB 6Fh	;9
	END