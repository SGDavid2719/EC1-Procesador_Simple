*-----------------------------------------------------------
* Title      : PRAFIN20
* Written by : David Santome Galvan (Grupo 1) 
* Written by : Mateo Javier Ramon Roman (Grupo 3)
* Date       : 20/05/2020
* Description: Emulador de la PS-ECI
*-----------------------------------------------------------
        ORG     $1000
EPROG:  DC.W    $8810,$400A,$E00D,$688E,$9000,$4003,$E00D,$6804 
        DC.W    $6FFD,$48A4,$495B,$E00D,$C009,$4020,$A012,$0000 
        DC.W    $0004,$0003,$0000
EIR:    DC.W    0 ;eregistro de instruccion
EPC:    DC.W    0 ;econtador de programa
ET0:    DC.W    0 ;eregistro T0
ET1:    DC.W    0 ;eregistro T1
ER2:    DC.W    0 ;eregistro R2
ER3:    DC.W    0 ;eregistro R3
ER4:    DC.W    0 ;eregistro R4
ER5:    DC.W    0 ;eregistro R5
EB6:    DC.W    0 ;eregistro B6
EB7:    DC.W    0 ;eregistro B7
ESR:    DC.W    0 ;eregistro de estado (00000000 00000ZNC)

*   D0 PARA EIR
*   D1 PARA EPROG CODE
*   D2 PARA EPC
*   D3 PARA SR , BIT A MIRAR
*   D4 PARA ESR
*   D5 PARA RESULTADO ENTRADA
*   D6 PARA RESULTADO SALIDA
*   D7 PARA DBRAS

*   A0 EPROG
*   A1 JMP PROFESOR
*   A2 JMP PROPIO
*   A3 REGISTROS 
*   A7 PILA 68K

START:
    CLR.W   EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	; ESCRIBID VUESTRO CODIGO AQUI
	
LOOPPROGRAMA:

    MOVE.W  EPC,D2
    MULU    #2,D2               ; MULTIPLICAMOS POR DOS EPC
    MOVEA.L D2,A0
    CLR.W   EIR
    MOVE.W  EPROG(A0),EIR       ; OBTENEMOS EPROG CORRESPONDIENTE
    CLR.L   D2
    MOVE.W  EPC,D2
    ADDQ.W  #1,D2               ; PONEMOS EPC APUNTANDO AL SIGUIENTE
    MOVE.W  D2,EPC
        
    ;--- FFETCH: FIN FETCH
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

	; ESCRIBID VUESTRO CODIGO AQUI
	
	MOVE.W  #0,-(A7)            ; RESERVAMOS UN ESPACIO PARA RESULTADO
    MOVE.W  EIR,-(A7)           ; MOVEMOS EIR A LA PILA
    JSR     DECOD
    MOVE.W  (A7)+,EIR
    MOVE.W  (A7)+,D1            ; GUARDAMOS EL RESULTADO EN D1
    MOVE.W  EIR,D0              ; MOVEMOS EIR A REGISTRO 68K
        
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU    #6,D1
    MOVEA.L D1,A1
    JMP     JMPLIST(A1)
JMPLIST:
    JMP EEXIT
    JMP ECOPY
    JMP EADD
    JMP ESUB
    JMP EAND
    JMP ENOT
    JMP ESTC
    JMP ELOA
    JMP ELOAI
    JMP ESTO
    JMP ESTOI
    JMP EBRI
    JMP EBRC
    JMP EBRZ    
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
EEXIT:
    SIMHALT                         ; DETIENE LA MAQUINA
    
    
ECOPY:
    JSR     SRCB                    ; MIRAMOS EL SOURCE bbb
    JSR     SRCEREGISTRO            ; MIRAMOS REGISTRO QUE TOCA SRC
    MOVE.W  D6,D5
    MOVE    SR,D3                   ; GUARDAMOS FLAGS 68K EN D3
    JSR     DSTC                    ; MIRAMOS EL DESTINO ccc
    JSR     DSTEREGISTRO    
    JSR     FLAGNRESULTADO          ; ACTUALIZAR EL FLAG N SEGUN EL RESULTADO
    JSR     FLAGZRESULTADO          ; ACTUALIZAR EL FLAG Z SEGUN EL RESULTADO
    JMP     LOOPPROGRAMA
    
    
