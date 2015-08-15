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
IDBIT EQU 0x00
ENDBIT5HZ EQU 0x01
ENDBIT10HZ EQU 0x02
    
TEMP EQU 0x01
BITS EQU 0x02
IDVALUE EQU 0x03
TICS EQU 0x04
COUNTER EQU 0x05
RAMADDRL EQU 0x06
RAMADDRH EQU 0x07
RAMDATA EQU 0x08
ADDRCOUNTERL EQU 0x09
ADDRCOUNTERH EQU 0x0A
VALUECOUNTER EQU 0x0B
IRDATA EQU 0x0C
IRTEMP EQU 0x0D
IRBITCOUNTER EQU 0x0E
 
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
    ; A0..A7 Output
    CLRF TRISA, 0
    ; A8..A11 Output
    BCF TRISB, 0, 0
    BCF TRISB, 1, 0
    BCF TRISB, 2, 0
    BCF TRISB, 3, 0
    ; A12..A14 Output
    BCF TRISC, 0, 0
    BCF TRISC, 1, 0
    BCF TRISC, 2, 0
    
    ; WE, OE, CS
    BCF TRISE, 0, 0
    BCF TRISE, 1, 0
    BCF TRISE, 2, 0
    
    ; IR TX/RX
    BSF TRISB, 4, 0
    BCF TRISB, 5, 0
        
    ; MCLR Progressbar Output
    BCF TRISC, 3, 0
    BCF LATC, 3, 0
    BSF LATC, 3, 0
    
    ; Progressbar Output
    BCF TRISC, 4, 0
    BCF LATC, 4, 0
    
    ; EUSART TX/RX
    BCF TRISC, 6, 0
    BSF TRISC, 7, 0
    
    ; Test Output
    BCF TRISC, 5, 0
    BCF LATC, 5, 0
    
    ; Clear Variables
    CLRF FLAGS
    CLRF IDBIT
    CLRF TEMP
    CLRF BITS
    CLRF IDVALUE
    CLRF TICS
    CLRF COUNTER
    CLRF RAMADDRL
    CLRF RAMADDRH
    CLRF RAMDATA
    CLRF ADDRCOUNTERL
    CLRF VALUECOUNTER
    CLRF IRBITCOUNTER
    
    RETURN
    
;******************
;* TEST FUNCTIONS *
;******************

TEST
    BSF LATC, 5, 0
    BCF LATC, 5, 0
    RETURN
    
WHILE1
    GOTO WHILE1   
;*************
;* FUNCTIONS *
;*************

;****************
;* LED HANDLERS *
;****************

INCLED
    BSF LATC, 4, 0
    BCF LATC, 4, 0
    BCF FLAGS, IDBIT, 0
    RETURN
CLRLEDS
    BCF LATC, 3, 0
    BSF LATC, 3, 0
    RETURN
INCCOUNTER
    CALL INCLED
    INCF COUNTER, 1, 0
SETLEDS
    MOVLW 0x08
    CPFSEQ COUNTER
    GOTO INCCOUNTER
    CLRF COUNTER
    RETURN

;*********************
;* BLINKING HANDLERS *
;*********************

CHECKWAITTICS10HZ
    CALL CHECKRX
    BTFSS FLAGS, ENDBIT10HZ, 0
    RETURN
    MOVLW 0x32 ; 50ms
    CPFSEQ TICS
    GOTO CHECKWAITTICS10HZ
    RETURN
BLINKING10HZ
    CALL SETLEDS
    CLRF TICS, 0
    CALL CHECKWAITTICS10HZ
    CALL CLRLEDS
    CLRF TICS, 0
    CALL CHECKWAITTICS10HZ
    RETURN
CHECKWAITTICS5HZ
    CALL CHECKRX
    BTFSS FLAGS, ENDBIT5HZ, 0
    RETURN
    MOVLW 0x63 ; 100ms
    CPFSEQ TICS
    GOTO CHECKWAITTICS5HZ
    RETURN
