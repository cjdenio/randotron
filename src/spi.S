#define __SFR_OFFSET 0
#include <avr/io.h>

.global SPITransfer

.text

; copied from the datasheet lol
SPITransfer:
	out USIDR,r24
	ldi r24,(1<<USIOIF)
	out USISR,r24
	ldi r17,(1<<USIWM0)|(1<<USICS1)|(1<<USICLK)|(1<<USITC)
SPITransfer_loop:
	out USICR,r17
	in r24, USISR
	sbrs r24, USIOIF
	rjmp SPITransfer_loop
	in r24,USIDR
	ret

; bit-banged SPI, technically works but not ideal
; SPITransfer:
; 	; transfer 8 bits
; 	ldi r17, 8
; 1:
; 	; put MSB on DO
; 	sbrc r24, 7  ; test bit
; 	rjmp 2f
; 	cbi PORTA, 5 ; bit clear
; 	rjmp 3f
; 2:
; 	sbi PORTA, 5 ; bit set
; 3:
;
; 	lsl r24
;
; 	; grab bit from DI
; 	sbic PINA, 6
; 	rjmp 2f
; 	cbr r24, 0b00000001 ; bit clear
; 	rjmp 3f
; 2:
; 	sbr r24, 0b00000001 ; bit set
; 3:
;
; 	; pulse clock
; 	sbi PORTA, 4
; 	cbi PORTA, 4
;
;
; 	dec r17
; 	brne 1b
;
; 	ret