EADD:
    JSR     SRCB                    ; MIRAMOS EL SOURCE bbb
    JSR     SRCEREGISTRO
    MOVE.W  D6,D5
    JSR     SRCA                    ; MIRAMOS EL SOURCE aaa
    JSR     SRCEREGISTRO
    ADD.W   D6,D5                   ; REALIZAMOS LA SUMA [Xa] + [Xb]
    MOVE    SR,D3                   ; GUARDAMOS FLAGS 68K EN D3
    JSR     DSTC                    ; MIRAMOS EL DESTINO ccc
    JSR     DSTEREGISTRO 
    JSR     FLAGCRESULTADO          ; ACTUALIZAR EL FLAG C SEGUN EL RESULTADO
    JSR     FLAGNRESULTADO          ; ACTUALIZAR EL FLAG N SEGUN EL RESULTADO
    JSR     FLAGZRESULTADO          ; ACTUALIZAR EL FLAG Z SEGUN EL RESULTADO
    JMP     LOOPPROGRAMA
    
    
ESUB:
    JSR     SRCB                    ; MIRAMOS EL SOURCE bbb
    JSR     SRCEREGISTRO
    MOVE.W  D6,D5
    NOT.W   D5
    ADDQ.W  #1,D5                   ; -B = (NOT(B)+1)
    JSR     SRCA                    ; MIRAMOS EL SOURCE aaa
    JSR     SRCEREGISTRO
    ADD.W   D6,D5                   ; REALIZAMOS LA SUMA [Xa] + -([Xb])
    MOVE    SR,D3                   ; GUARDAMOS FLAGS 68K EN D3
    JSR     DSTC                    ; MIRAMOS EL DESTINO ccc
    JSR     DSTEREGISTRO 
    JSR     FLAGCRESULTADO          ; ACTUALIZAR EL FLAG C SEGUN EL RESULTADO
    JSR     FLAGNRESULTADO          ; ACTUALIZAR EL FLAG N SEGUN EL RESULTADO
    JSR     FLAGZRESULTADO          ; ACTUALIZAR EL FLAG Z SEGUN EL RESULTADO
    JMP     LOOPPROGRAMA
    
    
EAND:
    JSR     SRCB                    ; MIRAMOS EL SOURCE bbb
    JSR     SRCEREGISTRO
    MOVE.W  D6,D5
    JSR     SRCA                    ; MIRAMOS EL SOURCE aaa
    JSR     SRCEREGISTRO
    AND.W   D6,D5                   ; REALIZAMOS LA AND [Xa] and [Xb]
    MOVE    SR,D3                   ; GUARDAMOS FLAGS 68K EN D3
    JSR     DSTC                    ; MIRAMOS EL DESTINO ccc
    JSR     DSTEREGISTRO 
    JSR     FLAGNRESULTADO          ; ACTUALIZAR EL FLAG N SEGUN EL RESULTADO
    JSR     FLAGZRESULTADO          ; ACTUALIZAR EL FLAG Z SEGUN EL RESULTADO
    JMP     LOOPPROGRAMA
    
    
ENOT:
    JSR     DSTC                    ; MIRAMOS EL SOURCE ccc
    JSR     SRCEREGISTRO 
    MOVE.W  D6,D5
    NOT.W   D5                      ; REALIZAMOS LA NOT [Xc]
    MOVE    SR,D3                   ; GUARDAMOS FLAGS 68K EN D3
    JSR     DSTC                    ; MIRAMOS EL DESTINO ccc
    JSR     DSTEREGISTRO 
    JSR     FLAGNRESULTADO          ; ACTUALIZAR EL FLAG N SEGUN EL RESULTADO
    JSR     FLAGZRESULTADO          ; ACTUALIZAR EL FLAG Z SEGUN EL RESULTADO
    JMP     LOOPPROGRAMA
    
    
