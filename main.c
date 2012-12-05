#include <avr/io.h>
#include <util/delay.h>
#include "avr_gc_usb.h"
#include "usb_rawhid.h"

#define CPU_PRESCALE(n) (CLKPR = 0x80, CLKPR = (n))

enum controller_mode_t{
    probe,
    poll
};

extern void led(void);
extern void controller_probe(void);
extern void controller_poll(void);
extern void controller_rumble(void);
extern void controller_save_data(void);

enum controller_mode_t controller_mode; 

uint8_t controller_buffer[10];

uint8_t usb_buffer[64];

int main (void)
{
    uint8_t i;
    CPU_PRESCALE(0);
    DDRB = 0xff;
    DDRD = 0xff;
    usb_init();
    while(!usb_configured());
    usb_buffer[0] = 0xab;
    usb_buffer[1] = 0xcd; 
    usb_buffer[63] = 4;
    led();
    controller_mode = probe;
    while(1){
        switch(controller_mode){
            case(probe):
                _delay_ms(12);
                usb_rawhid_send(usb_buffer, 50);
                break;
            case(poll):
                controller_poll();
                _delay_ms(6);
                break;
        }
    }
    return 0;
}
