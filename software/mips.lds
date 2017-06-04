/* Linker script for mips */

ENTRY(_reset)

MEMORY    
{
	MIPS_RAM (rx) : ORIGIN = 0x0, LENGTH = 4K
	DRAM (rwx) : ORIGIN = 0x10000000, LENGTH = 128M
}


SECTIONS
{
	.text : 
	{
		_stext = .;
		stext = .;
		*(.text)
		*(.text.*)
		. = ALIGN(4);
		_etext = .;
		etext = .;
	} > MIPS_RAM
	
    .rodata : 
	{
		_sdata = .;
		sdata = .;
		. = ALIGN(4);
		*(.rodata)
		*(.rodata.*)
	} > MIPS_RAM
	
    .data :
	{	
		*(.sdata)
		*(.data)
		*(.rwdata)
		*(.got.plt) *(.got)
		*(.shdata)
		*(.data.* .gnu.linkonce.d.*)
		. = ALIGN (4);
		_edata  =  .;
		edata  =  .;
	} > MIPS_RAM
	
    .bss :
	{
		. = ALIGN(4);
		__bss_start = .;
		*(.sbss .sbss.*)
		*(.bss .bss.*)
		*(COMMON)
		. += 0x100;
		_gp = .;
		. = ALIGN (4);
		__bss_end = .;
	} > MIPS_RAM
}

/* Stack base address */
__stack_pointer = 0x1000;



