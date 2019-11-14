.include "m16def.inc"
.cseg

.def temp = r16
.def state = r17
.def temp2 = r18
.def d1 = r19
.def d2 = r20
.def counter = r21
.def state2 = r22
.def flag = r23

.org 0x0000
	rjmp reset
.org 0x0012
	rjmp TIM0_OVFL

reset:
	;initialize Stack Pointer
	ldi temp, high(RAMEND)
	out SPH, temp
	ldi temp, low(RAMEND)
	out SPL, temp

	;**set Ports (I/O)**

	;PortD
	ldi counter, 16
	ldi temp, 0b00100000
	out DDRD, temp

	;PortA
	ldi temp, 0b01111110
	out DDRA, temp

	;PORTB
	ldi temp, 0b11111111
	out DDRB, temp

	;init TIMSK -> TOIE0==1
	ldi temp, 1<<TOIE0
	out TIMSK, temp
	;TIMER0

	;init TCNT0
	ldi temp, 12
	out TCNT0, temp

	;init TCCR0
	ldi temp, 0b00000101
	out TCCR0, temp

	;TIMER1

	;TCCR1B/A
	ldi temp, 0b11000010
	out TCCR1A, temp
	ldi temp, 0b00000001
	out TCCR1B, temp

	;OCR1AH/L
	ldi temp, 1
	out OCR1AH, temp
	ldi temp, 54
	out OCR1AL, temp

	;init state
	ldi state, 0
	out PORTB, state

	;init flag
	ldi flag, 0xFF

	sei
loop:
	rjmp loop

increament:
	in temp2, OCR1AH
	out PORTB, state

	in temp, OCR1AL
	subi temp, 26
	brcc no_carry
	
	dec temp2

no_carry:
	out OCR1AH, temp2
	out OCR1AL, temp

	ret

decreament:
	in temp2, OCR1AH
	out PORTB, state

	in temp, OCR1AL
	ldi d1, 26
	add temp, d1
	brcc no_carry

	inc temp2

no_carry2:
	out OCR1AH, temp2
	out OCR1AL, temp

	ret

TIM0_OVFL:
	dec counter
	brne restart

	ldi counter,16
	cpi state, 10
	breq inverse

df:
	inc state
	cpi flag, 0
	breq decreas

	call increament

	rjmp restart

decreas:
	call decreament

	rjmp restart

inverse:
	com flag
	clr state

	rjmp df

restart:
	ldi temp, 12
	out TCNT0,temp

	reti
