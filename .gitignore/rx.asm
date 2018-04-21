; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

#include "p16f887.inc"

; CONFIG1
; __config 0xE0F5
 __CONFIG _CONFIG1, _FOSC_INTRC_CLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF 
 
 
 
;*******************************************************************************
; VARIABLES                                                                    ;
;*******************************************************************************

   GPR_VAR        UDATA
  
   SERVO1       RES        1      ; VALOR DE LA CONVERSION ADC DEL PUERTO A0 
   SERVO2       RES	   1      ; VALOR DE LA CONVERSION ADC DEL PUERTO A1 
   ESTADO       RES        1      ; VARIABLE DE CAMBIO DE ESTADO
   CONTADOR     RES        1  
   MARCADOR     RES        1
   PWM		RES        1
   STATUST	RES        1
   VTEMP        RES        1
   DATOS        RES        1
;*******************************************************************************
; RESET VECTOR                                                                 ;
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    SETUP                   ; go to beginning of programA
;*******************************************************************************
; INTERRUPCIONES                                                               ;
;******************************************************************************* 
    
ISR       CODE    0x0004           ; interrupt vector location
    GOTO INT    
     RETFIE    

;*******************************************************************************
; MAIN PROGRAM                                                                 ;
;*******************************************************************************   
     
MAIN_PROG CODE                      ; let linker place main program
 
SETUP
    ;CAMBIAMOS DE BANCO
    ;BANCO 1
    BCF STATUS, RP1
    BSF STATUS, RP0 
    ;CONFIGURAMOS EL OSCILADOR INTERNO (500kHz)
    BSF OSCCON, SCS
    BCF OSCCON, OSTS 
    BSF OSCCON, HTS 
    BSF OSCCON, IRCF0
    BSF OSCCON, IRCF1
    BCF OSCCON, IRCF2 
    ;CONFIGURACION DEL REGISTRO ADCON1
    BCF ADCON1,ADFM	;DEFINIMOS JUSTIFICACION A LA IZQUIERDA
    BCF ADCON1,VCFG1
    BCF ADCON1,VCFG0
    ; PUERTO D COMO SALIDA
    CLRF TRISD
    CLRF TRISC
    CLRF TRISE
    ;PUERTOS DE ENTRADA
    BSF TRISA,RA0
    BSF TRISA,RA1	;RA0 Y RA1 DEL PUERTO A COMO ENTRADA.
    BSF TRISB,RB0	
    BSF TRISB,RB1	;RB0 Y RB1 DEL PUERTO B COMO ENTRADA.
    ;CONFIGURACION DEL REGISTRO OPTION_REG
    BCF OPTION_REG, T0CS 
    BSF OPTION_REG, T0SE 
    BCF OPTION_REG, PSA  
    BCF OPTION_REG, PS2
    BCF OPTION_REG, PS1
    BSF OPTION_REG, PS0 
    ;CONFIGURANDO EL REGISTRO TXSTA (BR=300)
    BCF TXSTA, SYNC
    BCF TXSTA, BRGH
    CLRF SPBRG 
    MOVLW .25
    MOVWF SPBRG
    BSF STATUS, RP1
   ;CAMBIAMOS DE BANCO
    ;BANCO 3
    BSF STATUS,RP0
    BSF STATUS,RP1
    ;CONFIGURAMOS EL REGISTRO ANSEL
    CLRF ANSEL		;QUEREMOS PUERTOS DIGITALES
    CLRF ANSELH		
    BSF ANSEL,ANS0	;EL PUERTO RA0 DE PORTA, SE UTILIZARÁ COMO ANÁLOGO
    BSF ANSEL,ANS1  	;EL PUERTO RA1 DE PORTA, SE UTILIZARÁ COMO ANÁLOGO
    ;CONFIGURANDO BAUDCTL
    BCF BAUDCTL, BRG16  
    ;CAMBIAMOS DE BANCO
    ;BANCO 0
    BCF STATUS, RP0
    BCF STATUS, RP1
    ;CONFIGURACION DE REGISTRO CCP1CON
    BSF CCP1CON,CCP2M3
    BSF CCP1CON,CCP2M2  
    ;CONFIGURACION DE REGISTRO CCP2CON
    BSF CCP2CON,CCP2M3		
    BSF CCP2CON,CCP2M2
    ;CONFIGURANDO EL REGISTRO ADCON0
    BSF ADCON0,ADON
    BCF ADCON0,1
    BCF ADCON0,CHS0
    BCF ADCON0,CHS1
    BCF ADCON0,CHS2
    BCF ADCON0,CHS3
    BSF ADCON0,ADCS0
    BSF ADCON0,ADCS1
    ;CONFIGURAMOS EL REGISTRO T2CON
    BSF T2CON, TMR2ON	;ENCENDEMOS EL TMR2
    BSF T2CON, T2CKPS0
    BSF T2CON, T2CKPS1	;ELEGIMOS UN PRESCALER DE 16
    ;CONFIGURAMOS EL REGISTRO RCSTA
    BSF RCSTA, SPEN
    BSF RCSTA, CREN	
    ;CAMBIAMOS DE BANCO
    ;BANCO 1
    BSF STATUS,RP0
    BCF STATUS,RP1
    ;CARGAMOS EL CALOR DE PR2
    MOVLW d'155'
    MOVWF PR2
    ;MODIFICAMOS EL REGISTRO TXSTA
    BCF TXSTA, TX9
    BSF TXSTA, TXEN 
    ;CONFIGURAMOS LAS INTERRUPCIONES
    BSF PIE1,RCIE
    BSF INTCON,PEIE
    BCF INTCON, GIE 
    BSF INTCON, RBIE 
    BCF INTCON, RBIF 
    BCF INTCON, T0IF 
    ;CARGAMOS EL VALOR PARA EL TMR0
    MOVLW .248	
    MOVWF TMR0	
    ;CAMBIAMOS DE BANCO
    ;BANCO 0    
    BCF STATUS, RP1
    BCF STATUS, RP0  

