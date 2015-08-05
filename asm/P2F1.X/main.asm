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
BYTES EQU 0x02
IDVALUE EQU 0x03
TICS EQU 0x04
COUNTER EQU 0x05
 
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
	RETFIE FAST

;*******
;* RSI *
;*******

HIGH_INT
    BTFSS INTCON, TMR0IF, 0
    RETFIE FAST
    
    ; Resetegem Timer0
    BCF INTCON, TMR0IF
    MOVLW   0xE0
    MOVWF   TMR0H, 0
    MOVLW   0xBF
    MOVWF   TMR0L, 0
    
    ; Incrementem tics
    INCF TICS, 1, 0
    
    RETFIE FAST

;*********
;* INITS *
;*********

INIT_CPU
    MOVLW 0x74
    MOVWF OSCCON ; 8MHz Internal Oscilator
    BSF OSCTUNE, PLLEN, 0
    RETURN
    
INIT_TMR0 
    ; Tins = 4 / 32MHz = 125ns
    ; Timer = 1 ms
    ; Steps = 1ms / 125ns = 8000
    ; Timer (16 bits) = 65535
    ; TMR0H/TMR0L = 57535 = 0xE0BF
    MOVLW   0x88
    MOVWF   T0CON, 0
    MOVLW   0xE0
    MOVWF   TMR0H, 0
    MOVLW   0xBF
    MOVWF   TMR0L, 0
    RETURN
    
INIT_INTERRUPTS
    BSF	RCON, IPEN      ; disable priority interrups
    BSF	INTCON, TMR0IE  ; enables the TMR0 overflow interrupt
    BCF	INTCON, TMR0IF  ; clear the TMR0 overflow flag
    BSF INTCON, GIE     ; enables all unmasked interrupts
    BSF INTCON, PEIE    ; enables all unmasked peripheral interrupts
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
    
INIT_PORTS
    CLRF TRISB
    CLRF PORTB
    
    BCF TRISC, 3, 0
    BCF LATC, 3, 0
    BSF LATC, 3, 0
    
    BCF TRISC, 4, 0  
    BCF LATC, 4, 0
    
    BCF TRISC, 5, 0
    BCF LATC, 5, 0
    
    CLRF FLAGS
    CLRF IDBIT
    CLRF TEMP
    CLRF BYTES
    CLRF IDVALUE
    
    RETURN

;*************
;* FUNCTIONS *
;*************

COUNTBYTES
    BCF FLAGS, IDBIT, 0
    CLRF BYTES, 0
    RETURN
    
CHECKVALORS
    INCF BYTES, 1, 0
    MOVLW 0x07
    SUBWF BYTES, 0, 0
    BTFSC STATUS, Z, 0
    CALL COUNTBYTES
    GOTO AVOIDCHECKIDBIT

INCPROGRESS
    BCF LATC, 4, 0
    BSF LATC, 4, 0
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

WAITTICS
    ;CALL CHECKRX
    MOVLW 0x63
    CPFSGT TICS
    GOTO WAITTICS
    RETURN
CLRLEDS
    BCF LATC, 3, 0
    BSF LATC, 3, 0
    RETURN
SETLED
    BCF LATC, 4, 0
    BSF LATC, 4, 0
    INCF COUNTER, 1, 0
SETLEDS
    MOVLW 0x07
    CPFSGT COUNTER
    GOTO SETLED
    CLRF COUNTER
    RETURN
BLINKING
    CALL SETLEDS
    CLRF TICS, 0
    BSF LATC, 5, 0
    CALL WAITTICS
    CALL CLRLEDS
    CLRF TICS, 0
    BCF LATC, 5, 0
    CALL WAITTICS
    RETURN
    
;********
;* MAIN *
;********

MAIN
    CALL INIT_CPU
    CALL INIT_TMR0
    CALL INIT_TXRX
    CALL INIT_INTERRUPTS
    CALL INIT_PORTS
    
LOOP
    CALL CHECKRX
    ;CALL BLINKING
    GOTO LOOP

;*******
;* END *
;*******

    END