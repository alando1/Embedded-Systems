#include <p18f4550.inc>
 CONFIG WDT=OFF	    ; disable watchdog timer
 CONFIG MCLRE = ON  ; MCLEAR Pin on
 CONFIG DEBUG = OFF  ; disable Debug Mode
 CONFIG LVP = OFF   ; Low-Voltage programming disabled (necessary for debugging)
 CONFIG FOSC = INTOSCIO_EC   ;External oscillator, port function on RA6
 ORG 0	
 
ButtonRow EQU D'1'
ButtonCol EQU D'2'
COLS EQU D'3'
FOUR EQU D'4'
EIGHT EQU D'5'
TWELVE EQU D'6'
COUNT1 EQU D'7'
COUNT2 EQU D'8'
TEMP EQU D'9'
THRESH EQU D'10'
VALUE EQU D'11'

    
    MOVLW 0x0A
    MOVWF THRESH
    
    CLRF COUNT1
    CLRF COUNT2
    CLRF COLS
    CLRF ButtonRow
    CLRF ButtonCol
    CLRF FOUR
    CLRF EIGHT
    CLRF TWELVE
    
    MOVLW b'00001011'
    MOVWF FOUR
    MOVLW b'00001101'
    MOVWF EIGHT
    MOVLW b'00001110'
    MOVWF TWELVE
    
    CLRF PORTB	    
    MOVLW H'F0'	    ;set PORTB 7-4 pins as inputs
    MOVWF TRISB	    
    
    MOVLW B'00001111'
    MOVWF ADCON1    ;initialize A0, A1 to be digital
    
    CLRF PORTA
    CLRF TRISA
    BSF PORTA, 3    ;PIN TO RELAY
    
    CLRF PORTD	    ;CLEAR output pins to LCD
    CLRF TRISD    ;set PORTD as output
    
    CALL DELAY
    MOVLW 0x38
    CALL CMDWRT
    MOVLW 0x0C
    CALL CMDWRT
    MOVLW 0x01
    CALL CMDWRT
    MOVLW 0x06
    CALL CMDWRT
    MOVLW 0x80
    CALL CMDWRT

MainLoop:
    MOVLW 0x80
    CALL CMDWRT
    
CheckPad:
    MOVFF PORTB, COLS	    ;Move PORTB bits to COLS
    CALL MASK		    ;MASK bits 0-3
    
    MOVLW B'00001111'
    CPFSEQ COLS 	    ;Skip next instruction if COLS = WREG
    GOTO ButtonDown
    BRA MainLoop

MASK:
    RRNCF COLS, 1	;Right Bit Shift 4times
    RRNCF COLS, 1
    RRNCF COLS, 1
    RRNCF COLS, 1
    MOVF COLS, 0
    ANDLW B'00001111'	;mask row bits
    MOVWF COLS		;move column bits into COLS
    RETURN

ButtonDown:
    
    MOVFF COLS, ButtonCol
    MOVLW B'00000000'
    MOVWF ButtonRow
    BCF LATB, LATB0
    BSF LATB, LATB1
    BSF LATB, LATB2
    BSF LATB, LATB3
    MOVFF PORTB, COLS
    CALL MASK
    MOVLW B'1111'
    CPFSEQ COLS		;SKIP Next instruction if COLS = WREG
    GOTO GETNUMBER		;GOTO GETNUMBER, row 1 button pressed
    
    MOVLW B'00000001'
    MOVWF ButtonRow
    BSF LATB, LATB0
    BCF LATB, LATB1
    BSF LATB, LATB2
    BSF LATB, LATB3
    MOVFF PORTB, COLS
    CALL MASK
    MOVLW B'1111'
    CPFSEQ COLS
    GOTO GETNUMBER
    
    MOVLW B'00000010'
    MOVWF ButtonRow
    BSF LATB, LATB0
    BSF LATB, LATB1
    BCF LATB, LATB2
    BSF LATB, LATB3
    MOVFF PORTB, COLS
    CALL MASK
    MOVLW B'1111'
    CPFSEQ COLS
    GOTO GETNUMBER
    
    MOVLW B'00000011'
    MOVWF ButtonRow
    BSF LATB, LATB0
    BSF LATB, LATB1
    BSF LATB, LATB2
    BCF LATB, LATB3
    MOVFF PORTB, COLS
    CALL MASK
    MOVLW B'1111'
    CPFSEQ COLS
    GOTO GETNUMBER
    GOTO MainLoop

GETNUMBER:
    MOVF ButtonCol, 0
    CPFSEQ FOUR
    GOTO CPEIGHT
;    MOVLW A'4'
;    CALL DATAWRT
    MOVLW B'00000100'
    GOTO CR
    
CPEIGHT:
    CPFSEQ EIGHT
    GOTO CPTWELVE