ESTC:
    JSR     SRCCONSTANTE            ; MIRAMOS LA CONSTANTE kkkkkkkk
    MOVE.W  D6,D5
    EXT.W   D5                      ; EXTENDEMOS LA CONSTANTE
    MOVE    SR,D3                   ; GUARDAMOS FLAGS 68K EN D3
    JSR     DSTC                    ; MIRAMOS EL DESTINO ccc
    JSR     DSTEREGISTRO 
    JSR     FLAGNRESULTADO          ; ACTUALIZAR EL FLAG N SEGUN EL RESULTADO
    JSR     FLAGZRESULTADO          ; ACTUALIZAR EL FLAG Z SEGUN EL RESULTADO
    JMP     LOOPPROGRAMA
    
    
ELOA:
    JSR     SRCMEMORIA              ; MIRAMOS LA POSICION DE MEMORIA mmmmmmmm
    MULU    #2,D6                   ; MULTIPLICAMOS POR DOS POR MEMORIA 68K
    MOVEA.L D6,A3   
    MOVE.W  EPROG(A3),D5            ; [M] EN Ti
    MOVE    SR,D3                   ; GUARDAMOS FLAGS 68K EN D3
    JSR     SRCRT                   ; MIRAMOS EL SOURCE Ti
    JSR     DSTEREGISTRO
    JSR     FLAGNRESULTADO          ; ACTUALIZAR EL FLAG N SEGUN EL RESULTADO
    JSR     FLAGZRESULTADO          ; ACTUALIZAR EL FLAG Z SEGUN EL RESULTADO
    JMP     LOOPPROGRAMA
    
    
ELOAI:
    JSR     SRCRB                   ; MIRAMOS EL SOURCE Bj
    JSR     SRCEREGISTRO
    MULU    #2,D6                   ; MULTIPLICAMOS POR DOS POR MEMORIA 68K
    MOVEA.L D6,A3   
    MOVE.W  EPROG(A3),D5            
    MOVE.W  D5,ET0                  ; [[Bj]] EN T0
    MOVE    SR,D3                   ; GUARDAMOS FLAGS 68K EN D3
    JSR     FLAGNRESULTADO          ; ACTUALIZAR EL FLAG N SEGUN EL RESULTADO
    JSR     FLAGZRESULTADO          ; ACTUALIZAR EL FLAG Z SEGUN EL RESULTADO
    JMP     LOOPPROGRAMA
    
    
ESTO:
    JSR     SRCRT                   ; MIRAMOS EL SOURCE Ti
    JSR     SRCEREGISTRO
    MOVE.W  D6,D5
    JSR     SRCMEMORIA              ; MIRAMOS LA POSICION DE MEMORIA mmmmmmmm
    MULU    #2,D6                   ; MULTIPLICAMOS POR DOS POR MEMORIA 68K
    MOVEA.L D6,A3   
    MOVE.W  D5,EPROG(A3)            ; [Ti] EN M
    JMP     LOOPPROGRAMA
    
    
ESTOI:
    MOVE.W  ET0,D6
    MOVE.W  D6,D5
    JSR     SRCRB                   ; MIRAMOS EL SOURCE Bj
    JSR     DSTEREGISTRO
    JMP     LOOPPROGRAMA


EBRI:
    JSR     SRCMEMORIA              ; VAMOS A BUSCAR LA MEMORIA
    CLR.W   EPC
    MOVE.W  D6,EPC                  ; [M] -> EPC
    JMP     LOOPPROGRAMA            ; VOLVEMOS AL PRINCIPIO
    
    
EBRC:
    MOVE.W  ESR,D4                  ; MOVEMOS ESR A D4
    BTST.L  #0,D4                   ; MIRAMOS SI C = 1
    BEQ     CZERO
    JSR     SRCMEMORIA              ; C = 1 SE VA A BUSCAR LA MEMORIA
    CLR.W   EPC
    MOVE.W  D6,EPC            
CZERO:    
    JMP     LOOPPROGRAMA            ; C = 0 NO MOVEMOS NADA A EPC
    
    
EBRZ:
    MOVE.W  ESR,D4
    BTST.L  #2,D4                   ; MIRAMOS SI ES ZERO Z = 1
    BEQ     ZZERO
    JSR     SRCMEMORIA              ; Z = 1 SE VA A BUSCAR LA MEMORIA
    CLR.W   EPC
    MOVE.W  D6,EPC