BLINKING5HZ
    CALL SETLEDS
    CLRF TICS, 0
    CALL CHECKWAITTICS5HZ
    CALL CLRLEDS
    CLRF TICS, 0
    CALL CHECKWAITTICS5HZ
    RETURN
CHECKBLINKING
    BTFSC FLAGS, ENDBIT5HZ, 0
    CALL BLINKING5HZ
    BTFSC FLAGS, ENDBIT10HZ, 0
    CALL BLINKING10HZ
    RETURN
    
;***************
;* IR HANDLERS *
;***************
    
;WAITTIMEMODULATION
;    MOVLW 0x65
;DECTIMEMODULATION
;    DECF WREG, 1
;    BTFSS STATUS, Z, 0
;    GOTO DECTIMEMODULATION
;    RETURN
;    
;MODULATEDOWN
;    BCF LATB, 5, 0
;    CALL WAITTIMEMODULATION
;    CALL WAITTIMEMODULATION
;    GOTO CHECKMODULATIONENDUP
;    
;MODULATEUP
;    BSF LATB, 5, 0
;    CALL WAITTIMEMODULATION
;    BCF LATB, 5, 0
;    CALL WAITTIMEMODULATION
;    GOTO CHECKMODULATIONENDUP
;    
;WAITMODULATIONDOWN
;    CLRF TICS, 0
;CHECKMODULATIONENDDOWN
;    MOVLW 0x01
;    CPFSEQ TICS, 0
;    CALL MODULATEDOWN
;    GOTO ENDMODULATION
;     
;WAITMODULATIONUP
;    CLRF TICS, 0
;CHECKMODULATIONENDUP
;    MOVLW 0x01
;    CPFSEQ TICS, 0
;    GOTO MODULATEUP
;    GOTO ENDMODULATION
;    
;MODULATEVALUE
;    MOVWF 0x01
;    CPFSEQ IRTEMP, 0
;    GOTO WAITMODULATIONDOWN
;    GOTO WAITMODULATIONUP
;ENDMODULATION
;    RETURN
;    
;CHECKMODULATEVALUE
;    CLRF IRBITCOUNTER, 0
;    MOVLW 0x00
;    MOVWF IRDATA, 0
;    ;MOVFF RAMDATA, IRDATA
;CHECKMODULATEBIT
;    MOVLW 0x01
;    ANDWF IRDATA, 0, 0
;    MOVFF WREG, IRTEMP
;    CALL MODULATEVALUE
;    RRNCF IRDATA, 0, 0
;    INCF IRBITCOUNTER, 1, 0
;    MOVLW 0x07
;    CPFSEQ IRBITCOUNTER
;    GOTO CHECKMODULATEBIT
;    RETURN
    
MODULATEUP
    BSF LATC, 5, 0
    CLRF TICS, 0
WAITMODULATEUP
    MOVLW 0x01
    CPFSEQ TICS, 0
    GOTO WAITMODULATEUP
    BCF LATC, 5, 0
    RETURN
    
MODULATEDOWN
    BCF LATC, 5, 0
    CLRF TICS, 0
WAITMODULATEDOWN
    MOVLW 0x01
    CPFSEQ TICS, 0
    GOTO WAITMODULATEDOWN
    BCF LATC, 5, 0
    RETURN
    
INCIRBIT
    INCF IRBITCOUNTER, 1, 0
    RRNCF IRDATA, 1, 0
MODULATEDATA
    MOVLW 0x01
    ANDWF IRDATA, 0, 0
    MOVWF IRTEMP
    MOVLW 0x00
    CPFSEQ IRTEMP, 0
    CALL MODULATEUP
    CALL MODULATEDOWN
    MOVLW 0x06
    CPFSEQ IRBITCOUNTER, 0
    GOTO INCIRBIT
    CLRF IRBITCOUNTER, 0
    RETURN
    
SENDIR
    CALL CLRRAMADDR
    CLRF VALUECOUNTER, 0
    CALL SENDVALUE
    GOTO SETENDBIT10HZ
    
;****************
;* RAM HANDLERS *
;****************

CLRRAMADDR
    CLRF RAMADDRL
    CLRF RAMADDRH
    CLRF RAMDATA
    RETURN
