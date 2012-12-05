#include <avr/io.h>
#include "avr_gc_usb.h"

.global led
.global controller_probe
.global controller_rumble
.global controller_poll
.extern controller_buffer

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

.macro lo_bit
    cbi _SFR_IO_ADDR(BANG_PORT), BANG_BIT /* 2 cycles */
    nop
    nop
    four_cycle_nop    
    four_cycle_nop
    four_cycle_nop
.endm

.macro hi_bit
    sbi _SFR_IO_ADDR(BANG_PORT), BANG_BIT /* 2 cycles */
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

led:
    sbi _SFR_IO_ADDR(PORTD), 6
    reti

controller_probe:
    push_sreg
    push r17
    push r18
    push r19

    /* The direction register has to be changed because AVRs' internal pullups
     * are too strong for some controllers. I used external 1k pullup instead */
    sbi _SFR_IO_ADDR(BANG_DIR), BANG_BIT

    send_probe_byte

    cbi _SFR_IO_ADDR(BANG_DIR), BANG_BIT

    pop r19
    pop r18
    pop r17
    pop_sreg 
    reti

/* Assumes that r18 is zero and uses it. Uses r16 for buffering and stores the 
 * byte to r17. */
.macro controller_fetch_byte
    fetch_loop:
        fetch_bit /* 4 cycles */
        inc r18 /* 1 cycle */
        four_cycle_nop
        four_cycle_nop        
        cpi r18, 8 /* 1 cycle */
    brne fetch_loop /* 2 cycles if branching (not equal), 1 if equal */
.endm

/* Uses r27, r26. */
.macro controller_load_data_buffer_pointer_to_x
    ldi  controller_buffer, 

.endm

.macro controller_save_word
    fetch_loop:
        fetch_bit /* 4 cycles */
        inc r18 /* 1 cycle */
        four_cycle_nop
        four_cycle_nop        
        cpi r18, 8 /* 1 cycle */
    brne fetch_loop /* 2 cycles if branching (not equal), 1 if equal */
    


.endm

.macro controller_save_data
 
/*    sbi _SFR_IO_ADDR(PORTD), 6 */
    
    controller_fetch_byte

    out _SFR_IO_ADDR(PORTC), r17

    cbi _SFR_IO_ADDR(PORTD), 6

.endm

/* The algorithm. In the port with the bang bit to Rb. Or Rb with Rs store
 * result to Rs. Shift Rs one bit left. Increment loop counter. If loop 
 * counter reaches 8, store Rs and increment index register. */
/* Assumes r17 to be zero and uses it, uses r16 */
.macro fetch_bit /* 4 cycles */
    lsr r17 /* 1 cycle */ /* need to do this first to preserve the last bit */
    in r16, _SFR_IO_ADDR(BANG_PIN) /* 1 cycle */
    andi r16, 128 /* 1 cycle */ /* to filter out all the other bits */
    or r17, r16 /* 1 cycle */ /* comine with the previous string of bits */
.endm

controller_poll:
    push_sreg
    push r16
    push r17
    push r18

    ldi r16, 0xff
    out _SFR_IO_ADDR(DDRC), r16 /* this is for debug */

    ldi r16, 0 /* temporary io */
    ldi r17, 0 /* data buffer */
    ldi r18, 0 /* loop counter */

    sbi _SFR_IO_ADDR(BANG_DIR), BANG_BIT
    sbi _SFR_IO_ADDR(DDRD), 6 /* debug */
    
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

    cbi _SFR_IO_ADDR(BANG_DIR), BANG_BIT
    
    controller_save_data

    pop r18
    pop r17
    pop r16

    pop_sreg
    reti

controller_rumble:
    sbi _SFR_IO_ADDR(BANG_DIR), BANG_BIT
    
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
    
    cbi _SFR_IO_ADDR(BANG_DIR), BANG_BIT

    reti

.macro six_cycle_nop
    four_cycle_nop
    nop
    nop
.endm

