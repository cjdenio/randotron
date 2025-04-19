#define __SFR_OFFSET 0
#include <avr/io.h>

.section .bss
current_digit: .zero 3

.section .vectors
_vectors:
	rjmp start		; RESET
	rjmp dummy_isr	; EXT_INT0
	rjmp dummy_isr  ; PCINT0
	rjmp dummy_isr	; PCINT1
	rjmp dummy_isr	; WDT
	rjmp dummy_isr	; TIM1_CAPT
	rjmp tick		; TIM1_COMPA
	rjmp dummy_isr	; TIM1_COMPB
	rjmp dummy_isr	; TIM1_OVF
	rjmp dummy_isr	; TIM0_COMPA
	rjmp dummy_isr	; TIM0_COMPB
	rjmp dummy_isr	; TIM0_OVF
	rjmp dummy_isr	; ANA_COMP
	rjmp dummy_isr	; ADC
	rjmp dummy_isr	; EE_RDY
	rjmp dummy_isr	; USI_STR
	rjmp dummy_isr	; USI_OVF



.text
dummy_isr: reti

start:
	ldi r16, 0x85 ; calibrate internal clock- my particular ATtiny runs a little fast
	out OSCCAL, r16

	clr r1 ; r1 should always be 0

	; set up pin directions
	ldi r16, 0b10111111
	out DDRA, r16
	ldi r16, 0b00000111
	out DDRB, r16

	; turn display off
	ldi r16, 0b10001111
	out PORTA, r16
	ldi r16, 0b00000111
	out PORTB, r16

	ldi r30, lo8(current_digit)
	ldi r31, hi8(current_digit)
	st  Z,   r1
	std Z+1, r1
	std Z+2, r1

	rcall show_next_digit ; show the first digit

	rcall setup_tick

main:
	; put the MCU in idle mode to (theoretically) save power
	ldi r16, (1 << SE) | SLEEP_MODE_IDLE
	out MCUCR, r16
	sleep
	rjmp main


get_digit_from_flash:
	push r22

	clc
	ror r24
	ror r23
	ror r22

	mov r25, r24

	cbi PORTA, 7 ; CE active

	ldi r24, 0x03		; Send `read` command to flash: 0x03 + 3 address bytes
	rcall SPITransfer
	mov r24, r25
	rcall SPITransfer
	mov r24, r23
	rcall SPITransfer
	mov r24, r22
	rcall SPITransfer

	rcall SPITransfer	; Read back byte from flash

	sbi PORTA, 7 ; CE inactive

	pop r22
	sbrc r22, 0
	swap r24
	andi r24, 0xF
	ret

tick:
	rcall show_next_digit

	reti

show_next_digit:
	ldi r30, lo8(current_digit)
	ldi r31, hi8(current_digit)

	ld  r22, Z
	ldd r23, Z+1
	ldd r24, Z+2

	push r22
	push r23
	push r24

	rcall get_digit_from_flash
	rcall render_digit

	pop r24
	pop r23
	pop r22

	ldi r16, 1

	add r22, r16
	adc r23, r1
	adc r24, r1

	ldi r30, lo8(current_digit)
	ldi r31, hi8(current_digit)

	st  Z,   r22
	std Z+1, r23
	std Z+2, r24

	ret


setup_tick:
	cli
	ldi r16, 0b00001011 ; divide clock by 64 (run at 15 KHz)
	out TCCR1B, r16 ; enable clock

	ldi r17, hi8(1000000/64)
	ldi r16, lo8(1000000/64)
	out OCR1AH, r17
	out OCR1AL, r16

	ldi r16, 2
	out TIMSK1, r16 ; enable compare interrupt
	sei

	ret

