//***************************************************************************
//   Copyright(c)2014, Lyu Yang
//   All rights reserved
//
//   File name        :   wb_ram_top.v
//   Module name      :   wb_ram_top
//   Author           :   Lyu Yang
//   Email            :   lyuyangly@outlook.com
//   Data             :   2014-09-30
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
`timescale 1 ns / 1 ps
// synopsys translate_on
module wb_ram_top (
    input           clk_i,
    input			rst_i,

    input			wb_stb_i,
    input			wb_cyc_i,
    output  reg     wb_ack_o,
    input   [31:0]	wb_adr_i,
    input   [3:0]	wb_sel_i,
    input			wb_we_i,
    input   [31:0] 	wb_dat_i,
    output  [31:0]	wb_dat_o
);

// catch the end of a wishbone cycle and ack
always @ (posedge clk_i)
begin
    if(rst_i)
        wb_ack_o <= 1'b0;
    else begin
        if(wb_ack_o)
            wb_ack_o <= 1'b0;
        else if(wb_stb_i & wb_cyc_i)
            wb_ack_o <= 1'b1;
        else wb_ack_o <= 1'b0;
    end
end

// ram 2048x32
altera_ram ram_inst (
	.clock			(clk_i),
	.address		(wb_adr_i[31:2]),
	.byteena		(wb_sel_i),
	.data			(wb_dat_i),
	.wren			(wb_we_i & wb_stb_i & wb_cyc_i),
	.q				(wb_dat_o)
);

endmodule


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module altera_ram (
	address,
	byteena,
	clock,
	data,
	wren,
	q);

	input	[10:0]  address;
	input	[3:0]  byteena;
	input	  clock;
	input	[31:0]  data;
	input	  wren;
	output	[31:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	[3:0]  byteena;
	tri1	  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [31:0] sub_wire0;
	wire [31:0] q = sub_wire0[31:0];

	altsyncram	altsyncram_component (
				.address_a (address),
				.byteena_a (byteena),
				.clock0 (clock),
				.data_a (data),
				.wren_a (wren),
				.q_a (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.byte_size = 8,
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.init_file = "../../software/altera.hex",
		altsyncram_component.intended_device_family = "Cyclone II",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 2048,
		altsyncram_component.operation_mode = "SINGLE_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.widthad_a = 11,
		altsyncram_component.width_a = 32,
		altsyncram_component.width_byteena_a = 4;


endmodule
