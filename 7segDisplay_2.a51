;Sa se scrie un program cu ajutorul caruia sa se implementeze un ceas.

Adr_8255_0_PA	EQU		8000h 
Adr_8255_0_PB	EQU		8001h 
Adr_8255_0_PC	EQU		8002h 
Adr_8255_0_CC	EQU		8003h

Adr_8255_1_PA	EQU		8004h 
Adr_8255_1_PB	EQU		8005h 
Adr_8255_1_PC	EQU		8006h 
Adr_8255_1_CC	EQU		8007h

CC_8255_0		EQU		80h
CC_8255_1		EQU		80h

ORG 0h
	LJMP PP
				
ORG 0Bh
	LJMP Intrerupere
			
ORG 100h
	PP:	CLR IE.7				;dezactivare globala a sistemului de intreruperi
		MOV TMOD,#01h 			;programarea modului de lucru
		MOV TH0,#0F9h 			;incarcare OMS al constantei de timp in TH0
		MOV TL0,#07Dh 			;incarcare OMPS al constantei de timp in TL0
		SETB IE.1 				;validarea intreruperilor de la timerul T0
		
		MOV R0,#00h				;initializare contor
		MOV DPTR,#Adr_8255_0_CC	;initializare 8255_0
		MOV A,#CC_8255_0
		MOVX @DPTR,A
		MOV DPTR,#Adr_8255_1_CC	;initializare 8255_1
		MOV A,#CC_8255_1
		MOVX @DPTR,A
		
		SETB TCON.4 			;pornire software a timerului T0
		SETB IE.7 				;activare globala a sistemului de intreruperi
		SJMP $					;bucla infinita
				
			
ORG 200h
	Intrerupere:	INC R0					;incrementare R0 
					CJNE R0,#0FFh,Afisare	;verificam daca a trecut o secunda
					MOV R0,#00h				;resetam R0
				
					MOV A,R1
					ADD A,#01h				;incrementare secunde
					DA A					;ajustare zecimala a adunarii pentru numere reprezentate in cod BCD
					MOV R1,A
					CJNE R1,#60h,Afisare	;verificam daca au trecut 60 de secunde
					MOV R1,#00h				;resetam R1

					MOV A,R2
					ADD A,#01h				;incrementare minute
					DA A					;ajustare zecimala a adunarii pentru numere reprezentate in cod BCD
					MOV R2,A
					CJNE R2,#60h,Afisare	;verificam daca au trecut 60 de minute
					MOV R2,#00h				;resetam R2
			
					MOV A,R3
					ADD A,#01h				;incrementare ore
					DA A					;ajustare zecimala a adunarii pentru numere reprezentate in cod BCD
					MOV R3,A
					CJNE R3,#24h,Afisare	;verificam daca au trecut 24 de ore
					MOV R3,#00h				;resetam R3
					RET
			
ORG 280h
	Afisare:	MOV A,R1
				LCALL conversie			;apel subrutina conversie 7SEG
				MOV DPTR,#Adr_8255_0_PA
				MOVX @DPTR,A
				MOV A,R1
				SWAP A					;interschimbare tetrade
				LCALL conversie			;apel subrutina conversie 7SEG
				MOV DPTR,#Adr_8255_0_PB
				MOVX @DPTR,A
			
				MOV A,R2
				LCALL conversie			;apel subrutina conversie 7SEG
				MOV DPTR,#Adr_8255_0_PC
				MOVX @DPTR,A
				MOV A,R2
				SWAP A					;interschimbare tetrade
				LCALL conversie			;apel subrutina conversie 7SEG
				MOV DPTR,#Adr_8255_1_PA
				MOVX @DPTR,A
			
				MOV A,R3
				LCALL conversie			;apel subrutina conversie 7SEG
				MOV DPTR,#Adr_8255_1_PB
				MOVX @DPTR,A
				MOV A,R3
				SWAP A					;interschimbare tetrade
				LCALL conversie			;apel subrutina conversie 7SEG
				MOV DPTR,#Adr_8255_1_PC
				MOVX @DPTR,A
				RETI

ORG 400h
	Conversie:	ANL A,#0Fh
				MOV R7,#00h 
				CJNE A,#09h,next 
		 Next: 	JNC exit 
				MOV DPTR,#SSEG 
				MOVC A,@A+DPTR 
				MOV R7,A 
		 Exit: 	MOV A,R7  
				RET

ORG 500h
	SSEG:	DB 3Fh	;0
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