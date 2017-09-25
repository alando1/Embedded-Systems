#include <xc.h>
#include "final.h"
#include "string.h"

typedef unsigned char byte;            

void commandLCD(byte val)
{
    PORTD = val; 
    PORTAbits.RA0 = 0; // RS = 0
    PORTAbits.RA1 = 0; // RW = 0
    PORTAbits.RA2 = 1; //  E = 1 
    __delay_ms(1);
    PORTAbits.RA2 = 0; //  E = 0
    __delay_ms(1);
}

void writeLCD(byte val)
{
    PORTD = val; 
    PORTAbits.RA0 = 1; // RS = 1
    PORTAbits.RA1 = 0; // RW = 0
    PORTAbits.RA2 = 1; //  E = 1 
    __delay_ms(1);
    PORTAbits.RA2 = 0; //  E = 0
    __delay_ms(1);
}

byte Lookup(byte look)
{
    switch(look)
    {
        case 0: return('1');
        case 1: return('2');
        case 2: return('3');
        case 3: return('A');
        case 4: return('4');
        case 5: return('5');
        case 6: return('6');
        case 7: return('B');
        case 8: return('7');
        case 9: return('8');
        case 10: return('9');
        case 11: return('C');
        case 12: return('*');
        case 13: return('0');
        case 14: return('#');
        case 15: return('D');      
        default: return('!');
          
    }
}

int asciiToInt(byte asc)
{
    return (int)(asc - 48);
}

void printString(byte* s)
{
    byte* p = s;
    
    while (*p != 0)
    {
        writeLCD(*p);
        p++;
    }
}

void printStringAt(byte* s, byte row, byte col)
{
    byte address = 0x40 * row + col;
    commandLCD(0x80 + address);
    printString(s);
}

void printCharAt(byte c, byte row, byte col)
{
    byte address = 0x40 * row + col;
    commandLCD(0x80 + address);
    writeLCD(c);
}
void printIntAt(int i, byte row, byte col)
{
    byte address = 0x40 * row + col;
    commandLCD(0x80 + address);
    writeLCD(i+'0');
}

void byteToBinary(byte* b, byte val)
{
    byte temp = val;
    byte rem;
    byte j = 7;
    
    // clear string
    for (byte i = 0; i < 8; ++i)
        b[i] = '0';
    b[8] = 0;     
            
    while (temp != 0)
    {
        rem = temp % 2;
        b[j] = rem + '0';
        temp /= 2;
        j--;
    }        
}

int getDecimalNumber(byte* in)
{
    int i = 0;
    while(in[i] != 0)
        i++;
    
    int result;
    if(i == 1)
        result = asciiToInt(in[0]);
    else if(i == 2)
    {
        int d1, d2;
        
        d1 = asciiToInt(in[0]);
        d2 = asciiToInt(in[1]);
        d1 *= 10;
        result = d1 + d2;
    }
    else
    {
        int d1, d2, d3;
        d1 = asciiToInt(in[0]);
        d2 = asciiToInt(in[1]);
        d3 = asciiToInt(in[2]);
        d2 *= 10;
        d1 *= 100;
        result = d1 + d2 + d3;
    }
    return result;
    
    
}

byte hexToAscii(byte n)
{
    switch (n)
    {
        case 0: return '0';
        case 1: return '1';
        case 2: return '2';
        case 3: return '3';
        case 4: return '4';
        case 5: return '5';
        case 6: return '6';
        case 7: return '7';
        case 8: return '8';
        case 9: return '9';
        case 10: return 'A';
        case 11: return 'B';
        case 12: return 'C';
        case 13: return 'D';
        case 14: return 'E';
        case 15: return 'F';
        default: return '!';
    }
}

void printBase(int b)
{
    switch(b)
    {
            case 2: printCharAt('2', 0, 12); break;
            case 3: printCharAt('3', 0, 12); break;
            case 4: printCharAt('4', 0, 12); break;
            case 5: printCharAt('5', 0, 12); break;
            case 6: printCharAt('6', 0, 12); break;
            case 7: printCharAt('7', 0, 12); break;
            case 8: printCharAt('8', 0, 12); break;
            case 9: printCharAt('9', 0, 12); break;
            case 10: printCharAt('1', 0, 12); printCharAt('0', 0, 13); break;
            case 11: printCharAt('1', 0, 12); printCharAt('1', 0, 13); break;
            case 12: printCharAt('1', 0, 12); printCharAt('2', 0, 13); break;
            case 13: printCharAt('1', 0, 12); printCharAt('3', 0, 13); break;
            case 14: printCharAt('1', 0, 12); printCharAt('4', 0, 13); break;
            case 15: printCharAt('1', 0, 12); printCharAt('5', 0, 13); break;
            case 16: printCharAt('1', 0, 12); printCharAt('6', 0, 13); break;
            default: return;
    }
    
    writeLCD(':');
            
}

