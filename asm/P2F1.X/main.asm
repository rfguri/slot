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

;*************
;* VARIABLES *
;*************
 
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
    RETURN
    
INIT_PORTS
    RETURN

INIT_INTERRUPTS
    RETURN

INIT_TXRX
    RETURN

;*************
;* FUNCTIONS *
;*************

;********
;* MAIN *
;********

MAIN
    CALL INIT_CPU
    CALL INIT_PORTS
    CALL INIT_INTERRUPTS
    CALL INIT_TXRX

LOOP
    GOTO LOOP

;*******
;* END *
;*******

    END