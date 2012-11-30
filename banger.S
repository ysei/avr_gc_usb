#include <avr/io.h>
#define bang_pin PB0

.global led
.global controller_probe
.global controller_rumble
.global controller_poll
.global controller_save_data
.extern controller_data_buff

.macro push_sreg 
    push r16
    in r16, _SFR_IO_ADDR(SREG)
    push r16 
.endm

.macro pop_sreg
    pop r16
    out _SFR_IO_ADDR(SREG), r16
    pop r16
.endm

.macro four_cycle_nop
    nop
    nop
    nop
    nop
.endm

/* assumes that load_reg_vals is executed before this */    
.macro lo_bit
    out _SFR_IO_ADDR(PORTB), r16 /* 1 clock */
    nop 
    nop
    nop
    four_cycle_nop    
    four_cycle_nop
    four_cycle_nop
.endm

.macro hi_bit
    out _SFR_IO_ADDR(PORTB), r17 /* 1 clock */
    nop 
    nop
    nop
    four_cycle_nop
    four_cycle_nop
    four_cycle_nop
.endm

.macro lo_enc_bit
    lo_bit
    lo_bit
    lo_bit
    hi_bit    
.endm

.macro hi_enc_bit
    lo_bit
    hi_bit
    hi_bit
    hi_bit
.endm

.macro send_lo_byte
    lo_enc_bit
    lo_enc_bit
    lo_enc_bit
    lo_enc_bit
    lo_enc_bit
    lo_enc_bit
    lo_enc_bit
    lo_enc_bit
.endm

.macro send_probe_byte
    send_lo_byte
    hi_enc_bit
.endm



controller_probe:
    push_sreg
    push r17
    push r18
    push r19

    ldi r16, 0
    ldi r17, 1

    send_probe_byte
    
/*    data_read_loop:
    in r18, _SFR_IO_ADDR(PORTB)
    and r18, r17
    sbrc r18, 1 *//* skip if bit in register cleared */
/*    ldi r19, 1
    ldi r19, 0
    out _SFR_IO_ADDR(PORTD), r19
    jmp data_read_loop*/

    pop r19
    pop r18
    pop r17
    pop_sreg 
    reti

controller_poll:
    push_sreg
    push r16
    push r17

    ldi r16, 0
    ldi r17, 1

    lo_enc_bit
    hi_enc_bit
    lo_enc_bit
    lo_enc_bit

    send_lo_byte

    lo_enc_bit
    lo_enc_bit
    hi_enc_bit
    hi_enc_bit

    lo_enc_bit
    lo_enc_bit
    lo_enc_bit
    lo_enc_bit

    lo_enc_bit
    lo_enc_bit
    hi_enc_bit
    lo_enc_bit
    
    hi_enc_bit 

    pop r17
    pop r16
    pop_sreg
    reti

controller_rumble:
    push_sreg
    push r16
    push r17

    ldi r16, 0
    ldi r17, 1

    lo_enc_bit
    hi_enc_bit
    lo_enc_bit
    lo_enc_bit

    send_lo_byte

    lo_enc_bit
    lo_enc_bit
    lo_enc_bit
    lo_enc_bit

    lo_enc_bit
    lo_enc_bit
    lo_enc_bit
    lo_enc_bit

    lo_enc_bit
    lo_enc_bit
    lo_enc_bit
    hi_enc_bit
   
    hi_enc_bit

    pop r17
    pop r16
    pop_sreg
    reti

controller_save_data:
    push_sreg
    

    pop_sreg
    reti
