UPLOADTYPE := SERIAL
#UPLOADTYPE := ICSP

#AVRDUDE ?= avrdude
AVRDUDE ?= $(HOME)/packages/avrdude/avrdude

ATMCPART = m2560

ifneq ($(findstring SERIAL, $(UPLOADTYPE)),)
	PROGTYPE = stk500v2
	PORT = /dev/ttyUSB0
else
	PROGTYPE = usbasp
	PORT = usb
endif

all: build
install: upload

build:
	make -C ArduCopter

distclean: clean
	rm -f cscope.files

clean:
	rm -fr cscope.in.out cscope.out cscope.po.out tags
	make -C ArduCopter clean

cscope.files:
	find . -type f -exec file \{} \; | grep -v '/.svn/' | grep 'program text' | awk 'BEGIN{ FS=":" }{ print $$1 }' | sort -u > cscope.files

cscope: cscope.files
	cscope -b -k -q

ctags: cscope.files
	ctags -L cscope.files --extra=+fq --fields=+aiKln --if0 --sort=foldcase --totals=yes

upload:
	$(AVRDUDE) -p $(ATMCPART) -c $(PROGTYPE) -P $(PORT) -U flash:w:"$(TMP)/ArduCopter.build/ArduCopter.hex":i
