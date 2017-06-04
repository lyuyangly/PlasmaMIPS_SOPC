//***************************************************************************
//   Copyright(c)2015, Lyu Yang
//   All rights reserved
//
//   File name        :   plasma_mips.v
//   Module name      :   plasma_mips
//   Author           :   Lyu Yang
//   Email            :   lyuyangly@outlook.com
//   Date             :   2015-09-30
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

`timescale 1ns / 100ps
module plasma_mips (
    input           clk_i,
    input           rst_i,
    input           intr_i,
    
    output  reg     wb_cyc_o,
    output  reg     wb_stb_o,
    output          wb_we_o,
    output  [3:0]   wb_sel_o,
    output  [31:0]  wb_adr_o,
    input   [31:0]  wb_dat_i,
    output  [31:0]  wb_dat_o,
    input           wb_ack_i
);


wire    [3:0]   plasma_bytewe;
reg             mem_busy;

// plasma mips core
mipslite_cpu mips_com (
    .clk                (clk_i),
    .reset_in           (rst_i),
    .intr_in            (intr_i),
    
    // cache
    .address_next       (),
    .byte_we_next       (),
    
    // data bus
    .address            (wb_adr_o),
    .byte_we            (plasma_bytewe),
    .data_w             (wb_dat_o),
    .data_r             (wb_dat_i),
    .mem_pause          (mem_busy)
);

// wishbone bus
always @ (posedge clk_i)
begin
    if(rst_i) begin
        wb_cyc_o <= 1'b1; // notice that if wishbone conmax have only one master(cpu), cyc can always be '1'
        wb_stb_o <= 1'b1;
        mem_busy <= 1'b1;
    end
    else begin
        if(wb_cyc_o & wb_stb_o & wb_ack_i)
        begin
            wb_cyc_o <= 1'b0;
            wb_stb_o <= 1'b0;
            mem_busy <= 1'b0;
        end
        else begin
            wb_cyc_o <= 1'b1;
            wb_stb_o <= 1'b1;
            mem_busy <= 1'b1;
        end
    end
end

assign wb_we_o = |plasma_bytewe;
assign wb_sel_o = (plasma_bytewe == 4'h0) ? 4'hf : plasma_bytewe;

endmodule