ZZERO:    
    JMP LOOPPROGRAMA                ; Z = 0 NO MOVEMOS NADA A EPC
    
    
    ;--- FEXEC: FIN EJECUCION

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	; ESCRIBID VUESTRO CODIGO AQUI
        
SRCMEMORIA:
    MOVE.W  D0,-(A7) 
    CLR.L   D6                      ; RESULTADO EN D6
    AND.W   #%0000000011111111,D0   ; MIRAMOS mmmmmmmm
    MOVE.W  D0,D6                   ; MOVEMOS mmmmmmmm A D6
    MOVE.W  (A7)+,D0     
    RTS


DSTC:
    MOVE.W  D0,-(A7) 
    CLR.L   D6                      ; RESULTADO EN D6
    AND.W   #%0000000000000111,D0   ; MIRAMOS ccc
    MOVE.W  D0,D6                   ; MOVEMOS ccc A D6
    MOVE.W  (A7)+,D0     
    RTS


SRCB: 
    MOVE.W  D0,-(A7) 
    CLR.L   D6                      ; RESULTADO EN D6
    AND.W   #%0000000000111000,D0   ; MIRAMOS bbb
    LSR.W   #3,D0                   ; MOVEMOS 3 BITS A LA DERECHA
    MOVE.W  D0,D6                   ; MOVEMOS bbb A D6
    MOVE.W  (A7)+,D0     
    RTS
    

SRCA: 
    MOVE.W  D0,-(A7) 
    CLR.L   D6                      ; RESULTADO EN D6
    AND.W   #%0000000111000000,D0   ; MIRAMOS aaa
    LSR.W   #6,D0                   ; MOVEMOS 6 BITS A LA DERECHA
    MOVE.W  D0,D6                   ; MOVEMOS aaa A D6
    MOVE.W  (A7)+,D0     
    RTS
    

SRCRT:
    MOVE.W  D0,-(A7) 
    CLR.L   D6                      ; RESULTADO EN D6
    AND.W   #%0000100000000000,D0   ; MIRAMOS i Y MOVEMOS 8+3=11 BITS
    LSR.W   #8,D0                   ; MOVEMOS 8 BITS A LA DERECHA
    LSR.W   #3,D0                   ; MOVEMOS 3 BITS A LA DERECHA
    MOVE.W  D0,D6                   ; MOVEMOS 00i A D6
    MOVE.W  (A7)+,D0     
    RTS                             ; NO PODEMOS 11B PORQUE EL RANGO ES 1-8B
  

SRCRB:
    MOVE.W  D0,-(A7) 
    CLR.L   D6                      ; RESULTADO EN D6
    AND.W   #%0000100000000000,D0   ; MIRAMOS j Y MOVEMOS 8+3=11 BITS
    LSR.W   #8,D0                   ; MOVEMOS 8 BITS A LA DERECHA
    LSR.W   #3,D0                   ; MOVEMOS 3 BITS A LA DERECHA
    BSET.L  #2,D0
    BSET.L  #1,D0                   ; PONEMOS EN D0 EL REGISTRO 11j
    MOVE.W  D0,D6                   ; MOVEMOS 11j A D6
    MOVE.W  (A7)+,D0     
    RTS

SRCCONSTANTE:
    MOVE.W  D0,-(A7) 
    CLR.L   D6                      ; RESULTADO EN D6
    AND.W   #%0000011111111000,D0   ; MIRAMOS kkkkkkkk
    LSR.W   #3,D0                   ; MOVEMOS 3 BITS A LA DERECHA
    BTST.L  #7,D0
    BEQ     NOEXTEND                ; SI ES NEGATIVO NO SALTAMOS
    EXT.W   D0                      ; EXTENDEMOS EL BIT MAS SIGNIFICATIVO
NOEXTEND:
    MOVE.W  D0,D6                   ; MOVEMOS kkkkkkkk A D6
    MOVE.W  (A7)+,D0     
    RTS
    

