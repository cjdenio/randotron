#define __SFR_OFFSET 0
#include <avr/io.h>

.text
.global render_digit

render_digit:
	; load digit
	ldi r30, lo8(digits)
	ldi r31, hi8(digits)
	add r30, r24
	adc r31, r1
	lpm r0, Z

	; invert bits
	ser r16
	eor r0, r16

	; === write port A ===
	in r16, PORTA
	andi r16, 0b11110000 ; clear port

	mov r17, r0
	andi r17, 0b00001111

	or r16, r17

	out PORTA, r16

	; === write port B ===
	in r16, PORTB
	andi r16, 0b11111000 ; clear port

	mov r17, r0
	andi r17, 0b01110000
	swap r17

	or r16, r17

	out PORTB, r16


	ret


digits:
	.byte 0b00111111 ; 0
	.byte 0b00001100 ; 1
	.byte 0b01011011 ; 2
	.byte 0b01011110 ; 3
	.byte 0b01101100 ; 4
	.byte 0b01110110 ; 5
	.byte 0b01110111 ; 6
	.byte 0b00011100 ; 7
	.byte 0b01111111 ; 8
	.byte 0b01111110 ; 9
