; ----------------------------------------------------------------------------
; Name: main.asm
; Author: Roger Fernandez Guri
; Version: 0.0
; ----------------------------------------------------------------------------

;*******************************************************************************
;* Required Files:              P18F4321.INC                                   *
;*                              18F4321.LKR                                    *
;*******************************************************************************

    LIST P=18F4321, F=INHX32
    #include <P18F4321.INC>

;******************
;* CONFIGURATIONS *
;******************

    CONFIG OSC = INTIO1
    CONFIG PBADEN = DIG
    CONFIG WDT = OFF

;*************
;* VARIABLES *
;*************

FLAGS EQU 0x00
IDBIT EQU 0x01
    
TEMP EQU 0x01
ACC EQU 0x02
IDVALUE EQU 0x03
 
;*************
;* CONSTANTS *
;*************

;*****************************
; ITERRUPT AND RESET VECTORS *
;*****************************

    ORG 0x000000
	GOTO MAIN

    ORG 0x000008
	GOTO HIGH_INT

    ORG 0x000018
	GOTO LOW_INT

;*******
;* RSI *
;*******

HIGH_INT
    retfie

LOW_INT
    retfie	

;*********
;* INITS *
;*********

INIT_CPU
    MOVLW 0x74
    MOVWF OSCCON ; 8MHz Internal Oscilator
    BSF OSCTUNE, PLLEN, 0
    RETURN
    
INIT_PORTS
    CLRF TRISB
    CLRF PORTB
    
    BCF TRISC, 3, 0
    BCF TRISC, 4, 0
    BCF LATC, 3, 0
    BSF LATC, 3, 0
    
    CLRF FLAGS
    CLRF IDBIT
    CLRF TEMP
    CLRF ACC
    CLRF IDVALUE
    
    RETURN

INIT_INTERRUPTS
    BSF RCON, IPEN, 0
    BCF INTCON, GIE/GIEH, 0
    BCF INTCON, PEIE/GIEL, 0
    RETURN

INIT_TXRX
    MOVLW 0x00
    MOVWF SPBRGH
    MOVLW 0x19
    MOVWF SPBRG
    BCF TXSTA, BRGH, 0
    BCF BAUDCON, BRG16, 0 ; Baud rate generator at 19200
    BCF TXSTA, SYNC, 0 ; Asynchronous mode
    BSF RCSTA, SPEN, 0 ; Enable serial
    BSF TXSTA, TXEN, 0 ; Enable transmision
    BSF RCSTA, CREN, 0 ; Enable reception
    RETURN

;*************
;* FUNCTIONS *
;*************

COUNTBYTES
    BCF FLAGS, IDBIT, 0
    CLRF ACC, 0
    RETURN
    
CHECKVALORS
    INCF ACC, 1, 0
    MOVLW 0x07
    SUBWF ACC, 0, 0
    BTFSC STATUS, Z, 0
    CALL COUNTBYTES
    GOTO AVOIDCHECKIDBIT

INCPROGRESS
    BSF LATC, 4, 0
    BCF LATC, 4, 0
    BCF FLAGS, IDBIT, 0
    RETURN
    
CHECKIDVALUE
    MOVFF TEMP, IDVALUE
    MOVLW 0x02
    SUBWF IDVALUE, 0, 0
    BTFSS STATUS, Z, 0
    CALL INCPROGRESS
    RETURN
    
CHECKIDBIT
    BTFSC FLAGS, IDBIT, 0
    GOTO CHECKVALORS
    BSF FLAGS, IDBIT, 0
    CALL CHECKIDVALUE
AVOIDCHECKIDBIT
    RETURN
    
SEND
    BSF TXSTA, TXEN, 0
    MOVFF TEMP, TXREG
WAITTX
    BTFSS TXSTA, TRMT, 0
    GOTO WAITTX
    RETURN
SERIAL
    MOVFF RCREG, TEMP
    MOVF TEMP, 0
    CALL CHECKIDBIT
    CALL SEND
    RETURN
CHECKRX
    BTFSC PIR1, RCIF, 0
    CALL SERIAL
    RETURN

;********
;* MAIN *
;********

MAIN
    CALL INIT_CPU
    CALL INIT_PORTS
    CALL INIT_INTERRUPTS
    CALL INIT_TXRX

LOOP
    CALL CHECKRX
    GOTO LOOP

;*******
;* END *
;*******

    END