SRCEREGISTRO:
    BTST.L  #2,D6
    BEQ     ETR0123SRC              ; SALTAMOS SI ES UN 0
    BTST.L  #1,D6
    BEQ     ETR45SRC                ; SALTAMOS SI ES UN 10
    BTST.L  #0,D6           
    BEQ     ETR6SRC                 ; SALTAMOS SI ES UN 110
    MOVE.W  EB7,D6                  ; REGISTO 111 = EB7
    JMP     EXIT2
ETR6SRC:
    MOVE.W  EB6,D6                  ; REGISTRO 110 = EB6
    JMP     EXIT2
ETR45SRC:
    BTST.L  #0,D6           
    BEQ     ETR4SRC                 ; SALTAMOS SI ES UN 100
    MOVE.W  ER5,D6                  ; REGISTO 101 = ER5
    JMP     EXIT2
ETR4SRC:
    MOVE.W  ER4,D6                  ; REGISTO 100 = ER4
    JMP     EXIT2
ETR0123SRC:
    BTST.L  #1,D6
    BEQ     ETR01SRC                ; SALTAMOS SI ES UN 00
    BTST.L  #0,D6
    BEQ     ETR2SRC                 ; SALTAMOS SI ES UN 010
    MOVE.W  ER3,D6                  ; REGISTRO 011 = ER3
    JMP     EXIT2
ETR2SRC:
    MOVE.W  ER2,D6                  ; REGISTRO 010 = ER2
    JMP     EXIT2
ETR01SRC:
    BTST.L  #0,D6
    BEQ     ETR0SRC                 ; SALTAMOS SI ES UN 000
    MOVE.W  ET1,D6                  ; REGISTRO 001 = ET1
    JMP     EXIT2
ETR0SRC:
    MOVE.W  ET0,D6                  ; REGISTRO 000 = ET0
    JMP     EXIT2
EXIT2:
    RTS
 
   
DSTEREGISTRO:
    BTST.L  #2,D6
    BEQ     ETR0123DST              ; SALTAMOS SI ES UN 0
    BTST.L  #1,D6
    BEQ     ETR45DST                ; SALTAMOS SI ES UN 10
    BTST.L  #0,D6           
    BEQ     ETR6DST                 ; SALTAMOS SI ES UN 110
    MOVE.W  D5,EB7                  ; REGISTO 111 = EB7
    JMP     EXIT3
ETR6DST:
    MOVE.W  D5,EB6                  ; REGISTRO 110 = EB6
    JMP     EXIT3
ETR45DST:
    BTST.L  #0,D6           
    BEQ     ETR4DST                 ; SALTAMOS SI ES UN 100
    MOVE.W  D5,ER5                  ; REGISTO 101 = ER5
    JMP     EXIT3
ETR4DST:
    MOVE.W  D5,ER4                  ; REGISTO 100 = ER4
    JMP     EXIT3
ETR0123DST:
    BTST.L  #1,D6
    BEQ     ETR01DST                ; SALTAMOS SI ES UN 00
    BTST.L  #0,D6
    BEQ     ETR2DST                 ; SALTAMOS SI ES UN 010
    MOVE.W  D5,ER3                  ; REGISTRO 011 = ER3
    JMP     EXIT3
ETR2DST:
    MOVE.W  D5,ER2                  ; REGISTRO 010 = ER2
    JMP     EXIT3
ETR01DST:
    BTST.L  #0,D6
    BEQ     ETR0DST                 ; SALTAMOS SI ES UN 000
    MOVE.W  D5,ET1                  ; REGISTRO 001 = ET1
    JMP     EXIT3
ETR0DST:
    MOVE.W  D5,ET0                  ; REGISTRO 000 = ET0
    JMP     EXIT3
EXIT3:
    RTS
    
 
FLAGCRESULTADO: 
    MOVE.W  ESR,D4
    BTST.L  #0,D3                   ; MIRAMOS BIT 0 == C DEL SR DEL 68K
    BEQ     FCR0
    BSET.L  #0,D4                   ; PONEMOS BIT C A 1
    JMP     EXITFCR
FCR0:
    BCLR.L  #0,D4                   ; PONEMOS BIT C A 0
EXITFCR:
    MOVE.W  D4,ESR
    RTS
    
    
