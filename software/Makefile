#*
#***********************************************************************************************
#	Function  	: Makefile
#	Parameter 	: all clean debug flash
#	Author    	: Lyu Yang
#	Date      	: 2016
#	Description : Makefile for MIPS32
#***********************************************************************************************
#*

PROJECT = main

INC_DIRS = -I./

LIB_DIRS = -L./

CC = mips-sde-elf-gcc
CFLAGS = $(INC_DIRS) -c -fno-pic -mips1 -mno-abicalls

CXX = mips-sde-elf-gcc
CXXFLAGS = $(INC_DIRS) -c -fno-pic -mips1 -mno-abicalls

AS = mips-sde-elf-gcc
ASFLAGS = $(INC_DIRS) -c -fno-pic -mips1 -mno-abicalls

LD = mips-sde-elf-gcc
LDFLAGS = $(LIB_DIRS) -nostartfiles -Tmips.lds -Wl,-Map,$(PROJECT).map

OBJCP = mips-sde-elf-objcopy
OBJCPFLAGS = -O binary -R .note -R .comment

DUMP = mips-sde-elf-objdump
DUMPFLAG = --disassemble --syms --all-header

# User should list all object files  
OBJS := Crt0.o
OBJS += main.o

.PHONY: all clean
all: $(PROJECT).elf $(PROJECT).asm $(PROJECT).bin
	mips-sde-elf-size $(PROJECT).elf
	./bin2fpga/bin2fpga 2048 $(PROJECT).bin
	
$(PROJECT).elf: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -o $@ $^
	
%.o: %.c
	$(CC) $(CFLAGS) -o $@ $^
	
%.o: %.S
	$(AS) $(ASFLAGS) -o $@ $^
	
$(PROJECT).asm: $(PROJECT).elf
	$(DUMP) $(DUMPFLAG) $(PROJECT).elf > $(PROJECT).asm
	
$(PROJECT).bin: $(PROJECT).elf
	$(OBJCP) $(OBJCPFLAGS) $< $@ 

clean:
	@-rm -f $(PROJECT).elf $(PROJECT).asm *.txt *.log *.map *.bin *.mif  *.coe *.o data.txt
	
