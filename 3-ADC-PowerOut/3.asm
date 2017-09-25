#include <p18f4550.inc>
 CONFIG WDT=OFF	    ; disable watchdog timer
 CONFIG MCLRE = ON  ; MCLEAR Pin on
 CONFIG DEBUG = OFF  ; disable Debug Mode
 CONFIG LVP = OFF   ; Low-Voltage programming disabled (necessary for debugging)
 CONFIG FOSC = INTOSCIO_EC   ;External oscillator, port function on RA6
 org 0		    ;
 
DIGIT1 EQU D'1'
DIGIT2 EQU D'2' 
RESULT EQU D'3'
COUNTER EQU D'4'    ;counter variable  1
 
    
    MOVLW D'255'	    ;Move decimal value of 255 to Working register
    MOVWF COUNTER	    ;Move value of working register to counter address
  
    BSF PORTA, 1
    BCF TRISA, 1
    
    CLRF PORTD	    ;clear port D bits
    CLRF TRISD	    ;setup port D as output

    CLRF TRISB		;set port B as output pins
    MOVLW B'00000001'   ;set all bits to 0 but RB0 
    MOVWF PORTB
    
    MOVLW B'00000000'	;bits 5-2 select channel AN0
    MOVWF ADCON0
    
    MOVLW B'00001110'	;set pin AN0 for analog input
    MOVWF ADCON1	
    
    MOVLW B'00001000'	;bits 5-3 16 TAD aquisition time, bits 2-0 Fosc/2 conversion clock select bits
    MOVWF ADCON2
    
    
    BSF ADCON0, ADON	;set bit 0 to enable analog digital conversion to be on
    
MainLoop:
    BSF ADCON0, GO_DONE

TEST:
    BTFSC ADCON0, 1	;bit test go/notdone, skip if clear
    BRA TEST		;branch to test
    
    
    MOVF ADRESH, 0	;send high byte of result to wreg
    MOVFF ADRESH, RESULT
    
    ANDLW B'00001111'	;AND low nibble of byte to wreg 
    
    CALL LookUp
    MOVWF DIGIT1
    
    RRNCF RESULT, 1
    RRNCF RESULT, 1
    RRNCF RESULT, 1
    RRNCF RESULT, 1
    MOVF RESULT, 0
    
    ANDLW B'00001111'
    CALL LookUp
    MOVWF DIGIT2
    
    BTFSS PORTB, 0
    BRA ShowDigit2
    
ShowDigit1:

    MOVFF DIGIT2, PORTD
    CALL TOGGLE
    CALL DELAY
    GOTO SwitchLoad

ShowDigit2:
    
    MOVFF DIGIT1, PORTD
    CALL TOGGLE
    CALL DELAY

SwitchLoad:
    MOVLW 0x9F
    MOVFF ADRESH, RESULT
    CPFSLT RESULT
    BRA SwitchOn
    BSF PORTA, 1
    GOTO MainLoop
    
SwitchOn:
    BCF PORTA, 1
    GOTO MainLoop
    
TOGGLE:
    BTG PORTB, 0
    BTG PORTB, 1
    RETURN
    
DELAY:
    DECFSZ COUNTER
    BRA DELAY
    
    MOVLW D'255'	;resets counter to 255
    MOVWF COUNTER
    RETURN

LookUp:
    MULLW 2
    MOVF PRODL, 0	    ;Move low byte of product of mult to wreg
    ADDWF PCL, 1	    ;Add low byte of program counter to wreg
    RETLW B'00111111'	    ;0
    RETLW B'00000110'	    ;1
    RETLW B'01011011'	    ;2
    RETLW B'01001111'	    ;3
    RETLW B'01100110'	    ;4
    RETLW B'01101101'	    ;5
    RETLW B'01111101'	    ;6
    RETLW B'00000111'	    ;7
    RETLW B'01111111'	    ;8
    RETLW B'01100111'	    ;9
    RETLW B'01110111'	    ;A
    RETLW B'01111100'	    ;B
    RETLW B'00111001'	    ;C
    RETLW B'01011110'	    ;D
    RETLW B'01111001'	    ;E
    RETLW B'01110001'	    ;F
 end