MAINLOOP:
    BSF INTCON, GIE
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    
    MOVF DATOS,W
    MOVWF PORTD
    
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    CLRF PORTD
    
    ;BCF STATUS, RP0
    ;BCF STATUS, RP1  ; BANCO 0
 
    ;MOVLW B'01000000'
    ;INCF PORTD
    ;MOVWF PORTD
    ;MOVF PORTD, W
    ;MOVWF TXREG
    
    ;BCF STATUS, RP1
    ;BSF STATUS, RP0  ; Banco 1
    
    ; SI TRMT ES 0 EL CARACTER SE TRANSFIRIO
    ;BTFSS TXSTA, TRMT
    ;BTFSC TXSTA, TRMT
    ;GOTO $-1
      
    ; PARA VER SI RECIBIO INFORMACION HAY QUE VER C
    
    
    GOTO MAINLOOP   
    
    
    
;****************************************************************************************;
; TIMER PARA GENERAR PWM PARA EL MARCADOR                                                ;
;****************************************************************************************;      

TIMER 
    MOVWF CONTADOR
    
    LOOP1:
    BCF INTCON,T0IF
    MOVLW .248	
    MOVWF TMR0
    
    LOOP2:
    BTFSS INTCON,T0IF
    GOTO LOOP2
    DECFSZ CONTADOR,F
    GOTO LOOP1
    
    RETURN 
    
INT 
    PUSH:
    MOVWF VTEMP
    SWAPF STATUS,W
    MOVWF STATUST
INTERRUPCION:
    BCF INTCON, GIE
    BTFSS PIR1, RCIF
    GOTO POP
    BCF PIR1,RCIF
    MOVF RCREG,W
    MOVWF DATOS
    
    ;MOVLW b'01010101'
    ;MOVWF PORTD
    POP:
    SWAPF STATUST,W
    MOVWF STATUS
    SWAPF VTEMP,F
    SWAPF VTEMP,W
    
    RETFIE
    END
            
