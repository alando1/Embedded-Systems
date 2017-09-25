#include <p18f4550.inc>
 CONFIG WDT=OFF ; disable watchdog timer
 CONFIG MCLRE = ON ; MCLEAR Pin on
 CONFIG DEBUG = ON ; Enable Debug Mode
 CONFIG LVP = OFF ; Low-Voltage programming disabled (necessary for debugging)
 ;CONFIG FOSC = INTOSCIO_EC ; Internal oscillator, port function on RA6 ;count equ 0x00
 CONFIG FOSC = HS;External oscillator, port function on RA6
 org 0;
Start:
 CLRF PORTB ;Clear PORTB
 SETF TRISB ;Set TRISB to input
 MOVLW B'11111111'
 MOVWF ADCON1
 CLRF PORTD ;Clear PORTD
 CLRF TRISD ;Set PORTD to output

MainLoop:
 BTFSS PORTB,0 ;Test bit if set, skip next instruction if not
 goto Push_Button_OFF

Push_Button_ON:
 MOVLW B'11111111' ;Move literal ‘11111111’ to working register
 MOVWF PORTD ;Move contents of working register to port D
 goto MainLoop

Push_Button_OFF:
 MOVLW B'00000000' ;Move literal ‘00000000’ to working register
 MOVWF PORTD ;Move contents of working register to to port D
 goto MainLoop
 end