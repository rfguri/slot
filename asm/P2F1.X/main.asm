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

TEMP EQU 0x00
 
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

SEND
    BSF TXSTA, TXEN, 0
    MOVWF TXREG, 0
WAITTX
    BTFSS TXSTA, TRMT
    GOTO WAITTX
    RETURN
SERIAL
    MOVFF RCREG, TEMP
    MOVF TEMP, 0
    CALL SEND
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
    BTFSC PIR1, RCIF
    CALL SERIAL
    
    GOTO LOOP

;*******
;* END *
;*******

    END