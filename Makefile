PROJECT=avr_gc_usb
CSOURCES=main.c usb_rawhid.c
ASSOURCES=banger.S
CC=avr-gcc
OBJCOPY=avr-objcopy
OBJDUMP=avr-objdump
#MMCU=atmega88
MMCU=at90usb1286
PROGRAMMER=teensy-loader-cli
F_CPU=16000000

CFLAGS=-mmcu=$(MMCU) -Wall -Os

ODFLAGS=-D

$(PROJECT).hex: $(PROJECT).out 
	$(OBJCOPY) -j .text -O ihex $(PROJECT).out $(PROJECT).hex

$(PROJECT).out: $(CSOURCES) $(ASSOURCES) Makefile
	$(CC) $(CFLAGS) -o $(PROJECT).out $(CSOURCES) -DF_CPU=$(F_CPU)UL -x \
		assembler-with-cpp $(ASFLAGS) $(ASSOURCES)
disasm: $(PROJECT).out
	$(OBJDUMP) $(ODFLAGS) $(PROJECT).out

program: $(PROJECT).hex
#	$(PROGRAMMER) -c usbtiny  -p$(MMCU) -U flash:w:$(PROJECT).hex
	$(PROGRAMMER) -mmcu=$(MMCU) -w -r $(PROJECT).hex
clean:
	rm -f $(PROJECT).out
	rm -f $(PROJECT).hex

