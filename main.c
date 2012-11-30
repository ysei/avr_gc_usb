#include <avr/io.h>
#include <util/delay.h>

//#define F_CPU 16UL
#define CPU_PRESCALE(n) (CLKPR = 0x80, CLKPR = (n))
#define FAST_SPI_SEND_NOP(data) (SPDR = (data), _delay_us(8), ({ __asm__ \
            volatile("nop");}) )
/* Do not call this one in right after it with constant argument. It breaks. */
#define FAST_SPI_SEND(data) (SPDR = (data), _delay_us(9))

enum controller_mode_t{
    probe,
    poll
};

extern void led(void);
extern void controller_probe(void);
extern void controller_poll(void);
extern void controller_rumble(void);

enum controller_mode_t controller_mode; 

uint8_t controller_data_buff[256];

int main (void)
{
    uint8_t i;
    CPU_PRESCALE(0);
/*    led();*/
    /*spi_init();*/
    DDRB = 0xff;
    DDRD = 0xff;
    controller_mode = probe;
/*    controller_rumble();*/
    while(1){
        switch(controller_mode){
            case(probe):
                DDRB = 0xff;
                controller_probe(); 
                DDRB = 0xff;
                _delay_us(5);
                if((PINB & 1) == 0){ /* kinda works */
                    PORTD = (1<<6);
                    controller_mode = poll;
                }
                _delay_ms(12);
                break;
            case(poll):
                DDRB = 0xff;
                controller_poll();
                DDRB = 0xff;
                _delay_ms(6);
                break;
        }
    }
    return 0;
}