void convert(int n, byte b, byte* buff)
{
    int q;
    byte r, i, j;
    
    byte notSoBuff[11];
    memset(notSoBuff, 0, sizeof(notSoBuff));
    
    q = n; 
    i = 10;
    
    if (q == 0)
        buff[0] = '0';
    else
    {
        while(q != 0)
        {
            //r = (byte)(q % b) + '0';
            r = hexToAscii((byte)(q % b));
            q /= b; 
            buff[i] = r;
            i--;
        }
 
        i = 0;
        while(buff[i] == 0)
            i++;
        
        j = 0;
        while(buff[i] != 0)
        {
            notSoBuff[j]= buff[i];
            i++;
            j++;
        }
        notSoBuff[j] = 0;
        
        for(i = 0; i < 11; i++)
            buff[i] = notSoBuff[i];
        
    }
}

byte buttonMath(byte r, byte port)
{
    byte col;
    if(port == 0b01110000)     //0111
        col = 3;
    else if(port == 0b10110000)//1011
        col = 2;
    else if(port == 0b11010000)//1101
        col = 1;
    else if(port == 0b11100000)//1110
        col = 0;

    byte result;
    result = (byte)(r*4 + col);
    result = Lookup(result);
    
    PORTB &= 0xF0;
    
    return result;
}



byte handleInput()
{           
    //HANDLE BUTTON DOWN CASE
    byte row, temp2;
    row = 0x00;

    PORTBbits.RB0 = 0;
    PORTBbits.RB1 = 1;
    PORTBbits.RB2 = 1;
    PORTBbits.RB3 = 1;
    temp2 = (byte)(PORTB & 0xF0); // shift upper 4 bits down and mask

    if(temp2 != 0xF0)
        return buttonMath(row, temp2);

    row = 0x01;
    PORTBbits.RB0 = 1;
    PORTBbits.RB1 = 0;
    PORTBbits.RB2 = 1;
    PORTBbits.RB3 = 1;
    temp2 = (byte)(PORTB & 0xF0); // shift upper 4 bits down and mask

    if(temp2 != 0xF0)
        return buttonMath(row, temp2);

    row = 0x02;
    PORTBbits.RB0 = 1;
    PORTBbits.RB1 = 1;
    PORTBbits.RB2 = 0;
    PORTBbits.RB3 = 1;
    temp2 = (byte)(PORTB & 0xF0); // shift upper 4 bits down and mask

    if(temp2 != 0xF0)
        return buttonMath(row, temp2);

    row = 0x03;
    PORTBbits.RB0 = 1;
    PORTBbits.RB1 = 1;
    PORTBbits.RB2 = 1;
    PORTBbits.RB3 = 0;
    temp2 = (byte)(PORTB & 0xF0); // shift upper 4 bits down and mask

   if(temp2 != 0xF0)
        return buttonMath(row, temp2);
    else
    return '?';
    

}
void main() 
{ 
    PORTB = 0x00;
    TRISB = 0xF0;
    ADCON1 = 0x0F;      //Initialize A0, A1, A2 for digital
    
    PORTA = 0x00;
    TRISA = 0x00;
    
    PORTD = 0x00;
    TRISD = 0x00;
    
    commandLCD(56);
    commandLCD(12);
    commandLCD(1);
    commandLCD(6);
    commandLCD(128);
    
    printStringAt("Enter A Number,", 0, 0);
    printStringAt("# converts base", 1, 0);
    
    byte digitsIn[4];
    byte digitPtr = 0;
    digitsIn[0] = 0;
    digitsIn[1] = 0;
    digitsIn[2] = 0;
    digitsIn[3] = 0;
    
    byte baseDigits[3];
    memset(baseDigits, 0, sizeof(baseDigits));
    
    byte digitsOut[11];
    memset(digitsOut, 0, sizeof(digitsOut));
    int base = 1;
    
    while(1)
    {
        byte key;
        if(PORTB != 0xF0)
        {
            //commandLCD(01);
            key = handleInput();
            
            while(PORTB != 0xF0)
                __delay_ms(10);
            
            commandLCD(0x01);
            if (key >= '0' && key <= '9' && digitPtr < 3)
            {
                digitsIn[digitPtr] = key;
                digitPtr++;
            }
            else if(key == 'A' || key == 'B' || key == 'C' || key == 'D' || key == '*')
            {
                printStringAt("Invalid input", 0, 0);
                continue;
            }
            else if(key == '#')
            {
                base++;
                    
                if(base > 16)
                    base = 2;
                
                printStringAt("in Base ", 0, 4);
                printBase(base);
                
                memset(baseDigits, 0, sizeof(baseDigits));
                memset(digitsOut, 0, sizeof(digitsOut));
                
                int result = getDecimalNumber(digitsIn);
                convert(result, base, digitsOut);
                printStringAt(digitsOut, 1, 5);
            }
           
            printStringAt(digitsIn, 0, 0); 
                        
        }
    }
    return;
}