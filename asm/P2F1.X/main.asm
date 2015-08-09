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

    CONFIG OSC = INTIO2
    CONFIG PBADEN = DIG
    CONFIG WDT = OFF

;*************
;* VARIABLES *
;*************

FLAGS EQU 0x00
IDBIT EQU 0x01
ENDBIT EQU 0x02
    
TEMP EQU 0x01
BITS EQU 0x02
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
    
    ; Reset Timer0
    BCF INTCON, TMR0IF, 0
    MOVLW 0xE0
    MOVWF TMR0H, 0
    MOVLW 0xBF
    MOVWF TMR0L, 0
    
    ; Increment Tics
    INCF TICS, 1, 0
    
    RETFIE FAST
    
;*********
;* INITS *
;*********
  
INIT_TMR0
    ; Timer = 1ms , Tins = 4 / 32MHz = 125ns
    ; Timer = 1ms
    ; Steps = 1ms / 125ns = 8000 steps
    ; Timer (16 bits) = 65535 - 8000 = 57535 = 0xE0BF
    MOVLW 0x88
    MOVWF T0CON, 0
    MOVLW 0xE0
    MOVWF TMR0H, 0
    MOVLW 0xBF
    MOVWF TMR0L, 0
    RETURN
    
INIT_INTERRUPTS
    BSF RCON, IPEN, 0 ; Enable priority interrupts
    BSF INTCON, GIE, 0 ; Enable interrupts
    BSF INTCON, PEIE, 0 ; Enable peripheral interrupt
    BSF INTCON, TMR0IE, 0 ; Enable TMR0 overflow interrupt
    BSF INTCON2, TMR0IP, 0 ; Enable TMR0 high priority interrupt
    BCF INTCON, TMR0IF, 0 ; Clear TMR0 overflow flag
    RETURN
    
INIT_CPU
    ; 32MHz Internal Oscilator
    MOVLW 0x74
    MOVWF OSCCON
    BSF OSCTUNE, PLLEN, 0
    RETURN
    
INIT_TXRX
    MOVLW 0x00
    MOVWF SPBRGH
    MOVLW 0x19
    MOVWF SPBRG
    BCF TXSTA, BRGH, 0
    BCF BAUDCON, BRG16, 0 ; Enable baud rate generator at 19200
    BCF TXSTA, SYNC, 0 ; Enable Asynchronous mode
    BSF RCSTA, SPEN, 0 ; Enable serial
    BSF TXSTA, TXEN, 0 ; Enable transmision
    BSF RCSTA, CREN, 0 ; Enable reception
    RETURN
    
INIT_PORTS
    ; A8..A11 Output
    BCF TRISB, 0, 0
    BCF TRISB, 1, 0
    BCF TRISB, 2, 0
    BCF TRISB, 3, 0
    
    ; IR TX/RX
    BSF TRISB, 4, 0
    BSF TRISB, 5, 0
        
    ; MCLR Progressbar Output
    BCF TRISC, 3, 0
    BCF LATC, 3, 0
    BSF LATC, 3, 0
    
    ; Progressbar Output
    BCF TRISC, 4, 0
    BCF LATC, 4, 0
    
    ; Test pin
    BCF TRISC, 5, 0
    BCF LATC, 5, 0
    
    CLRF FLAGS
    CLRF IDBIT
    CLRF TEMP
    CLRF BITS
    CLRF IDVALUE
    CLRF TICS
    CLRF COUNTER
    
    RETURN

    
;******************
;* TEST FUNCTIONS *
;******************

TEST
    BSF LATC, 5, 0
    BCF LATC, 5, 0
    BCF FLAGS, IDBIT, 0
    RETURN    
    
;*************
;* FUNCTIONS *
;*************
CHECKWAITTICS
    CALL CHECKRX
    BTFSS FLAGS, ENDBIT, 0
    RETURN
    MOVLW 0x63 ; 100ms
    CPFSEQ TICS
    GOTO CHECKWAITTICS
    RETURN
CLRLEDS
    BCF LATC, 3, 0
    BSF LATC, 3, 0
    RETURN
INCCOUNTER
    BSF LATC, 4, 0
    BCF LATC, 4, 0
    BCF FLAGS, IDBIT, 0
    INCF COUNTER, 1, 0
SETLEDS
    MOVLW 0x08
    CPFSEQ COUNTER
    GOTO INCCOUNTER
    CLRF COUNTER
    RETURN
BLINKING
    CALL SETLEDS
    CLRF TICS, 0
    CALL CHECKWAITTICS
    CALL CLRLEDS
    CLRF TICS, 0
    CALL CHECKWAITTICS
    RETURN    
    
ENDGAME
    CLRF BITS, 0
    BCF FLAGS, IDBIT, 0
    RETURN   
CHECKGAME
    INCF BITS, 1, 0
    MOVLW 0x07
    CPFSLT BITS
    CALL ENDGAME
    GOTO AVOIDCHECKIDBIT
INCPROGRESS
    BSF LATC, 4, 0
    BCF LATC, 4, 0
    BCF FLAGS, IDBIT, 0
    BCF FLAGS, ENDBIT, 0
    RETURN     
SETENDBIT
    BSF FLAGS, ENDBIT, 0
    BCF FLAGS, IDBIT, 0
    GOTO AVOIDPROGRESS
CHECKIDVALUE
    MOVLW 0x34 ; 4 -> End RX
    CPFSLT IDVALUE
    GOTO SETENDBIT
    MOVLW 0x33 ; 3 -> Start RX
    CPFSLT IDVALUE
    CALL CLRLEDS
    MOVLW 0x32 ; 2 -> Progress bar
    CPFSLT IDVALUE, 0
    CALL INCPROGRESS
    RETURN
CHECKIDBIT
    BSF FLAGS, IDBIT, 0
    MOVFF TEMP, IDVALUE
    GOTO CHECKIDVALUE
AVOIDPROGRESS
    RETURN   
CHECKBIT
    BTFSC FLAGS, IDBIT, 0
    GOTO CHECKGAME
    CALL CHECKIDBIT
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
    CALL CHECKBIT
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
    CALL INIT_INTERRUPTS
    CALL INIT_TMR0
    CALL INIT_CPU
    CALL INIT_TXRX
    CALL INIT_PORTS

LOOP
    BTFSC FLAGS, ENDBIT, 0
    CALL BLINKING
    CALL CHECKRX
    GOTO LOOP

;*******
;* END *
;*******

    END