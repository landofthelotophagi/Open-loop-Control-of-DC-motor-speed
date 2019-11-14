.include "m16def.inc"

.cseg

;definitions
.def temp = r16
.def holder1L = r17
.def result = r18
.def counter = r19
.def holder2L = r20

;init interupt vectors addresses
.org 0x0000
	rjmp reset
.org 0x000A
	rjmp TIM1_CAPT

reset:
	;initialize Stack Pointer
	ldi temp, high(RAMEND)
	out SPH, temp
	ldi temp, low(RAMEND)
	out SPL, temp

	;set LEDs to portB
	ldi temp, 0b11111111
	out DDRB, temp

	;set Switches to portA
	ldi temp, 0b01111110
	out DDRA, temp

	;Set Input ICP1 to portD
	ldi temp,0b10111111
	out DDRD, temp

	;clear counter (counter's start value = 0)
	clr temp
	out TCNT1H, temp
	out TCNT1L, temp

	;clear ICR1
	out ICR1H, temp
	out ICR1L, temp

pulse:
	;clear ACSR
	out ACSR, temp

	;Enable TICIE1 bit of TIMSK (pulse mode
	interupt)
	ldi temp, 1<<TICIE1
	out TIMSK, temp

	;set prescaler CK/64
	ldi temp, 0b00000000
	out TCCR1A, temp

	ldi temp, 0b00000011
	out TCCR1B, temp

	;set counter (number of pulses)
	ldi counter, 1

	;enable interupts (StatusRegister{I} = 1)
	sei
	loop:
	;if (SW_A0==pressed) -> display result
	;else -> inf loop until interupt happens
	sbis PINA, 0
	out PORTB, result

	rjmp loop

TIM1_CAPT:
	;if counter==0 -> start again
	cpi counter, 0
	breq start_again
	
	;if counter!=0 -> get timer's value
	cpi counter, 1
	breq pulse

	reti
;get the current timer value and decrease counter's
value
	in holder1L, ICR1L
	dec counter

	reti

start_again:
	;calculate pulse' duration
	in holder2L, ICR1L
	sub holder2L, holder1L

	;get result
	mov result, holder2L
	com result

	;clear TCNT1
	clr temp
	out TCNT1H, temp
	out TCNT1L, temp

	;clear ICR1
	out ICR1H, temp
	out ICR1L, temp

	;clear ACSR
	out ACSR, temp

	;set counter's value
	ldi counter, 1

	reti
