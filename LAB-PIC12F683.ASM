           ;processor 12f683
	   ;LIST    p=12F683 ; PIC16F84A is the target processor

           #include "P12F683.INC" ; Include header file

 	   __config _WDTE_OFF & _MCLRE_OFF & _CP_OFF & _INTRC_OSC_NOCLKOUT

           CBLOCK 0x20   ; Temporary storage
              state
	      delay
              l1,l2
           ENDC

           org     0               ; Start up vector.
           goto    setports        ; Go to start up code.

	   org     4               ; Interrupt vector.
halt0       goto   halt0           ; Sit in endless loop and do nothing.


Start:
;===============================================================================
;BANKSEL GPIO ;
;CLRF GPIO ;Init GPIO
;MOVLW 07h ;Set CM<2:0> to digital I/O
;MOVWF CMCON0 
;BANKSEL ANSEL ;
;CLRF ANSEL ;Set to digital I/O
;MOVLW 00h 
;MOVWF TRISIO ;Set GP<5:0> as outputs
    
setports   

	   BANKSEL ANSEL
	   movlw B'00000000'	   ;Set to digital I/O
	   movwf ANSEL 
	   
	   BANKSEL CMCON0
	   movlw B'00000111'	   ; Comparators disabled
	   movwf CMCON0
	   
	   ;BANKSEL ADCON0
	   ;movlw B'00000000'	   ; A/D disabled
	   ;movwf ADCON0 
	   
	   ;BANKSEL T1CON
	   ;bcf T1CON, 3
	   
	   BANKSEL TRISIO
           clrw                    ; Mask for all bits as outputs.
           movwf   TRISIO          ; Set TRISIO register.
           bsf     TRISIO,3
	   
	   	   BANKSEL GPIO
	   clrw                    ; Zero in to W.
           movwf   GPIO	           ; Ensure PORTIO1 is zero before we enable it.
	   
	   BANKSEL GPIO
	   movlw B'00111111'
	   movwf   GPIO
	   
	   ;movlw B'00000111'	   ; A/D disabled
	   ;movwf ADCON0 
  	   ;movlw B'01100000'	   ; A/D disabled
	   ;movwf OSCCON 
	   
	   
initialise clrw                    ; Initial state.
           movwf   state           ; Set it.
	   
	   clrw                    ; Initial delay.
           movwf   delay           ; Set it.

loop       call    getmask         ; Convert state to bitmask.
           movwf   GPIO	           ; Write it to port.
           incf    state,W         ; Increment state in to W.
           andlw   0x03            ; Wrap it around.
           movwf   state           ; Put it back in to memory.
	   
           call    wait            ; Wait :-)	   
	   call    wait            ; Wait :-)
	   call    wait            ; Wait :-)
	   call    wait            ; Wait :-)
	   call    wait            ; Wait :-)
	   call    wait            ; Wait :-)
	   call    wait            ; Wait :-)
	   call    wait            ; Wait :-)
	   
	   btfsc GPIO,3
	   goto  next1
	   incf  delay,W
	   andlw  0x1F            ; Wrap it around.
           movwf delay
next1
	   
           goto    loop            ; And loop :-)

           ; Function to return bitmask for output port for current state.
           ; The top nibble contains the bits for one set of lights and the
           ; lower nibble the bits for the other set. Bit 1 is red, 2 is amber
           ; and bit three is green. Bit four is not used.
getmask    movf    state,W         ; Get state in to W.
           addwf   PCL,F           ; Add offset in W to PCL to calc. goto.
	   
           retlw   0x21            ; state==0 is Green and Red.
           retlw   0x03            ; state==1 is Amber and Red/Amber
           retlw   0x14            ; state==3 is Red   and Green
           retlw   0x12            ; state==4 is Red/Amber and Amber.

           ; Function using two loops to achieve a delay.
wait       ; movlw   255
	   movf    delay,W         ; Get state in to W.
           movwf   l1

w1         call    wait2
           decfsz  l1
           goto    w1

           return


wait2      clrf    l2
w2         decfsz  l2
           goto    w2
           return
           END
