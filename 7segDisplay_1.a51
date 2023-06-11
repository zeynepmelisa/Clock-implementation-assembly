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
				
ORG 03h
			INC 	R6					;incrementare contor
			CJNE	R6,#32h,next		;verifica daca a trecut o secunda
	next:	JNC		exit				;daca a trecut sare la exit 
			RETI						
			
	exit:	MOV		R6,#00h				;se reseteaza R6 cand a trecut o secunda
			LCALL	intrerupere			;sare la rutina de tratare a intreruperii 
			RET
				
			
ORG 100h
	PP:	CLR IE.7				;dezactivare globala a sistemului de intreruperi
		SETB IE.0 				;validarea intreruperilor de la timerul INT0			
		ACALL initializari		;salt la sectiunea de initializari
		SETB TCON.0 			;INT0 activ pe front coborator
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
	intrerupere:	INC R0						;incrementare secunde 
					CJNE R0,#0Ah,next0			;verifica daca au trecut 10 secunde
		  next0:	JC afisare					;daca nu au trecut se sare la afisare 
					MOV R0,#00h					;daca au trecut se reseteaza R0
				
					MOV A,R1					
					ADD A,#10h					;incrementare secunde partea zecimala
					MOV R1,A
					CJNE R1,#60h,next1			;verifica daca au trecut 60 de secunde
		  next1:	JC afisare					;daca nu au trecut se sare la afisare 
					MOV R1,#00h					;daca au trecut se reseteaza R1
				
					INC R2						;incrementare minute
					CJNE R2,#0Ah,next2			;verifica daca au trecut 10 de minute
		  next2:	JC afisare					;daca nu au trecut se sare la afisare
					MOV R2,#00h					;daca au trecut se reseteaza R2
				
					MOV A,R3					
					ADD A,#10h					;incrementare minute partea zecimala 
					MOV R3,A
					CJNE R3,#60h,next3			;verifica daca au trecut 60 de minute
	      next3:	JC afisare					;daca nu au trecut se sare la afisare 
					MOV R3,#00h					;daca au trecut se reseteaza R3
				
					INC R4						;incrementare ora
					CJNE R4,#04h,next4			;verifica daca au trecut 4 ore
		  next4:	JC afisare					;daca nu au trecut se sare la afisare 
					MOV R4,#00h					;daca au trecut se reseteaza R4
				
					MOV A,R5					 
					ADD A,#04h					;incrementare ora 
					MOV R5,A
					CJNE R5,#24h,next5			;verifica daca au trecut 24 ore
	      next5:	JC afisare					;daca nu au trecut se sare la afisare 
					MOV R5,#00h					;daca au trecut se reseteaza R5
					RETI
			
ORG 380h
	afisare:	MOV A,R0
				LCALL conversie					
				MOV DPTR,#Adr_8255_0_PA
				MOVX @DPTR,A
				
				MOV A,R1
				SWAP A
				LCALL conversie
				MOV DPTR,#Adr_8255_0_PB
				MOVX @DPTR,A
				
				MOV A,R2
				LCALL conversie
				MOV DPTR,#Adr_8255_0_PC
				MOVX @DPTR,A
				
				MOV A,R3
				SWAP A
				LCALL conversie
				MOV DPTR,#Adr_8255_1_PA
				MOVX @DPTR,A
				
				MOV A,R4
				LCALL conversie
				MOV DPTR,#Adr_8255_1_PB
				MOVX @DPTR,A
				
				MOV A,R5
				SWAP A
				LCALL conversie
				MOV DPTR,#Adr_8255_1_PC
				MOVX @DPTR,A
				
				RETI

ORG 500h
	conversie:	ANL A,#0Fh
				MOV R7,#00h 
				CJNE A,#09h,next6 
		next6:  JNC exit6 
				MOV DPTR,#SSEG 
				MOVC A,@A+DPTR 
				MOV R7,A 
		 exit6: MOV A,R7  
				RET
 
ORG 600h
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