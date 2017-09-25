#include <p18f4550.inc> 
    CONFIG WDT=OFF; disable watchdog timer 
    CONFIG MCLRE = ON; MCLEAR Pin on 
    CONFIG DEBUG = ON; Enable Debug Mode 
    CONFIG LVP = OFF; Low-Voltage programming disabled (necessary for debugging) 
    CONFIG FOSC = INTOSCIO_EC; Internal oscillator, port function on RA6 ;count equ 0x00
    org 0;
Start:
    CLRF PORTB; Clear PORTB
    SETF TRISB;	Set TRISB to input
    MOVLW B'11111111';
    MOVWF ADCON1;
    CLRF PORTD;	Clear PORTD
    CLRF TRISD;
     
    
MainLoop:
    BTFSS PORTB,0;
    goto Push_Button_OFF;
    
Push_Button_ON:
    MOVLW B'11111111';
    MOVWF PORTD; 
    goto MainLoop;
    
Push_Button_OFF:
    MOVLW B'00000000';
    MOVWF PORTD;
    goto MainLoop;
 end