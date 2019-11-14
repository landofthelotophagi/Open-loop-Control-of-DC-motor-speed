.include "m16def.inc"
.cseg

.def temp = r16
.def state = r17
.def temp2 = r18
.def d1 = r19
.def d2 = r20

.org 0x0000
	rjmp reset

reset:
	;initialize Stack Pointer
	ldi temp, high(RAMEND)
	out SPH, temp
	ldi temp, low(RAMEND)
	out SPL, temp

	;set LEDs to portB
	ldi temp, 0b11111111
	out DDRB, temp

	;set Switches to PortA
	ldi temp, 0b01111110
	out DDRA, temp

	;turn off leds
	ser temp
	out PORTB, temp

	;set 7414's Input to portD
	ldi temp, 0b00100000
	out DDRD, temp

	;set PWM (9bit mode)
	ldi temp, 0b11000010
	out TCCR1A, temp

	;set prescaler to 1
	ldi temp, 0b00000001
	out TCCR1B, temp
	;set duty cycle to 20%
	ldi temp, 1
	out OCR1AH, temp
	ldi temp, 154
	out OCR1AL, temp

	clr state

loop:
	sbis PINA, 0 ;if (pinA_0==1) -> skip
	rjmp increament

	sbis PINA, 7 ;if (pinA_7==1) -> skip
	rjmp decreament

	rjmp loop

increament:
	sbic PINA, 0 ;if (pinA_0==0) -> skip
	rjmp incr_cont

	rjmp increament

incr_cont:
	call delay

	;get OCR1AH
	in temp2, OCR1AH

	;compare state and check if increase is
	needed or not
	cpi state, 10
	breq no_increament ;if (state==10) -> don't
	increase state
	inc state ;increase state
	out PORTB, state

	;get OCR1AL
	in temp, OCR1AL
	subi temp, 26 ;sub with 26

	brcc no_carry ;check for carry (OCR1AL
overflow)
	dec temp2 ;decrease

	no_carry:
	out OCR1AH, temp2
	out OCR1AL, temp

no_increament:
	rjmp loop

decreament:
	sbic PINA, 7 ;if (pinA_7=0) -> skip
	rjmp decr_cont

	rjmp decreament

decr_cont:
	call delay

	in temp2,OCR1AH ;set OCR1AH
	cpi state, 0 ;compare if (state==0)
	breq no_increament

	dec state
	out PORTB, state

	in temp, OCR1AL
	ldi d1, 26
	add temp, d1
	brcc no_carry

	inc temp2
	
	rjmp no_carry

;delay implement based on micro-1 method
delay:
	ldi d1, 0xFF

outer:
	dec d1
	breq endit

	ldi d2, 0xFF

inner:
	nop
	nop
	dec d2
	breq outer

	rjmp inner

endit:
	ret