INCRAMADDR
    INFSNZ RAMADDRL, 1, 0
    INCF RAMADDRH, 1, 0
    RETURN
SETRAMADDRH
    BCF LATB, 0, 0
    BCF LATB, 1, 0
    BCF LATB, 2, 0
    BCF LATB, 3, 0
    BCF LATC, 0, 0
    BCF LATC, 1, 0
    BCF LATC, 2, 0
    RETURN
SETRAMADDRL
    MOVFF RAMADDRL, LATA
    RETURN
SETRAMDATA
    MOVFF TEMP, RAMDATA
    MOVLW 0x0F
    ANDWF RAMDATA, 1, 0
    MOVFF RAMDATA, LATD
    RETURN
GETRAMDATA
    MOVFF PORTD, RAMDATA
    MOVFF RAMDATA, IRDATA
    BSF LATE, 2, 0 ; CS = 1
    RETURN
WRITERAM
    CLRF TRISD, 0
    BCF LATE, 0, 0 ; WE = 0
    BCF LATE, 1, 0 ; OE = 0
    BCF LATE, 2, 0 ; CS = 0
    NOP
    BSF LATE, 2, 0 ; CS = 1
    BSF LATE, 0, 0 ; WE = 1
    INCF ADDRCOUNTERL, 1, 0
    RETURN
READRAM
    SETF TRISD, 0
    BSF LATE, 0, 0 ; WE = 1
    BCF LATE, 1, 0 ; OE = 0
    BCF LATE, 2, 0 ; CS = 0
    INCF VALUECOUNTER, 1, 0
    RETURN 
WRITEVALUE
    CALL SETRAMADDRH
    CALL SETRAMADDRL
    CALL SETRAMDATA
    CALL WRITERAM
    CALL INCRAMADDR
    RETURN
SAVEVALUE
    CALL WRITEVALUE
    GOTO AVOIDCHECKIDBIT
    
READVALUE
    CALL SETRAMADDRH
    CALL SETRAMADDRL
    CALL READRAM
    CALL GETRAMDATA
    CALL MODULATEDATA
    CALL INCRAMADDR
SENDVALUE
    MOVF ADDRCOUNTERL, 0
    CPFSEQ VALUECOUNTER
    GOTO READVALUE
    RETURN
;*******************
;* EUSART HANDLERS *
;*******************

ENDGAME
    CLRF BITS, 0
    BCF FLAGS, IDBIT, 0
    GOTO AVOIDCHECKIDBIT
CHECKGAME
    INCF BITS, 1, 0
    MOVLW 0x08
    CPFSLT BITS
    GOTO ENDGAME
    GOTO SAVEVALUE 
INCPROGRESS
    CALL INCLED
    BCF FLAGS, ENDBIT5HZ, 0
    BCF FLAGS, ENDBIT10HZ, 0
    RETURN     
SETENDBIT10HZ
    CALL CLRLEDS
    BSF FLAGS, ENDBIT10HZ, 0
    BCF FLAGS, ENDBIT5HZ, 0
    BCF FLAGS, IDBIT, 0
    GOTO AVOIDPROGRESS
SETENDBIT5HZ
    CALL CLRLEDS
    BSF FLAGS, ENDBIT5HZ, 0
    BCF FLAGS, ENDBIT10HZ, 0
    BCF FLAGS, IDBIT, 0
    GOTO AVOIDPROGRESS
CHECKIDVALUE
    MOVLW 0x34 ; 4 -> IR
    CPFSLT IDVALUE, 0
    GOTO SENDIR
    MOVLW 0x33 ; 3 -> End RX
    CPFSLT IDVALUE
    GOTO SETENDBIT5HZ
    MOVLW 0x32 ; 2 -> Start RX
    CPFSLT IDVALUE
    CALL CLRLEDS
    MOVLW 0x31 ; 1 -> Progress bar
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
    ;MOVF TEMP, 0
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
    CALL CHECKRX
    CALL CHECKBLINKING
    GOTO LOOP

;*******
;* END *
;*******

    END