;    MOVLW A'8'
;    CALL DATAWRT
    MOVLW B'00001000'
    GOTO CR
    
CPTWELVE:
    CPFSEQ TWELVE
    GOTO ZERO
;    MOVLW A'C'
;    CALL DATAWRT
    MOVLW B'00001100'
    GOTO CR
    
ZERO:
;    MOVLW A'0'
;    CALL DATAWRT
    MOVLW B'00000000'
    
CR: 
    ADDWF ButtonRow, 0
    ;CALL LookUpAscii
    ;CALL HexToASCII
    ;MOVLW a'z'
    ;ADDLW '0'
    ;CALL DATAWRT
    MOVWF VALUE
       
    ; print
    CALL GetDigit
    CALL DATAWRT
    
    ; convert
    CALL ConvertDigit
    MOVWF VALUE
    
    ; comparison
    MOVF THRESH, 0
    CPFSGT VALUE
    GOTO SwitchOff

SwitchOn:
    BCF PORTA, 3
    GOTO FinishLoop
    
SwitchOff:
    BSF PORTA, 3
    
FinishLoop:
    
    BCF PORTB, 0
    BCF PORTB, 1
    BCF PORTB, 2
    BCF PORTB, 3
    
    CALL DELAY
    GOTO MainLoop
    
    
    
ConvertDigit:
    MOVWF TEMP
    MOVLW ':'
    CPFSLT TEMP
    GOTO ConvertLetter

ConvertNumber:
    MOVLW '0'
    SUBWF TEMP, 1
    GOTO ConversionDone    
    
ConvertLetter:
    MOVLW 'A'
    SUBWF TEMP, 1
    MOVLW 0x0A
    ADDWF TEMP, 1
    
ConversionDone:
    MOVF TEMP, 0
    RETURN    
    
    
   
CMDWRT:
    MOVWF PORTD
    BCF PORTA, 1;CLEAR RS   connected to A1 pin
    BCF PORTA, 2;R/W 0 FOR WRITE
    BSF PORTA, 0;SET ENABLE connected on A0 pin
    CALL DELAY	;DELAY
    BCF PORTA, 0;CLEAR ENABLE 
    CALL DELAY
    RETURN
    
DATAWRT:
    MOVWF PORTD
    BSF PORTA, 1;SET RS
    BCF PORTA, 2;R/W 0 FOR WRITE
    BSF PORTA, 0;SET ENABLE 
    CALL DELAY	;DELAY
    BCF PORTA, 0;CLEAR ENABLE
    CALL DELAY
    RETURN
    
GetDigit:
    MOVWF TEMP

    MOVLW 0
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'A'
    GOTO DigitDone
    
    MOVLW 1
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'B'
    GOTO DigitDone
    
    MOVLW 2
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'C'
    GOTO DigitDone
    
    MOVLW 3
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'D'
    GOTO DigitDone
    
    MOVLW 4
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'3'
    GOTO DigitDone
    
    MOVLW 5
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'6'
    GOTO DigitDone
    
    MOVLW 6
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'9'
    GOTO DigitDone
    
    MOVLW 7
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'E'
    GOTO DigitDone
    
    MOVLW 8
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'2'
    GOTO DigitDone
    
    MOVLW 9
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'5'
    GOTO DigitDone
    
    MOVLW 0x0A
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'8'
    GOTO DigitDone
    
    MOVLW 0x0B
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'0'
    GOTO DigitDone
    
    MOVLW 0x0C
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'1'
    GOTO DigitDone
    
    MOVLW 0x0D
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'4'
    GOTO DigitDone
    
    MOVLW 0x0E
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'7'
    GOTO DigitDone
    
    MOVLW 0x0F
    CPFSEQ TEMP
    BRA $+6
    MOVLW a'F'    
    
DigitDone:
    RETURN  
    
LookUpAscii:
    MULLW 2
    MOVF PRODL, 0	    ;Move low byte of product of mult to wreg
    ADDWF PCL, 1	    ; Add low byte of program counter to wreg
    RETLW a'1'	    ;	    1
    RETLW a'2'	    ;	    2
    RETLW a'3'	    ;	    3
    RETLW a'A'	    ;	    A
    RETLW a'4'	    ;	    4
    RETLW a'5'	    ;	    5
    RETLW a'6'	    ;	    6
    RETLW a'B'	    ;	    B
    RETLW a'7'	    ;	    7
    RETLW a'8'	    ;	    8
    RETLW a'9'	    ;	    9
    RETLW a'C'	    ;	    C
    RETLW a'*'	    ;	    *
    RETLW a'0'	    ;	    0
    RETLW a'#'	    ;	    #
    RETLW a'D'	    ;	    D
    
DELAY:
    DECFSZ COUNT1
    BRA DELAY
	
    ;DECFSZ COUNT2
    ;BRA DELAY
    RETURN
 end