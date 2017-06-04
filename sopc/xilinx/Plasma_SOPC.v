//***************************************************************************
//   Copyright(c)2016, Lyu Yang
//   All rights reserved
//
//   File name        :   Plasma_SOPC.v
//   Module name      :   
//   Author           :   Lyu Yang
//   Email            :   lyuyangly@qq.com
//   Date             :   2016-12-20
//   Version          :   v1.0
//
//   Abstract         :   
//
//   Modification history
//   ------------------------------------------------------------------------
// Version       Date(yyyy/mm/dd)   name
// Description
//
// $Log$
//***************************************************************************

// synopsys translate_off
`timescale 1 ns / 100 ps
// synopsys translate_on
module Plasma_SOPC (
    input			    clk,
    input			    rst,
	
	// ddr2 chip signals
	output				mcb3_dram_ck,
	output				mcb3_dram_ck_n,
	inout  [15:0]		mcb3_dram_dq,
	output [12:0]		mcb3_dram_a,
	output [2:0]		mcb3_dram_ba,
	output				mcb3_dram_ras_n,
	output				mcb3_dram_cas_n,
	output				mcb3_dram_we_n,
	output				mcb3_dram_odt,
	output				mcb3_dram_cke,
	output				mcb3_dram_dm,
	inout				mcb3_dram_udqs,
	inout				mcb3_dram_udqs_n,
	output				mcb3_dram_udm,
	inout				mcb3_dram_dqs,
	inout				mcb3_dram_dqs_n,
	inout				mcb3_rzq,
	inout				mcb3_zio,
	
	// uart
	output				uart_txd,
	input				uart_rxd,
	
    // ports
	input		[3:0]	key,
    output      [3:0]	led
); 
// iwb
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

// dwb
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

// onchip_ram
wire			ram_ack_o;
wire			ram_cyc_i;
wire			ram_stb_i;
wire [31:0]		ram_dat_i;
wire [31:0]		ram_dat_o;
wire [31:0]		ram_adr_i;
wire [3:0]		ram_sel_i;
wire			ram_we_i;

// DDR
wire 			ddr_ack_o;
wire 			ddr_cyc_i;
wire 			ddr_stb_i;
wire [31:0]		ddr_dat_i;
wire [31:0]		ddr_dat_o;
wire [31:0]		ddr_adr_i;
wire [3:0]		ddr_sel_i;
wire			ddr_we_i;

// GPIO
wire            gpio_ack_o;
wire            gpio_cyc_i;
wire            gpio_stb_i;
wire [31:0]     gpio_dat_i;
wire [31:0]     gpio_dat_o;
wire [31:0]     gpio_adr_i;
wire [3:0]      gpio_sel_i;
wire            gpio_we_i;
wire            gpio_err_o;
wire            gpio_int_o;

// Processor
plasma_mips cpu (
    .clk_i      (clk),
    .rst_i      (rst),
    .intr_i     (1'b0),
    
    // wishbone bus
    .wb_cyc_o   (iwb_cyc_o),
    .wb_stb_o   (iwb_stb_o),
    .wb_we_o    (iwb_we_o),
    .wb_sel_o   (iwb_sel_o),
    .wb_adr_o   (iwb_adr_o),
    .wb_dat_i   (iwb_dat_i),
    .wb_dat_o   (iwb_dat_o),
    .wb_ack_i   (iwb_ack_i)
);

// Wishbone Conmax
wb_conmax_top wb_conmax (
	.clk_i				(clk),
	.rst_i				(rst),

	// Master 0 Interface
	.m0_data_i			(iwb_dat_o),
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
	.s1_data_i			(ddr_dat_o),
	.s1_data_o			(ddr_dat_i),
	.s1_addr_o			(ddr_adr_i),
	.s1_sel_o			(ddr_sel_i),
	.s1_we_o			(ddr_we_i),
	.s1_cyc_o			(ddr_cyc_i),
	.s1_stb_o			(ddr_stb_i),
	.s1_ack_i			(ddr_ack_o),
	.s1_err_i			(0),
	.s1_rty_i			(0),
    
	// Slave 2 Interface
	.s2_data_i			(gpio_dat_o),
	.s2_data_o			(gpio_dat_i),
	.s2_addr_o			(gpio_adr_i),
	.s2_sel_o			(gpio_sel_i),
	.s2_we_o			(gpio_we_i),
	.s2_cyc_o			(gpio_cyc_i),
	.s2_stb_o			(gpio_stb_i),
	.s2_ack_i			(gpio_ack_o),
	.s2_err_i			(gpio_err_o),
	.s2_rty_i			(0)
);

// ram for cpu
wb_ram cpu_ram (
    .wb_clk_i              (clk),
    .wb_rst_i              (rst),
    .wb_cyc_i              (ram_cyc_i),
    .wb_stb_i              (ram_stb_i),
    .wb_we_i               (ram_we_i),
    .wb_sel_i              (ram_sel_i),
    .wb_adr_i              (ram_adr_i),
    .wb_dat_i              (ram_dat_i),
    .wb_dat_o              (ram_dat_o),
    .wb_ack_o              (ram_ack_o)
);

// ddr2 sdram
wb_xmigddr ddr0 (
    .wb_clk_i					(clk),
    .wb_rst_i					(rst),

    // Wishbone Interface
    .wb_cyc_i					(ddr_cyc_i),
    .wb_stb_i					(ddr_stb_i),
    .wb_we_i					(ddr_we_i),
    .wb_sel_i					(ddr_sel_i),
    .wb_adr_i					(ddr_adr_i),
    .wb_dat_i					(ddr_dat_i),
    .wb_dat_o					(ddr_dat_o),
    .wb_ack_o					(ddr_ack_o),
	
   // ddr2 chip signals
	.mcb3_dram_dq				(mcb3_dram_dq),
	.mcb3_dram_a				(mcb3_dram_a),
	.mcb3_dram_ba				(mcb3_dram_ba),
	.mcb3_dram_ras_n			(mcb3_dram_ras_n),
	.mcb3_dram_cas_n			(mcb3_dram_cas_n),
	.mcb3_dram_we_n				(mcb3_dram_we_n),
	.mcb3_dram_odt				(mcb3_dram_odt),
	.mcb3_dram_cke				(mcb3_dram_cke),
	.mcb3_dram_dm				(mcb3_dram_dm),
	.mcb3_dram_udqs				(mcb3_dram_udqs),
	.mcb3_dram_udqs_n			(mcb3_dram_udqs_n),
	.mcb3_dram_udm				(mcb3_dram_udm),
	.mcb3_dram_dqs				(mcb3_dram_dqs),
	.mcb3_dram_dqs_n			(mcb3_dram_dqs_n),
	.mcb3_dram_ck				(mcb3_dram_ck),
	.mcb3_dram_ck_n				(mcb3_dram_ck_n),
	.mcb3_rzq					(mcb3_rzq),
	.mcb3_zio					(mcb3_zio)
);


// GPIO 
gpio_top gpio_inst (
   .wb_clk_i        (clk),
   .wb_rst_i        (rst),
   .wb_cyc_i        (gpio_cyc_i),
   .wb_adr_i        (gpio_adr_i),
   .wb_dat_i        (gpio_dat_i),
   .wb_sel_i        (gpio_sel_i),
   .wb_we_i         (gpio_we_i),
   .wb_stb_i        (gpio_stb_i),
   .wb_dat_o        (gpio_dat_o),
   .wb_ack_o        (gpio_ack_o),
   .wb_err_o        (gpio_err_o),
   .wb_inta_o       (gpio_int_o),
   // external ports
   .ext_pad_i       (key),
   .ext_pad_o       (led),
   .ext_padoe_o     ()
);

endmodule

