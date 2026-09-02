# ATmega328P Programming Makefile

# Constants for ATmega328P
PROCESSOR=m328p
HIGH_FUSE=0xD9
LOW_FUSE=0xE2

# Project settings
PROJECT=${project}
HEX_FILE=$(PROJECT).hex

# Programmer settings
PROGRAMMER=usbtiny
PORT=usb
BAUD_OPTS=-B 500

# AVRDUDE settings
AVRDUDE=avrdude
AVRDUDE_OPTS=-p $(PROCESSOR) -c $(PROGRAMMER) -P $(PORT) $(BAUD_OPTS) -F -v

# Default target
.PHONY: all program program-only verify

all: program

# Full programming (fuses + flash)
program:
	@echo "Programming ATmega328P with $(HEX_FILE)..."
	$(AVRDUDE) $(AVRDUDE_OPTS) -e -U hfuse:w:$(HIGH_FUSE):m -U lfuse:w:$(LOW_FUSE):m -U flash:w:$(HEX_FILE)
	@echo "Programming complete!"

# Program flash only (no fuses)
program-only:
	@echo "Programming ATmega328P flash only..."
	$(AVRDUDE) $(AVRDUDE_OPTS) -U flash:w:$(HEX_FILE)
	@echo "Flash programming complete!"

# Verify the chip
verify:
	@echo "Verifying ATmega328P connection..."
	$(AVRDUDE) $(AVRDUDE_OPTS)
	@echo "Verification complete!"