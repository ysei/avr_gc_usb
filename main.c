#include <avr/io.h>
#include <util/delay.h>
#include "avr_gc_usb.h"

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

uint8_t controller_data_buff[256];

int main (void)
{
    uint8_t i;
    CPU_PRESCALE(0);
    DDRB = 0xff;
    DDRD = 0xff;
    led();
    controller_mode = poll;
    while(1){
        switch(controller_mode){
            case(probe):
                _delay_ms(12);
                break;
            case(poll):
                controller_poll();
                _delay_ms(6);
                break;
        }
    }
    return 0;
}
