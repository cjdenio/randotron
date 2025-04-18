all: a.hex a.bin

a.out: src/*.S
	avr-gcc -nostartfiles -mmcu=attiny84a -o $@ $^

a.hex: a.out
	avr-objcopy -O ihex $< $@

a.bin: a.out
	avr-objcopy -O binary $< $@

deploy: a.bin
	avrdude -p t84a -c arduino_as_isp -P /dev/tty.usbmodem11301 -U flash:w:$<:r

