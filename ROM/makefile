XA = xa
MAIN = src/SB02.s
INCLUDES = -I src/LCD.s
OUT_EXE = SB02.rom

build:
	$(XA) -v -e error.log -l label_list.txt -o $(OUT_EXE) $(INCLUDES) $(MAIN)

clean:
	rm -rf error.log

rebuid: clean build