FLAGNRESULTADO: 
    MOVE.W  ESR,D4
    BTST.L  #3,D3                   ; MIRAMOS BIT 3 == N DEL SR DEL 68K
    BEQ     FNR0
    BSET.L  #1,D4                   ; PONEMOS BIT N A 1
    JMP     EXITFNR
FNR0:
    BCLR.L  #1,D4                   ; PONEMOS BIT N A 0
EXITFNR:
    MOVE.W  D4,ESR
    RTS
   
   
FLAGZRESULTADO:
    MOVE.W  ESR,D4
    BTST.L  #2,D3                   ; MIRAMOS BIT 2 == Z DEL SR DEL 68K
    BEQ     FZR0
    BSET.L  #2,D4                   ; PONEMOS BIT Z A 1
    JMP     EXITFZR
FZR0:
    BCLR.L  #2,D4                   ; PONEMOS BIT N A 0
EXITFZR:
    MOVE.W  D4,ESR
    RTS

    ;--- FSUBR: FIN SUBRUTINAS

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:

	; ESCRIBID VUESTRO CODIGO AQUI
    
    MOVE.L  D0,-(A7)       
    MOVE.W  8(A7),D0
    
    BTST.L  #15,D0
    BNE     ETD0                    ; BRANCH SI ES UN 1
    BTST.L  #14,D0
    BNE     ETD1                    ; BRANCH SI ES UN 01
    MOVE.W  #0,10(A7)               ; 00 ES EXIT
    JMP EXIT

ETD0:
    
    BTST.L  #14,D0
    BNE     ETD7                    ; BRANCH SI ES UN 11
    BTST.L  #13,D0
    BNE     ETD8                    ; BRANCH SI ES UN 101
    BTST.L  #12,D0
    BNE     ETD9                    ; BRANCH SI ES UN 1001 
    MOVE.W  #7,10(A7)               ; 1000 ES LOA
    JMP EXIT   
    
ETD1:

    BTST.L  #13,D0
    BNE     ETD2                    ; BRANCH SI ES UN 011
    BTST.L  #12,D0
    BNE     ETD3                    ; BRANCH SI ES UN 0101
    BTST.L  #11,D0
    BNE     ETD4                    ; BRANCH SI ES UN 01001
    MOVE.W  #1,10(A7)               ; 01000 ES COPY
    JMP     EXIT

ETD4:
    
    MOVE.W  #2,10(A7)               ; 01001 ES ADD
    JMP     EXIT 
    
ETD3:

    BTST.L  #11,D0
    BNE     ETD5                     ; BRANCH SI ES UN 01011
    MOVE.W  #3,10(A7)               ; 01010 ES SUB
    JMP     EXIT
    
ETD5:

    MOVE.W  #4,10(A7)               ; 01011 ES AND
    JMP     EXIT 
    
ETD2:

    BTST.L  #11,D0
    BNE     ETD6                    ; BRANCH SI ES UN 01101
    MOVE.W  #5,10(A7)               ; 01100 ES NOT
    JMP     EXIT
    
ETD6:

    MOVE.W  #6,10(A7)               ; 01101 ES STC
    JMP     EXIT 

ETD9: 

    MOVE.W  #8,10(A7)               ; 1001 ES LOAI
    JMP     EXIT
    
ETD8:    

    BTST.L  #12,D0
    BNE     ETD10                   ; BRANCH SI ES UN 1011 
    MOVE.W  #9,10(A7)               ; 1010 ES STO
    JMP EXIT   
    
ETD10:
    
    MOVE.W  #10,10(A7)               ; 1011 ES STOI
    JMP     EXIT
  
ETD7:
    
    BTST.L  #13,D0
    BNE     ETD11                    ; BRANCH SI ES UN 111
    BTST.L  #12,D0
    BNE     ETD12                    ; BRANCH SI ES UN 1101
    MOVE.W  #11,10(A7)               ; 1100 ES BRI
    JMP     EXIT
    
ETD11:
    
    MOVE.W  #13,10(A7)               ; 111 ES BRZ
    JMP     EXIT
    
ETD12:

    MOVE.W  #12,10(A7)               ; 1101 ES BRC
    JMP     EXIT
 
EXIT:   
    MOVE.L (A7)+,D0
    RTS

    ;--- FDECOD: FIN DECOD
    END    START























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
