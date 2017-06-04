//***************************************************************************
//   Copyright(c)2015, Lyu Yang
//   All rights reserved
//
//   File name        :   Plasma_SOPC.v
//   Module name      :   
//   Author           :   Lyu Yang
//   Email            :   lyuyangly@outlook.com
//   Data             :   2015-09-20
//   Version          :   v1.0
//
//   Abstract         :   
//
//   Modification history
//   ------------------------------------------------------------------------
// Version       Data(yyyy/mm/dd)   name
// Description
//
// $Log$
//***************************************************************************

// synopsys translate_off
`timescale 1 ns / 100 ps
// synopsys translate_on
module Plasma_SOPC (
    input			    clk         ,
    input			    rst_n       ,
    
	// sdram interface
	output				sdram_clk	,
	output				sdram_cke	,
	output				sdram_cs_n	,
	output				sdram_ras_n	,
	output				sdram_cas_n	,
	output				sdram_we_n	,
	output		[1:0]	sdram_ba	,
	output		[1:0]	sdram_dqm	,
	output		[12:0]	sdram_addr	,
	inout		[15:0]	sdram_data	,
    
    // prots
	input		[7:0]	sw			,
    output      [7:0]	led
); 

// **************************************************
// Wires from MIPS32 System fabric
// **************************************************

wire            clk_bus;

// **************************************************
// Wires from MIPS32 Inst Master to Conmax m0
// **************************************************

wire 			iwb_ack_i;
wire 			iwb_cyc_o;
wire 			iwb_stb_o;
wire [31:0]		iwb_dat_i;
wire [31:0]		iwb_dat_o;
wire [31:0]		iwb_adr_o;
wire [3:0]		iwb_sel_o;
wire			iwb_we_o;
wire			iwb_err_i;
wire			iwb_rty_i;

// **************************************************
// Wires from MIPS32 Data Master to Conmax m1
// **************************************************

wire			dwb_ack_i;
wire			dwb_cyc_o;
wire			dwb_stb_o;
wire [31:0]		dwb_dat_i;
wire [31:0]		dwb_dat_o;
wire [31:0]		dwb_adr_o;
wire [3:0]		dwb_sel_o;
wire			dwb_we_o;
wire			dwb_err_i;
wire			dwb_rty_i;

// **************************************************
// Wires from MIPS32 Data Master to Conmax m1
// **************************************************

wire			xwb_ack_i;
wire			xwb_cyc_o;
wire			xwb_stb_o;
wire [31:0]		xwb_dat_i;
wire [31:0]		xwb_dat_o;
wire [31:0]		xwb_adr_o;
wire [3:0]		xwb_sel_o;
wire			xwb_we_o;
wire			xwb_err_i;
wire			xwb_rty_i;

// **************************************************
// Wires from Conmax s0 to onchip_ram
// **************************************************

wire			ram_ack_o;
wire			ram_cyc_i;
wire			ram_stb_i;
wire [31:0]		ram_dat_i;
wire [31:0]		ram_dat_o;
wire [31:0]		ram_adr_i;
wire [3:0]		ram_sel_i;
wire			ram_we_i;

// **************************************************
// Wires from MIPS32 SDRAM Controller
// **************************************************

wire 			sdr_ack_i;
wire 			sdr_cyc_o;
wire 			sdr_stb_o;
wire [31:0]		sdr_dat_i;
wire [31:0]		sdr_dat_o;
wire [31:0]		sdr_adr_o;
wire [3:0]		sdr_sel_o;
wire			sdr_we_o;
wire			sdr_err_i;
wire			sdr_rty_i;

// **************************************************
// Wires from Conmax s2 to GPIO
// **************************************************

wire            gpio_ack_o;
wire            gpio_cyc_i;
wire            gpio_stb_i;
wire [31:0]     gpio_data_i;
wire [31:0]     gpio_data_o;
wire [31:0]     gpio_addr_i;
wire [3:0]      gpio_sel_i;
wire            gpio_we_i;
wire            gpio_err_o;
wire            gpio_inta_o;

// PLL altera
pll pll_inst (
	.inclk0     (clk),
	.c0         (clk_bus),
    .c1         (sdram_clk)
);

// Processor
plasma_mips cpu (
    .clk_i      (clk_bus),
    .rst_i      (!rst_n),
    .intr_i     (1'b0),
    
    // wishbone bus
    .wb_cyc_o   (dwb_cyc_o),
    .wb_stb_o   (dwb_stb_o),
    .wb_we_o    (dwb_we_o),
    .wb_sel_o   (dwb_sel_o),
    .wb_adr_o   (dwb_adr_o),
    .wb_dat_i   (dwb_dat_i),
    .wb_dat_o   (dwb_dat_o),
    .wb_ack_i   (dwb_ack_i)
);
 
/*
 *    Wishbone conmax for MIPS32
 */
wb_conmax_top wishbone_conmax  (
	.clk_i				(clk_bus),
	.rst_i				(!rst_n),

	// Master 0 Interface
	.m0_data_i			(),
	.m0_data_o			(iwb_dat_i),
	.m0_addr_i			(iwb_adr_o),
	.m0_sel_i			(iwb_sel_o),
	.m0_we_i			(iwb_we_o),
	.m0_cyc_i			(iwb_cyc_o),
	.m0_stb_i			(iwb_stb_o),
	.m0_ack_o			(iwb_ack_i),
	.m0_err_o			(),
	.m0_rty_o			(),

	// Master 1 Interface
	.m1_data_i			(dwb_dat_o),
	.m1_data_o			(dwb_dat_i),
	.m1_addr_i			(dwb_adr_o),
	.m1_sel_i			(dwb_sel_o),
	.m1_we_i			(dwb_we_o),
	.m1_cyc_i			(dwb_cyc_o),
	.m1_stb_i			(dwb_stb_o),
	.m1_ack_o			(dwb_ack_i),
	.m1_err_o			(),
	.m1_rty_o			(),

	// Master 2 Interface
	.m2_data_i			(xwb_dat_o),
	.m2_data_o			(xwb_dat_i),
	.m2_addr_i			(xwb_adr_o),
	.m2_sel_i			(xwb_sel_o),
	.m2_we_i			(xwb_we_o),
	.m2_cyc_i			(xwb_cyc_o),
	.m2_stb_i			(xwb_stb_o),
	.m2_ack_o			(xwb_ack_i),
	.m2_err_o			(),
	.m2_rty_o			(),
	
	// Slave 0 Interface
	.s0_data_i			(ram_dat_o),
	.s0_data_o			(ram_dat_i),
	.s0_addr_o			(ram_adr_i),
	.s0_sel_o			(ram_sel_i),
	.s0_we_o			(ram_we_i),
	.s0_cyc_o			(ram_cyc_i),
	.s0_stb_o			(ram_stb_i),
	.s0_ack_i			(ram_ack_o),
	.s0_err_i			(0),
	.s0_rty_i			(0),

	// Slave 1 Interface
	.s1_data_i			(sdr_dat_i),
	.s1_data_o			(sdr_dat_o),
	.s1_addr_o			(sdr_adr_o),
	.s1_sel_o			(sdr_sel_o),
	.s1_we_o			(sdr_we_o),
	.s1_cyc_o			(sdr_cyc_o),
	.s1_stb_o			(sdr_stb_o),
	.s1_ack_i			(sdr_ack_i),
	.s1_err_i			(0),
	.s1_rty_i			(0),
    
	// Slave 2 Interface
	.s2_data_i			(gpio_data_o),
	.s2_data_o			(gpio_data_i),
	.s2_addr_o			(gpio_addr_i),
	.s2_sel_o			(gpio_sel_i),
	.s2_we_o			(gpio_we_i),
	.s2_cyc_o			(gpio_cyc_i),
	.s2_stb_o			(gpio_stb_i),
	.s2_ack_i			(gpio_ack_o),
	.s2_err_i			(0),
	.s2_rty_i			(0)
);

// SDRAM Controller
wb_sdram sdr_0 (
    .clk_i              (clk_bus),
    .rst_i              (!rst_n),

    // Wishbone I/F
    .addr_i             (sdr_adr_o),
    .data_i             (sdr_dat_o),
    .data_o             (sdr_dat_i),
    .stb_i              (sdr_stb_o),
    .sel_i              (sdr_sel_o),
    .cyc_i              (sdr_cyc_o),
    .we_i               (sdr_we_o),
    .ack_o              (sdr_ack_i),

    // SDRAM Interface
    .sdram_clk_o        (),
    .sdram_cke_o        (sdram_cke),
    .sdram_cs_o         (sdram_cs_n),
    .sdram_ras_o        (sdram_ras_n),
    .sdram_cas_o        (sdram_cas_n),
    .sdram_we_o         (sdram_we_n),
    .sdram_dqm_o        (sdram_dqm),
    .sdram_addr_o       (sdram_addr),
    .sdram_ba_o         (sdram_ba),
    .sdram_data_io      (sdram_data)
);

// ram
wb_ram_top ram_inst (
    .clk_i				(clk_bus),
    .rst_i				(!rst_n),
    .wb_stb_i			(ram_stb_i),
    .wb_cyc_i			(ram_cyc_i),
    .wb_ack_o			(ram_ack_o),
    .wb_adr_i			(ram_adr_i),
    .wb_sel_i			(ram_sel_i),
    .wb_we_i			(ram_we_i),
    .wb_dat_i			(ram_dat_i),
    .wb_dat_o			(ram_dat_o)
);

// GPIO 
gpio_top gpio_inst (
   // WISHBONE Interface
   .wb_clk_i        (clk_bus),
   .wb_rst_i        (!rst_n),
   .wb_cyc_i        (gpio_cyc_i),
   .wb_adr_i        (gpio_addr_i),
   .wb_dat_i        (gpio_data_i),
   .wb_sel_i        (gpio_sel_i),
   .wb_we_i         (gpio_we_i),
   .wb_stb_i        (gpio_stb_i),
   .wb_dat_o        (gpio_data_o),
   .wb_ack_o        (gpio_ack_o),
   .wb_err_o        (gpio_err_o),
   .wb_inta_o       (gpio_inta_o),
   // external ports
   .ext_pad_i       (sw),
   .ext_pad_o       (led),
   .ext_padoe_o     ()
);


endmodule

